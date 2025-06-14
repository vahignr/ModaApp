import SwiftUI

struct ModernTheme {
    // MARK: - Midnight Luxe Color Palette
    // Luxury fashion colors with deep blacks and metallic accents
    
    // Primary Colors
    static let primary = Color(hex: "E8B4B8")         // Rose Gold - Main luxury accent
    static let secondary = Color(hex: "D4AF37")       // Champagne Gold - Secondary accent
    static let tertiary = Color(hex: "F5E6E8")        // Blush Pink - Soft accent
    static let accent = Color(hex: "C9A961")          // Antique Gold - Additional accent
    
    // Neutral Colors
    static let background = Color(hex: "000000")      // Pure Black - App background
    static let surface = Color(hex: "1C1C1E")         // Rich Charcoal - Cards and surfaces
    static let textPrimary = Color(hex: "FFFFFF")     // Pure White - Main text
    static let textSecondary = Color(hex: "EBEBF5").opacity(0.6)   // Soft White - Secondary text
    static let textTertiary = Color(hex: "EBEBF5").opacity(0.3)    // Muted White - Disabled/hint text
    
    // Semantic Colors (luxury tones)
    static let success = Color(hex: "34C759")         // Emerald Green - Success states
    static let warning = Color(hex: "FFD60A")         // Gold - Warning states
    static let error = Color(hex: "FF453A")           // Ruby Red - Error states
    static let info = Color(hex: "64D2FF")            // Diamond Blue - Info states
    
    // Additional Luxury Colors
    static let lightSage = Color(hex: "2C2C2E")       // Dark gray for subtle backgrounds
    static let darkSage = Color(hex: "3A3A3C")        // Medium dark gray for emphasis
    static let cream = Color(hex: "F2F2F7").opacity(0.1)  // Translucent white for overlays
    static let sand = Color(hex: "48484A")            // Dark gray for accents
    
