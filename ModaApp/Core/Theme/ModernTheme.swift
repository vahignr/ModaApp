import SwiftUI

struct ModernTheme {
    // MARK: - Midnight Luxe Color Palette
    // Sophisticated luxury colors for high-fashion aesthetic
    
    // Primary Colors
    static let primary = Color(hex: "0A0E27")         // Midnight Blue - Deep sophistication
    static let secondary = Color(hex: "E8B4B8")       // Rose Gold - Luxury accent
    static let tertiary = Color(hex: "D4AF37")        // Champagne Gold - Premium touch
    static let accent = Color(hex: "FFF0F5")          // Soft Blush - Feminine elegance
    
    // Neutral Colors
    static let background = Color(hex: "FAFAF8")      // Off-white - Clean luxury
    static let surface = Color(hex: "FFFFFF")         // Pure White - Cards and surfaces
    static let textPrimary = Color(hex: "1C1C1E")     // Charcoal - Main text
    static let textSecondary = Color(hex: "636366")   // Gray - Secondary text
    static let textTertiary = Color(hex: "C7C7CC")    // Light Gray - Disabled text
    
    // Semantic Colors (luxury tones)
    static let success = Color(hex: "34C759")         // Emerald Green - Success
    static let warning = Color(hex: "FF9500")         // Amber - Warning
    static let error = Color(hex: "FF3B30")           // Ruby Red - Error
    static let info = Color(hex: "5AC8FA")            // Sky Blue - Info
    
    // Additional Luxury Colors
    static let lightBlush = Color(hex: "FFF5F7")      // Very light blush for backgrounds
    static let darkMidnight = Color(hex: "050611")    // Almost black for emphasis
    static let cream = Color(hex: "FFF8E7")           // Warm cream for accents
    static let platinum = Color(hex: "E5E5EA")        // Platinum for borders
    
    // Glass Morphism Colors
    static let glassWhite = Color.white.opacity(0.7)
    static let glassOverlay = Color.white.opacity(0.25)
    static let glassBorder = Color.white.opacity(0.3)
    
