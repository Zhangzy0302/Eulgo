import PhotosUI
import SwiftUI
import UIKit

struct CourseAccessProfileSetupView: View {
    @State private var courseAccessPlayerName = ""
    @State private var courseAccessBirthdayDate = CourseAccessProfileSetupView.courseAccessDefaultBirthdayDate
    @State private var courseAccessLocation = "LA"
    @State private var courseAccessGender: CourseAccessPlayerGender = .male
    @State private var courseAccessAvatarAddress = "EULGO_default_avatar"
    @State private var courseAccessShowsAvatarPicker = false
    @State private var courseAccessIsSubmittingProfile = false
    let courseAccessEmailAddress: String
    let courseAccessPassword: String
    let courseAccessBackAction: () -> Void
    let courseAccessRegisterSuccessAction: (String) -> Void

    private let courseAccessLocationOptions = [
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
                    venueFairwayHeight: 48,
                    venueFairwayHorizontalPadding: 16,
                    venueFairwayLeadingContent: {
                        VenueFairwayHeaderView.venueFairwayBackButton(action: courseAccessBackAction)
                    },
                    venueFairwayCenterContent: {
                        EmptyView()
                    },
                    venueFairwayTrailingContent: {
                        EmptyView()
                    }
                )
                    .padding(.top, 14)

                CourseAccessAvatarPickerView(
                    courseAccessAvatarAddress: courseAccessAvatarAddress,
                    courseAccessShowsAvatarPicker: $courseAccessShowsAvatarPicker
                )
                    .padding(.top, 28)

                VStack(spacing: 24) {
                    CourseAccessProfileTextField(
                        courseAccessTitle: "Name",
                        courseAccessPlaceholder: "Enter name",
                        courseAccessText: $courseAccessPlayerName
                    )

                    CourseAccessProfileDateField(
                        courseAccessTitle: "Birthday",
                        courseAccessDate: $courseAccessBirthdayDate
                    )

                    CourseAccessProfileMenuField(
                        courseAccessTitle: "Location",
                        courseAccessValue: courseAccessLocation,
                        courseAccessOptions: courseAccessLocationOptions,
                        courseAccessSelectionAction: { courseAccessLocation = $0 }
                    )

                    CourseAccessGenderPickerView(courseAccessGender: $courseAccessGender)
                }
                .padding(.horizontal, 16)
                .padding(.top, 22)

                Spacer(minLength: 24)

                Button(action: courseAccessCreateUserProfile) {
                    ZStack {
                        Text("Next")
                            .opacity(courseAccessIsSubmittingProfile ? 0 : 1)

                        if courseAccessIsSubmittingProfile {
                            ProgressView()
                                .tint(.black)
                        }
                    }
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(
                            colors: [
                                FairwayStylePalette.fairwayLime,
                                FairwayStylePalette.fairwayMint
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .disabled(courseAccessIsSubmittingProfile)
                .opacity(courseAccessIsSubmittingProfile ? 0.72 : 1)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $courseAccessShowsAvatarPicker) {
            CourseAccessPhotoPickerView { courseAccessImage in
                courseAccessHandleAvatarSelection(courseAccessImage)
            }
        }
        .greenPathSwipeBack(greenPathBackAction: courseAccessBackAction)
    }

    private func courseAccessCreateUserProfile() {
        guard courseAccessIsSubmittingProfile == false else {
            return
        }

        let courseAccessTrimmedName = courseAccessPlayerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let courseAccessNormalizedEmail = courseAccessEmailAddress.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let courseAccessTrimmedPassword = courseAccessPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let courseAccessResolvedAvatarAddress = courseAccessAvatarAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "EULGO_default_avatar"
            : courseAccessAvatarAddress

        guard courseAccessTrimmedName.isEmpty == false else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please enter name", style: .error)
            return
        }

        guard TeeBoxUserStore.teeBoxReadUser(teeBoxEmail: courseAccessNormalizedEmail) == nil else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("This email is already registered", style: .error)
            return
        }

        let courseAccessUser = TeeBoxUserModel(
            teeBoxEmail: courseAccessNormalizedEmail,
            teeBoxPassword: courseAccessTrimmedPassword,
            teeBoxAvatarAddress: courseAccessResolvedAvatarAddress,
            teeBoxUsername: courseAccessTrimmedName,
            teeBoxBirthdayDate: courseAccessBirthdayDate,
            teeBoxLocation: courseAccessLocation,
            teeBoxGender: courseAccessGender.courseAccessStorageValue,
            teeBoxIsGuest: false
        )

