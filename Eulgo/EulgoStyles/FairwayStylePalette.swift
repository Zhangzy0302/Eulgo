import SwiftUI

enum FairwayStylePalette {
    static let fairwayLime = Color(red: 0.72, green: 0.95, blue: 0.28)
    static let fairwayMint = Color(red: 0.14, green: 0.81, blue: 0.72)
    static let fairwaySoftLime = Color(red: 0.68, green: 0.94, blue: 0.22)
    static let fairwaySoftMint = Color(red: 0.18, green: 0.82, blue: 0.76)
    static let fairwayCameraLime = Color(red: 0.70, green: 0.95, blue: 0.24)
    static let fairwayCameraMint = Color(red: 0.20, green: 0.84, blue: 0.75)
    static let fairwayLinkGreen = Color(red: 0.58, green: 0.96, blue: 0.31)
    static let fairwaySuccessGreen = Color(red: 0.42, green: 0.94, blue: 0.42)
    static let fairwayLikePink = Color(red: 1.0, green: 0.24, blue: 0.61)
    static let fairwayAlertRed = Color(red: 1.0, green: 0.20, blue: 0.10)
    static let fairwayStarOrange = Color(red: 1.0, green: 0.73, blue: 0.10)
    static let fairwayScoreCream = Color(red: 0.99, green: 0.97, blue: 0.78)
    static let fairwayWarmCream = Color(red: 1.0, green: 0.97, blue: 0.73)
    static let fairwayEULACream = Color(red: 245 / 255, green: 241 / 255, blue: 206 / 255)
    static let fairwayCoinYellow = Color(red: 0.98, green: 0.87, blue: 0.15)
    static let fairwayTextPrimary = Color(red: 0.14, green: 0.14, blue: 0.14)
    static let fairwayTextSecondary = Color(red: 0.24, green: 0.24, blue: 0.24)

    static let fairwayHeaderControlBackground = Color.white.opacity(0.20)
    static let fairwayPanelBackground = Color.white.opacity(0.28)
    static let fairwayFocusedPanelBackground = Color.white.opacity(0.36)
    static let fairwaySubtlePanelBackground = Color.white.opacity(0.18)
    static let fairwaySegmentBackground = Color.white.opacity(0.24)
    static let fairwayPlaceholderWhite = Color.white.opacity(0.42)
    static let fairwayInputPlaceholderWhite = Color.white.opacity(0.36)
    static let fairwaySheetMask = Color.black.opacity(0.58)
    static let fairwayInputBarBackground = Color(red: 23 / 255, green: 23 / 255, blue: 23 / 255)
    static let fairwayCardBlack = Color.black.opacity(0.86)

    static func fairwayBrandGradient(
        startPoint: UnitPoint = .leading,
        endPoint: UnitPoint = .trailing
    ) -> LinearGradient {
        LinearGradient(
            colors: [fairwayLime, fairwayMint],
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    static func fairwayActionGradient(
        startPoint: UnitPoint = .leading,
        endPoint: UnitPoint = .trailing
    ) -> LinearGradient {
        LinearGradient(
            colors: [fairwaySoftLime, fairwaySoftMint],
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    static func fairwayCameraGradient(
        startPoint: UnitPoint = .leading,
        endPoint: UnitPoint = .trailing
    ) -> LinearGradient {
        LinearGradient(
            colors: [fairwayCameraLime, fairwayCameraMint],
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    static func fairwayCreamGradient(
        startPoint: UnitPoint = .leading,
        endPoint: UnitPoint = .trailing
    ) -> LinearGradient {
        LinearGradient(
            colors: [fairwayLime, fairwayWarmCream],
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}
