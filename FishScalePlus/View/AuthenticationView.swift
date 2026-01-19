import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showLogin = true
    @State private var animateWaves = false
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.primaryBlue.opacity(0.8),
                    Color.seaGreen.opacity(0.6),
                    Color.primaryBlue.opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated waves
            WaveBackgroundView(isAnimating: $animateWaves)
                .opacity(0.3)
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo and title
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 140, height: 140)
                            .blur(radius: 20)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 120, height: 120)
                            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                        
                        FishScaleIcon()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.primaryBlue)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Smart Scale")
                            .font(.displayBold(36))
                            .foregroundColor(.white)
                        
                        Text("Plus")
                            .font(.displayMedium(28))
                            .foregroundColor(.sunriseYellow)
                    }
                    
                    Text("Your Digital Fishing Journal")
                        .font(.bodyRegular(16))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.bottom, 40)
                
                // Auth forms container
                VStack(spacing: 0) {
                    // Toggle between login and register
                    HStack(spacing: 0) {
                        Button(action: { withAnimation { showLogin = true } }) {
                            Text("Login")
                                .font(.displayMedium(18))
                                .foregroundColor(showLogin ? .primaryBlue : .textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(showLogin ? Color.white : Color.clear)
                                .cornerRadius(16, corners: [.topLeft])
                        }
                        
                        Button(action: { withAnimation { showLogin = false } }) {
                            Text("Register")
                                .font(.displayMedium(18))
                                .foregroundColor(showLogin ? .textSecondary : .primaryBlue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(showLogin ? Color.clear : Color.white)
                                .cornerRadius(16, corners: [.topRight])
                        }
                    }
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(16, corners: [.topLeft, .topRight])
                    
                    // Forms
                    if showLogin {
                        LoginForm()
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                    } else {
                        RegisterForm()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                }
                .padding(.horizontal, 20)
                
                // Guest access button
                Button(action: {
                    authManager.signInAnonymously()
                }) {
                    HStack {
                        Image(systemName: "person.fill.questionmark")
                            .font(.system(size: 18))
                        Text("Continue as Guest")
                            .font(.displayMedium(16))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                if authManager.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                }
                
                if let error = authManager.error {
                    Text(error)
                        .font(.bodyRegular(14))
                        .foregroundColor(.coralOrange)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                }
                
                Spacer()
            }
        }
        .onAppear {
            animateWaves = true
        }
    }
}

// MARK: - Login Form
struct LoginForm: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Email field
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.primaryBlue)
                        .frame(width: 20)
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .font(.bodyRegular(16))
                }
                .padding()
                .background(Color.background)
                .cornerRadius(12)
            }
            
            // Password field
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.primaryBlue)
                        .frame(width: 20)
                    
                    if showPassword {
                        TextField("Password", text: $password)
                            .font(.bodyRegular(16))
                    } else {
                        SecureField("Password", text: $password)
                            .font(.bodyRegular(16))
                    }
                    
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding()
                .background(Color.background)
                .cornerRadius(12)
            }
            
            // Forgot password
            HStack {
                Spacer()
                Button(action: {
                    // TODO: Implement forgot password
                }) {
                    Text("Forgot Password?")
                        .font(.bodyRegular(14))
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.horizontal, 4)
            
            // Login button
            Button(action: {
                authManager.signIn(email: email, password: password)
            }) {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 20))
                    Text("Login")
                        .font(.displayMedium(18))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.primaryBlue,
                            Color.seaGreen
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: Color.primaryBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                .opacity(isValid ? 1 : 0.5)
            }
            .disabled(!isValid || authManager.isLoading)
            .padding(.top, 8)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
    }
    
    var isValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
}

// MARK: - Register Form
struct RegisterForm: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Name field
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.primaryBlue)
                        .frame(width: 20)
                    
                    TextField("Name", text: $name)
                        .font(.bodyRegular(16))
                }
                .padding()
                .background(Color.background)
                .cornerRadius(12)
            }
            
            // Email field
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.primaryBlue)
                        .frame(width: 20)
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .font(.bodyRegular(16))
                }
                .padding()
                .background(Color.background)
                .cornerRadius(12)
            }
            
            // Password field
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.primaryBlue)
                        .frame(width: 20)
                    
                    if showPassword {
                        TextField("Password", text: $password)
                            .font(.bodyRegular(16))
                    } else {
                        SecureField("Password", text: $password)
                            .font(.bodyRegular(16))
                    }
                    
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding()
                .background(Color.background)
                .cornerRadius(12)
                
                if !password.isEmpty && password.count < 6 {
                    Text("Password must be at least 6 characters")
                        .font(.bodyRegular(12))
                        .foregroundColor(.coralOrange)
                        .padding(.horizontal, 4)
                }
            }
            
            // Confirm password field
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.primaryBlue)
                        .frame(width: 20)
                    
                    if showConfirmPassword {
                        TextField("Confirm Password", text: $confirmPassword)
                            .font(.bodyRegular(16))
                    } else {
                        SecureField("Confirm Password", text: $confirmPassword)
                            .font(.bodyRegular(16))
                    }
                    
                    Button(action: { showConfirmPassword.toggle() }) {
                        Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding()
                .background(Color.background)
                .cornerRadius(12)
                
                if !confirmPassword.isEmpty && password != confirmPassword {
                    Text("Passwords do not match")
                        .font(.bodyRegular(12))
                        .foregroundColor(.coralOrange)
                        .padding(.horizontal, 4)
                }
            }
            
            // Register button
            Button(action: {
                authManager.register(name: name, email: email, password: password)
            }) {
                HStack {
                    Image(systemName: "person.badge.plus.fill")
                        .font(.system(size: 20))
                    Text("Create Account")
                        .font(.displayMedium(18))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.seaGreen,
                            Color.primaryBlue
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: Color.seaGreen.opacity(0.3), radius: 10, x: 0, y: 5)
                .opacity(isValid ? 1 : 0.5)
            }
            .disabled(!isValid || authManager.isLoading)
            .padding(.top, 8)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
    }
    
    var isValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        password.count >= 6 &&
        password == confirmPassword
    }
}

// MARK: - Wave Background
struct WaveBackgroundView: View {
    @Binding var isAnimating: Bool
    @State private var phase: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<3) { index in
                    Wave(phase: phase + CGFloat(index) * .pi / 3)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .offset(y: CGFloat(index) * 20)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear {
            withAnimation(
                Animation.linear(duration: 3.0)
                    .repeatForever(autoreverses: false)
            ) {
                phase = .pi * 2
            }
        }
    }
}

struct Wave: Shape {
    var phase: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height / 2
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let sine = sin(relativeX * .pi * 4 + phase)
            let y = midHeight + sine * 30
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AuthenticationManager())
    }
}
