# Prompt de Auditoria — Meu Crespo iOS App

## Instrução Principal

Você é um engenheiro iOS sênior especializado em SwiftUI, arquitetura MVVM e distribuição na App Store. Sua tarefa é realizar uma **auditoria completa de pré-produção** do projeto Meu Crespo — um app de cronograma capilar inteligente com integração WeatherKit.

**REGRA ABSOLUTA:** Você deve apenas **identificar problemas e sugerir correções**. Não altere, reescreva ou refatore nenhum arquivo sem aprovação explícita do desenvolvedor. Toda sugestão deve ser apresentada como proposta, não como fato consumado.

---

## Contexto do Projeto

**Stack técnica:**
- SwiftUI + MVVM
- Apple WeatherKit (dados climáticos em tempo real)
- AppStorage / UserDefaults para persistência do perfil capilar
- UNUserNotificationCenter + BGTaskScheduler (notificações e refresh em background)
- PostHog iOS SDK (analytics via SPM)
- Apple FoundationModels (iOS 18.1+ — em desenvolvimento)
- Suporte multilíngue: pt-BR, en, de, fr via `LanguageManager`
- Widget extension: `MeuCrespoWidget`

**Arquivos do projeto:**
```
Meu-Crespo/
├── Meu_CrespoApp.swift              # Entry point, @main
├── Model/
│   ├── ContentModel.swift
│   ├── HairProfile.swift            # HairPorosity, HairDryness, WashFrequency, ChemicalTreatment
│   └── HomeModel.swift
├── Resources/
│   ├── Colors.swift                 # redBrown, pinky, brownBg
│   ├── dados.json                   # Sugestões por clima: penteados, cronograma, dicas
│   └── conteudos.json               # Artigos educativos (LearnView)
├── Utils/
│   ├── ContentService.swift
│   ├── HairProfileManager.swift
│   ├── HairstyleAIService.swift
│   ├── LanguageManager.swift
│   ├── NotificationManager.swift
│   ├── SharedDefaults.swift
│   ├── TreatmentInsightService.swift
│   └── WeatherManager.swift
├── ViewModel/
│   └── TimelineViewModel.swift      # Lógica do cronograma capilar
├── Views/
│   ├── ContentView.swift            # TabView root
│   ├── HomeView.swift
│   ├── LearnView.swift
│   ├── OnboardingView.swift
│   ├── SettingsView.swift
│   ├── SplashScreen.swift
│   ├── TimelineView.swift
│   ├── WeatherView.swift
│   └── Components/
│       ├── CardHome.swift           # CardListView, atualizarConteudoConformeClima()
│       ├── CardLearning.swift
│       ├── CardParaHoje.swift
│       ├── CardWheather.swift       # [nota: typo no nome]
│       ├── HairCalendar.swift
│       └── WeekSlider.swift
├── [pt-BR|en|de|fr].lproj/
│   ├── dados.json                   # Versões localizadas
│   └── conteudos.json
MeuCrespoWidget/
├── MeuCrespoWidget.swift
├── MeuCrespoWidgetBundle.swift
├── MeuCrespoWidgetControl.swift
├── MeuCrespoWidgetLiveActivity.swift
└── MeuCrespoWidgetView.swift
```

---

## Domínios de Auditoria

Analise cada arquivo e inspecione os seguintes domínios. Para cada problema encontrado, forneça:
- **Localização exata** (arquivo + linha aproximada)
- **Severidade**: 🔴 Crítico (bloqueia produção) / 🟡 Médio (degrada UX) / 🟢 Melhoria (boas práticas)
- **Descrição clara** do problema
- **Sugestão de correção** (pseudocódigo ou descrição — sem aplicar)

---

### 1. Arquitetura e MVVM

