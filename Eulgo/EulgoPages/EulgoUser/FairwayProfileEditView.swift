import PhotosUI
import SwiftUI
import UIKit

struct FairwayProfileEditView: View {
    @State private var fairwayProfileName = ""
    @State private var fairwayProfileBirthdayDate = FairwayProfileEditView.fairwayProfileDefaultBirthdayDate
    @State private var fairwayProfileLocation = "LA"
    @State private var fairwayProfileGender: FairwayProfileGender = .male
    @State private var fairwayProfileAvatarAddress = ""
    @State private var fairwayProfileShowsPhotoPicker = false
    @State private var fairwayProfileDidLoadUser = false
    @State private var fairwayProfileIsSaving = false

    let fairwayProfileBackAction: () -> Void

    private let fairwayProfileLocationOptions = [
        "LA",
        "San Diego",
        "Palm Springs",
        "Scottsdale",
        "Pebble Beach"
    ]

    var body: some View {
        ZStack {
            CourseAccessAuthBackgroundView()

            VStack(spacing: 0) {
                VenueFairwayHeaderView(
                    venueFairwayTitle: "Edit personal profile",
                    venueFairwayBackAction: fairwayProfileBackAction,
                    venueFairwayTrailingAction: nil,
                    venueFairwayHorizontalPadding: 14
                )
                .padding(.top, 14)

                FairwayProfileEditAvatarView(
                    fairwayProfileAvatarAddress: fairwayProfileAvatarAddress,
                    fairwayProfileShowsPhotoPicker: $fairwayProfileShowsPhotoPicker
                )
                    .padding(.top, 30)

                VStack(spacing: 20) {
                    FairwayProfileEditTextField(
                        fairwayProfileTitle: "Name",
                        fairwayProfileText: $fairwayProfileName
                    )

                    FairwayProfileEditDateField(
                        fairwayProfileTitle: "Birthday",
                        fairwayProfileDate: $fairwayProfileBirthdayDate
                    )

                    FairwayProfileEditMenuField(
                        fairwayProfileTitle: "Location",
                        fairwayProfileValue: fairwayProfileLocation,
                        fairwayProfileOptions: fairwayProfileLocationOptions,
                        fairwayProfileSelectionAction: { fairwayProfileLocation = $0 }
                    )

                    FairwayProfileEditGenderPickerView(fairwayProfileGender: $fairwayProfileGender)
                }
                .padding(.horizontal, 14)
                .padding(.top, 24)

                Spacer(minLength: 24)

                Button(action: fairwayProfileConfirmAction) {
                    ZStack {
                        Text("Confirm")
                            .opacity(fairwayProfileIsSaving ? 0 : 1)

                        if fairwayProfileIsSaving {
                            ProgressView()
                                .tint(.black)
                        }
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(FairwayStylePalette.fairwayBrandGradient())
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(fairwayProfileIsSaving)
                .opacity(fairwayProfileIsSaving ? 0.72 : 1)
                .padding(.horizontal, 14)
                .padding(.bottom, 20)
            }
        }
        .onAppear(perform: fairwayProfileLoadCurrentUserIfNeeded)
        .sheet(isPresented: $fairwayProfileShowsPhotoPicker) {
            FairwayProfilePhotoPickerView { fairwayProfileImage in
                fairwayProfileHandlePhotoSelection(fairwayProfileImage)
            }
        }
        .greenPathSwipeBack(greenPathBackAction: fairwayProfileBackAction)
    }

    private func fairwayProfileConfirmAction() {
        guard fairwayProfileIsSaving == false else {
            return
        }

        guard var fairwayProfileCurrentUser = PlayerBadgeSessionStore.playerBadgeReadLoginUser() else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please log in first", style: .error)
            return
        }

        let fairwayProfileTrimmedName = fairwayProfileName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard fairwayProfileTrimmedName.isEmpty == false else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please enter name", style: .error)
            return
        }

        fairwayProfileIsSaving = true

        fairwayProfileCurrentUser.teeBoxUsername = fairwayProfileTrimmedName
        fairwayProfileCurrentUser.teeBoxBirthdayDate = fairwayProfileBirthdayDate
        fairwayProfileCurrentUser.teeBoxLocation = fairwayProfileLocation
        fairwayProfileCurrentUser.teeBoxGender = fairwayProfileGender.fairwayProfileStorageValue
        fairwayProfileCurrentUser.teeBoxAvatarAddress = fairwayProfileAvatarAddress

        if TeeBoxUserStore.teeBoxUpdateUser(fairwayProfileCurrentUser) {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Profile updated", style: .success)
            fairwayProfileBackAction()
        } else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Update failed", style: .error)
        }

