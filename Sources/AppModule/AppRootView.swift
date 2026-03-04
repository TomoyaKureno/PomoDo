import SwiftUI

struct AppRootView: View {
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            HomeView()
                .environmentObject(coordinator)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .home:
                        HomeView().environmentObject(coordinator)
                        
                    case .timer(let config):
                        TimerView(config: config)
                        .environmentObject(coordinator)
                    }
                }
        }
        .environmentObject(coordinator)
    }
}