        guard TeeBoxUserStore.teeBoxCreateUser(courseAccessUser) else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Unable to create account", style: .error)
            return
        }

        courseAccessRunProfileSimulatedNetworkDelay {
            courseAccessRegisterSuccessAction(courseAccessUser.teeBoxUserID)
        }
    }

    private func courseAccessRunProfileSimulatedNetworkDelay(_ courseAccessCompletion: @escaping () -> Void) {
        courseAccessIsSubmittingProfile = true
        GolfPulseOverlayCenter.shared.golfPulseShowLoading()

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 800_000_000)
            GolfPulseOverlayCenter.shared.golfPulseHideLoading()
            courseAccessIsSubmittingProfile = false
            courseAccessCompletion()
        }
    }

    private static let courseAccessDateFormatter: DateFormatter = {
        let courseAccessFormatter = DateFormatter()
        courseAccessFormatter.calendar = Calendar(identifier: .gregorian)
        courseAccessFormatter.locale = Locale(identifier: "en_US_POSIX")
        courseAccessFormatter.dateFormat = "yyyy-MM-dd"
        return courseAccessFormatter
    }()

    private static let courseAccessDefaultBirthdayDate = courseAccessDateFormatter.date(from: "2003-01-01") ?? Date()

    private func courseAccessHandleAvatarSelection(_ courseAccessImage: UIImage) {
        guard let courseAccessAvatarURL = courseAccessSaveAvatarImage(courseAccessImage) else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Avatar import failed", style: .error)
            return
        }

        courseAccessAvatarAddress = courseAccessAvatarURL.path
    }

    private func courseAccessSaveAvatarImage(_ courseAccessImage: UIImage) -> URL? {
        guard let courseAccessImageData = courseAccessImage.jpegData(compressionQuality: 0.88) else {
            return nil
        }

        let courseAccessAvatarURL = courseAccessAvatarDirectory()
            .appendingPathComponent("courseAccessAvatar-\(UUID().uuidString).jpg")

        do {
            try courseAccessImageData.write(to: courseAccessAvatarURL, options: [.atomic])
            return courseAccessAvatarURL
        } catch {
            return nil
        }
    }

    private func courseAccessAvatarDirectory() -> URL {
        let courseAccessBaseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let courseAccessDirectoryURL = courseAccessBaseURL.appendingPathComponent("EulgoProfileAvatars", isDirectory: true)

        if FileManager.default.fileExists(atPath: courseAccessDirectoryURL.path) == false {
            try? FileManager.default.createDirectory(at: courseAccessDirectoryURL, withIntermediateDirectories: true)
        }

        return courseAccessDirectoryURL
    }
}

private enum CourseAccessPlayerGender {
    case male
    case female

    var courseAccessStorageValue: String {
        switch self {
        case .male:
            return "Male"
        case .female:
            return "Female"
        }
    }
}

private struct CourseAccessAvatarPickerView: View {
    let courseAccessAvatarAddress: String
    @Binding var courseAccessShowsAvatarPicker: Bool

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            FairwayGalleryImageView(
                fairwayGalleryImageAddress: courseAccessAvatarAddress,
                fairwayGalleryContentMode: .fill,
                fairwayGalleryPlaceholderColor: Color.white.opacity(0.24),
                fairwayGalleryFailureIconName: "person.fill"
            )
            .frame(width: 108, height: 108)
            .clipShape(Circle())

            Button {
                courseAccessShowsAvatarPicker = true
            } label: {
                ZStack{
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    FairwayStylePalette.fairwayLime,
                                    FairwayStylePalette.fairwayMint
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        ).frame(width: 32)
                    Image("EULGO_camera")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 17.5, height: 17.5)
                }
                
            }
            .buttonStyle(.plain)
            .offset(x: 4, y: 2)
        }
    }
}

private struct CourseAccessPhotoPickerView: UIViewControllerRepresentable {
    let courseAccessSelectionAction: (UIImage) -> Void

    func makeCoordinator() -> CourseAccessPhotoPickerCoordinator {
        CourseAccessPhotoPickerCoordinator(courseAccessSelectionAction: courseAccessSelectionAction)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var courseAccessConfiguration = PHPickerConfiguration(photoLibrary: .shared())
        courseAccessConfiguration.filter = .images
        courseAccessConfiguration.selectionLimit = 1

        let courseAccessPicker = PHPickerViewController(configuration: courseAccessConfiguration)
        courseAccessPicker.delegate = context.coordinator
        return courseAccessPicker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
}

private final class CourseAccessPhotoPickerCoordinator: NSObject, PHPickerViewControllerDelegate {
    let courseAccessSelectionAction: (UIImage) -> Void