- Views que contêm lógica de negócio (regras que deveriam estar no ViewModel/Service)
- ViewModels que fazem operações de UI diretamente
- Dependências circulares entre camadas (Model ↔ ViewModel ↔ View)
- `@StateObject` vs `@ObservedObject` usado incorretamente
- Injeção de `@EnvironmentObject` sem garantia de que foi injetado no pai
- `@AppStorage` sendo lido em múltiplos lugares para a mesma chave (risco de dessincronização)
- Services que deveriam ser singletons mas são instanciados repetidamente

### 2. Lógica de Cronograma Capilar (`TimelineViewModel`)

- `washFrequency` é lida do `@AppStorage` mas **nunca usada** na função `treatmentForDay()`
- Os `if` de perfil capilar se sobrescrevem em sequência — último vence, combinações ignoradas
- `customTreatments: [Date: HairTreatment]` está em memória pura — perdido ao reiniciar o app
- O ciclo baseia-se no `weekday` (1–7) sem relação com dias reais de lavagem
- `treatmentForSelectedDay()` normaliza a data com `startOfDay` mas `treatmentForDay()` não — risco de inconsistência
- Verifique se existe teste ou validação dos limites do array `treatments[(weekday - 1) % treatments.count]`

### 3. WeatherManager e Dados Climáticos

- Tratamento de erros nas chamadas WeatherKit — o que acontece com a UI em caso de falha?
- `@MainActor` aplicado corretamente onde há publicação de `@Published` a partir de async?
- Dados climáticos expiram? Há cache ou TTL?
- `windStatusKey` ("low"/"moderate"/"alert") — os valores são consistentes com os usados nos JSONs de dados?
- `updateWeather(for: newDate)` na TimelineView — faz sentido buscar clima para datas passadas/futuras?
- Permissão de localização — o que acontece se o usuário negar? Há fallback de cidade?

### 4. Persistência e AppStorage

- Inventarie **todas** as chaves `@AppStorage` usadas no projeto e verifique:
  - Chaves duplicadas com strings diferentes referenciando o mesmo dado
  - Chaves sem valor padrão seguro (pode causar crash na primeira execução)
  - Tipos incompatíveis sendo salvos/lidos (ex: Int salvo como String)
- `SharedDefaults.swift` — verifica se o App Group está configurado corretamente para compartilhamento com o Widget
- `customTreatments` precisa de persistência — analise se há plano para isso

### 5. Localização e JSONs multilíngue

- Os arquivos `dados.json` e `conteudos.json` existem em pt-BR, en, de, fr — verifique:
  - Estrutura idêntica entre todas as versões (mesmas chaves, mesmo número de itens)
  - Chaves climáticas consistentes: `ensolarado`, `chuvoso`, `nublado`, `frio`, `ventando` — todas presentes em todos os idiomas?
  - Strings de `Localizable.strings` que existem em pt-BR mas faltam em en/de/fr (ou vice-versa)
- `LanguageManager` — como reage a um idioma não suportado? Há fallback para pt-BR?
- A função `L()` (helper de localização) — o que retorna se a chave não existir?

### 6. Widget Extension (`MeuCrespoWidget`)

- O widget acessa dados do app principal? Via App Group / `UserDefaults(suiteName:)`?
- `SharedDefaults.swift` — o App Group identifier está correto e igual ao configurado no target do widget?
- `MeuCrespoWidgetControl` e `MeuCrespoWidgetLiveActivity` — estão implementados ou são stubs gerados pelo Xcode? Stubs vazios podem causar rejeição na App Store
- O widget atualiza com a frequência correta? `TimelineRecommendation` ou similar está sendo usado?
- Dados sensíveis de perfil estão sendo expostos no widget sem proteção?

### 7. NotificationManager e Background Tasks

- `UNUserNotificationCenter` — as notificações são reagendadas após o usuário reinstalar o app?
- O que acontece se o usuário revogar a permissão de notificação — o app detecta e para de tentar agendar?
- `BGTaskScheduler` — o identificador da task está registrado no `Info.plist` (`BGTaskSchedulerPermittedIdentifiers`)?
- Há proteção contra múltiplos agendamentos da mesma task (task duplicada ao abrir o app várias vezes)?

