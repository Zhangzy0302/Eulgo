import SwiftUI

struct CaddieBridgeChatReminderView: View {
    let caddieBridgeConfirmAction: () -> Void

    var body: some View {
        GeometryReader { caddieBridgeProxy in
            let caddieBridgeDialogWidth = min(343, max(0, caddieBridgeProxy.size.width - 36))

            ZStack {
                FairwayStylePalette.fairwaySheetMask
                    .ignoresSafeArea()
                    .onTapGesture(perform: caddieBridgeConfirmAction)

                ZStack(alignment: .topLeading) {
                    Image("EULGO_chat_reminder_bg")
                        .resizable()
                        .frame(width: caddieBridgeDialogWidth, height: 220)

                    VStack(spacing: 0) {
                        VStack(spacing: 14) {
                            Text("Reminder")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(FairwayStylePalette.fairwayTextPrimary)
                                .padding(.top, 32)

                            Text("To send messages, please follow each other\nfirst. Once they follow you back, you can begin\nyour conversation.")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(.black.opacity(0.64))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .minimumScaleFactor(0.9)

                            Button(action: caddieBridgeConfirmAction) {
                                Text("Got it")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(FairwayStylePalette.fairwayBrandGradient())
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                            .padding(.top, 6)
                            .padding(.bottom, 18)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 26)
                    }
                }
                .frame(width: caddieBridgeDialogWidth)
            }
            .frame(width: caddieBridgeProxy.size.width, height: caddieBridgeProxy.size.height)
        }
    }
}


#Preview {
    ZStack {
        CourseAccessAuthBackgroundView()
        CaddieBridgeChatReminderView {
        }
    }
}
