import SwiftUI

struct CaddieGuardReportSheetPresenter: ViewModifier {
    @Binding var caddieGuardIsPresented: Bool
    let caddieGuardTargetUserID: String?
    let caddieGuardBlockSuccessAction: () -> Void

    func body(content: Content) -> some View {
        ZStack {
            content

            if caddieGuardIsPresented {
                FairwayStylePalette.fairwaySheetMask
                    .ignoresSafeArea()
                    .onTapGesture {
                        caddieGuardIsPresented = false
                    }
                    .zIndex(98)

                VStack {
                    Spacer()

                    MarshalFlagReportBlockSheet(
                        marshalFlagTargetUserID: caddieGuardTargetUserID,
                        marshalFlagReportAction: {
                        },
                        marshalFlagBlockSuccessAction: caddieGuardBlockSuccessAction,
                        marshalFlagCancelAction: {
                            caddieGuardIsPresented = false
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(99)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: caddieGuardIsPresented)
    }
}

extension View {
    func caddieGuardReportSheet(
        caddieGuardIsPresented: Binding<Bool>,
        caddieGuardTargetUserID: String?,
        caddieGuardBlockSuccessAction: @escaping () -> Void = {}
    ) -> some View {
        modifier(
            CaddieGuardReportSheetPresenter(
                caddieGuardIsPresented: caddieGuardIsPresented,
                caddieGuardTargetUserID: caddieGuardTargetUserID,
                caddieGuardBlockSuccessAction: caddieGuardBlockSuccessAction
            )
        )
    }
}
