import SwiftUI
import UserNotifications

struct Medication: Codable, Identifiable {
    var id = UUID()
    var name: String
    var dose: String
    var frequency: Frequency
    var time: Date
    var taken: Bool = false
    var lastTaken: Date?
}

enum Frequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}

struct ContentView: View {
    @State private var name: String = ""
    @State private var dose: String = ""
    @State private var frequency: Frequency = .daily
    @State private var selectedDateTime = Date()
    @State private var howOften: Int = 1
    @State private var medications: [Medication] = []

    var body: some View {
        NavigationView {
        VStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .textFieldStyle(PlainTextFieldStyle())
                    TextField("Dose", text: $dose)
                        .textFieldStyle(PlainTextFieldStyle())
                    HStack {
                        Text("Frequency")
                        Picker("Frequency", selection: $frequency) {
                            ForEach(Frequency.allCases, id: \.self) { frequency in
                                Text(frequency.rawValue)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    DatePicker("Start Date & Time", selection: $selectedDateTime, displayedComponents: [.date, .hourAndMinute])
                    Stepper(value: $howOften, in: 1...30) {
                        Text("How often: \(howOften)")
                    }
                }
                Section {
                    Button(action: {
                        addMedication()
                    }) {
                        Text("Add Medication")
                    }
                }
                List(medications) { medication in
                    VStack(alignment: .leading) {
                        Text("Name: \(medication.name)").font(.headline)
                        Text("Dose: \(medication.dose)")
                        Text("Frequency: \(medication.frequency.rawValue)")
                        Text("Time: \(medication.time, formatter: dateFormatter)")
                        Text("\(medicationTakenToday(medication) ? "Taken Today" : "Not Taken Today")")
                        .foregroundColor(medicationTakenToday(medication) ? .green : .red)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            deleteMedication(medication)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            markAsTaken(medication)
                        } label: {
                            Label("Mark as Taken", systemImage: "checkmark.circle")
                        }
                        .tint(.blue)
                    }
                }
            }
            NavigationLink(destination: SettingsView()) {
                    Text("Settings")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
        }
        }
        .padding()
        .onAppear {
            loadMedications()
            NotificationManager.shared.requestNotificationPermission()
            NotificationManager.shared.addNotificationActions()
        }
        .navigationBarTitle("Medications")
    }

    private func addMedication() {
        let newMedication = Medication(name: self.name, dose: self.dose, frequency: self.frequency, time: self.selectedDateTime)
        self.medications.append(newMedication)
        saveMedications()
        NotificationManager.shared.scheduleNotification(for: newMedication)
        clearInputFields()
    }

    private func deleteMedication(_ medication: Medication) {
        self.medications.removeAll { $0.id == medication.id }
        saveMedications()
    }

    private func saveMedications() {
        do {
            let jsonData = try JSONEncoder().encode(self.medications)
            UserDefaults.standard.set(jsonData, forKey: "medications")
        } catch {
            print("Error encoding medications: \(error)")
        }
    }

    private func loadMedications() {
        if let medicationsData = UserDefaults.standard.data(forKey: "medications") {
            do {
                self.medications = try JSONDecoder().decode([Medication].self, from: medicationsData)
                resetTakenStatusIfNeeded()
            } catch {
                print("Error decoding medications: \(error)")
            }
        }
    }

    private func medicationTakenToday(_ medication: Medication) -> Bool {
        guard let lastTaken = medication.lastTaken else { return false }
        return Calendar.current.isDateInToday(lastTaken)
    }

    private func markAsTaken(_ medication: Medication) {
        if let index = self.medications.firstIndex(where: { $0.id == medication.id }) {
            self.medications[index].taken = true
            self.medications[index].lastTaken = Date()  // Update last taken date
            saveMedications()
        }
    }

    private func clearInputFields() {
        name = ""
        dose = ""
        selectedDateTime = Date()
        frequency = .daily
    }

    private func resetTakenStatusIfNeeded() {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .short

        let lastAccessDateString = UserDefaults.standard.string(forKey: "lastAccessDate") ?? formatter.string(from: currentDate)
        let lastAccessDate = formatter.date(from: lastAccessDateString)!

        if !Calendar.current.isDateInToday(lastAccessDate) {
            for i in medications.indices {
                medications[i].taken = false
            }
            saveMedications()
            UserDefaults.standard.set(formatter.string(from: currentDate), forKey: "lastAccessDate")
        }
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter
    }()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}