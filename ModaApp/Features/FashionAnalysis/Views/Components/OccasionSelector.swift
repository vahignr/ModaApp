import SwiftUI

struct OccasionSelector: View {
    @Binding var selectedOccasion: Occasion?
    @Binding var customOccasion: String
    @State private var showCustomInput = false
    @FocusState private var isCustomFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.lg) {
            // Header
            VStack(spacing: ModernTheme.Spacing.xs) {
                Text("Select the Occasion")
                    .font(ModernTheme.Typography.headline)
                    .foregroundColor(ModernTheme.textPrimary)
                
                Text("Help us style you perfectly for your event")
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
                    Text("Describe your occasion")
                        .font(ModernTheme.Typography.caption)
                        .foregroundColor(ModernTheme.textSecondary)
                    
                    TextField("e.g., Blues concert at outdoor venue", text: $customOccasion)
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
    }
}

// MARK: - Occasion Card Component
struct OccasionCard: View {
    let occasion: Occasion
    let isSelected: Bool
    let action: () -> Void
    
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
                    Text(occasion.name)
                        .font(ModernTheme.Typography.caption)
                        .fontWeight(isSelected ? .semibold : .medium)
                        .foregroundColor(isSelected ? ModernTheme.primary : ModernTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                    
                    if !occasion.description.isEmpty {
                        Text(occasion.description)
                            .font(ModernTheme.Typography.caption2)
                            .foregroundColor(ModernTheme.textTertiary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .opacity(0.8)
                    }
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
        @State var selectedOccasion: Occasion?
        @State var customOccasion = ""
        
        var body: some View {
            VStack {
                OccasionSelector(
                    selectedOccasion: $selectedOccasion,
                    customOccasion: $customOccasion
                )
                .padding()
                
                // Preview selected values
                if let occasion = selectedOccasion {
                    VStack {
                        Text("Selected: \(occasion.name)")
                        if !customOccasion.isEmpty {
                            Text("Custom: \(customOccasion)")
                        }
                    }
                    .padding()
                    .background(ModernTheme.primary.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .background(ModernTheme.background)
        }
    }
    
    return PreviewWrapper()
}
