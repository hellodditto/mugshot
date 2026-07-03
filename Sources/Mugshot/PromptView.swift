import SwiftUI
import QuickLookThumbnailing
import MugshotCore

struct PromptView: View {
    enum SaveOutcome {
        case saved      // renamed (and copied); show the checkmark beat, then dismiss
        case failed     // rename failed; keep the panel up and shake
        case dismissed  // controller already resolved it (empty reason = skip)
    }

    let file: URL
    let message: String
    let strings: LocaleStrings
    let attemptSave: (String) -> SaveOutcome
    let onDismiss: () -> Void

    @State private var reason = ""
    @State private var thumbnail: NSImage?
    @State private var saved = false
    @State private var failed = false
    @State private var shakes: CGFloat = 0
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                thumbnailView
                Text(message)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            TextField(strings.fieldPlaceholder, text: $reason)
                .textFieldStyle(.roundedBorder)
                .focused($focused)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.red.opacity(failed ? 0.8 : 0), lineWidth: 1.5)
                )
                .modifier(Shake(travels: shakes))
                .onSubmit { save() }
                .disabled(saved)
            HStack {
                if saved {
                    Label(strings.btnSave, systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .labelStyle(.titleAndIcon)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
                Spacer()
                Button(strings.btnSkip) { onDismiss() }
                    .keyboardShortcut(.cancelAction)
                    .disabled(saved)
                Button(strings.btnSave) { save() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(saved)
            }
        }
        .padding(16)
        .frame(width: 380)
        .onAppear {
            DispatchQueue.main.async { focused = true }
        }
        .task { thumbnail = await loadThumbnail() }
    }

    @ViewBuilder
    private var thumbnailView: some View {
        if let thumbnail {
            Image(nsImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 96, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
        } else {
            RoundedRectangle(cornerRadius: 6)
                .fill(.quaternary)
                .frame(width: 96, height: 72)
                .overlay(Image(systemName: file.pathExtension == "mov"
                               ? "video.fill" : "photo")
                    .foregroundStyle(.secondary))
        }
    }

    private func save() {
        guard !saved else { return }
        switch attemptSave(reason) {
        case .saved:
            withAnimation(.easeOut(duration: 0.15)) {
                saved = true
                failed = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { onDismiss() }
        case .failed:
            withAnimation(.easeOut(duration: 0.1)) { failed = true }
            withAnimation(.linear(duration: 0.35)) { shakes += 1 }
        case .dismissed:
            break
        }
    }

    private func loadThumbnail() async -> NSImage? {
        // QuickLook for images too: it decodes at thumbnail size instead of
        // pulling a full 5K screenshot into memory for a 96×72 view.
        let request = QLThumbnailGenerator.Request(
            fileAt: file, size: CGSize(width: 192, height: 144),
            scale: 2, representationTypes: .thumbnail)
        let rep = try? await QLThumbnailGenerator.shared.generateBestRepresentation(for: request)
        return rep?.nsImage
    }
}

/// Horizontal shake for the rename-failed state.
private struct Shake: GeometryEffect {
    var travels: CGFloat
    var animatableData: CGFloat {
        get { travels }
        set { travels = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(
            translationX: 6 * sin(travels * .pi * 6), y: 0))
    }
}
