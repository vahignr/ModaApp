import SwiftUI

struct ModernTheme {
    // MARK: - Sage Garden Color Palette
    // Natural and calming colors for sustainable fashion
    
    // Primary Colors
    static let primary = Color(hex: "87A96B")         // Sage Green - Main brand color
    static let secondary = Color(hex: "F4A460")       // Sandy Brown - Warm accent
    static let tertiary = Color(hex: "C1D8C3")        // Light Sage - Soft accent
    static let accent = Color(hex: "A8C09A")          // Medium Sage - Additional accent
    
    // Neutral Colors
    static let background = Color(hex: "F7FFF7")      // Very Light Mint - App background
    static let surface = Color(hex: "FFFFFF")         // Pure White - Cards and surfaces
    static let textPrimary = Color(hex: "3E4E3C")     // Dark Forest Green - Main text
    static let textSecondary = Color(hex: "5C6E58")   // Medium Forest - Secondary text
    static let textTertiary = Color(hex: "8B9D83")    // Sage Gray - Disabled/hint text
    
    // Semantic Colors (keeping natural tones)
    static let success = Color(hex: "6B8E23")         // Olive Green - Success states
    static let warning = Color(hex: "DAA520")         // Goldenrod - Warning states
    static let error = Color(hex: "CD5C5C")           // Indian Red - Error states
    static let info = Color(hex: "7B9BA6")            // Grayish Blue - Info states
    
    // Additional Sage Garden Colors
    static let lightSage = Color(hex: "E8F3E8")       // Very light sage for backgrounds
    static let darkSage = Color(hex: "556B2F")        // Dark olive for emphasis
    static let cream = Color(hex: "FFF8DC")           // Cornsilk cream for warmth
    static let sand = Color(hex: "F5DEB3")            // Wheat color for accents
    
    // MARK: - Gradient Presets
    static let primaryGradient = LinearGradient(
        colors: [primary, primary.opacity(0.85)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let secondaryGradient = LinearGradient(
        colors: [secondary, secondary.opacity(0.85)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let sageGradient = LinearGradient(
        colors: [primary, tertiary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let naturalGradient = LinearGradient(
        colors: [Color(hex: "87A96B"), Color(hex: "C1D8C3"), Color(hex: "F4A460").opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [Color.white, Color(hex: "F7FFF7")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // MARK: - Typography
    struct Typography {
        // Using rounded design for a friendly, approachable feel
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 20, weight: .medium, design: .rounded)
        static let body = Font.system(size: 16, weight: .regular, design: .rounded)
        static let callout = Font.system(size: 15, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .rounded)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xl: CGFloat = 24
        static let full: CGFloat = 9999
    }
    
    // MARK: - Shadows (softer for natural theme)
    struct Shadow {
        static let small = (color: Color(hex: "87A96B").opacity(0.08), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let medium = (color: Color(hex: "87A96B").opacity(0.12), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let large = (color: Color(hex: "87A96B").opacity(0.16), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
        static let colored = (color: primary.opacity(0.25), radius: CGFloat(12), x: CGFloat(0), y: CGFloat(6))
    }
}

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    var isElevated: Bool = true
    
    func body(content: Content) -> some View {
        content
            .background(ModernTheme.surface)
            .cornerRadius(ModernTheme.CornerRadius.large)
            .if(isElevated) { view in
                view.shadow(
                    color: ModernTheme.Shadow.medium.color,
                    radius: ModernTheme.Shadow.medium.radius,
                    x: ModernTheme.Shadow.medium.x,
                    y: ModernTheme.Shadow.medium.y
                )
            }
    }
}

struct PrimaryButtonStyle: ViewModifier {
    var isEnabled: Bool = true
    
    func body(content: Content) -> some View {
        content
            .font(ModernTheme.Typography.headline)
            .foregroundColor(.white)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isEnabled {
                        ModernTheme.primaryGradient
                    } else {
                        ModernTheme.textTertiary.opacity(0.3)
                    }
                }
            )
            .cornerRadius(ModernTheme.CornerRadius.full)
            .shadow(
                color: isEnabled ? ModernTheme.Shadow.colored.color : Color.clear,
                radius: ModernTheme.Shadow.colored.radius,
                x: ModernTheme.Shadow.colored.x,
                y: ModernTheme.Shadow.colored.y
            )
            .scaleEffect(isEnabled ? 1.0 : 0.98)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isEnabled)
    }
}

struct SecondaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(ModernTheme.Typography.body)
            .foregroundColor(ModernTheme.primary)
            .padding(.horizontal, ModernTheme.Spacing.lg)
            .padding(.vertical, ModernTheme.Spacing.sm)
            .background(
                Capsule()
                    .stroke(ModernTheme.primary, lineWidth: 2)
            )
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle(isElevated: Bool = true) -> some View {
        modifier(CardStyle(isElevated: isElevated))
    }
    
    func primaryButtonStyle(isEnabled: Bool = true) -> some View {
        modifier(PrimaryButtonStyle(isEnabled: isEnabled))
    }
    
    func secondaryButtonStyle() -> some View {
        modifier(SecondaryButtonStyle())
    }
    
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
