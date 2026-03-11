# Meu Crespo

Este projeto é um assistente inteligente de cuidados capilares voltado para cabelos crespos. O diferencial técnico reside na integração de dados climáticos em tempo real para sugerir dicas e tratamento ideal especificamente para cabelos crespos, entendendo que fatores como umidade e incidência UV impactam diretamente a saúde do fio.

## 🚀 Destaques Técnicos

* **Arquitetura Reativa:** Utilização de `ObservableObject`, `@Published` e `@EnvironmentObject` para um fluxo de dados consistente entre as views.
* **Integração com WeatherKit:** Consumo da API de clima da Apple para monitorar umidade, velocidade do vento e índice UV.
* **Geolocalização (CoreLocation):** Implementação de busca de localização em tempo real com tratamento de permissões e geocodificação reversa para identificar a cidade do usuário.
* **Persistência de Dados:** Uso de `@AppStorage` para configurações de onboarding e `JSONEncoder/Decoder` para o perfil capilar persistido via `UserDefaults`.
* **Interoperabilidade SwiftUI/UIKit:** Integração de componentes SwiftUI dentro de um ciclo de vida UIKit (através de `UIHostingController`), demonstrando flexibilidade técnica.

## 🛠 Tecnologias e Frameworks

* **Interface:** SwiftUI (principais telas e componentes de UI).
* **Service Layer:** WeatherKit para dados meteorológicos precisos.
* **Location:** CoreLocation para serviços de mapeamento e posicionamento.
* **Data Management:** Combine (para gerenciamento de estados assíncronos) e Foundation.
* **Design:** Custom SFSymbols, animações de transição suave e suporte a Dark Mode.

## 📂 Estrutura do Projeto

* `WeatherManager.swift`: Singleton responsável por gerenciar toda a lógica de clima e localização. Centraliza as chamadas assíncronas (`async/await`) e atualiza a UI via `@Published`.
* `TimelineView.swift`: Implementação de um cronograma dinâmico que permite ao usuário visualizar e editar tratamentos diários.
* `OnboardingView.swift`: Fluxo de entrada que utiliza máquinas de estado simples para coletar o perfil do usuário (porosidade, química, frequência de lavagem).
* `HairProfileManager.swift`: Camada de serviço para persistência do perfil capilar.

## 📱 Funcionalidades

1. **Onboarding Personalizado:** Coleta de dados sobre porosidade e saúde capilar para gerar recomendações precisas.
2. **Dashboard de Clima:** Exibição dinâmica de temperatura, umidade e status de vento/UV.
3. **Cronograma Inteligente:** Sugestão automática de tratamentos baseada no clima local e no perfil do usuário.
4. **Conteúdo Educativo:** Seção de aprendizado que carrega dicas de cuidados capilares a partir de fontes locais (JSON).

## 🧩 Como Executar o Projeto

1. Clone o repositório.
2. Certifique-se de ter o **Xcode 15+** instalado.
3. O projeto requer uma conta de desenvolvedor Apple ativa para utilizar as capabilities de **WeatherKit** e **Location Updates**.
4. Configure o *Signing & Capabilities* no Xcode com o seu Team ID.
5. Execute no simulador ou em um dispositivo físico.

---

### Sobre o Desenvolvedor

**Estudante de Sistemas de Informação | iOS Developer & Interface Designer**

*Conecte-se comigo: [linkedin](https://www.linkedin.com/feed/)
