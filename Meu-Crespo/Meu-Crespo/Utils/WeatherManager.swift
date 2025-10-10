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
    
    // Dados para exibir na sua View (inicialmente vazios)
    @Published var symbolName: String = "questionmark.circle"
    @Published var temperature: String = "..."
    @Published var condition: String = "Buscando localização..."
    
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
        
        // Inicia a busca do clima
        fetchWeather(for: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Erro ao obter localização: \(error.localizedDescription)")
        status = .failed
        condition = "Erro de Localização"
    }
    
    // MARK: - WeatherKit Fetch
    
    private func fetchWeather(for location: CLLocation) {
        Task {
            do {
                let result = try await weatherService.weather(for: location)
                let currentWeather = result.currentWeather
                
                // Atualiza as propriedades @Published, que acionam a atualização da View
                DispatchQueue.main.async {
                    self.symbolName = currentWeather.symbolName
                    self.temperature = currentWeather.temperature.formatted() // Formata automaticamente
                    self.condition = currentWeather.condition.description
                    self.status = .loaded
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