    // MARK: - Gradient Presets
    static let primaryGradient = LinearGradient(
        colors: [primary, primary.opacity(0.8), secondary.opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let secondaryGradient = LinearGradient(
        colors: [secondary, secondary.opacity(0.8), tertiary.opacity(0.5)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let luxuryGradient = LinearGradient(
        colors: [Color(hex: "0A0E27"), Color(hex: "1A1F3A"), Color(hex: "2A2F4A")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let roseGoldGradient = LinearGradient(
        colors: [secondary, Color(hex: "F4C2C7"), tertiary.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Radial gradient for iOS 16 compatibility (instead of MeshGradient)
    static let radialBlushGradient = RadialGradient(
        colors: [
            Color(hex: "E8B4B8").opacity(0.3),
            Color(hex: "FFF0F5").opacity(0.2),
            Color(hex: "FAFAF8").opacity(0.1)
        ],
        center: .center,
        startRadius: 50,
        endRadius: 300
    )
    
    static let shimmerGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.0),
            Color.white.opacity(0.3),
            Color.white.opacity(0.5),
            Color.white.opacity(0.3),
            Color.white.opacity(0.0)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // MARK: - Typography
    struct Typography {
        // Premium fashion-forward typography
        static let largeTitle = Font.custom("SF Pro Display", size: 40).weight(.bold)
        static let title = Font.custom("SF Pro Display", size: 32).weight(.semibold)
        static let title2 = Font.custom("SF Pro Display", size: 24).weight(.semibold)
        static let headline = Font.custom("SF Pro Display", size: 20).weight(.medium)
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let callout = Font.system(size: 15, weight: .regular, design: .default)
        static let caption = Font.system(size: 12, weight: .regular, design: .default)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
        
        // Fallback for devices without SF Pro Display
        static func title(size: CGFloat, weight: Font.Weight) -> Font {
            if UIFont.familyNames.contains("SF Pro Display") {
                return Font.custom("SF Pro Display", size: size).weight(weight)
            } else {
                return Font.system(size: size, weight: weight, design: .default)
            }
        }
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
        static let xxxl: CGFloat = 64
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let xl: CGFloat = 28
        static let full: CGFloat = 9999
    }
    
    // MARK: - Shadows (Enhanced for luxury depth)
    struct Shadow {
        static let small = (
            color: Color.black.opacity(0.04),
            radius: CGFloat(8),
            x: CGFloat(0),
            y: CGFloat(4)
        )
        static let medium = (
            color: Color.black.opacity(0.08),
            radius: CGFloat(16),
            x: CGFloat(0),
            y: CGFloat(8)
        )
        static let large = (
            color: Color.black.opacity(0.12),
            radius: CGFloat(24),
            x: CGFloat(0),
            y: CGFloat(12)
        )
        static let colored = (
            color: secondary.opacity(0.25),
            radius: CGFloat(20),
            x: CGFloat(0),
            y: CGFloat(10)
        )
        static let glow = (
            color: secondary.opacity(0.5),
            radius: CGFloat(32),
            x: CGFloat(0),
            y: CGFloat(0)
        )
    }
    
    // MARK: - Animation Curves
    static let springAnimation = Animation.spring(response: 0.4, dampingFraction: 0.75, blendDuration: 0)
    static let smoothSpring = Animation.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)
    static let bounceSpring = Animation.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0)
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

// MARK: - Glass Morphism Modifier
struct GlassMorphism: ViewModifier {
    var cornerRadius: CGFloat = ModernTheme.CornerRadius.large
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Base glass layer
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(ModernTheme.glassWhite)
                        .background(
                            .ultraThinMaterial,
                            in: RoundedRectangle(cornerRadius: cornerRadius)
                        )
                    
                    // Border
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(ModernTheme.glassBorder, lineWidth: 1)
                }
            )
            .shadow(
                color: Color.black.opacity(0.1),
                radius: 20,
                x: 0,
                y: 10
            )
    }
}

// MARK: - Shimmer Effect Modifier
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    var duration: Double = 1.5
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ModernTheme.shimmerGradient
                    .mask(content)
                    .offset(x: phase * 400 - 200)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: duration)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

// MARK: - Glow Effect Modifier
struct GlowEffect: ViewModifier {
    var color: Color = ModernTheme.secondary
    var radius: CGFloat = 20
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.3), radius: radius * 2, x: 0, y: 0)
    }
}

// MARK: - Premium Button Styles
struct PrimaryButtonStyle: ViewModifier {
    var isEnabled: Bool = true
    @State private var isPressed = false
    
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
                            .overlay(
                                ModernTheme.shimmerGradient
                                    .opacity(isPressed ? 0.3 : 0)
                            )
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
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(ModernTheme.springAnimation, value: isPressed)
            .onLongPressGesture(
                minimumDuration: .infinity,
                maximumDistance: .infinity,
                pressing: { pressing in
                    isPressed = pressing
                },
                perform: {}
            )
    }
}

struct SecondaryButtonStyle: ViewModifier {
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        content
            .font(ModernTheme.Typography.body)
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
                            .fill(ModernTheme.secondary.opacity(isHovered ? 0.1 : 0))
                    )
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(ModernTheme.springAnimation, value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle(isElevated: Bool = true) -> some View {
        modifier(CardStyle(isElevated: isElevated))
    }
    
    func glassMorphism(cornerRadius: CGFloat = ModernTheme.CornerRadius.large) -> some View {
        modifier(GlassMorphism(cornerRadius: cornerRadius))
    }
    
    func shimmerEffect(duration: Double = 1.5) -> some View {
        modifier(ShimmerEffect(duration: duration))
    }
    
    func glowEffect(color: Color = ModernTheme.secondary, radius: CGFloat = 20) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
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
