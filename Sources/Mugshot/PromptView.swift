import SwiftUI
import MugshotCore

struct PromptView: View {
    let file: URL
    let message: String
    let strings: LocaleStrings
    let onDone: (String?) -> Void

    @State private var reason = ""
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                if let img = NSImage(contentsOf: file) {
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 96, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                Text(message)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            TextField("", text: $reason)
                .textFieldStyle(.roundedBorder)
                .focused($focused)
                .onSubmit { onDone(reason) }
            HStack {
                Spacer()
                Button(strings.btnSkip) { onDone(nil) }
                    .keyboardShortcut(.cancelAction)
                Button(strings.btnSave) { onDone(reason) }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(width: 380)
        .onAppear {
            DispatchQueue.main.async { focused = true }
        }
    }
}
