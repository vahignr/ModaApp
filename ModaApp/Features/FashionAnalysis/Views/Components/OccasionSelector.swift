import SwiftUI

struct OccasionSelector: View {
    @Binding var selectedOccasion: Occasion?
    @Binding var customOccasion: String
    @Binding var selectedTone: TonePersona?
    @State private var showCustomInput = false
    @FocusState private var isCustomFieldFocused: Bool
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var hoveredOccasion: Occasion?
    @State private var hoveredTone: TonePersona?
    @State private var calendarScale: CGFloat = 1.0
    @State private var personScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.xl) {
            ScrollView {
                VStack(spacing: ModernTheme.Spacing.xxl) {
                    // Occasion Selection Section
                    VStack(spacing: ModernTheme.Spacing.lg) {
                        // Header with animation
                        VStack(spacing: ModernTheme.Spacing.xs) {
                            HStack {
                                Image(systemName: "calendar")
                                    .font(.system(size: 24))
                                    .foregroundStyle(ModernTheme.primaryGradient)
                                    .scaleEffect(calendarScale)
                                
                                Text(localized(.selectTheOccasion))
                                    .font(ModernTheme.Typography.title2)
                                    .foregroundColor(ModernTheme.textPrimary)
                            }
                            
                            Text(localized(.helpUsStyle))
                                .font(ModernTheme.Typography.callout)
                                .foregroundColor(ModernTheme.textSecondary)
                        }
                        .padding(.horizontal)
                        .onChange(of: selectedOccasion) { _ in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                calendarScale = 1.2
                            }
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7).delay(0.1)) {
                                calendarScale = 1.0
                            }
                        }
                        
                        // Occasion Grid with 3D effects
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: ModernTheme.Spacing.md),
                            GridItem(.flexible(), spacing: ModernTheme.Spacing.md)
                        ], spacing: ModernTheme.Spacing.md) {
                            ForEach(Array(Occasion.presets.enumerated()), id: \.element.id) { index, occasion in
                                Luxury3DOccasionCard(
                                    occasion: occasion,
                                    isSelected: selectedOccasion?.id == occasion.id,
                                    isHovered: hoveredOccasion?.id == occasion.id,
                                    animationDelay: Double(index) * 0.05,
                                    action: {
                                        selectOccasion(occasion)
                                    },
                                    onHover: { isHovered in
                                        hoveredOccasion = isHovered ? occasion : nil
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Custom Input Field with animation
                        if showCustomInput {
                            VStack(alignment: .leading, spacing: ModernTheme.Spacing.sm) {
                                Text(localized(.describeYourOccasion))
                                    .font(ModernTheme.Typography.caption)
                                    .foregroundColor(ModernTheme.textSecondary)
                                
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                                        .fill(ModernTheme.glassWhite)
                                        .background(
                                            .ultraThinMaterial,
                                            in: RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [ModernTheme.primary, ModernTheme.secondary],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    ),
                                                    lineWidth: isCustomFieldFocused ? 2 : 1
                                                )
                                        )
                                    
                                    TextField(localized(.occasionPlaceholder), text: $customOccasion)
                                        .padding(ModernTheme.Spacing.md)
                                        .font(ModernTheme.Typography.body)
                                        .foregroundColor(ModernTheme.textPrimary)
                                        .focused($isCustomFieldFocused)
                                        .submitLabel(.done)
                                }
                                .frame(height: 50)
                                .shadow(
                                    color: isCustomFieldFocused ? ModernTheme.Shadow.colored.color : Color.clear,
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                            }
                            .padding(.horizontal)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.9).combined(with: .opacity),
                                removal: .scale(scale: 0.9).combined(with: .opacity)
                            ))
                        }
                    }
                    
                    // Animated Divider
                    LuxuryDivider()
                    
                    // Tone Selection Section
                    VStack(spacing: ModernTheme.Spacing.lg) {
                        // Header with animation
                        VStack(spacing: ModernTheme.Spacing.xs) {
                            HStack {
                                Image(systemName: "person.fill.viewfinder")
                                    .font(.system(size: 24))
                                    .foregroundStyle(ModernTheme.secondaryGradient)
                                    .scaleEffect(personScale)
                                
                                Text(localized(.selectVoiceTone))
                                    .font(ModernTheme.Typography.title2)
                                    .foregroundColor(ModernTheme.textPrimary)
                            }
                            
                            Text(localized(.voiceToneDescription))
                                .font(ModernTheme.Typography.callout)
                                .foregroundColor(ModernTheme.textSecondary)
                        }
                        .padding(.horizontal)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                personScale = 1.1
                            }
                        }
                        
                        // Tone Grid with personality animations
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: ModernTheme.Spacing.md),
                            GridItem(.flexible(), spacing: ModernTheme.Spacing.md)
                        ], spacing: ModernTheme.Spacing.md) {
                            ForEach(Array(TonePersona.personas.enumerated()), id: \.element.id) { index, tone in
                                AnimatedToneCard(
                                    tone: tone,
                                    isSelected: selectedTone?.id == tone.id,
                                    isHovered: hoveredTone?.id == tone.id,
                                    animationDelay: Double(index) * 0.05,
                                    action: {
                                        selectTone(tone)
                                    },
                                    onHover: { isHovered in
                                        hoveredTone = isHovered ? tone : nil
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, ModernTheme.Spacing.xxl)
            }
        }
        .onAppear {
            setupInitialState()
        }
    }
    
    // MARK: - Helper Methods
    
    private func selectOccasion(_ occasion: Occasion) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        withAnimation(ModernTheme.springAnimation) {
            selectedOccasion = occasion
            if occasion.name == "Custom" {
                showCustomInput = true
                isCustomFieldFocused = true
            } else {
                showCustomInput = false
                customOccasion = ""
            }
        }
    }
    
    private func selectTone(_ tone: TonePersona) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        withAnimation(ModernTheme.springAnimation) {
            selectedTone = tone
        }
    }
    
    private func setupInitialState() {
        if selectedOccasion?.name == "Custom" && !customOccasion.isEmpty {
            showCustomInput = true
        }
        
        if selectedTone == nil {
            selectedTone = TonePersona.defaultPersona
        }
    }
}