        fairwayProfileIsSaving = false
    }

    private func fairwayProfileLoadCurrentUserIfNeeded() {
        guard fairwayProfileDidLoadUser == false,
              let fairwayProfileCurrentUser = PlayerBadgeSessionStore.playerBadgeReadLoginUser() else {
            return
        }

        fairwayProfileDidLoadUser = true
        fairwayProfileName = fairwayProfileCurrentUser.teeBoxUsername
        fairwayProfileBirthdayDate = fairwayProfileCurrentUser.teeBoxBirthdayDate
        fairwayProfileLocation = fairwayProfileCurrentUser.teeBoxLocation
        fairwayProfileGender = FairwayProfileGender(fairwayProfileStorageValue: fairwayProfileCurrentUser.teeBoxGender)
        fairwayProfileAvatarAddress = fairwayProfileCurrentUser.teeBoxAvatarAddress
    }

    private func fairwayProfileHandlePhotoSelection(_ fairwayProfileImage: UIImage) {
        guard let fairwayProfileAvatarURL = fairwayProfileSaveAvatarImage(fairwayProfileImage) else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Avatar import failed", style: .error)
            return
        }

        fairwayProfileAvatarAddress = fairwayProfileAvatarURL.path
    }

    private func fairwayProfileSaveAvatarImage(_ fairwayProfileImage: UIImage) -> URL? {
        guard let fairwayProfileImageData = fairwayProfileImage.jpegData(compressionQuality: 0.88) else {
            return nil
        }

        let fairwayProfileDirectoryURL = fairwayProfileAvatarDirectory()
        let fairwayProfileAvatarURL = fairwayProfileDirectoryURL
            .appendingPathComponent("fairwayProfileAvatar-\(UUID().uuidString).jpg")

        do {
            try fairwayProfileImageData.write(to: fairwayProfileAvatarURL, options: [.atomic])
            return fairwayProfileAvatarURL
        } catch {
            return nil
        }
    }

    private func fairwayProfileAvatarDirectory() -> URL {
        let fairwayProfileBaseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let fairwayProfileDirectoryURL = fairwayProfileBaseURL.appendingPathComponent("EulgoProfileAvatars", isDirectory: true)

        if FileManager.default.fileExists(atPath: fairwayProfileDirectoryURL.path) == false {
            try? FileManager.default.createDirectory(at: fairwayProfileDirectoryURL, withIntermediateDirectories: true)
        }

        return fairwayProfileDirectoryURL
    }

    private static let fairwayProfileDateFormatter: DateFormatter = {
        let fairwayProfileFormatter = DateFormatter()
        fairwayProfileFormatter.calendar = Calendar(identifier: .gregorian)
        fairwayProfileFormatter.locale = Locale(identifier: "en_US_POSIX")
        fairwayProfileFormatter.dateFormat = "yyyy-MM-dd"
        return fairwayProfileFormatter
    }()

    private static let fairwayProfileDefaultBirthdayDate = fairwayProfileDateFormatter.date(from: "2003-01-01") ?? Date()
}

private enum FairwayProfileGender {
    case male
    case female

    init(fairwayProfileStorageValue: String) {
        let fairwayProfileNormalizedValue = fairwayProfileStorageValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self = fairwayProfileNormalizedValue == "female" ? .female : .male
    }

    var fairwayProfileStorageValue: String {
        switch self {
        case .male:
            return "Male"
        case .female:
            return "Female"
        }
    }
}

private struct FairwayProfileEditAvatarView: View {
    let fairwayProfileAvatarAddress: String
    @Binding var fairwayProfileShowsPhotoPicker: Bool

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                if fairwayProfileAvatarAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    LinearGradient(
                        colors: [
                            Color(red: 0.65, green: 0.76, blue: 0.52),
                            Color(red: 0.25, green: 0.43, blue: 0.29)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Image(systemName: "person.fill")
                        .font(.system(size: 38, weight: .medium))
                        .foregroundStyle(.white.opacity(0.72))
                } else {
                    FairwayGalleryImageView(
                        fairwayGalleryImageAddress: fairwayProfileAvatarAddress,
                        fairwayGalleryContentMode: .fill,
                        fairwayGalleryPlaceholderColor: FairwayStylePalette.fairwayPanelBackground,
                        fairwayGalleryFailureIconName: "person.fill"
                    )
                }
            }
            .frame(width: 78, height: 78)
            .clipShape(Circle())

            Button {
                fairwayProfileShowsPhotoPicker = true
            } label: {
                ZStack {
                    Circle()
                        .fill(FairwayStylePalette.fairwayCameraGradient())

                    Image("EULGO_camera")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                }
                .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .offset(x: 5, y: 3)
        }
    }
}

private struct FairwayProfilePhotoPickerView: UIViewControllerRepresentable {
    let fairwayProfileSelectionAction: (UIImage) -> Void

    func makeCoordinator() -> FairwayProfilePhotoPickerCoordinator {
        FairwayProfilePhotoPickerCoordinator(fairwayProfileSelectionAction: fairwayProfileSelectionAction)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var fairwayProfileConfiguration = PHPickerConfiguration(photoLibrary: .shared())
        fairwayProfileConfiguration.filter = .images
        fairwayProfileConfiguration.selectionLimit = 1

        let fairwayProfilePicker = PHPickerViewController(configuration: fairwayProfileConfiguration)
        fairwayProfilePicker.delegate = context.coordinator
        return fairwayProfilePicker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
}

private final class FairwayProfilePhotoPickerCoordinator: NSObject, PHPickerViewControllerDelegate {
    let fairwayProfileSelectionAction: (UIImage) -> Void

