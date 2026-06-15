import SwiftUI
import UIKit

struct LawnNoteTransparentTextView: UIViewRepresentable {
    @Binding var lawnNoteText: String
    var lawnNoteFont: UIFont = .systemFont(ofSize: 14, weight: .regular)
    var lawnNoteTextColor: UIColor = .white
    var lawnNoteTintColor: UIColor = .white
    var lawnNoteInsets: UIEdgeInsets = UIEdgeInsets(top: 13, left: 14, bottom: 13, right: 14)
    var lawnNoteMaxLength: Int?
    var lawnNoteFocusChanged: (Bool) -> Void = { _ in }

    func makeUIView(context: Context) -> UITextView {
        let lawnNoteTextView = UITextView()
        lawnNoteTextView.delegate = context.coordinator
        lawnNoteTextView.backgroundColor = .clear
        lawnNoteTextView.isOpaque = false
        lawnNoteTextView.textColor = lawnNoteTextColor
        lawnNoteTextView.tintColor = lawnNoteTintColor
        lawnNoteTextView.font = lawnNoteFont
        lawnNoteTextView.textContainerInset = lawnNoteInsets
        lawnNoteTextView.textContainer.lineFragmentPadding = 0
        lawnNoteTextView.keyboardDismissMode = .interactive
        return lawnNoteTextView
    }

    func updateUIView(_ lawnNoteTextView: UITextView, context: Context) {
        if lawnNoteTextView.text != lawnNoteText {
            lawnNoteTextView.text = lawnNoteText
        }

        lawnNoteTextView.backgroundColor = .clear
        lawnNoteTextView.isOpaque = false
        lawnNoteTextView.textColor = lawnNoteTextColor
        lawnNoteTextView.tintColor = lawnNoteTintColor
        lawnNoteTextView.font = lawnNoteFont
        lawnNoteTextView.textContainerInset = lawnNoteInsets
    }

    func makeCoordinator() -> LawnNoteCoordinator {
        LawnNoteCoordinator(
            lawnNoteText: $lawnNoteText,
            lawnNoteMaxLength: lawnNoteMaxLength,
            lawnNoteFocusChanged: lawnNoteFocusChanged
        )
    }

    final class LawnNoteCoordinator: NSObject, UITextViewDelegate {
        @Binding var lawnNoteText: String
        let lawnNoteMaxLength: Int?
        let lawnNoteFocusChanged: (Bool) -> Void

        init(
            lawnNoteText: Binding<String>,
            lawnNoteMaxLength: Int?,
            lawnNoteFocusChanged: @escaping (Bool) -> Void
        ) {
            self._lawnNoteText = lawnNoteText
            self.lawnNoteMaxLength = lawnNoteMaxLength
            self.lawnNoteFocusChanged = lawnNoteFocusChanged
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            lawnNoteFocusChanged(true)
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            lawnNoteFocusChanged(false)
        }

        func textViewDidChange(_ textView: UITextView) {
            if let lawnNoteMaxLength, textView.text.count > lawnNoteMaxLength {
                textView.text = String(textView.text.prefix(lawnNoteMaxLength))
            }

            lawnNoteText = textView.text
        }
    }
}
