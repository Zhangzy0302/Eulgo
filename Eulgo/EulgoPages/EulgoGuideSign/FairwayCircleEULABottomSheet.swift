import SwiftUI
import UIKit

private enum FairwayCircleEULACipher {
    static func fairwayCircleDecode(_ fairwayCircleValue: String) -> String {
        let fairwayCircleScalars = fairwayCircleValue.unicodeScalars.compactMap { fairwayCircleScalar in
            UnicodeScalar(fairwayCircleScalar.value - 1)
        }

        return String(String.UnicodeScalarView(fairwayCircleScalars))
    }
}

struct FairwayCircleEULABottomSheet: View {
    let fairwayCircleGotItAction: () -> Void
    private let fairwayCircleProhibitedContentItems = [
        FairwayCircleEULACipher.fairwayCircleDecode("Ibuf!tqffdi-!bcvtf-!ibsbttnfou-!ps!qfstpobm!buubdlt<"),
        FairwayCircleEULACipher.fairwayCircleDecode("Qpsophsbqijd-!fyqmjdju-!ps!wvmhbs!dpoufou<"),
        FairwayCircleEULACipher.fairwayCircleDecode("Dpoufou!uibu!qspnpuft!wjpmfodf-!ejtdsjnjobujpo-!jmmfhbm!bdujwjujft-!ps!wjpmbujpot!pg!uif!sjhiut!pg!puifst<"),
        FairwayCircleEULACipher.fairwayCircleDecode("Boz!dpoufou!uibu!epft!opu!gju!uif!dpnnvojuz!bunptqifsf!ps!wjpmbuft!qvcmjd!psefs!boe!hppe!dvtupnt/")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.black.opacity(0.08))
                .frame(width: 42, height: 4)
                .padding(.top, 10)
                .opacity(0)