    init(courseAccessSelectionAction: @escaping (UIImage) -> Void) {
        self.courseAccessSelectionAction = courseAccessSelectionAction
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let courseAccessProvider = results.first?.itemProvider,
              courseAccessProvider.canLoadObject(ofClass: UIImage.self) else {
            return
        }

        courseAccessProvider.loadObject(ofClass: UIImage.self) { [courseAccessSelectionAction] courseAccessObject, _ in
            guard let courseAccessImage = courseAccessObject as? UIImage else {
                return
            }

            DispatchQueue.main.async {
                courseAccessSelectionAction(courseAccessImage)
            }
        }
    }
}

private struct CourseAccessProfileTextField: View {
    let courseAccessTitle: String
    let courseAccessPlaceholder: String
    @Binding var courseAccessText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            CourseAccessProfileLabel(courseAccessTitle)

            TextField("", text: $courseAccessText, prompt: Text(courseAccessPlaceholder).foregroundColor(.white.opacity(0.42)))
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
                .tint(.white)
                .padding(.horizontal, 15)
                .frame(height: 54)
                .background(FairwayStylePalette.fairwayPanelBackground)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}

private struct CourseAccessProfileDateField: View {
    let courseAccessTitle: String
    @Binding var courseAccessDate: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            CourseAccessProfileLabel(courseAccessTitle)

            ZStack {
                HStack {
                    Text(Self.courseAccessDateFormatter.string(from: courseAccessDate))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.white)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.16))
                        .clipShape(Circle())
                }

                DatePicker(
                    "",
                    selection: $courseAccessDate,
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
            .padding(.leading, 15)
            .padding(.trailing, 9)
            .frame(height: 54)
            .background(FairwayStylePalette.fairwayPanelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private static let courseAccessDateFormatter: DateFormatter = {
        let courseAccessFormatter = DateFormatter()
        courseAccessFormatter.calendar = Calendar(identifier: .gregorian)
        courseAccessFormatter.locale = Locale(identifier: "en_US_POSIX")
        courseAccessFormatter.dateFormat = "yyyy-MM-dd"
        return courseAccessFormatter
    }()
}

private struct CourseAccessProfileMenuField: View {
    let courseAccessTitle: String
    let courseAccessValue: String
    let courseAccessOptions: [String]
    let courseAccessSelectionAction: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            CourseAccessProfileLabel(courseAccessTitle)

            Menu {
                ForEach(courseAccessOptions, id: \.self) { courseAccessOption in
                    Button(courseAccessOption) {
                        courseAccessSelectionAction(courseAccessOption)
                    }
                }
            } label: {
                HStack {
                    Text(courseAccessValue)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.white)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Circle())
                }
                .padding(.leading, 15)
                .padding(.trailing, 9)
                .frame(height: 54)
                .background(FairwayStylePalette.fairwayPanelBackground)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
}

private struct CourseAccessGenderPickerView: View {
    @Binding var courseAccessGender: CourseAccessPlayerGender

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            CourseAccessProfileLabel("Gender")

            HStack(spacing: 14) {
                CourseAccessGenderButton(
                    courseAccessTitle: "Male",
                    courseAccessIsSelected: courseAccessGender == .male,
                    courseAccessSelectionAction: {
                        courseAccessGender = .male
                    }
                )

                CourseAccessGenderButton(
                    courseAccessTitle: "Female",
                    courseAccessIsSelected: courseAccessGender == .female,
                    courseAccessSelectionAction: {
                        courseAccessGender = .female
                    }
                )
            }
        }
    }
}

private struct CourseAccessGenderButton: View {
    let courseAccessTitle: String
    let courseAccessIsSelected: Bool
    let courseAccessSelectionAction: () -> Void

    var body: some View {
        Button(action: courseAccessSelectionAction) {
            Text(courseAccessTitle)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(courseAccessIsSelected ? .black : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    Group {
                        if courseAccessIsSelected {
                            FairwayStylePalette.fairwaySuccessGreen
                        } else {
                            Color.white.opacity(0.22)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct CourseAccessProfileLabel: View {
    let courseAccessTitle: String

    init(_ courseAccessTitle: String) {
        self.courseAccessTitle = courseAccessTitle
    }

    var body: some View {
        Text(courseAccessTitle)
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(.white)
    }
}

#Preview {
    CourseAccessProfileSetupView(
        courseAccessEmailAddress: "player@example.com",
        courseAccessPassword: "password",
        courseAccessBackAction: {
        },
        courseAccessRegisterSuccessAction: { _ in
        }
    )
}
