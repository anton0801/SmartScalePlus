import SwiftUI
import WebKit
import Combine

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var catchManager: CatchManager
    @AppStorage("weightUnit") private var weightUnit = "kg"
    @AppStorage("lengthUnit") private var lengthUnit = "cm"
    
    @State private var showResetAlert = false
    @State private var showExportSheet = false
    @State private var showAboutSheet = false
    @State private var showPrivacySheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                List {
                    // User Section
                    Section {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.primaryBlue,
                                                Color.seaGreen
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: authManager.isAnonymous ? "person.fill.questionmark" : "person.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(authManager.currentUserName ?? "User")
                                    .font(.displayMedium(18))
                                    .foregroundColor(.textPrimary)
                                
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(authManager.isAnonymous ? Color.sunriseYellow : Color.seaGreen)
                                        .frame(width: 8, height: 8)
                                    
                                    Text(authManager.isAnonymous ? "Guest Account" : "Registered")
                                        .font(.bodyRegular(13))
                                        .foregroundColor(.textSecondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                authManager.signOut()
                            }) {
                                Image(systemName: "arrow.right.square")
                                    .font(.system(size: 20))
                                    .foregroundColor(.coralOrange)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Units Section
                    Section(header: Text("Units").font(.displayMedium(14))) {
                        Picker("Weight", selection: $weightUnit) {
                            Text("Kilograms (kg)").tag("kg")
                            Text("Pounds (lb)").tag("lb")
                        }
                        
                        Picker("Length", selection: $lengthUnit) {
                            Text("Centimeters (cm)").tag("cm")
                            Text("Inches (in)").tag("in")
                        }
                    }
                    
                    // Data Section
                    Section(header: Text("Data").font(.displayMedium(14))) {
                        Button(action: { showExportSheet = true }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.primaryBlue)
                                Text("Export Data")
                                    .foregroundColor(.textPrimary)
                                Spacer()
                            }
                        }
                        
                        Button(action: { showResetAlert = true }) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.coralOrange)
                                Text("Reset All Data")
                                    .foregroundColor(.coralOrange)
                                Spacer()
                            }
                        }
                    }
                    
                    // App Info Section
                    Section(header: Text("About").font(.displayMedium(14))) {
                        Button(action: { showPrivacySheet = true }) {
                            HStack {
                                Image(systemName: "hand.raised")
                                    .foregroundColor(.textSecondary)
                                Text("Privacy Policy")
                                    .foregroundColor(.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        
                        Button(action: { showAboutSheet = true }) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.textSecondary)
                                Text("About")
                                    .foregroundColor(.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "app.badge")
                                .foregroundColor(.textSecondary)
                            Text("Version")
                                .foregroundColor(.textPrimary)
                            Spacer()
                            Text("1.0.0")
                                .font(.monoMedium(14))
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    // Statistics Summary
                    Section(header: Text("Your Stats").font(.displayMedium(14))) {
                        HStack {
                            Text("Total Catches")
                            Spacer()
                            Text("\(catchManager.catches.count)")
                                .font(.monoMedium(16))
                                .foregroundColor(.primaryBlue)
                        }
                        
                        HStack {
                            Text("Different Species")
                            Spacer()
                            let uniqueSpecies = Set(catchManager.catches.map { $0.fishType }).count
                            Text("\(uniqueSpecies)")
                                .font(.monoMedium(16))
                                .foregroundColor(.seaGreen)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Reset All Data", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    if let userId = authManager.currentUserId {
                        catchManager.deleteAllCatches(userId: userId)
                    }
                }
            } message: {
                Text("Are you sure you want to delete all your catches? This action cannot be undone.")
            }
            .sheet(isPresented: $showExportSheet) {
                ExportDataView()
                    .environmentObject(catchManager)
            }
            .sheet(isPresented: $showAboutSheet) {
                AboutView()
            }
            .sheet(isPresented: $showPrivacySheet) {
                PrivacyPolicyView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Export Data View
struct ExportDataView: View {
    @EnvironmentObject var catchManager: CatchManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var isExporting = false
    @State private var showShareSheet = false
    @State private var exportedURL: URL?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.primaryBlue.opacity(0.15))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 36))
                                    .foregroundColor(.primaryBlue)
                            }
                            
                            Text("Export Your Data")
                                .font(.displayBold(24))
                                .foregroundColor(.textPrimary)
                            
                            Text("Export your catches as a CSV file")
                                .font(.bodyRegular(16))
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.top)
                        
                        // Date range selection
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Start Date")
                                    .font(.displayMedium(14))
                                    .foregroundColor(.textSecondary)
                                
                                DatePicker("", selection: $startDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("End Date")
                                    .font(.displayMedium(14))
                                    .foregroundColor(.textSecondary)
                                
                                DatePicker("", selection: $endDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // Export info
                        let filteredCatches = catchManager.getCatchesForDateRange(start: startDate, end: endDate)
                        VStack(spacing: 12) {
                            HStack {
                                Text("Catches in range:")
                                Spacer()
                                Text("\(filteredCatches.count)")
                                    .font(.monoMedium(18))
                                    .foregroundColor(.primaryBlue)
                            }
                            
                            if !filteredCatches.isEmpty {
                                HStack {
                                    Text("Estimated file size:")
                                    Spacer()
                                    Text("~\(filteredCatches.count * 200 / 1024) KB")
                                        .font(.monoMedium(14))
                                        .foregroundColor(.textSecondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color.primaryBlue.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Export button
                        Button(action: exportData) {
                            if isExporting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                HStack {
                                    Image(systemName: "arrow.down.doc")
                                    Text("Export CSV")
                                }
                                .font(.displayMedium(18))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(filteredCatches.isEmpty ? Color.gray : Color.primaryBlue)
                        .cornerRadius(16)
                        .disabled(filteredCatches.isEmpty || isExporting)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = exportedURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
    
    private func exportData() {
        isExporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let catches = catchManager.getCatchesForDateRange(start: startDate, end: endDate)
            let exportData = ExportData(startDate: startDate, endDate: endDate, catches: catches)
            let csvString = exportData.generateCSV()
            
            // Save to temporary file
            let fileName = "catches_\(ISO8601DateFormatter().string(from: Date())).csv"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            do {
                try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
                
                DispatchQueue.main.async {
                    self.exportedURL = tempURL
                    self.isExporting = false
                    self.showShareSheet = true
                }
            } catch {
                print("Error exporting data: \(error)")
                DispatchQueue.main.async {
                    self.isExporting = false
                }
            }
        }
    }
}

// MARK: - About View
struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // App icon
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.primaryBlue,
                                                Color.seaGreen
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                FishScaleIcon()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            }
                            
                            Text("Smart Scale Plus")
                                .font(.displayBold(28))
                                .foregroundColor(.textPrimary)
                            
                            Text("Version 1.0.0")
                                .font(.bodyRegular(16))
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.top)
                        
                        // Description
                        VStack(alignment: .leading, spacing: 16) {
                            Text("About")
                                .font(.displayBold(20))
                                .foregroundColor(.textPrimary)
                            
                            Text("Smart Scale Plus is your digital fishing journal. Track every catch, analyze your success, and never forget a memorable fishing moment.")
                                .font(.bodyRegular(16))
                                .foregroundColor(.textSecondary)
                                .lineSpacing(4)
                            
                            Text("Features:")
                                .font(.displayMedium(18))
                                .foregroundColor(.textPrimary)
                                .padding(.top, 8)
                            
                            FeatureRow(icon: "fish.fill", title: "Track Catches", description: "Record weight, length, and details")
                            FeatureRow(icon: "chart.bar.fill", title: "View Statistics", description: "Analyze your fishing success")
                            FeatureRow(icon: "icloud.fill", title: "Cloud Sync", description: "Access data anywhere")
                            FeatureRow(icon: "square.and.arrow.up", title: "Export Data", description: "Download as CSV")
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        
                        // Credits
                        VStack(spacing: 8) {
                            Text("Made with ❤️ for anglers")
                                .font(.bodyRegular(14))
                                .foregroundColor(.textSecondary)
                            
                            Text("© 2026 Smart Scale Plus")
                                .font(.bodyRegular(12))
                                .foregroundColor(.textSecondary)
                        }
                        .padding()
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.primaryBlue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.displayMedium(15))
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(.bodyRegular(13))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Privacy Policy")
                            .font(.displayBold(28))
                            .foregroundColor(.textPrimary)
                        
                        PolicySection(
                            title: "Data Collection",
                            content: "Smart Scale Plus only collects the fishing catch data you voluntarily enter into the app. This includes fish species, weight, length, dates, locations, and notes."
                        )
                        
                        PolicySection(
                            title: "Data Storage",
                            content: "Your data is securely stored in Firebase Realtime Database and is associated with your anonymous user ID. We use industry-standard security measures to protect your information."
                        )
                        
                        PolicySection(
                            title: "Data Usage",
                            content: "Your catch data is used solely to provide app functionality. We do not share, sell, or use your data for any purpose other than displaying it back to you in the app."
                        )
                        
                        PolicySection(
                            title: "Data Deletion",
                            content: "You can delete all your data at any time using the 'Reset All Data' option in Settings. This action is permanent and cannot be undone."
                        )
                        
                        PolicySection(
                            title: "Contact",
                            content: "If you have questions about this privacy policy or your data, please contact us through the app's feedback system."
                        )
                        
                        Text("Last updated: January 19, 2026")
                            .font(.bodyRegular(12))
                            .foregroundColor(.textSecondary)
                            .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.displayBold(18))
                .foregroundColor(.textPrimary)
            
            Text(content)
                .font(.bodyRegular(15))
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthenticationManager())
            .environmentObject(CatchManager())
    }
}

