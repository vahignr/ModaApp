import SwiftUI

struct OccasionSelector: View {
    @Binding var selectedOccasion: Occasion?
    @Binding var customOccasion: String
    @Binding var selectedTone: TonePersona?
    @State private var showCustomInput = false
    @FocusState private var isCustomFieldFocused: Bool
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.lg) {
            ScrollView {
                VStack(spacing: ModernTheme.Spacing.xl) {
                    // Occasion Selection Section
                    VStack(spacing: ModernTheme.Spacing.lg) {
                        // Header
                        VStack(spacing: ModernTheme.Spacing.xs) {
                            Text(localized(.selectTheOccasion))
                                .font(ModernTheme.Typography.headline)
                                .foregroundColor(ModernTheme.textPrimary)
                            
                            Text(localized(.helpUsStyle))
                                .font(ModernTheme.Typography.callout)
                                .foregroundColor(ModernTheme.textSecondary)
                        }
                        
                        // Occasion Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: ModernTheme.Spacing.md),
                            GridItem(.flexible(), spacing: ModernTheme.Spacing.md)
                        ], spacing: ModernTheme.Spacing.md) {
                            ForEach(Occasion.presets) { occasion in
                                OccasionCard(
                                    occasion: occasion,
                                    isSelected: selectedOccasion?.id == occasion.id,
                                    action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
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
                                )
                            }
                        }
                        
                        // Custom Input Field
                        if showCustomInput {
                            VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
                                Text(localized(.describeYourOccasion))
                                    .font(ModernTheme.Typography.caption)
                                    .foregroundColor(ModernTheme.textSecondary)
                                
                                TextField(localized(.occasionPlaceholder), text: $customOccasion)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .focused($isCustomFieldFocused)
                                    .submitLabel(.done)
                            }
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                        }
                    }
                    
                    // Divider
                    Rectangle()
                        .fill(ModernTheme.lightSage)
                        .frame(height: 1)
                        .padding(.vertical, ModernTheme.Spacing.sm)
                    
                    // Tone Selection Section
                    VStack(spacing: ModernTheme.Spacing.lg) {
                        // Header
                        VStack(spacing: ModernTheme.Spacing.xs) {
                            Text(localized(.selectVoiceTone))
                                .font(ModernTheme.Typography.headline)
                                .foregroundColor(ModernTheme.textPrimary)
                            
                            Text(localized(.voiceToneDescription))
                                .font(ModernTheme.Typography.callout)
                                .foregroundColor(ModernTheme.textSecondary)
                        }
                        
                        // Tone Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: ModernTheme.Spacing.md),
                            GridItem(.flexible(), spacing: ModernTheme.Spacing.md)
                        ], spacing: ModernTheme.Spacing.md) {
                            ForEach(TonePersona.personas) { tone in
                                ToneCard(
                                    tone: tone,
                                    isSelected: selectedTone?.id == tone.id,
                                    action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedTone = tone
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.bottom, ModernTheme.Spacing.xxl)
            }
        }
        .onAppear {
            // Check if custom occasion should be shown
            if selectedOccasion?.name == "Custom" && !customOccasion.isEmpty {
                showCustomInput = true
            }
            
            // Ensure a tone is selected
            if selectedTone == nil {
                selectedTone = TonePersona.defaultPersona
            }
        }
    }
}

// MARK: - Tone Card Component
struct ToneCard: View {
    let tone: TonePersona
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: ModernTheme.Spacing.sm) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ?
                            LinearGradient(
                                colors: [ModernTheme.secondary, ModernTheme.secondary.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [ModernTheme.cream, ModernTheme.cream],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: tone.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(isSelected ? .white : ModernTheme.secondary)
                }
                .scaleEffect(isPressed ? 0.95 : 1.0)
                
                // Text
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
                        .opacity(0.8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, ModernTheme.Spacing.md)
            .padding(.horizontal, ModernTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .fill(isSelected ? ModernTheme.secondary.opacity(0.1) : ModernTheme.surface)
                    .shadow(
                        color: isSelected ? ModernTheme.secondary.opacity(0.2) : ModernTheme.Shadow.small.color,
                        radius: isSelected ? 8 : ModernTheme.Shadow.small.radius,
                        x: 0,
                        y: isSelected ? 4 : ModernTheme.Shadow.small.y
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .stroke(isSelected ? ModernTheme.secondary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
    }
}

// MARK: - Occasion Card Component
struct OccasionCard: View {
    let occasion: Occasion
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: ModernTheme.Spacing.sm) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ?
                            LinearGradient(
                                colors: [ModernTheme.primary, ModernTheme.primary.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [ModernTheme.lightSage, ModernTheme.lightSage],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: occasion.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(isSelected ? .white : ModernTheme.primary)
                }
                .scaleEffect(isPressed ? 0.95 : 1.0)
                
                // Text
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
                    .fill(isSelected ? ModernTheme.primary.opacity(0.1) : ModernTheme.surface)
                    .shadow(
                        color: isSelected ? ModernTheme.primary.opacity(0.2) : ModernTheme.Shadow.small.color,
                        radius: isSelected ? 8 : ModernTheme.Shadow.small.radius,
                        x: 0,
                        y: isSelected ? 4 : ModernTheme.Shadow.small.y
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .stroke(isSelected ? ModernTheme.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
    }
}

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(ModernTheme.Spacing.md)
            .background(ModernTheme.surface)
            .cornerRadius(ModernTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                    .stroke(ModernTheme.primary.opacity(0.3), lineWidth: 1)
            )
            .font(ModernTheme.Typography.body)
            .foregroundColor(ModernTheme.textPrimary)
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State var selectedOccasion: Occasion? = Occasion.presets.first
        @State var customOccasion = ""
        @State var selectedTone: TonePersona? = TonePersona.defaultPersona
        
        var body: some View {
            VStack {
                OccasionSelector(
                    selectedOccasion: $selectedOccasion,
                    customOccasion: $customOccasion,
                    selectedTone: $selectedTone
                )
                .padding()
                
                // Preview selected values
                VStack(spacing: 8) {
                    if let occasion = selectedOccasion {
                        Text("Occasion: \(occasion.name)")
                        if !customOccasion.isEmpty {
                            Text("Custom: \(customOccasion)")
                        }
                    }
                    if let tone = selectedTone {
                        Text("Tone: \(tone.name)")
                    }
                }
                .padding()
                .background(ModernTheme.primary.opacity(0.1))
                .cornerRadius(8)
            }
            .background(ModernTheme.background)
            .environmentObject(LocalizationManager.shared)
        }
    }
    
    return PreviewWrapper()
}