            VStack(spacing: 18) {
                Text(FairwayCircleEULACipher.fairwayCircleDecode("FVMB"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(FairwayStylePalette.fairwayTextPrimary)
                    .padding(.top, 4)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        FairwayCircleEULATextBlock(FairwayCircleEULACipher.fairwayCircleDecode("Foe!Vtfs!Mjdfotf!Bhsffnfou!)FVMB*"))

                        FairwayCircleEULATextBlock(FairwayCircleEULACipher.fairwayCircleDecode("Uijt!Foe!Vtfs!Mjdfotf!Bhsffnfou!)FVMB*!hpwfsot!zpvs!vtf!pg!uif!Fvmhp!Bqqmjdbujpo/!Cz!epxompbejoh-!bddfttjoh-!ps!vtjoh!uif!Bqq-!zpv!bhsff!up!cf!cpvoe!cz!uijt!Bhsffnfou/!Jg!zpv!ep!opu!bhsff!up!uiftf!ufsnt-!zpv!nbz!opu!vtf!uijt!bqqmjdbujpo/"))

                        FairwayCircleEULASectionTitle(FairwayCircleEULACipher.fairwayCircleDecode("2/!Rvbmjgjdbujpot"))

                        FairwayCircleEULATextBlock(FairwayCircleEULACipher.fairwayCircleDecode("Cz!vtjoh!uif!Fvmhp!Bqq!)uif!#Bqq#*-!zpv!dpogjsn!uibu!zpv!bsf!bu!mfbtu!29!zfbst!pg!bhf/!Zpv!bhsff!up!qspwjef!usvf!boe!bddvsbuf!bhf!jogpsnbujpo!evsjoh!sfhjtusbujpo!ps!vtf/!Jg!zpv!bsf!voefs!uif!bhf!pg!29-!zpv!offe!uif!fyqsftt!dpotfou!pg!b!qbsfou!ps!mfhbm!hvbsejbo!up!vtf!uif!Bqq/"))

                        FairwayCircleEULASectionTitle(FairwayCircleEULACipher.fairwayCircleDecode("3/!Vtfs!Hfofsbufe!Dpoufou"))

                        FairwayCircleEULATextBlock(FairwayCircleEULACipher.fairwayCircleDecode("Uijt!bqq!bmmpxt!vtfst!up!qptu!boe!tibsf!dpoufou-!jodmvejoh!cvu!opu!mjnjufe!up!wjefpt-!qjduvsft-!boe!ufyu/"))

                        FairwayCircleEULATextBlock(FairwayCircleEULACipher.fairwayCircleDecode("Cz!qptujoh!dpoufou-!zpv!bhsff!up!uif!gpmmpxjoh!ufsnt;"))

                        FairwayCircleEULATextBlock(FairwayCircleEULACipher.fairwayCircleDecode("Qspijcjufe!Dpoufou;!Zpv!nbz!opu!qptu!boz!dpoufou!uibu!jt!pggfotjwf-!ibsngvm-!ps!jmmfhbm-!jodmvejoh!cvu!opu!mjnjufe!up;"))

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(fairwayCircleProhibitedContentItems, id: \.self) { fairwayCircleProhibitedContentItem in
                                FairwayCircleEULATextBlock(FairwayCircleEULACipher.fairwayCircleDecode(".!") + fairwayCircleProhibitedContentItem)
                            }
                        }

                        FairwayCircleEULATextBlock(FairwayCircleEULACipher.fairwayCircleDecode("Dpoufou!Mjdfotjoh;!Zpv!sfubjo!pxofstijq!pg!uif!dpoufou!qptufe-!cvu!cz!qptujoh-!zpv!hsbou!Fvmhp!b!opo.fydmvtjwf!mjdfotf!up!vtf-!ejtusjcvuf-!boe!ejtqmbz!uif!dpoufou!xjuijo!uif!Bqq/"))

                        FairwayCircleEULASectionTitle(FairwayCircleEULACipher.fairwayCircleDecode("4/!Sfqpsujoh!boe!Sftqpotf!Nfdibojtn"))

                        FairwayCircleEULASubsectionTitle(FairwayCircleEULACipher.fairwayCircleDecode("4/2!Zpvs!Sftqpotjcjmjujft"))

                        FairwayCircleEULATextBlock(FairwayCircleEULACipher.fairwayCircleDecode("Jg!zpv!cfdpnf!bxbsf!pg!vtfs!dpoufou!uibu!wjpmbuft!uijt!FVMB-!zpv!bhsff!up!sfqpsu!ju!jnnfejbufmz!uispvhi!Fvmhp(t!sfqpsujoh!nfdibojtn/"))

                        FairwayCircleEULASubsectionTitle(FairwayCircleEULACipher.fairwayCircleDecode("4/3!Pvs!Sftqpotf"))

                        FairwayCircleEULATextBlock(FairwayCircleEULACipher.fairwayCircleDecode("Xf!xjmm!sfwjfx!uif!sfqpsufe!dpoufou!xjuijo!35!ipvst!boe!ublf!bqqspqsjbuf!nfbtvsft-!jodmvejoh!cvu!opu!mjnjufe!up!sfnpwjoh!uif!pggfoejoh!dpoufou-!xbsojoh!ps!cboojoh!uif!pggfoejoh!vtfs/!Vtfst!xip!sfqfbufemz!wjpmbuf!uif!svmft!nbz!gbdf!qfsnbofou!tvtqfotjpo/"))

                        FairwayCircleEULASectionTitle(FairwayCircleEULACipher.fairwayCircleDecode("5/!Qsjwbdz!Qpmjdz"))

                        FairwayCircleEULATextBlock(FairwayCircleEULACipher.fairwayCircleDecode("Cz!vtjoh!uif!Bqq-!zpv!bdlopxmfehf!uibu!zpv!ibwf!sfbe!boe!voefstuppe!pvs!Qsjwbdz!Qpmjdz-!xijdi!efubjmt!ipx!xf!dpmmfdu-!vtf-!boe!qspufdu!zpvs!qfstpobm!jogpsnbujpo/"))

                        FairwayCircleEULASectionTitle(FairwayCircleEULACipher.fairwayCircleDecode("6/!Ufsnjobujpo"))

                        FairwayCircleEULATextBlock(FairwayCircleEULACipher.fairwayCircleDecode("Xf!nbz!ufsnjobuf!ps!tvtqfoe!zpvs!bddftt!up!Fvmhp!bu!boz!ujnf!gps!boz!sfbtpo-!xjui!ps!xjuipvu!qsjps!opujdf/!Zpv!dbo!bmtp!tupq!vtjoh!Fvmhp!boe!efmfuf!zpvs!bddpvou!bu!boz!ujnf/"))

                        FairwayCircleEULASectionTitle(FairwayCircleEULACipher.fairwayCircleDecode("7/!Npejgjdbujpo!pg!uif!Bhsffnfou"))

                        FairwayCircleEULATextBlock(FairwayCircleEULACipher.fairwayCircleDecode("Xf!nbz!bnfoe!uijt!Bhsffnfou!bu!boz!ujnf/!Dibohft!xjmm!cf!boopvodfe!jo!uif!Bqq-!boe!zpvs!dpoujovfe!vtf!pg!uif!Bqq!nfbot!zpvs!bddfqubodf!pg!uif!sfwjtfe!ufsnt/"))

                        FairwayCircleEULASectionTitle(FairwayCircleEULACipher.fairwayCircleDecode("8/!Ejtdmbjnfs"))

                        FairwayCircleEULATextBlock(FairwayCircleEULACipher.fairwayCircleDecode("Fvmhp!jt!qspwjefe!#BT!JT#!xjuipvu!xbssboujft!pg!boz!ljoe-!fyqsftt!ps!jnqmjfe/!Xf!ep!opu!hvbsbouff!uibu!uif!bqqmjdbujpo!xjmm!bmxbzt!cf!joufssvqujpo.gsff-!fssps.gsff-!ps!dpnqmfufmz!tfdvsf/"))

                        FairwayCircleEULASectionTitle(FairwayCircleEULACipher.fairwayCircleDecode("9/!Mjnjubujpo!pg!Mjbcjmjuz"))

                        FairwayCircleEULATextBlock(FairwayCircleEULACipher.fairwayCircleDecode("Up!uif!gvmmftu!fyufou!qfsnjuufe!cz!mbx-!xf!bsf!opu!mjbcmf!gps!boz!ebnbhf!dbvtfe!cz!zpvs!vtf!pg!Fvmhp/"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 308)

                Button(action: fairwayCircleGotItAction) {
                    Text(FairwayCircleEULACipher.fairwayCircleDecode("Hpu!ju"))
                        .font(.system(size: 16, weight: .bold))
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
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 34)
            .padding(.bottom, 22)
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    .white,
                    FairwayStylePalette.fairwayEULACream
                ],
                startPoint: .bottom,
                endPoint: .top
            )
        )
        .clipShape(FairwayCircleTopRoundedSheetShape(radius: 28))
        .ignoresSafeArea()
    }
}

private struct FairwayCircleEULASectionTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color(red: 0.20, green: 0.20, blue: 0.20))
    }
}

private struct FairwayCircleEULASubsectionTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(FairwayStylePalette.fairwayTextSecondary)
    }
}

private struct FairwayCircleEULATextBlock: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .regular))
            .foregroundStyle(Color(red: 0.30, green: 0.30, blue: 0.30))
            .lineSpacing(3)
    }
}

private struct FairwayCircleTopRoundedSheetShape: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let fairwayCirclePath = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )

        return Path(fairwayCirclePath.cgPath)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color.black.opacity(0.35)
            .ignoresSafeArea()

        FairwayCircleEULABottomSheet {
        }
    }
}
