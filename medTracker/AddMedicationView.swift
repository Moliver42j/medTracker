import SwiftUI

struct AddMedicationView: View {
    @State private var name: String = ""
    @State private var dose: String = ""
    @State private var frequency: Frequency = .daily
    @State private var selectedDateTime = Date()
    @State private var howOften: Int = 1
    var onSave: (Medication) -> Void
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
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
                        let newMedication = Medication(name: name, dose: dose, frequency: frequency, time: selectedDateTime)
                        onSave(newMedication)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Add Medication")
                    }
                }
            }
            .navigationBarTitle("Add Medication", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct AddMedicationView_Previews: PreviewProvider {
    static var previews: some View {
        AddMedicationView { _ in }
    }
}
