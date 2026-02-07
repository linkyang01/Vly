import SwiftUI
import Foundation

// MARK: - Credential Input View

/// View for entering network credentials
struct CredentialInputView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var password = ""
    @State private var domain = ""
    @State private var rememberCredentials = true
    @State private var showPassword = false
    
    let onSubmit: (Credential) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "lock.shield")
                    .foregroundColor(.accentColor)
                Text("Authentication Required")
                    .font(.headline)
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Form
            VStack(alignment: .leading, spacing: 16) {
                // Warning
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    Text("Enter your credentials to access this server")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top)
                
                Form {
                    Section("Authentication") {
                        TextField("Username", text: $username)
                            .textContentType(.username)
                            #if os(iOS)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            #endif
                        
                        HStack {
                            if showPassword {
                                TextField("Password", text: $password)
                                    .textContentType(.password)
                            } else {
                                SecureField("Password", text: $password)
                                    .textContentType(.password)
                            }
                            
                            Button {
                                showPassword.toggle()
                            } label: {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        TextField("Domain (optional)", text: $domain)
                            #if os(iOS)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            #endif
                    }
                    
                    Section {
                        Toggle("Remember credentials", isOn: $rememberCredentials)
                        
                        Text("Credentials are stored securely in your keychain")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .formStyle(.grouped)
            }
            
            Divider()
            
            // Footer
            HStack {
                Spacer()
                Button("Connect") {
                    submit()
                }
                .buttonStyle(.borderedProminent)
                .disabled(username.isEmpty || password.isEmpty)
                .keyboardShortcut(.return, modifiers: .command)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 400, height: 400)
        .onSubmit {
            submit()
        }
    }
    
    // MARK: - Actions
    
    private func submit() {
        let credential = Credential(
            username: username,
            password: password,
            domain: domain.isEmpty ? nil : domain,
            protocol: .smb // Protocol will be set by the caller
        )
        
        onSubmit(credential)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    CredentialInputView { credential in
        print("Username: \(credential.username)")
    }
}
