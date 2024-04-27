import SwiftUI

struct Medication: Codable, Identifiable {
    var id = UUID()
    var name: String
    var dose: String
    var frequency: String
}

struct ContentView: View {
    @State private var name: String = ""
    @State private var dose: String = ""
    @State private var frequency: String = ""
    @State private var medications: [Medication] = []

    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .textFieldStyle(PlainTextFieldStyle()) // make the text editable
                    TextField("Dose", text: $dose)
                        .textFieldStyle(PlainTextFieldStyle()) // make the text editable
                    TextField("Frequency", text: $frequency)
                        .textFieldStyle(PlainTextFieldStyle()) // make the text editable
                }
                Section {
                    Button(action: {
                        // add the new medication to the list
                        let newMedication = Medication(name: self.name, dose: self.dose, frequency: self.frequency)
                        self.medications.append(newMedication)
                        // clear text fields after adding
                        self.name = ""
                        self.dose = ""
                        self.frequency = ""
                        // save medications as JSON
                        self.saveMedications()
                    }) {
                        Text("Add Medication")
                    }
                }
            }
            
            List {
                ForEach(medications) { medication in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(medication.name)
                            Text("Dose: \(medication.dose)")
                            Text("Frequency: \(medication.frequency)")
                        }
                        Spacer()
                        Button(action: {
                            self.deleteMedication(medication)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            // Load medications from JSON file when ContentView appears
            self.loadMedications()
        }
    }
    
    private func saveMedications() {
        do {
            let jsonData = try JSONEncoder().encode(self.medications)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
                // Here you can save jsonString to a file or use it as needed
                // For example, you can save it to UserDefaults or to a file in the app's documents directory
            }
        } catch {
            print("Error encoding medications: \(error)")
        }
    }
    
    private func loadMedications() {
        // Load medications from a JSON file or other storage
        // For example, you can load from UserDefaults or from a file in the app's documents directory
        // Here we are just printing a placeholder message
        print("Loading medications...")
    }
    
    private func deleteMedication(_ medication: Medication) {
        self.medications.removeAll { $0.id == medication.id }
        // save medications after deletion
        self.saveMedications()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