### 8. PostHog Analytics e LGPD

- `PostHogSDK.shared.capture()` está sendo chamado antes da inicialização do SDK?
- Dados pessoais (nome do usuário, perfil capilar) estão sendo enviados para o PostHog sem consentimento explícito?
- Há um mecanismo de opt-out de analytics nas configurações? (`SettingsView`)
- O `distinct_id` do PostHog é baseado em algo identificável (UUID do dispositivo, e-mail)?
- LGPD: há coleta de dados antes da aceitação dos termos no onboarding?

### 9. Onboarding e Primeiro Uso

- O que acontece se o usuário fechar o app no meio do onboarding — estado é preservado?
- Há validação dos campos do perfil capilar antes de salvar?
- O app funciona sem perfil configurado (usuário pula onboarding)? Há defaults seguros?
- `hasChemical: Bool` no `AppStorage` — o modelo tem `ChemicalTreatment` com `.partial` — há perda de informação na conversão?

### 10. Typos, Naming e Convenções

- `CardWheather.swift` — typo no nome do arquivo (deveria ser `CardWeather`)
- Verifique inconsistências de nomenclatura entre arquivos (camelCase vs snake_case em strings de chave)
- Funções com nomes em português misturadas com inglês no mesmo arquivo
- `atualizarConteudoConformeClima()` — lógica de mapeamento 5-buckets descarta dados numéricos ricos do WeatherKit

### 11. Performance e Memory

- Views com `ForEach` sem `id` explícito ou com `id` instável
- Imagens carregadas sem cache ou redimensionamento
- `@StateObject` sendo recriado desnecessariamente por estar em subview
- Closures retendo `self` fortemente em contextos async (potencial retain cycle)
- `ScrollView` com conteúdo pesado sem `LazyVStack`

### 12. Prontidão para App Store

- `Info.plist` contém todas as `NSUsageDescription` necessárias (localização, notificações)?
- O bundle identifier do widget segue o padrão `com.xxx.MeuCrespo.widget`?
- Versão e build number consistentes entre targets (app principal e widget)?
- Há código de debug, `print()` statements ou flags de desenvolvimento que não devem ir para produção?
- `#if DEBUG` está sendo usado para separar código de produção de desenvolvimento?

---

## Formato de Saída Esperado

Organize o relatório assim:

```
## RESUMO EXECUTIVO
[2–3 frases sobre o estado geral do projeto e os riscos mais críticos]

## PROBLEMAS CRÍTICOS 🔴
[Lista numerada com: arquivo, problema, impacto, sugestão]

## PROBLEMAS MÉDIOS 🟡
[Lista numerada com: arquivo, problema, impacto, sugestão]

## MELHORIAS RECOMENDADAS 🟢
[Lista numerada com: arquivo, oportunidade, benefício]

## CHECKLIST PRÉ-PRODUÇÃO
[ ] Item 1
[ ] Item 2
...

## PRÓXIMOS PASSOS SUGERIDOS (por prioridade)
1. ...
2. ...
```

---

## Arquivos para Analisar (nesta ordem)

1. `Meu_CrespoApp.swift`
2. `ViewModel/TimelineViewModel.swift`
3. `Utils/WeatherManager.swift`
4. `Utils/SharedDefaults.swift`
5. `Utils/NotificationManager.swift`
6. `Model/HairProfile.swift`
7. `Views/ContentView.swift`
8. `Views/HomeView.swift`
9. `Views/TimelineView.swift`
10. `Views/OnboardingView.swift`
11. `Views/SettingsView.swift`
12. `Views/Components/CardHome.swift`
13. `MeuCrespoWidget/MeuCrespoWidget.swift`
14. `MeuCrespoWidget/MeuCrespoWidgetView.swift`
15. `Resources/dados.json` (comparar entre todos os lproj)
16. `Resources/conteudos.json` (comparar entre todos os lproj)

Leia todos os arquivos antes de emitir qualquer conclusão. Não assuma — verifique o código real.
