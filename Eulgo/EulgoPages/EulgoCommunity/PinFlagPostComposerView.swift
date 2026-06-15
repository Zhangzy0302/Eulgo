import AVFoundation
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct PinFlagPostComposerView: View {
    @State private var pinFlagCopywriter = ""
    @State private var pinFlagShowsVideoPicker = false
    @State private var pinFlagSelectedVideoURL: URL?
    @State private var pinFlagSelectedCoverURL: URL?
    @State private var pinFlagIsPosting = false

    let pinFlagBackAction: () -> Void
    let pinFlagPostSuccessAction: () -> Void

    init(
        pinFlagBackAction: @escaping () -> Void,
        pinFlagPostSuccessAction: @escaping () -> Void = {}
    ) {
        self.pinFlagBackAction = pinFlagBackAction
        self.pinFlagPostSuccessAction = pinFlagPostSuccessAction
    }

    var body: some View {
        ZStack {
            CourseAccessAuthBackgroundView()

            VStack(alignment: .leading, spacing: 0) {
                VenueFairwayHeaderView(
                    venueFairwayTitle: "Post",
                    venueFairwayBackAction: pinFlagBackAction,
                    venueFairwayTrailingAction: nil,
                    venueFairwayHorizontalPadding: 0
                )

                Text("Copywriter")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 28)

                PinFlagCopywriterEditor(pinFlagText: $pinFlagCopywriter)
                    .padding(.top, 10)
                    .zIndex(2)

                Text("Upload")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 14)
                    .zIndex(1)

                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(FairwayStylePalette.fairwayPanelBackground)

                    if let pinFlagSelectedVideoURL {
                        PinFlagSelectedVideoPreview(
                            pinFlagVideoURL: pinFlagSelectedVideoURL,
                            pinFlagCoverURL: pinFlagSelectedCoverURL
                        )
                        .allowsHitTesting(false)
                    } else {
                        ZStack {
                            Circle()
                                .fill(FairwayStylePalette.fairwayCameraGradient())

                            Image("EULGO_camera")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                        }
                        .frame(width: 49, height: 49)
                        .allowsHitTesting(false)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 144)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .onTapGesture(perform: pinFlagUploadAction)
                .padding(.top, 10)
                .zIndex(0)

                Spacer(minLength: 24)

                Button(action: pinFlagPostAction) {
                    ZStack {
                        Text("Post")
                            .opacity(pinFlagIsPosting ? 0 : 1)

                        if pinFlagIsPosting {
                            ProgressView()
                                .tint(.black)
                        }
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(FairwayStylePalette.fairwayBrandGradient())
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(pinFlagIsPosting)
                .opacity(pinFlagIsPosting ? 0.72 : 1)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 16)
        }
        .sheet(isPresented: $pinFlagShowsVideoPicker) {
            PinFlagAlbumVideoPicker(pinFlagVideoPickedAction: pinFlagHandleAlbumVideoPick)
        }
        .greenPathSwipeBack(greenPathBackAction: pinFlagBackAction)
    }

    private func pinFlagUploadAction() {
        pinFlagShowsVideoPicker = true
    }

    private func pinFlagPostAction() {
        guard pinFlagIsPosting == false else {
            return
        }

        let pinFlagTrimmedCopywriter = pinFlagCopywriter.trimmingCharacters(in: .whitespacesAndNewlines)

        guard pinFlagTrimmedCopywriter.isEmpty == false else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please enter copywriter", style: .error)
            return
        }

        guard let pinFlagSelectedVideoURL else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please upload a video", style: .error)
            return
        }

        guard let pinFlagCurrentUserID = PlayerBadgeSessionStore.playerBadgeCurrentUserID else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please log in first", style: .error)
            return
        }

        pinFlagIsPosting = true

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)

            let pinFlagPost = BirdieClipVideoPostModel(
                birdieClipPublisherID: pinFlagCurrentUserID,
                birdieClipCoverAddress: pinFlagSelectedCoverURL?.path ?? "",
                birdieClipVideoAddress: pinFlagSelectedVideoURL.path,
                birdieClipCaptionText: pinFlagTrimmedCopywriter,
                birdieClipLikeCount: 0
            )

            if BirdieClipVideoPostStore.birdieClipCreatePost(pinFlagPost) {
                GolfPulseOverlayCenter.shared.golfPulseShowToast("Posted", style: .success)
                pinFlagPostSuccessAction()
            } else {
                GolfPulseOverlayCenter.shared.golfPulseShowToast("Post failed", style: .error)
            }

            pinFlagIsPosting = false
        }
    }

    private func pinFlagHandleAlbumVideoPick(_ pinFlagVideoURL: URL?) {
        guard let pinFlagVideoURL else {
            return
        }

        guard let pinFlagStoredVideoURL = pinFlagStoredVideoURL(from: pinFlagVideoURL) else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Video import failed", style: .error)
            return
        }

        pinFlagSelectedVideoURL = pinFlagStoredVideoURL
        pinFlagSelectedCoverURL = pinFlagGeneratedCoverURL(for: pinFlagStoredVideoURL)
    }

    private func pinFlagStoredVideoURL(from pinFlagSourceURL: URL) -> URL? {
        let pinFlagCanAccess = pinFlagSourceURL.startAccessingSecurityScopedResource()
        defer {
            if pinFlagCanAccess {
                pinFlagSourceURL.stopAccessingSecurityScopedResource()
            }
        }

        let pinFlagExtension = pinFlagSourceURL.pathExtension.isEmpty ? "mp4" : pinFlagSourceURL.pathExtension
        let pinFlagDestinationURL = pinFlagUploadsDirectory()
            .appendingPathComponent("pinFlagPostVideo-\(UUID().uuidString).\(pinFlagExtension)")

        do {
            try FileManager.default.copyItem(at: pinFlagSourceURL, to: pinFlagDestinationURL)
            return pinFlagDestinationURL
        } catch {
            return nil
        }
    }

    private func pinFlagGeneratedCoverURL(for pinFlagVideoURL: URL) -> URL? {
        let pinFlagAsset = AVURLAsset(url: pinFlagVideoURL)
        let pinFlagGenerator = AVAssetImageGenerator(asset: pinFlagAsset)
        pinFlagGenerator.appliesPreferredTrackTransform = true

        do {
            let pinFlagCGImage = try pinFlagGenerator.copyCGImage(at: CMTime(seconds: 0.1, preferredTimescale: 600), actualTime: nil)
            let pinFlagImage = UIImage(cgImage: pinFlagCGImage)

            guard let pinFlagJPEGData = pinFlagImage.jpegData(compressionQuality: 0.86) else {
                return nil
            }

            let pinFlagCoverURL = pinFlagUploadsDirectory()
                .appendingPathComponent("pinFlagPostCover-\(UUID().uuidString).jpg")
            try pinFlagJPEGData.write(to: pinFlagCoverURL, options: [.atomic])
            return pinFlagCoverURL
        } catch {
            return nil
        }
    }

    private func pinFlagUploadsDirectory() -> URL {
        let pinFlagBaseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let pinFlagDirectoryURL = pinFlagBaseURL.appendingPathComponent("EulgoPostUploads", isDirectory: true)

        if FileManager.default.fileExists(atPath: pinFlagDirectoryURL.path) == false {
            try? FileManager.default.createDirectory(at: pinFlagDirectoryURL, withIntermediateDirectories: true)
        }

        return pinFlagDirectoryURL
    }
}