struct ScaleContentView: View {
    
    @State private var targetURL: String? = ""
    
    var body: some View {
        ZStack {
            if let urlString = targetURL,
               let url = URL(string: urlString) {
                WebViewProxy(url: url)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            initialize()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LoadTempURL"))) { _ in
            reload()
        }
    }
    
    private func initialize() {
        let temp = UserDefaults.standard.string(forKey: "temp_url")
        let cached = UserDefaults.standard.string(forKey: "cached_endpoint") ?? ""
        
        targetURL = temp ?? cached
        
        if temp != nil {
            UserDefaults.standard.removeObject(forKey: "temp_url")
        }
    }
    
    private func reload() {
        if let temp = UserDefaults.standard.string(forKey: "temp_url"),
           !temp.isEmpty {
            targetURL = nil
            targetURL = temp
            UserDefaults.standard.removeObject(forKey: "temp_url")
        }
    }
}

// MARK: - Web View Proxy
struct WebViewProxy: UIViewRepresentable {
    
    let url: URL
    
    @StateObject private var orchestrator = ViewOrchestrator()
    
    func makeCoordinator() -> NavigationProxy {
        NavigationProxy(orchestrator: orchestrator)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        orchestrator.initializePrimaryView()
        orchestrator.primaryView.uiDelegate = context.coordinator
        orchestrator.primaryView.navigationDelegate = context.coordinator
        
        orchestrator.sessionProxy.restoreSessions()
        orchestrator.primaryView.load(URLRequest(url: url))
        
        return orchestrator.primaryView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - View Orchestrator
final class ViewOrchestrator: ObservableObject {
    
    @Published var secondaryViews: [WKWebView] = []
    @Published private(set) var primaryView: WKWebView!
    
    let sessionProxy = SessionProxy()
    
    private var subscriptions = Set<AnyCancellable>()
    
    func initializePrimaryView() {
        let config = createConfiguration()
        primaryView = WKWebView(frame: .zero, configuration: config)
        configureView(primaryView)
    }
    
    private func createConfiguration() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let prefs = WKPreferences()
        prefs.javaScriptEnabled = true
        prefs.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = prefs
        
        let webpagePrefs = WKWebpagePreferences()
        webpagePrefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = webpagePrefs
        
        return config
    }
    
    private func configureView(_ view: WKWebView) {
        view.scrollView.minimumZoomScale = 1.0
        view.scrollView.maximumZoomScale = 1.0
        view.scrollView.bounces = false
        view.scrollView.bouncesZoom = false
        view.allowsBackForwardNavigationGestures = true
    }
    
    func navigateBack(fallbackURL: URL? = nil) {
        if !secondaryViews.isEmpty {
            if let last = secondaryViews.last {
                last.removeFromSuperview()
                secondaryViews.removeLast()
            }
            
            if let fallback = fallbackURL {
                primaryView.load(URLRequest(url: fallback))
            }
        } else if primaryView.canGoBack {
            primaryView.goBack()
        }
    }
    
    func refreshView() {
        primaryView.reload()
    }
}

// MARK: - Navigation Proxy
final class NavigationProxy: NSObject {
    
