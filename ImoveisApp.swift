// ImoveisApp.swift

import SwiftUI
import SwiftData

@main
struct ImoveisApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Visita.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do { return try ModelContainer(for: schema, configurations: [config]) }
        catch { fatalError("ModelContainer error: \(error)") }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    NotificationManager.shared.requestAuthorization()
                    injectSampleDataIfNeeded()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    // Injeta dados de exemplo apenas no primeiro lançamento
    private func injectSampleDataIfNeeded() {
        let key = "sampleDataInjected_v2"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)

        let ctx = sharedModelContainer.mainContext
        let now = Date()

        let samples: [(String, String, String, Date, Double, String, Bool)] = [
            ("Rua das Palmeiras, 340 — Apto 82", "Jardim Europa", "São Paulo - SP",
             Calendar.current.date(byAdding: .hour, value: 2, to: now)!,
             1_250_000, "3 quartos, 2 suítes, varanda gourmet, 2 vagas cobertas.", true),

            ("Av. Brigadeiro Faria Lima, 1800", "Pinheiros", "São Paulo - SP",
             Calendar.current.date(byAdding: .hour, value: 5, to: now)!,
             980_000, "Cobertura duplex com piscina privativa.", true),

            ("Rua Oscar Freire, 55", "Cerqueira César", "São Paulo - SP",
             Calendar.current.date(byAdding: .day, value: 2, to: Calendar.current.startOfDay(for: now).addingTimeInterval(10 * 3600))!,
             750_000, "Studio reformado, 45m². Ideal para investimento.", false),

            ("Rua Haddock Lobo, 1000", "Higienópolis", "São Paulo - SP",
             Calendar.current.date(byAdding: .day, value: -3, to: Calendar.current.startOfDay(for: now).addingTimeInterval(14 * 3600))!,
             1_800_000, "Apartamento clássico, pé direito duplo.", false),
        ]

        for sample in samples {
            let novaVisita = Visita(
                endereco: sample.0,
                bairro: sample.1,
                cidade: sample.2,
                dataHora: sample.3,
                precoImovel: sample.4,
                anotacoes: sample.5,
                notificacaoAgendada: sample.6
            )
            ctx.insert(novaVisita)
        }
    }
}

// MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