private struct PinFlagSelectedVideoPreview: View {
    let pinFlagVideoURL: URL
    let pinFlagCoverURL: URL?

    var body: some View {
        ZStack {
            if let pinFlagCoverURL {
                FairwayGalleryImageView(
                    fairwayGalleryImageAddress: pinFlagCoverURL.path,
                    fairwayGalleryContentMode: .fill,
                    fairwayGalleryPlaceholderColor: FairwayStylePalette.fairwayPanelBackground,
                    fairwayGalleryFailureIconName: "play.rectangle.fill"
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            }

            Color.black.opacity(0.24)

            VStack(spacing: 10) {
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)

                Text(pinFlagVideoURL.lastPathComponent)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.82))
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(maxWidth: 220)
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 144)
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct PinFlagAlbumVideoPicker: UIViewControllerRepresentable {
    let pinFlagVideoPickedAction: (URL?) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var pinFlagConfiguration = PHPickerConfiguration(photoLibrary: .shared())
        pinFlagConfiguration.filter = .videos
        pinFlagConfiguration.selectionLimit = 1
        pinFlagConfiguration.preferredAssetRepresentationMode = .current

        let pinFlagPicker = PHPickerViewController(configuration: pinFlagConfiguration)
        pinFlagPicker.delegate = context.coordinator
        return pinFlagPicker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }

    func makeCoordinator() -> PinFlagCoordinator {
        PinFlagCoordinator(pinFlagVideoPickedAction: pinFlagVideoPickedAction)
    }

    final class PinFlagCoordinator: NSObject, PHPickerViewControllerDelegate {
        let pinFlagVideoPickedAction: (URL?) -> Void