    private weak var orchestrator: ViewOrchestrator?
    private var redirectCount = 0
    private var lastURL: URL?
    private let redirectLimit = 70
    
    init(orchestrator: ViewOrchestrator) {
        self.orchestrator = orchestrator
        super.init()
    }
}

// MARK: - WKNavigationDelegate
extension NavigationProxy: WKNavigationDelegate {
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let targetURL = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        lastURL = targetURL
        
        if isNavigationAllowed(to: targetURL) {
            decisionHandler(.allow)
        } else {
            openExternally(targetURL)
            decisionHandler(.cancel)
        }
    }
    
    private func isNavigationAllowed(to url: URL) -> Bool {
        let scheme = (url.scheme ?? "").lowercased()
        let path = url.absoluteString.lowercased()
        
        let allowedSchemes: Set<String> = [
            "http", "https", "about", "blob", "data", "javascript", "file"
        ]
        
        let allowedPaths = ["srcdoc", "about:blank", "about:srcdoc"]
        
        return allowedSchemes.contains(scheme) ||
               allowedPaths.contains { path.hasPrefix($0) } ||
               path == "about:blank"
    }
    
    private func openExternally(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func webView(
        _ webView: WKWebView,
        didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!
    ) {
        redirectCount += 1
        
        if redirectCount > redirectLimit {
            webView.stopLoading()
            
            if let recovery = lastURL {
                webView.load(URLRequest(url: recovery))
            }
            
            redirectCount = 0
            return
        }
        
        lastURL = webView.url
        orchestrator?.sessionProxy.persistSessions(from: webView)
    }
    
    func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
        applyEnhancements(to: webView)
    }
    
