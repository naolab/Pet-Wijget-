import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            PetListView()
                .tabItem {
                    Image(systemName: "pawprint.fill")
                    Text("ペット")
                }

            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "slider.horizontal.3")
                Text("ウィジェット")
            }
        }
    }
}

#Preview {
    MainTabView()
}