        init(pinFlagVideoPickedAction: @escaping (URL?) -> Void) {
            self.pinFlagVideoPickedAction = pinFlagVideoPickedAction
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let pinFlagProvider = results.first?.itemProvider else {
                DispatchQueue.main.async {
                    self.pinFlagVideoPickedAction(nil)
                }
                return
            }

            let pinFlagMovieType = UTType.movie.identifier
            guard pinFlagProvider.hasItemConformingToTypeIdentifier(pinFlagMovieType) else {
                DispatchQueue.main.async {
                    GolfPulseOverlayCenter.shared.golfPulseShowToast("Please select a video", style: .error)
                    self.pinFlagVideoPickedAction(nil)
                }
                return
            }

            pinFlagProvider.loadFileRepresentation(forTypeIdentifier: pinFlagMovieType) { pinFlagURL, _ in
                guard let pinFlagURL else {
                    DispatchQueue.main.async {
                        GolfPulseOverlayCenter.shared.golfPulseShowToast("Video import failed", style: .error)
                        self.pinFlagVideoPickedAction(nil)
                    }
                    return
                }

                let pinFlagTemporaryURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("pinFlagAlbumVideo-\(UUID().uuidString).\(pinFlagURL.pathExtension.isEmpty ? "mov" : pinFlagURL.pathExtension)")

                do {
                    if FileManager.default.fileExists(atPath: pinFlagTemporaryURL.path) {
                        try FileManager.default.removeItem(at: pinFlagTemporaryURL)
                    }

                    try FileManager.default.copyItem(at: pinFlagURL, to: pinFlagTemporaryURL)
                    DispatchQueue.main.async {
                        self.pinFlagVideoPickedAction(pinFlagTemporaryURL)
                    }
                } catch {
                    DispatchQueue.main.async {
                        GolfPulseOverlayCenter.shared.golfPulseShowToast("Video import failed", style: .error)
                        self.pinFlagVideoPickedAction(nil)
                    }
                }
            }
        }
    }
}

private struct PinFlagCopywriterEditor: View {
    @State private var pinFlagIsFocused = false
    @Binding var pinFlagText: String

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack(alignment: .topLeading) {
                if pinFlagText.isEmpty {
                    Text("Share a swing thought, course moment, or clubhouse story...")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.white.opacity(0.42))
                        .lineLimit(2)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 14)
                }

                PinFlagTransparentTextView(
                    pinFlagText: $pinFlagText,
                    pinFlagMaxLength: 180,
                    pinFlagFocusChanged: { pinFlagIsFocused = $0 }
                )
            }

            Text("\(pinFlagText.count)/180")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(pinFlagIsFocused ? 0.76 : 0.46))
                .padding(.trailing, 13)
                .padding(.bottom, 10)
        }
        .frame(height: 124)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(pinFlagIsFocused ? FairwayStylePalette.fairwayFocusedPanelBackground : FairwayStylePalette.fairwayPanelBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    pinFlagIsFocused ? FairwayStylePalette.fairwaySoftMint.opacity(0.68) : Color.white.opacity(0.08),
                    lineWidth: 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct PinFlagTransparentTextView: UIViewRepresentable {
    @Binding var pinFlagText: String
    let pinFlagMaxLength: Int
    let pinFlagFocusChanged: (Bool) -> Void

    func makeUIView(context: Context) -> UITextView {
        let pinFlagTextView = UITextView()
        pinFlagTextView.delegate = context.coordinator
        pinFlagTextView.backgroundColor = .clear
        pinFlagTextView.isOpaque = false
        pinFlagTextView.textColor = .white
        pinFlagTextView.tintColor = .white
        pinFlagTextView.font = .systemFont(ofSize: 14, weight: .regular)
        pinFlagTextView.textContainerInset = UIEdgeInsets(top: 13, left: 15, bottom: 30, right: 15)
        pinFlagTextView.textContainer.lineFragmentPadding = 0
        pinFlagTextView.keyboardDismissMode = .interactive
        return pinFlagTextView
    }

    func updateUIView(_ pinFlagTextView: UITextView, context: Context) {
        if pinFlagTextView.text != pinFlagText {
            pinFlagTextView.text = pinFlagText
        }

        pinFlagTextView.backgroundColor = .clear
        pinFlagTextView.textColor = .white
        pinFlagTextView.tintColor = .white
    }

    func makeCoordinator() -> PinFlagCoordinator {
        PinFlagCoordinator(
            pinFlagText: $pinFlagText,
            pinFlagMaxLength: pinFlagMaxLength,
            pinFlagFocusChanged: pinFlagFocusChanged
        )
    }

    final class PinFlagCoordinator: NSObject, UITextViewDelegate {
        @Binding var pinFlagText: String
        let pinFlagMaxLength: Int
        let pinFlagFocusChanged: (Bool) -> Void

        init(
            pinFlagText: Binding<String>,
            pinFlagMaxLength: Int,
            pinFlagFocusChanged: @escaping (Bool) -> Void
        ) {
            self._pinFlagText = pinFlagText
            self.pinFlagMaxLength = pinFlagMaxLength
            self.pinFlagFocusChanged = pinFlagFocusChanged
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            pinFlagFocusChanged(true)
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            pinFlagFocusChanged(false)
        }

        func textViewDidChange(_ textView: UITextView) {
            if textView.text.count > pinFlagMaxLength {
                textView.text = String(textView.text.prefix(pinFlagMaxLength))
            }

            pinFlagText = textView.text
        }
    }
}

#Preview {
    PinFlagPostComposerView {
    }
    .fairwayGreenDismissKeyboardOnTap()
}
