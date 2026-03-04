import UIKit
import CoreLocation
import WeatherKit
import SwiftUI // Importar SwiftUI é crucial para usar UIHostingController

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Properties
    
    let locationManager = CLLocationManager()
    let weatherService = WeatherService.shared
    
    // Guarda a referência para o UIHostingController para evitar que ele seja criado múltiplas vezes
    private var weatherHostingController: UIHostingController<WeatherInfoView>?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // 1. Configura a UI Inicial (Placeholder simples enquanto espera o clima)
        setupInitialLoadingUI()
        
        // 2. Inicia o processo de obtenção da localização
        getUserLocation()
    }
    
    // MARK: - UI Setup & Updates
    
    private func setupInitialLoadingUI() {
        // Remove qualquer view anterior (como um UIHostingController antigo)
        self.children.forEach { $0.removeFromParent() }
        self.view.subviews.forEach { $0.removeFromSuperview() }
        
        let label = UILabel()
        label.text = "Buscando o clima..."
        label.textAlignment = .center
        label.frame = view.bounds
        view.addSubview(label)
    }
    
    // Função principal para apresentar o SwiftUI View com os dados reais
    private func displayWeatherUI(symbolName: String, temperature: String, condition: String) {
        
        // Remove a view de 'Buscando o clima...'
        self.view.subviews.forEach { $0.removeFromSuperview() }
        
        // 1. Cria a instância da sua SwiftUI View com os dados reais
        let weatherView = WeatherInfoView(
        )
        
        // 2. Cria o Hosting Controller (se ainda não existir)
        let hostingController: UIHostingController<WeatherInfoView>
        
        if let existingController = weatherHostingController {
            // Se já existe, apenas atualiza a rootView (bom para performance)
            existingController.rootView = weatherView
            hostingController = existingController
        } else {
            // Se não existe, cria o novo e guarda a referência
            hostingController = UIHostingController(rootView: weatherView)
            weatherHostingController = hostingController
            
            // Adiciona ao ViewController (apenas na primeira vez)
            self.addChild(hostingController)
            self.view.addSubview(hostingController.view)
            
            // Configura as constraints para preencher a tela
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            
            hostingController.didMove(toParent: self)
        }
    }
    
    // MARK: - Location (CoreLocation)
    
    private func getUserLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        manager.stopUpdatingLocation()
        getWeather(for: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Erro ao obter localização: \(error.localizedDescription)")
        // TODO: Mostrar mensagem de erro na UI
    }
    
    // MARK: - WeatherKit Fetch
    
    private func getWeather(for location: CLLocation) {
        Task {
            do {
                let result = try await weatherService.weather(for: location)
                let currentWeather = result.currentWeather
                
                // Formatação dos dados para a View:
                let iconName = currentWeather.symbolName
                // Formata para 0 casas decimais e usa o símbolo de unidade do sistema (e.g., °C, °F)
                let formattedTemperature = currentWeather.temperature.formatted()
                let condition = currentWeather.condition.description

                // CHAMA A FUNÇÃO DINÂMICA
                displayWeatherUI(
                    symbolName: iconName,
                    temperature: formattedTemperature,
                    condition: condition
                )

            } catch {
                print("❌ Erro ao buscar o clima com WeatherKit: \(error.localizedDescription)")
                // TODO: Mostrar erro de API na UI
            }
        }
    }
}

// MARK: - A View para Exibir as Informações do Clima

struct WeatherInfoView: View {
    // 1. Acessa o objeto do ambiente para ler os dados dinâmicos
    @EnvironmentObject var weatherManager: WeatherManager
    
    var body: some View {
        VStack(spacing: 10) {
            
            // Ícone do Clima (SFSymbols) - Pega o valor do manager!
            Image(systemName: weatherManager.symbolName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
            
            // Temperatura Atual - Pega o valor do manager!
            Text(weatherManager.temperature)
                .font(.system(size: 80, weight: .thin))
            
            // Condição do Clima (Descrição) - Pega o valor do manager!
            Text(weatherManager.condition)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.top, 100)
    }
}

// MARK: - Preview (Requer um mock do EnvironmentObject)

struct WeatherInfoView_Previews: PreviewProvider {
    static var previews: some View {
        // Para que o Preview funcione, ele precisa de um WeatherManager
        WeatherInfoView()
            .environmentObject(WeatherManager())
    }
}

// MARK: - Preview (Apenas para o Xcode)

