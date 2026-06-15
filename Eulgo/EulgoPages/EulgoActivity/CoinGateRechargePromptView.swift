import SwiftUI

struct CoinGateRechargePromptView: View {
    let coinGateOKAction: () -> Void
    let coinGateRechargeAction: () -> Void

    var body: some View {
        GeometryReader { coinGateProxy in
            let coinGateDialogWidth = min(343, max(0, coinGateProxy.size.width - 36))

            ZStack {
                FairwayStylePalette.fairwaySheetMask
                    .ignoresSafeArea()
                    .onTapGesture(perform: coinGateOKAction)

                ZStack(alignment: .topLeading) {
                    Image("EULGO_dialog_bg")
                        .resizable()
                        .frame(width: coinGateDialogWidth, height: 184)

                    Image("EULGO_coin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 78, height: 78)
                        .offset(x: 16, y: -22)

                    VStack(alignment: .leading, spacing: 26) {
                        Text("Sorry, your current balance is insufficient")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(FairwayStylePalette.fairwayTextPrimary)
                            .lineSpacing(3)
                            .padding(.top, 40)
                            .padding(.leading, min(98, coinGateDialogWidth * 0.29))
                            .padding(.trailing, 26)

                        HStack(spacing: 16) {
                            Button(action: coinGateOKAction) {
                                Text("OK")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Color(red: 0.68, green: 0.75, blue: 0.77))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 58)
                                    .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                            .buttonStyle(.plain)

                            Button(action: coinGateRechargeAction) {
                                Text("Recharge")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 58)
                                    .background(FairwayStylePalette.fairwayBrandGradient())
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 26)
                        .padding(.bottom, 22)
                    }
                }
                .frame(width: coinGateDialogWidth)
            }
            .frame(width: coinGateProxy.size.width, height: coinGateProxy.size.height)
        }
    }
}

#Preview {
    ZStack {
        CourseAccessAuthBackgroundView()
        CoinGateRechargePromptView(
            coinGateOKAction: {
            },
            coinGateRechargeAction: {
            }
        )
    }
}