    private func applyEnhancements(to view: WKWebView) {
        let enhancement = """
        (function() {
            const meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.head.appendChild(meta);
            
            const style = document.createElement('style');
            style.textContent = 'body { touch-action: pan-x pan-y; } input, textarea { font-size: 16px !important; }';
            document.head.appendChild(style);
            
            document.addEventListener('gesturestart', e => e.preventDefault());
            document.addEventListener('gesturechange', e => e.preventDefault());
        })();
        """
        
        view.evaluateJavaScript(enhancement) { _, error in
            if let error = error {
                print("Enhancement error: \(error)")
            }
        }
    }
    
    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        let errorCode = (error as NSError).code
        
        if errorCode == NSURLErrorHTTPTooManyRedirects,
           let recovery = lastURL {
            webView.load(URLRequest(url: recovery))
        }
    }
    
    func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

// MARK: - WKUIDelegate
extension NavigationProxy: WKUIDelegate {
    
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        guard navigationAction.targetFrame == nil,
              let orchestrator = orchestrator,
              let primary = orchestrator.primaryView else {
            return nil
        }
        
        let secondary = WKWebView(frame: .zero, configuration: configuration)
        
        setupSecondary(secondary, within: primary)
        attachGesture(to: secondary)
        
        orchestrator.secondaryViews.append(secondary)
        
        if let url = navigationAction.request.url,
           url.absoluteString != "about:blank" {
            secondary.load(navigationAction.request)
        }
        
        return secondary
    }
    
    private func setupSecondary(_ secondary: WKWebView, within primary: WKWebView) {
        secondary.translatesAutoresizingMaskIntoConstraints = false
        secondary.scrollView.isScrollEnabled = true
        secondary.scrollView.minimumZoomScale = 1.0
        secondary.scrollView.maximumZoomScale = 1.0
        secondary.scrollView.bounces = false
        secondary.scrollView.bouncesZoom = false
        secondary.allowsBackForwardNavigationGestures = true
        secondary.navigationDelegate = self
        secondary.uiDelegate = self
        
        primary.addSubview(secondary)
        
        NSLayoutConstraint.activate([
            secondary.leadingAnchor.constraint(equalTo: primary.leadingAnchor),
            secondary.trailingAnchor.constraint(equalTo: primary.trailingAnchor),
            secondary.topAnchor.constraint(equalTo: primary.topAnchor),
            secondary.bottomAnchor.constraint(equalTo: primary.bottomAnchor)
        ])
    }
    
    private func attachGesture(to view: WKWebView) {
        let gesture = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(handleSwipe(_:))
        )
        gesture.edges = .left
        view.addGestureRecognizer(gesture)
    }
    
    @objc private func handleSwipe(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        guard recognizer.state == .ended,
              let view = recognizer.view as? WKWebView else {
            return
        }
        
        if view.canGoBack {
            view.goBack()
        } else if orchestrator?.secondaryViews.last === view {
            orchestrator?.navigateBack(fallbackURL: nil)
        }
    }
    
    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}

// MARK: - Session Proxy
final class SessionProxy {
    
    private let key = "stored_sessions"
    
    func restoreSessions() {
        guard let data = UserDefaults.standard.object(forKey: key) as? [String: [String: [HTTPCookiePropertyKey: AnyObject]]] else {
            return
        }
        
        let store = WKWebsiteDataStore.default().httpCookieStore
        
        let cookies = data.values
            .flatMap { $0.values }
            .compactMap { properties in
                HTTPCookie(properties: properties as [HTTPCookiePropertyKey: Any])
            }
        
        cookies.forEach { cookie in
            store.setCookie(cookie)
        }
    }
    
    func persistSessions(from view: WKWebView) {
        let store = view.configuration.websiteDataStore.httpCookieStore
        
        store.getAllCookies { [weak self] cookies in
            guard let self = self else { return }
            
            var data: [String: [String: [HTTPCookiePropertyKey: Any]]] = [:]
            
            for cookie in cookies {
                var domainData = data[cookie.domain] ?? [:]
                
                if let properties = cookie.properties {
                    domainData[cookie.name] = properties
                }
                
                data[cookie.domain] = domainData
            }
            
            UserDefaults.standard.set(data, forKey: self.key)
        }
    }
}
