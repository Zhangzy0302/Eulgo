import SwiftUI

struct FairwayAccountDeleteAlertView: View {
    @State private var fairwayAccountCardAppeared = false

    let fairwayAccountCancelAction: () -> Void
    let fairwayAccountConfirmAction: () -> Void

    var body: some View {
        GeometryReader { fairwayAccountProxy in
            let fairwayAccountDialogWidth = min(343, max(0, fairwayAccountProxy.size.width - 32))

            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.62))
                    .ignoresSafeArea()

                ZStack(alignment: .topLeading) {
                    Image("EULGO_dialog_bg")
                        .resizable()
                        .frame(width: fairwayAccountDialogWidth, height: 180)

                    Image("EULGO_delete_account")
                        .resizable()
                        .frame(width: 68, height: 68)
                        .padding(.leading, 18)

                    HStack(alignment: .top, spacing: 18) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Deleting the account will clear the account data. Are you sure to delete?")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(FairwayStylePalette.fairwayTextPrimary)
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.leading, min(98, fairwayAccountDialogWidth * 0.29))
                                .padding(.trailing, 20)

                            HStack(spacing: 14) {
                                Button(action: fairwayAccountCancelAction) {
                                    Text("Cancel")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(Color(red: 0.66, green: 0.73, blue: 0.77))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 52)
                                        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }
                                .buttonStyle(.plain)

                                Button(action: fairwayAccountConfirmAction) {
                                    Text("Confirm")
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
                        }
                    }
                    .padding(.top, 25)
                    .padding(.bottom, 18)
                }
                .frame(width: fairwayAccountDialogWidth)
                .scaleEffect(fairwayAccountCardAppeared ? 1 : 0.94)
                .opacity(fairwayAccountCardAppeared ? 1 : 0)
            }
            .frame(width: fairwayAccountProxy.size.width, height: fairwayAccountProxy.size.height)
        }
        .onAppear {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                fairwayAccountCardAppeared = true
            }
        }
    }
}

#Preview {
    FairwayAccountDeleteAlertView {
    } fairwayAccountConfirmAction: {
    }
}
