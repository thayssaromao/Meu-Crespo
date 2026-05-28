import CoreLocation
import WeatherKit
internal import Combine
import MapKit
import PostHog

enum WeatherStatus {
    case loading, loaded, failed
}

final class WeatherManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var status: WeatherStatus = .loading
    @Published var uvIndex: String = "..."
    @Published var precipitationChance: String = "..."
    @Published var uvSymbol: String = "sun.max.fill"
    @Published var humidity: String = "..."

    @Published var windSpeed: String = "..."
    @Published var windSymbol: String = "wind"
    @Published var windStatus: String = "..."
    @Published var windStatusKey: String = "low"

    @Published var symbolName: String = "questionmark.circle"
    @Published var temperature: String = "..."
    @Published var condition: String = L("weather.fetchingLocation")

    @Published var cityName: String = L("weather.fetchingCity")

    @Published var dailyForecasts: [DayWeather] = []
    @Published var selectedDate: Date = Date()

    private let locationManager = CLLocationManager()
    private let weatherService = WeatherService.shared

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard status != .loaded, let location = locations.first else { return }
        manager.stopUpdatingLocation()
        fetchCityName(for: location)
        fetchWeather(for: location)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied:
            status = .failed
            condition = L("weather.errorLocation")
            PostHogSDK.shared.capture("weather_failed", properties: ["reason": "location_denied"])
        case .restricted:
            status = .failed
            condition = L("weather.errorLocation")
            PostHogSDK.shared.capture("weather_failed", properties: ["reason": "location_restricted"])
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Erro ao obter localização: \(error.localizedDescription)")
        status = .failed
        condition = L("weather.errorLocation")
        PostHogSDK.shared.capture("weather_failed", properties: [
            "reason": "location_error",
            "error": error.localizedDescription,
        ])
    }

    private func formatWindStatus(for speed: Measurement<UnitSpeed>) -> String {
        let speedInKph = speed.converted(to: .kilometersPerHour).value

        if speedInKph >= 30.0 {
            windSymbol = "exclamationmark.octagon.fill"
            windStatusKey = "alert"
            return L("weather.wind.alert")
        } else if speedInKph >= 15.0 {
            windSymbol = "wind"
            windStatusKey = "moderate"
            return L("weather.wind.moderate")
        } else {
            windSymbol = "wind"
            windStatusKey = "low"
            return L("weather.wind.low")
        }
    }

    private func fetchCityName(for location: CLLocation) {
        if #available(iOS 26.0, *) {
            Task {
                let request = MKReverseGeocodingRequest(location: location)
                let city = (try? await request?.mapItems)?.first?.addressRepresentations?.cityName
                await MainActor.run {
                    cityName = city ?? L("weather.unknownLocation")
                }
            }
        } else {
            CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, _ in
                DispatchQueue.main.async {
                    self?.cityName = placemarks?.first?.locality ?? L("weather.unknownLocation")
                }
            }
        }
    }

    private func formatUvIndex(_ uv: Int) -> String {
        switch uv {
        case 8...: return L("weather.uv.extreme")
        case 6...7: return L("weather.uv.high")
        case 3...5: return L("weather.uv.moderate")
        default: return L("weather.uv.low")
        }
    }

    func updateWeather(for date: Date) {
        selectedDate = date
        let calendar = Calendar.current

        if let weatherForDay = dailyForecasts.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            let maxTemp = Int(weatherForDay.highTemperature.value.rounded())
            let tempUnit = weatherForDay.highTemperature.unit.symbol
            temperature = "\(maxTemp)\(tempUnit)"

            let uv = weatherForDay.uvIndex.value
            uvIndex = String(uv)
            uvSymbol = (uv > 6) ? "sun.max.fill" : "sun.min.fill"

            let maxWindSpeed = weatherForDay.wind.speed
            let formatter = MeasurementFormatter()
            formatter.unitOptions = .providedUnit
            formatter.numberFormatter.maximumFractionDigits = 0
            windSpeed = formatter.string(from: maxWindSpeed)
            windStatus = formatWindStatus(for: maxWindSpeed)

            condition = weatherForDay.condition.description
            symbolName = weatherForDay.symbolName

            let precip = weatherForDay.precipitationChance * 100
            precipitationChance = "\(Int(precip))%"

            status = .loaded
        } else {
            temperature = "N/D"
            condition = L("weather.unavailable")
            symbolName = "xmark.circle"
            status = .failed
            PostHogSDK.shared.capture("weather_failed", properties: ["reason": "no_forecast_for_date"])
        }
    }

    // MARK: - WeatherKit Fetch

    private func fetchWeather(for location: CLLocation) {
        Task {
            do {
                let weatherData = try await weatherService.weather(for: location, including: .current, .daily)
                let currentWeather = weatherData.0
                let dailyForecast = weatherData.1

                let temperatureValue = Int(currentWeather.temperature.value.rounded())
                let temperatureUnit = currentWeather.temperature.unit.symbol
                let formattedTemperature = "\(temperatureValue)\(temperatureUnit)"

                let humidityPercentage = Int(currentWeather.humidity * 100)
                let formattedHumidity = "\(humidityPercentage)%"

                await MainActor.run {
                    dailyForecasts = dailyForecast.forecast
                    temperature = formattedTemperature
                    condition = currentWeather.condition.description
                    symbolName = currentWeather.symbolName
                    humidity = formattedHumidity
                    status = .loaded
                    updateWeather(for: Date())
                }
            } catch {
                print("❌ Erro ao buscar o clima com WeatherKit: \(error.localizedDescription)")
                await MainActor.run {
                    self.status = .failed
                    self.condition = L("weather.errorLoad")
                    PostHogSDK.shared.capture("weather_failed", properties: [
                        "reason": "weatherkit_error",
                        "error": error.localizedDescription,
                    ])
                }
            }
        }
    }
}