    init(fairwayProfileSelectionAction: @escaping (UIImage) -> Void) {
        self.fairwayProfileSelectionAction = fairwayProfileSelectionAction
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let fairwayProfileProvider = results.first?.itemProvider,
              fairwayProfileProvider.canLoadObject(ofClass: UIImage.self) else {
            return
        }

        fairwayProfileProvider.loadObject(ofClass: UIImage.self) { [fairwayProfileSelectionAction] fairwayProfileObject, _ in
            guard let fairwayProfileImage = fairwayProfileObject as? UIImage else {
                return
            }

            DispatchQueue.main.async {
                fairwayProfileSelectionAction(fairwayProfileImage)
            }
        }
    }
}

private struct FairwayProfileEditTextField: View {
    let fairwayProfileTitle: String
    @Binding var fairwayProfileText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            FairwayProfileEditLabel(fairwayProfileTitle)

            TextField("", text: $fairwayProfileText)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.white)
                .tint(.white)
                .padding(.horizontal, 14)
                .frame(height: 42)
                .background(FairwayStylePalette.fairwayPanelBackground)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
    }
}

private struct FairwayProfileEditDateField: View {
    let fairwayProfileTitle: String
    @Binding var fairwayProfileDate: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            FairwayProfileEditLabel(fairwayProfileTitle)

            ZStack {
                HStack {
                    Text(Self.fairwayProfileDateFormatter.string(from: fairwayProfileDate))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.white)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(Color.white.opacity(0.16))
                        .clipShape(Circle())
                }

                DatePicker(
                    "",
                    selection: $fairwayProfileDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .colorScheme(.dark)
                .tint(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(0.02)
                .contentShape(Rectangle())
            }
            .padding(.leading, 14)
            .padding(.trailing, 8)
            .frame(height: 42)
            .background(FairwayStylePalette.fairwayPanelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
    }

    private static let fairwayProfileDateFormatter: DateFormatter = {
        let fairwayProfileFormatter = DateFormatter()
        fairwayProfileFormatter.calendar = Calendar(identifier: .gregorian)
        fairwayProfileFormatter.locale = Locale(identifier: "en_US_POSIX")
        fairwayProfileFormatter.dateFormat = "yyyy-MM-dd"
        return fairwayProfileFormatter
    }()
}

private struct FairwayProfileEditMenuField: View {
    let fairwayProfileTitle: String
    let fairwayProfileValue: String
    let fairwayProfileOptions: [String]
    let fairwayProfileSelectionAction: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            FairwayProfileEditLabel(fairwayProfileTitle)

            Menu {
                ForEach(fairwayProfileOptions, id: \.self) { fairwayProfileOption in
                    Button(fairwayProfileOption) {
                        fairwayProfileSelectionAction(fairwayProfileOption)
                    }
                }
            } label: {
                HStack {
                    Text(fairwayProfileValue)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.white)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(FairwayStylePalette.fairwaySubtlePanelBackground)
                        .clipShape(Circle())
                }
                .padding(.leading, 14)
                .padding(.trailing, 8)
                .frame(height: 42)
                .background(FairwayStylePalette.fairwayPanelBackground)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
}

private struct FairwayProfileEditGenderPickerView: View {
    @Binding var fairwayProfileGender: FairwayProfileGender

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            FairwayProfileEditLabel("Gender")

            HStack(spacing: 10) {
                FairwayProfileEditGenderButton(
                    fairwayProfileTitle: "Male",
                    fairwayProfileIsSelected: fairwayProfileGender == .male,
                    fairwayProfileSelectionAction: { fairwayProfileGender = .male }
                )

                FairwayProfileEditGenderButton(
                    fairwayProfileTitle: "Female",
                    fairwayProfileIsSelected: fairwayProfileGender == .female,
                    fairwayProfileSelectionAction: { fairwayProfileGender = .female }
                )
            }
        }
    }
}

private struct FairwayProfileEditGenderButton: View {
    let fairwayProfileTitle: String
    let fairwayProfileIsSelected: Bool
    let fairwayProfileSelectionAction: () -> Void

    var body: some View {
        Button(action: fairwayProfileSelectionAction) {
            Text(fairwayProfileTitle)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(fairwayProfileIsSelected ? .black : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(
                    Group {
                        if fairwayProfileIsSelected {
                            Color(red: 0.42, green: 0.94, blue: 0.42)
                        } else {
                            Color.white.opacity(0.22)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct FairwayProfileEditLabel: View {
    let fairwayProfileTitle: String

    init(_ fairwayProfileTitle: String) {
        self.fairwayProfileTitle = fairwayProfileTitle
    }

    var body: some View {
        Text(fairwayProfileTitle)
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(.white)
    }
}

#Preview {
    FairwayProfileEditView {
    }
}
