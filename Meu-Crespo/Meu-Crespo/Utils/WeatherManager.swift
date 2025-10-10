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
    
    // Dados para exibir na sua View (inicialmente vazios)
    @Published var symbolName: String = "questionmark.circle"
    @Published var temperature: String = "..."
    @Published var condition: String = "Buscando localização..."
    
    @Published var cityName: String = "Buscando cidade..."
    private let geocoder = CLGeocoder()
    
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
    // MARK: - WeatherKit Fetch
    
    private func fetchWeather(for location: CLLocation) {
        Task {
            do {
                let result = try await weatherService.weather(for: location)
                let currentWeather = result.currentWeather
                
                // Atualiza as propriedades @Published, que acionam a atualização da View
                // ... dentro do WeatherManager.swift, na função fetchWeather ...
                let temperatureValue = Int(currentWeather.temperature.value.rounded())
                            // 2. Pega o símbolo da unidade (°C ou °F)
                let temperatureUnit = currentWeather.temperature.unit.symbol
                
                // 3. Concatena para obter a string final (ex: "24°C")
                let formattedTemperature = "\(temperatureValue)\(temperatureUnit)"

                DispatchQueue.main.async {
                    self.symbolName = currentWeather.symbolName
                    self.temperature = formattedTemperature
                    self.condition = currentWeather.condition.description
                    self.status = .loaded
                    
                    // 2. Correção da Lógica do UV Index (Removemos o 'if let' desnecessário)
                    let uv = currentWeather.uvIndex.value
                    self.uvIndex = String(uv)
                    self.uvSymbol = (uv > 6) ? "sun.max.fill" : "sun.min.fill"
                    
                    // 3. Lógica da Precipitação (Mantida e Correta)
                    if let todayForecast = result.dailyForecast.first {
                        let precip = todayForecast.precipitationChance * 100
                        self.precipitationChance = "\(Int(precip))%"
                    } else {
                        self.precipitationChance = "N/D"
                    }
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
