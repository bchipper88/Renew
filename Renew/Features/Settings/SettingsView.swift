import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var state: AppState

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    if let email = state.profile?.email ?? state.session?.email {
                        HStack {
                            Text("Signed in as")
                            Spacer()
                            Text(email)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Button("Sign Out", role: .destructive) {
                        container.authService.signOut()
                        state.session = nil
                        state.profile = nil
                        state.onboardingCompleted = false
                    }
                }

                Section("Notifications") {
                    Text("Manage reminders from iOS Settings → Notifications → Renew.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("About") {
                    NavigationLink("Privacy Policy") {
                        MarkdownStaticPage(title: "Privacy Policy", markdown: SampleCopy.privacy)
                    }
                    NavigationLink("Terms of Use") {
                        MarkdownStaticPage(title: "Terms of Use", markdown: SampleCopy.terms)
                    }
                    NavigationLink("Contact Support") {
                        MarkdownStaticPage(title: "Support", markdown: SampleCopy.support)
                    }
                }
            }
            .background(GradientBackground())
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
        }
    }
}

struct MarkdownStaticPage: View {
    let title: String
    let markdown: String

    var body: some View {
        ScrollView {
            Text(markdown)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .navigationTitle(title)
    }
}

enum SampleCopy {
    static let privacy = """
    We respect your privacy. Data stays encrypted in Supabase and health metrics remain on-device unless you opt-in.
    """

    static let terms = """
    Renew provides wellness guidance, not medical advice. By using the app you agree to our subscription terms.
    """

    static let support = """
    Need help? Reach us at support@renew.app and we'll respond within 24 hours.
    """
}
