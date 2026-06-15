import PhotosUI
import SwiftUI
import UIKit

struct GreenTeeCreateActivityView: View {
    @State private var greenTeeEventName = ""
    @State private var greenTeeIntroduction = ""
    @State private var greenTeeLocation = ""
    @State private var greenTeeEventDate = Date()
    @State private var greenTeeDurationText = "15:00 - 18:00"
    @State private var greenTeeCoverImage: UIImage?
    @State private var greenTeeCoverAddress = ""
    @State private var greenTeeShowsCoverPicker = false
    @State private var greenTeeIsCreating = false

    let greenTeeBackAction: () -> Void

    var body: some View {
        ZStack {
            CourseAccessAuthBackgroundView()

            VStack(alignment: .leading, spacing: 0) {
                VenueFairwayHeaderView(
                    venueFairwayHeight: 48,
                    venueFairwayHorizontalPadding: 0,
                    venueFairwayLeadingContent: {
                        VenueFairwayHeaderView.venueFairwayBackButton(action: greenTeeBackAction)
                    },
                    venueFairwayCenterContent: {
                        EmptyView()
                    },
                    venueFairwayTrailingContent: {
                        EmptyView()
                    }
                )

                GreenTeeTextFieldSection(
                    greenTeeTitle: "Event Name",
                    greenTeePlaceholder: "Please enter...",
                    greenTeeText: $greenTeeEventName
                )
                .padding(.top, 26)

                Text("Event Cover")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 24)

                Button(action: greenTeeCoverAction) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(FairwayStylePalette.fairwayPanelBackground)

                        if let greenTeeCoverImage {
                            Image(uiImage: greenTeeCoverImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 117, height: 117)
                                .clipped()

                            Color.black.opacity(0.18)

                            Image("EULGO_camera")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .frame(width: 38, height: 38)
                                .background(FairwayStylePalette.fairwayCameraGradient())
                                .clipShape(Circle())
                        } else {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                FairwayStylePalette.fairwayCameraLime,
                                                FairwayStylePalette.fairwayCameraMint
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )

                                Image("EULGO_camera")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                            }
                            .frame(width: 49, height: 49)
                        }
                    }
                    .frame(width: 117, height: 117)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.top, 12)

                Text("Introduction")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 24)

                ZStack(alignment: .topLeading) {
                    if greenTeeIntroduction.isEmpty {
                        Text("Please enter...")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.white.opacity(0.42))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 14)
                    }

                    LawnNoteTransparentTextView(
                        lawnNoteText: $greenTeeIntroduction,
                        lawnNoteInsets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
                    )
                }
                .frame(height: 99)
                .background(FairwayStylePalette.fairwayPanelBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.top, 12)

                GreenTeeScheduleCard(
                    greenTeeEventDate: $greenTeeEventDate,
                    greenTeeDurationText: $greenTeeDurationText,
                    greenTeeLocation: $greenTeeLocation
                )
                    .padding(.top, 14)

                Spacer(minLength: 20)

                Button(action: greenTeeCreateAction) {
                    ZStack {
                        Text("Create")
                            .opacity(greenTeeIsCreating ? 0 : 1)

                        if greenTeeIsCreating {
                            ProgressView()
                                .tint(.black)
                        }
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
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
                .buttonStyle(.plain)
                .disabled(greenTeeIsCreating)
                .opacity(greenTeeIsCreating ? 0.76 : 1)
                .padding(.bottom, 26)
            }
            .padding(.horizontal, 15)
        }
        .sheet(isPresented: $greenTeeShowsCoverPicker) {
            GreenTeeCoverPhotoPickerView { greenTeeImage in
                greenTeeCoverImage = greenTeeImage
                greenTeeCoverAddress = greenTeeStoredCoverAddress(from: greenTeeImage) ?? ""
            }
        }
        .greenPathSwipeBack(greenPathBackAction: greenTeeBackAction)
    }

    private func greenTeeCoverAction() {
        greenTeeShowsCoverPicker = true
    }

    private func greenTeeCreateAction() {
        guard greenTeeIsCreating == false else {
            return
        }

        let greenTeeTrimmedName = greenTeeEventName.trimmingCharacters(in: .whitespacesAndNewlines)
        let greenTeeTrimmedIntroduction = greenTeeIntroduction.trimmingCharacters(in: .whitespacesAndNewlines)
        let greenTeeTrimmedLocation = greenTeeLocation.trimmingCharacters(in: .whitespacesAndNewlines)

        guard greenTeeTrimmedName.isEmpty == false else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please enter event name", style: .error)
            return
        }

        guard greenTeeTrimmedIntroduction.isEmpty == false else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please enter introduction", style: .error)
            return
        }

        guard greenTeeTrimmedLocation.isEmpty == false else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please enter location", style: .error)
            return
        }

        guard let greenTeeCurrentUserID = PlayerBadgeSessionStore.playerBadgeCurrentUserID else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please log in first", style: .error)
            return
        }

        greenTeeIsCreating = true

        let greenTeeActivity = MatchDayActivityModel(
            matchDayPublisherID: greenTeeCurrentUserID,
            matchDayActivityName: greenTeeTrimmedName,
            matchDayCoverAddress: greenTeeCoverAddress,
            matchDayIntroductionText: greenTeeTrimmedIntroduction,
            matchDayDate: greenTeeEventDate,
            matchDayDurationText: greenTeeDurationText,
            matchDayLocation: greenTeeTrimmedLocation,
            matchDayParticipantUserIDs: [greenTeeCurrentUserID]
        )

        if MatchDayActivityStore.matchDayCreateActivity(greenTeeActivity) {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Created", style: .success)
            greenTeeBackAction()
        } else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Create failed", style: .error)
        }

        greenTeeIsCreating = false
    }

    private func greenTeeStoredCoverAddress(from greenTeeImage: UIImage) -> String? {
        guard let greenTeeData = greenTeeImage.jpegData(compressionQuality: 0.88) else {
            return nil
        }

        let greenTeeDirectoryURL = greenTeeUploadsDirectory()
        let greenTeeCoverURL = greenTeeDirectoryURL
            .appendingPathComponent("greenTeeActivityCover-\(UUID().uuidString).jpg")

        do {
            try greenTeeData.write(to: greenTeeCoverURL, options: [.atomic])
            return greenTeeCoverURL.path
        } catch {
            return nil
        }
    }

    private func greenTeeUploadsDirectory() -> URL {
        let greenTeeBaseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let greenTeeDirectoryURL = greenTeeBaseURL.appendingPathComponent("EulgoActivityUploads", isDirectory: true)

        if FileManager.default.fileExists(atPath: greenTeeDirectoryURL.path) == false {
            try? FileManager.default.createDirectory(at: greenTeeDirectoryURL, withIntermediateDirectories: true)
        }

        return greenTeeDirectoryURL
    }
}

