import SwiftUI

struct SettingsView: View {
    @ObservedObject var catchManager: CatchManager
    @State private var showingExportSheet = false
    @State private var showingResetAlert = false
    @State private var csvData: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Units").foregroundColor(.blue)) {
                    Text("Weight: kg (default)")
                    Text("Length: cm (default)")
                }
                
                Section(header: Text("Data").foregroundColor(.blue)) {
                    Button("Export Data (CSV)") {
                        csvData = catchManager.exportCSV()
                        showingExportSheet = true
                    }
                    .foregroundColor(.blue)
                    
                    Button("Reset Data") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("About").foregroundColor(.blue)) {
                    Text("Smart Scale Plus v1.0")
                    Text("Privacy Policy: Your data is stored locally on your device only.")
                }
            }
            .navigationTitle("Settings")
            .background(Color.white)
            .sheet(isPresented: $showingExportSheet) {
                ActivityViewController(activityItems: [csvData])
            }
            .alert(isPresented: $showingResetAlert) {
                Alert(
                    title: Text("Reset Data"),
                    message: Text("This will delete all catches. Are you sure?"),
                    primaryButton: .destructive(Text("Reset")) {
                        catchManager.reset()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
