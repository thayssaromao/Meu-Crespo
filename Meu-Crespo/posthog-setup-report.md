<wizard-report>
# PostHog post-wizard report

The wizard has completed a deep integration of PostHog analytics into Meu Crespo, a SwiftUI iOS hair care app. The PostHog iOS SDK (v3.59.0) was added as a Swift Package Manager dependency in the Xcode project. PostHog is initialized in the app entry point using environment variables read via a `PostHogEnv` enum with `fatalError` if missing — values are set in the Xcode scheme's Run environment variables. Ten events are captured across six files covering the full user journey: onboarding, home recommendations, learning content, timeline customization, settings changes, and churn signals. Users are identified at onboarding start (name step) and again at completion with full hair profile properties.

| Event | Description | File |
|-------|-------------|------|
| `onboarding_step_completed` | User advances through each onboarding step (name, porosity, wash frequency, chemical, dryness) | `Views/OnboardingView.swift` |
| `onboarding_completed` | User finishes onboarding; hair profile properties captured | `Views/OnboardingView.swift` |
| `home_recommendation_opened` | User taps a weather-based hair recommendation card on the home screen | `Views/Components/CardHome.swift` |
| `learn_content_opened` | User opens a learning article in the Learn section | `Views/Components/CardLearning.swift` |
| `hair_treatment_changed` | User overrides the suggested hair treatment for a day in the timeline | `Views/TimelineView.swift` |
| `calendar_view_toggled` | User toggles between week view and full calendar on the timeline | `Views/TimelineView.swift` |
| `hair_profile_updated` | User updates a hair profile field in Settings (porosity, dryness, wash frequency, chemical) | `Views/SettingsView.swift` |
| `appearance_changed` | User changes the app appearance mode (light/dark/system) | `Views/SettingsView.swift` |
| `onboarding_reset` | User resets onboarding from Settings — churn/friction signal | `Views/SettingsView.swift` |
| `language_changed` | User changes the app language | `Utils/LanguageManager.swift` |

## Next steps

We've built a dashboard and five insights to monitor user behavior from day one:

- [Analytics basics dashboard](/dashboard/1632606)
- [Onboarding Funnel](/insights/Z90OfxSh) — conversion from first step through full completion
- [Key Events Over Time](/insights/7fnBzsFu) — onboarding completions, recommendation opens, and learn content opens
- [Onboarding Reset (Churn Signal)](/insights/KsYSuYMR) — users who restart onboarding
- [Hair Profile Updates](/insights/7zU9Zl1M) — unique users updating their hair profile after onboarding
- [Hair Treatment Customizations](/insights/0MI2quwW) — users actively overriding suggested treatments

**Before running the app**, open the Xcode scheme editor (**Product > Scheme > Edit Scheme > Run > Arguments > Environment Variables**) and set `POSTHOG_PROJECT_TOKEN` to your project token from `.env`.

### Agent skill

We've left an agent skill folder in your project at `.claude/skills/integration-swift/`. You can use this context for further agent development when using Claude Code. This will help ensure the model provides the most up-to-date approaches for integrating PostHog.

</wizard-report>