private struct GreenTeeCoverPhotoPickerView: UIViewControllerRepresentable {
    let greenTeeSelectionAction: (UIImage) -> Void

    func makeCoordinator() -> GreenTeeCoverPhotoPickerCoordinator {
        GreenTeeCoverPhotoPickerCoordinator(greenTeeSelectionAction: greenTeeSelectionAction)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var greenTeeConfiguration = PHPickerConfiguration(photoLibrary: .shared())
        greenTeeConfiguration.filter = .images
        greenTeeConfiguration.selectionLimit = 1

        let greenTeePicker = PHPickerViewController(configuration: greenTeeConfiguration)
        greenTeePicker.delegate = context.coordinator
        return greenTeePicker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
}

private final class GreenTeeCoverPhotoPickerCoordinator: NSObject, PHPickerViewControllerDelegate {
    let greenTeeSelectionAction: (UIImage) -> Void

    init(greenTeeSelectionAction: @escaping (UIImage) -> Void) {
        self.greenTeeSelectionAction = greenTeeSelectionAction
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let greenTeeProvider = results.first?.itemProvider,
              greenTeeProvider.canLoadObject(ofClass: UIImage.self) else {
            return
        }

        greenTeeProvider.loadObject(ofClass: UIImage.self) { [greenTeeSelectionAction] greenTeeObject, _ in
            guard let greenTeeImage = greenTeeObject as? UIImage else {
                return
            }

            DispatchQueue.main.async {
                greenTeeSelectionAction(greenTeeImage)
            }
        }
    }
}

private struct GreenTeeTextFieldSection: View {
    let greenTeeTitle: String
    let greenTeePlaceholder: String
    @Binding var greenTeeText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(greenTeeTitle)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            TextField("", text: $greenTeeText, prompt: Text(greenTeePlaceholder).foregroundColor(.white.opacity(0.42)))
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.white)
                .tint(.white)
                .textInputAutocapitalization(.words)
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(FairwayStylePalette.fairwayPanelBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

private struct GreenTeeScheduleCard: View {
    @Binding var greenTeeEventDate: Date
    @Binding var greenTeeDurationText: String
    @Binding var greenTeeLocation: String

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 0) {
                GreenTeeDatePickerButton(
                    greenTeeIconName: "calendar",
                    greenTeeDate: $greenTeeEventDate
                )

                Spacer()

                GreenTeeDurationMenuButton(
                    greenTeeIconName: "clock.fill",
                    greenTeeDurationText: $greenTeeDurationText
                )
            }

            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 20)

                TextField("", text: $greenTeeLocation, prompt: Text("Please enter...").foregroundColor(Color.black.opacity(0.28)))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.black)
                    .tint(.black)
                    .padding(.horizontal, 13)
                    .frame(height: 40)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.72, green: 0.96, blue: 0.32),
                    Color(red: 1.0, green: 0.97, blue: 0.73)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}

private struct GreenTeeDatePickerButton: View {
    let greenTeeIconName: String
    @Binding var greenTeeDate: Date

    var body: some View {
        ZStack {
            HStack(spacing: 6) {
                Image(systemName: greenTeeIconName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.black)

                Text(Self.greenTeeDateFormatter.string(from: greenTeeDate))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 9)
            .frame(height: 32)
            .background(Color.white.opacity(0.30))
            .clipShape(Capsule())

            DatePicker("", selection: $greenTeeDate, in: Date()..., displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.compact)
                .tint(.black)
                .opacity(0.01)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
    }

    private static let greenTeeDateFormatter: DateFormatter = {
        let greenTeeFormatter = DateFormatter()
        greenTeeFormatter.locale = Locale(identifier: "en_US_POSIX")
        greenTeeFormatter.dateFormat = "EEE, d MMM yyyy"
        return greenTeeFormatter
    }()
}

private struct GreenTeeDurationMenuButton: View {
    let greenTeeIconName: String
    @Binding var greenTeeDurationText: String

    private let greenTeeDurationOptions = [
        "08:00 - 11:00",
        "09:00 - 12:00",
        "13:00 - 16:00",
        "15:00 - 18:00",
        "18:00 - 20:00"
    ]

    var body: some View {
        Menu {
            ForEach(greenTeeDurationOptions, id: \.self) { greenTeeOption in
                Button(greenTeeOption) {
                    greenTeeDurationText = greenTeeOption
                }
            }
        } label: {
            HStack(spacing: 7) {
                Image(systemName: greenTeeIconName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.black)

                Text(greenTeeDurationText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.black)
                    .lineLimit(1)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.black)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GreenTeeCreateActivityView {
    }
    .fairwayGreenDismissKeyboardOnTap()
}
