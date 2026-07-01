import SwiftUI
import UIKit

struct PutterPebbleLocationPermissionDialog: View {
    let putterPebbleOpenSettingsAction: () -> Void
    let putterPebbleCancelAction: () -> Void

    init(
        putterPebbleOpenSettingsAction: @escaping () -> Void = PutterPebbleLocationPermissionDialog.putterPebbleOpenAppSettings,
        putterPebbleCancelAction: @escaping () -> Void
    ) {
        self.putterPebbleOpenSettingsAction = putterPebbleOpenSettingsAction
        self.putterPebbleCancelAction = putterPebbleCancelAction
    }

    var body: some View {
        GeometryReader { putterPebbleProxy in
            let putterPebbleDialogWidth = min(343, max(0, putterPebbleProxy.size.width - 36))

            ZStack {
                FairwayStylePalette.fairwaySheetMask
                    .ignoresSafeArea()
                    .onTapGesture(perform: putterPebbleCancelAction)

                ZStack(alignment: .topLeading) {
                    Image("EULGO_dialog_bg")
                        .resizable()
                        .frame(width: putterPebbleDialogWidth, height: 252)

                    putterPebbleLocationBadge
                        .offset(x: 18, y: -20)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Location Permission")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(FairwayStylePalette.fairwayTextPrimary)
                            .padding(.top, 34)
                            .padding(.leading, min(102, putterPebbleDialogWidth * 0.30))
                            .padding(.trailing, 22)

                        Text("This app needs access to your location to customize services based on your region. Your location data is used only for this purpose.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.black.opacity(0.64))
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 24)

                        HStack(spacing: 14) {
                            Button(action: putterPebbleCancelAction) {
                                Text("Cancel")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Color(red: 0.68, green: 0.75, blue: 0.77))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                            .buttonStyle(.plain)

                            Button(action: putterPebbleOpenSettingsAction) {
                                Text("Settings")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(FairwayStylePalette.fairwayBrandGradient())
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 2)
                        .padding(.bottom, 22)
                    }
                }
                .frame(width: putterPebbleDialogWidth)
                .transition(
                    .scale(scale: 0.96)
                        .combined(with: .opacity)
                )
            }
            .frame(width: putterPebbleProxy.size.width, height: putterPebbleProxy.size.height)
        }
        .transition(.opacity)
    }

    private var putterPebbleLocationBadge: some View {
        ZStack {
            Circle()
                .fill(FairwayStylePalette.fairwayBrandGradient(startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 72, height: 72)

            Circle()
                .fill(Color.white.opacity(0.22))
                .frame(width: 52, height: 52)

            Image(systemName: "location.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.black)
        }
    }

    private static func putterPebbleOpenAppSettings() {
        guard let putterPebbleSettingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        Task { @MainActor in
            guard UIApplication.shared.canOpenURL(putterPebbleSettingsURL) else {
                return
            }

            await UIApplication.shared.open(putterPebbleSettingsURL)
        }
    }
}

#Preview {
    PutterPebbleLocationPermissionDialog(
        putterPebbleCancelAction: {}
    )
}
