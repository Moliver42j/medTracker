import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notifications")) {
                    Toggle("Enable Medication Reminders", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { value in
                            NotificationManager.shared.updateNotificationSettings(enabled: value)
                        }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