    // MARK: - Gradient Presets
    static let primaryGradient = LinearGradient(
        colors: [primary, primary.opacity(0.7), secondary.opacity(0.5)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let secondaryGradient = LinearGradient(
        colors: [secondary, secondary.opacity(0.8), primary.opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let sageGradient = LinearGradient(
        colors: [surface, darkSage],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let naturalGradient = LinearGradient(
        colors: [Color(hex: "1C1C1E"), Color(hex: "000000")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let cardGradient = LinearGradient(
        colors: [surface, surface.opacity(0.8)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Luxury Animated Gradient
    static let luxuryGradient = LinearGradient(
        colors: [
            primary.opacity(0.8),
            secondary.opacity(0.6),
            primary.opacity(0.4),
            secondary.opacity(0.8)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Glass Morphism Gradient
    static let glassGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.1),
            Color.white.opacity(0.05)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Typography
    struct Typography {
        // Luxury typography with refined weights and elegant serif options
        static let largeTitle = Font.system(size: 40, weight: .thin, design: .serif)
        static let title = Font.system(size: 32, weight: .light, design: .serif)
        static let title2 = Font.system(size: 26, weight: .regular, design: .default)
        static let headline = Font.system(size: 22, weight: .medium, design: .default)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let callout = Font.system(size: 16, weight: .regular, design: .default)
        static let caption = Font.system(size: 13, weight: .regular, design: .default)
        static let caption2 = Font.system(size: 12, weight: .light, design: .default)
        
        // Additional luxury text styles
        static let heroTitle = Font.system(size: 48, weight: .ultraLight, design: .serif)
        static let displayText = Font.system(size: 36, weight: .thin, design: .serif)
        static let elegantBody = Font.system(size: 18, weight: .light, design: .serif)
        static let finePrint = Font.system(size: 11, weight: .light, design: .default)
        static let buttonText = Font.system(size: 18, weight: .medium, design: .default)
        static let navText = Font.system(size: 16, weight: .semibold, design: .default)
        
        // Letter spacing for luxury feel
        static func withTracking(_ font: Font, _ tracking: CGFloat) -> some View {
            Text("").font(font).tracking(tracking)
        }
    }
    
    // MARK: - Spacing (more generous for luxury feel)
    struct Spacing {
        static let xxs: CGFloat = 6
        static let xs: CGFloat = 10
        static let sm: CGFloat = 16
        static let md: CGFloat = 20
        static let lg: CGFloat = 32
        static let xl: CGFloat = 40
        static let xxl: CGFloat = 56
        static let xxxl: CGFloat = 72
    }
    
    // MARK: - Corner Radius (slightly increased for modern feel)
    struct CornerRadius {
        static let small: CGFloat = 10
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let xl: CGFloat = 28
        static let full: CGFloat = 9999
    }
    
    // MARK: - Shadows (darker and more dramatic)
    struct Shadow {
        static let small = (color: Color.black.opacity(0.25), radius: CGFloat(6), x: CGFloat(0), y: CGFloat(2))
        static let medium = (color: Color.black.opacity(0.35), radius: CGFloat(12), x: CGFloat(0), y: CGFloat(4))
        static let large = (color: Color.black.opacity(0.45), radius: CGFloat(20), x: CGFloat(0), y: CGFloat(8))
        static let colored = (color: primary.opacity(0.4), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(6))
        static let glow = (color: primary.opacity(0.6), radius: CGFloat(24), x: CGFloat(0), y: CGFloat(0))
    }
    
    // MARK: - Glass Morphism Helpers
    static func glassBackground(opacity: Double = 0.15) -> some View {
        RoundedRectangle(cornerRadius: CornerRadius.large)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(opacity),
                        Color.white.opacity(opacity * 0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.large)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
    }
    
    // MARK: - Blur Effects
    static let glassBlur: CGFloat = 20
    static let backgroundBlur: CGFloat = 80
    
    // MARK: - Animation Durations
    static let quickAnimation: Double = 0.2
    static let normalAnimation: Double = 0.3
    static let slowAnimation: Double = 0.5
    static let luxuryAnimation: Double = 0.8
}

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    var isElevated: Bool = true
    
    func body(content: Content) -> some View {
        content
            .background(
                ModernTheme.glassBackground(opacity: 0.1)
                    .background(
                        ModernTheme.surface.opacity(0.7)
                    )
            )
            .background(.ultraThinMaterial.opacity(0.5))
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
            .font(ModernTheme.Typography.buttonText)
            .tracking(1.2) // Letter spacing for luxury
            .foregroundColor(.white)
            .frame(height: 60) // Increased height for premium feel
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isEnabled {
                        ModernTheme.primaryGradient
                            .overlay(
                                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.full)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.3),
                                                Color.white.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 0.5
                                    )
                            )
                    } else {
                        Color.white.opacity(0.1)
                    }
                }
            )
            .cornerRadius(ModernTheme.CornerRadius.full)
            .shadow(
                color: isEnabled ? ModernTheme.primary.opacity(0.5) : Color.clear,
                radius: isEnabled ? 20 : 0,
                x: 0,
                y: isEnabled ? 10 : 0
            )
            .scaleEffect(isEnabled ? 1.0 : 0.98)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isEnabled)
    }
}

struct SecondaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(ModernTheme.Typography.callout)
            .tracking(0.8)
            .foregroundColor(ModernTheme.primary)
            .padding(.horizontal, ModernTheme.Spacing.lg)
            .padding(.vertical, ModernTheme.Spacing.sm)
            .background(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [ModernTheme.primary, ModernTheme.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
                    .background(
                        Capsule()
                            .fill(ModernTheme.primary.opacity(0.1))
                    )
            )
    }
}

// MARK: - Luxury Text Modifier
struct LuxuryTextStyle: ViewModifier {
    let style: LuxuryTextVariant
    
    enum LuxuryTextVariant {
        case hero
        case display
        case elegant
        case accent
    }
    
    func body(content: Content) -> some View {
        switch style {
        case .hero:
            content
                .font(ModernTheme.Typography.heroTitle)
                .tracking(2.0)
                .foregroundStyle(
                    LinearGradient(
                        colors: [ModernTheme.primary, ModernTheme.secondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        case .display:
            content
                .font(ModernTheme.Typography.displayText)
                .tracking(1.5)
                .foregroundColor(ModernTheme.textPrimary)
        case .elegant:
            content
                .font(ModernTheme.Typography.elegantBody)
                .tracking(0.5)
                .foregroundColor(ModernTheme.textPrimary)
        case .accent:
            content
                .font(ModernTheme.Typography.headline)
                .tracking(1.0)
                .foregroundColor(ModernTheme.primary)
        }
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
    
    func luxuryText(_ style: LuxuryTextStyle.LuxuryTextVariant) -> some View {
        modifier(LuxuryTextStyle(style: style))
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
