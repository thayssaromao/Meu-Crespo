//
//  WeatherManager.swift
//  Meu-Crespo
//
//  Created by Thayssa Romão on 10/10/25.
//

import CoreLocation
import WeatherKit
internal import Combine

// Define o estado possível do clima
enum WeatherStatus {
    case loading, loaded, failed
}

// ObservableObject para gerenciar o estado e os dados do clima
final class WeatherManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var status: WeatherStatus = .loading
    @Published var uvIndex: String = "..." // Ex: "Moderado" ou "3"
    @Published var precipitationChance: String = "..." // Ex: "70%"
    @Published var uvSymbol: String = "sun.max.fill"
    @Published var humidity: String = "..."
    
    @Published var windSpeed: String = "..." // NOVO: Velocidade do vento
    @Published var windSymbol: String = "wind"
    @Published var windStatus: String = "..." // NOVO: Status de risco do vento

    
    // Dados para exibir na sua View (inicialmente vazios)
    @Published var symbolName: String = "questionmark.circle"
    @Published var temperature: String = "..."
    @Published var condition: String = "Buscando localização..."
    
    @Published var cityName: String = "Buscando cidade..."
    private let geocoder = CLGeocoder()
    
    @Published var dailyForecasts: [DayWeather] = []

    
    private let locationManager = CLLocationManager()
    private let weatherService = WeatherService.shared
    
    override init() {
        super.init()
        // Configura o Manager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // Inicia a busca (ou espera a permissão)
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard status != .loaded, let location = locations.first else { return }
        
        // Para a busca por localização para economizar bateria
        manager.stopUpdatingLocation()
        
        fetchCityName(for: location)
        
        // Inicia a busca do clima
        fetchWeather(for: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Erro ao obter localização: \(error.localizedDescription)")
        status = .failed
        condition = "Erro de Localização"
    }
    
    private func formatWindStatus(for speed: Measurement<UnitSpeed>) -> String {
        // Convertendo para Km/h para melhor leitura, já que o Brasil usa métricas.
        let speedInKph = speed.converted(to: .kilometersPerHour).value
        
        if speedInKph >= 30.0 { // Vento forte (30 km/h+)
            self.windSymbol = "exclamationmark.octagon.fill"
            return "Alerta"
        } else if speedInKph >= 15.0 { // Vento moderado (15-29 km/h)
            self.windSymbol = "wind"
            return "Moderado"
        } else { // Vento baixo
            self.windSymbol = "wind"
            return "Baixo"
        }
    }
    
    private func fetchCityName(for location: CLLocation) {
            geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
                guard let self = self else { return }
                
                // Tratamento de erro ou nome da cidade
                if let city = placemarks?.first?.locality {
                    DispatchQueue.main.async {
                        self.cityName = city // Armazena o nome da cidade
                    }
                } else {
                    DispatchQueue.main.async {
                        self.cityName = "Localização Desconhecida"
                    }
                }
            }
        }
    
    private func formatUvIndex(_ uv: Int) -> String {
        switch uv {
        case 8...:
            return "EXTREMO"
        case 6...7:
            return "ALTO"
        case 3...5:
            return "MODERADO"
        default:
            return "BAIXO"
        }
    }
    
    func updateWeather(for date: Date) {
           let calendar = Calendar.current
           
           // 1. Busca o DayWeather que corresponde à data selecionada
           if let weatherForDay = dailyForecasts.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
               
               // 2. Atualiza todas as propriedades com base no dia selecionado (usando o low/high da previsão diária)
               
               let maxTemp = Int(weatherForDay.highTemperature.value.rounded())
               let tempUnit = weatherForDay.highTemperature.unit.symbol
               self.temperature = "\(maxTemp)\(tempUnit)"

               let uv = weatherForDay.uvIndex.value
               self.uvIndex = String(uv)
               self.uvSymbol = (uv > 6) ? "sun.max.fill" : "sun.min.fill"
               
               let maxWindSpeed = weatherForDay.wind.speed
                   
                   // Formata a velocidade para string (ex: "25 km/h")
                   let formatter = MeasurementFormatter()
                   formatter.unitOptions = .providedUnit // Não tenta adivinhar o formato
                   formatter.numberFormatter.maximumFractionDigits = 0 // Sem casas decimais
                   
                   self.windSpeed = formatter.string(from: maxWindSpeed)
                   
                   // Define o símbolo e a recomendação (usando a nova função)
               self.windStatus = formatWindStatus(for: maxWindSpeed)
               
               // Outras propriedades
               self.condition = weatherForDay.condition.description
               self.symbolName = weatherForDay.symbolName
               
               // Precipitação (já está no dailyForecast)
               let precip = weatherForDay.precipitationChance * 100
               self.precipitationChance = "\(Int(precip))%"
               
               self.status = .loaded
               
           } else {
               // Se a data estiver fora da previsão de 10 dias
               self.temperature = "N/D"
               self.condition = "Dados indisponíveis"
               self.symbolName = "xmark.circle"
               self.status = .failed
           }
       }
    // MARK: - WeatherKit Fetch
    
    private func fetchWeather(for location: CLLocation) {
        Task {
            do {
                let weatherData = try await weatherService.weather(for: location, including: .current, .daily)

                let currentWeather = weatherData.0
                let dailyForecast = weatherData.1

                
                // Atualiza as propriedades @Published, que acionam a atualização da View
                // ... dentro do WeatherManager.swift, na função fetchWeather ...
                let temperatureValue = Int(currentWeather.temperature.value.rounded())
                            // 2. Pega o símbolo da unidade (°C ou °F)
                let temperatureUnit = currentWeather.temperature.unit.symbol
                
                // 3. Concatena para obter a string final (ex: "24°C")
                let formattedTemperature = "\(temperatureValue)\(temperatureUnit)"

                let humidityPercentage = Int(currentWeather.humidity * 100)
                let formattedHumidity = "\(humidityPercentage)%"
                
                await MainActor.run {
                                    // Salva a previsão completa. Isso deve ocorrer PRIMEIRO!
                                    self.dailyForecasts = dailyForecast.forecast
                                    
                                    // Altera o clima inicial para o CLIMA ATUAL
                                    self.temperature = formattedTemperature
                                    self.condition = currentWeather.condition.description
                                    self.symbolName = currentWeather.symbolName
                                    self.humidity = formattedHumidity
                                    self.status = .loaded
                                                                       
                                    // Chamamos a função de atualização para garantir que a UI comece com os dados de HOJE
                                    self.updateWeather(for: Date())
                                }
            } catch {
                print("❌ Erro ao buscar o clima com WeatherKit: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.status = .failed
                    self.condition = "Erro ao carregar o clima"
                }
            }
        }
    }
}
