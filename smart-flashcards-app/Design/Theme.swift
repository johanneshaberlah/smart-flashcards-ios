import SwiftUI

enum Theme {
    // MARK: - Brand Colors (work in both modes)
    static let emerald600 = Color(hex: "#059669")
    static let emerald500 = Color(hex: "#10B981")

    // MARK: - Amber Colors (for AI features)
    static let amber500 = Color(hex: "#F59E0B")
    static let amber600 = Color(hex: "#D97706")

    // MARK: - Status Colors (used on colored backgrounds)
    static let red500 = Color(hex: "#EF4444")
    static let orange500 = Color(hex: "#F97316")

    // MARK: - Button Tint (used with white text on glass effects)
    static let buttonTintNeutral = Color(hex: "#4B5563")

    // MARK: - Spacing
    static let spacing4: CGFloat = 16
    static let spacing6: CGFloat = 24

    // MARK: - Corner Radius
    static let cornerRadius: CGFloat = 6
}
