import SwiftUI
import PhotosUI
import UIKit

struct ProfileView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var state: AppState

    @State private var displayName: String = ""
    @State private var selectedAvatarItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    @State private var avatarData: Data?
    @State private var hasLoadedProfile = false

    private var profileID: UUID? { state.profile?.id }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ProfileGlassCard(title: "Avatar & Name") {
                        HStack(alignment: .center, spacing: 20) {
                            avatarView

                            VStack(alignment: .leading, spacing: 12) {
                                TextField("Your name", text: $displayName)
                                    .textInputAutocapitalization(.words)
                                    .disableAutocorrection(true)
                                    .font(.title3.weight(.semibold))

                                PhotosPicker(selection: $selectedAvatarItem, matching: .images) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "camera.fill")
                                        Text("Update Photo")
                                    }
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 14)
                                    .background(.thinMaterial, in: Capsule())
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    ProfileJourneyProgressSection()

                    ProfileGlassCard(title: "Account") {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Email")
                                Spacer()
                                Text(accountEmail)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    ProfileGlassCard(title: "Notifications") {
                        Text("Manage reminders from iOS Settings → Notifications → Renew.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    ProfileGlassCard(title: "About") {
                        VStack(spacing: 0) {
                            ProfileLinkRow(title: "Privacy Policy") {
                                MarkdownStaticPage(title: "Privacy Policy", markdown: SampleCopy.privacy)
                            }

                            Divider().overlay(Color.white.opacity(0.15))

                            ProfileLinkRow(title: "Terms of Use") {
                                MarkdownStaticPage(title: "Terms of Use", markdown: SampleCopy.terms)
                            }

                            Divider().overlay(Color.white.opacity(0.15))

                            ProfileLinkRow(title: "Contact Support") {
                                MarkdownStaticPage(title: "Support", markdown: SampleCopy.support)
                            }
                        }
                    }

                    ProfileGlassCard(title: nil) {
                        Button(role: .destructive, action: signOut) {
                            Text("Sign Out")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red.opacity(0.9))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 32)
            }
            .background(GradientBackground())
            .navigationTitle("Profile")
        }
        .onAppear { syncFromState(force: true) }
        .onChange(of: profileID) { _ in syncFromState(force: true) }
        .onChange(of: selectedAvatarItem) { newItem in
            guard let newItem else { return }
            Task { await loadAvatar(from: newItem) }
        }
        .onChange(of: displayName) { newValue in
            guard hasLoadedProfile else { return }
            updateDisplayName(newValue)
        }
    }

    private var avatarView: some View {
        ZStack {
            if let avatarImage {
                avatarImage
                    .resizable()
                    .scaledToFill()
            } else {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        Text(initials)
                            .font(.largeTitle.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.85))
                    )
            }
        }
        .frame(width: 96, height: 96)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 8)
        .accessibilityLabel("Profile photo")
    }

    private var accountEmail: String {
        state.profile?.email ?? state.session?.email ?? "Not signed in"
    }

    private var initials: String {
        let name = displayName.isEmpty ? (state.profile?.email ?? "") : displayName
        let components = name.split(separator: " ").map(String.init)
        let initials = components.prefix(2).compactMap { $0.first }
        if initials.isEmpty, let first = name.first {
            return String(first)
        }
        return initials.map(String.init).joined()
    }

    @MainActor
    private func loadAvatar(from item: PhotosPickerItem) async {
        defer { selectedAvatarItem = nil }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                avatarData = data
                avatarImage = image(from: data)
                updateProfileAvatar(with: data)
            }
        } catch {
            #if DEBUG
            print("Failed to load avatar: \(error.localizedDescription)")
            #endif
        }
    }

    private func syncFromState(force: Bool) {
        guard force else { return }

        guard let profile = state.profile else {
            displayName = ""
            avatarData = nil
            avatarImage = nil
            hasLoadedProfile = true
            return
        }

        displayName = profile.displayName
        avatarData = profile.avatarImageData
        avatarImage = image(from: profile.avatarImageData)
        hasLoadedProfile = true
    }

    private func updateDisplayName(_ newValue: String) {
        guard var profile = state.profile else { return }
        guard profile.displayName != newValue else { return }
        profile.displayName = newValue
        profile.avatarImageData = avatarData
        state.profile = profile
    }

    private func updateProfileAvatar(with data: Data?) {
        guard var profile = state.profile else { return }
        profile.avatarImageData = data
        profile.displayName = displayName
        state.profile = profile
    }

    private func image(from data: Data?) -> Image? {
        guard
            let data,
            let uiImage = UIImage(data: data)
        else { return nil }
        return Image(uiImage: uiImage)
    }

    private func signOut() {
        container.authService.signOut()
        state.session = nil
        state.profile = nil
        state.onboardingCompleted = false
    }
}

private struct ProfileGlassCard<Content: View>: View {
    let title: String?
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let title {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            content
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.white.opacity(0.25))
        )
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 12)
    }
}

private struct ProfileLinkRow<Destination: View>: View {
    let title: String
    @ViewBuilder var destination: Destination

    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
    }
}

private struct ProfileJourneyProgressSection: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel = JourneyViewModel()
    @State private var displayedMonth = Date()

    var body: some View {
        ProfileGlassCard(title: "Progress Overview") {
            VStack(alignment: .leading, spacing: 16) {
                Picker("View Mode", selection: $viewModel.selectedMode) {
                    ForEach(JourneyViewMode.allCases) { mode in
                        Text(mode.title)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                switch viewModel.selectedMode {
                case .calendar:
                    JourneyCalendarView(
                        scores: viewModel.dailyScores,
                        displayedMonth: $displayedMonth
                    )
                case .graph:
                    JourneyGraphView(scores: viewModel.dailyScores)
                }
            }
        }
        .task {
            await viewModel.connect(container: container)
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