// MARK: - Luxury 3D Occasion Card
struct Luxury3DOccasionCard: View {
    let occasion: Occasion
    let isSelected: Bool
    let isHovered: Bool
    let animationDelay: Double
    let action: () -> Void
    let onHover: (Bool) -> Void
    
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var isPressed = false
    @State private var appeared = false
    @State private var rotation3D: Double = 0
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: ModernTheme.Spacing.sm) {
                // 3D Icon Container
                ZStack {
                    // Shadow layer
                    Circle()
                        .fill(
                            isSelected ?
                            ModernTheme.secondary.opacity(0.3) :
                            ModernTheme.primary.opacity(0.1)
                        )
                        .frame(width: 64, height: 64)
                        .blur(radius: 15)
                        .offset(y: 5)
                        .scaleEffect(isHovered ? 1.1 : 1.0)
                    
                    // Gradient background
                    Circle()
                        .fill(
                            isSelected ?
                            ModernTheme.primaryGradient :
                            LinearGradient(
                                colors: [ModernTheme.lightBlush, ModernTheme.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .rotation3DEffect(
                            .degrees(rotation3D),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.5
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ? ModernTheme.glassBorder : Color.clear,
                                    lineWidth: 2
                                )
                        )
                    
                    // Icon with animation
                    Image(systemName: occasion.icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(isSelected ? .white : ModernTheme.primary)
                        .scaleEffect(isHovered ? 1.1 : 1.0)
                        .rotationEffect(.degrees(isHovered ? 10 : 0))
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)
                
                // Text content
                VStack(spacing: 2) {
                    Text(localized(occasion.localizationKey))
                        .font(ModernTheme.Typography.caption)
                        .fontWeight(isSelected ? .semibold : .medium)
                        .foregroundColor(isSelected ? ModernTheme.primary : ModernTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                    
                    Text(localized(occasion.descriptionKey))
                        .font(ModernTheme.Typography.caption2)
                        .foregroundColor(ModernTheme.textTertiary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .opacity(0.8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, ModernTheme.Spacing.md)
            .padding(.horizontal, ModernTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .fill(
                        isSelected ?
                        ModernTheme.primary.opacity(0.08) :
                        ModernTheme.glassWhite
                    )
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .stroke(
                        isSelected ?
                        ModernTheme.primaryGradient :
                        LinearGradient(colors: [ModernTheme.glassBorder], startPoint: .leading, endPoint: .trailing),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? ModernTheme.Shadow.colored.color : ModernTheme.Shadow.small.color,
                radius: isSelected ? 12 : ModernTheme.Shadow.small.radius,
                x: 0,
                y: isSelected ? 6 : ModernTheme.Shadow.small.y
            )
            .scaleEffect(appeared ? 1 : 0.8)
            .opacity(appeared ? 1 : 0)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onHover { hovering in
            withAnimation(ModernTheme.springAnimation) {
                onHover(hovering)
                if hovering {
                    rotation3D = 15
                } else {
                    rotation3D = 0
                }
            }
        }
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(ModernTheme.springAnimation) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
        .onAppear {
            withAnimation(
                .spring(response: 0.6, dampingFraction: 0.7)
                .delay(animationDelay)
            ) {
                appeared = true
            }
        }
    }
}

// MARK: - Animated Tone Card
struct AnimatedToneCard: View {
    let tone: TonePersona
    let isSelected: Bool
    let isHovered: Bool
    let animationDelay: Double
    let action: () -> Void
    let onHover: (Bool) -> Void
    
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var isPressed = false
    @State private var appeared = false
    @State private var iconAnimation = false
    @State private var glowAnimation = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: ModernTheme.Spacing.sm) {
                // Animated Icon Container
                ZStack {
                    // Animated glow rings
                    if isSelected {
                        ForEach(0..<3) { index in
                            Circle()
                                .stroke(ModernTheme.secondary.opacity(0.3 - Double(index) * 0.1), lineWidth: 2)
                                .frame(width: 60 + CGFloat(index * 15), height: 60 + CGFloat(index * 15))
                                .scaleEffect(glowAnimation ? 1.2 : 1.0)
                                .opacity(glowAnimation ? 0 : 1)
                                .animation(
                                    Animation.easeOut(duration: 2)
                                        .repeatForever(autoreverses: false)
                                        .delay(Double(index) * 0.3),
                                    value: glowAnimation
                                )
                        }
                    }
                    
                    // Main circle with gradient
                    Circle()
                        .fill(
                            isSelected ?
                            ModernTheme.secondaryGradient :
                            LinearGradient(
                                colors: [ModernTheme.cream, ModernTheme.lightBlush],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ?
                                    ModernTheme.glassBorder :
                                    ModernTheme.platinum.opacity(0.5),
                                    lineWidth: 2
                                )
                        )
                    
                    // Animated icon
                    Image(systemName: tone.icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(isSelected ? .white : ModernTheme.secondary)
                        .rotationEffect(.degrees(iconAnimation ? 360 : 0))
                        .scaleEffect(isHovered ? 1.15 : 1.0)
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)
                
                // Text content with fade animation
                VStack(spacing: 2) {
                    Text(localized(tone.localizationKey))
                        .font(ModernTheme.Typography.caption)
                        .fontWeight(isSelected ? .semibold : .medium)
                        .foregroundColor(isSelected ? ModernTheme.secondary : ModernTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                    
                    Text(localized(tone.descriptionKey))
                        .font(ModernTheme.Typography.caption2)
                        .foregroundColor(ModernTheme.textTertiary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .opacity(isHovered ? 1 : 0.8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, ModernTheme.Spacing.md)
            .padding(.horizontal, ModernTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .fill(
                        isSelected ?
                        ModernTheme.secondary.opacity(0.08) :
                        ModernTheme.glassWhite
                    )
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .stroke(
                        isSelected ?
                        ModernTheme.secondaryGradient :
                        LinearGradient(colors: [ModernTheme.glassBorder], startPoint: .leading, endPoint: .trailing),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? ModernTheme.Shadow.colored.color : ModernTheme.Shadow.small.color,
                radius: isSelected ? 12 : ModernTheme.Shadow.small.radius,
                x: 0,
                y: isSelected ? 6 : ModernTheme.Shadow.small.y
            )
            .scaleEffect(appeared ? 1 : 0.8)
            .opacity(appeared ? 1 : 0)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onHover { hovering in
            withAnimation(ModernTheme.springAnimation) {
                onHover(hovering)
            }
        }
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(ModernTheme.springAnimation) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
        .onAppear {
            withAnimation(
                .spring(response: 0.6, dampingFraction: 0.7)
                .delay(animationDelay)
            ) {
                appeared = true
            }
            
            if isSelected {
                glowAnimation = true
            }
            
            // Special animations for specific personas
            if tone.name == "Fashion Police" && isSelected {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    iconAnimation = true
                }
            }
        }
        .onChange(of: isSelected) { newValue in
            if newValue {
                glowAnimation = true
            }
        }
    }
}

// MARK: - Luxury Divider
struct LuxuryDivider: View {
    @State private var shimmerOffset: CGFloat = -100
    
    var body: some View {
        ZStack {
            // Base line
            Rectangle()
                .fill(ModernTheme.platinum.opacity(0.3))
                .frame(height: 1)
            
            // Shimmer effect
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            ModernTheme.secondary.opacity(0.5),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 50, height: 1)
                .offset(x: shimmerOffset)
        }
        .frame(height: 1)
        .padding(.horizontal, ModernTheme.Spacing.xl)
        .padding(.vertical, ModernTheme.Spacing.sm)
        .onAppear {
            withAnimation(
                .linear(duration: 3)
                .repeatForever(autoreverses: false)
            ) {
                shimmerOffset = UIScreen.main.bounds.width + 100
            }
        }
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State var selectedOccasion: Occasion? = Occasion.presets.first
        @State var customOccasion = ""
        @State var selectedTone: TonePersona? = TonePersona.defaultPersona
        
        var body: some View {
            ZStack {
                ModernTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    OccasionSelector(
                        selectedOccasion: $selectedOccasion,
                        customOccasion: $customOccasion,
                        selectedTone: $selectedTone
                    )
                    .padding()
                }
            }
            .environmentObject(LocalizationManager.shared)
        }
    }
    
    return PreviewWrapper()
}
