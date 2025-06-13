import SwiftUI

struct FashionResultsView: View {
    let analysis: FashionAnalysis
    @ObservedObject var audioManager: AudioPlayerManager
    let audioURL: URL?
    let isSearchingImages: Bool
    let onNewAnalysis: () -> Void
    
    @State private var selectedTab = 0
    @State private var expandedItems: Set<UUID> = []
    @State private var showFullImage = false
    @State private var selectedImageURL: String?
    @State private var dragOffset: CGSize = .zero
    @State private var audioCardExpanded = true
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        ZStack {
            // Background with gradient
            ResultsBackground()
            
            VStack(spacing: 0) {
                // Swipeable Content Area
                TabView(selection: $selectedTab) {
                    // Overall Analysis Tab
                    ScrollView {
                        VStack(spacing: ModernTheme.Spacing.lg) {
                            // Audio Analysis Card
                            LuxuryCommentCard(
                                comment: analysis.overallComment,
                                audioManager: audioManager,
                                audioURL: audioURL,
                                isExpanded: $audioCardExpanded
                            )
                            .padding(.horizontal)
                            .padding(.top, ModernTheme.Spacing.lg)
                            
                            // Current Outfit Items
                            if !analysis.currentItems.isEmpty {
                                CurrentOutfitSection(
                                    items: analysis.currentItems,
                                    expandedItems: $expandedItems
                                )
                            }
                            
                            Spacer(minLength: 100)
                        }
                    }
                    .tag(0)
                    
                    // Suggestions Tab
                    ScrollView {
                        VStack(spacing: ModernTheme.Spacing.lg) {
                            // Suggestions Header
                            SuggestionsHeader()
                                .padding(.horizontal)
                                .padding(.top, ModernTheme.Spacing.lg)
                            
                            // Suggestion Cards
                            ForEach(Array(analysis.suggestions.enumerated()), id: \.element.id) { index, suggestion in
                                LuxurySuggestionCard(
                                    suggestion: suggestion,
                                    isSearchingImages: isSearchingImages,
                                    animationDelay: Double(index) * 0.1,
                                    onImageTap: { imageURL in
                                        selectedImageURL = imageURL
                                        showFullImage = true
                                    }
                                )
                                .padding(.horizontal)
                            }
                            
                            Spacer(minLength: 100)
                        }
                    }
                    .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)
                
                // Custom Tab Bar
                CustomTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal)
                    .padding(.bottom, ModernTheme.Spacing.md)
            }
            
            // Floating New Analysis Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingAnalysisButton(action: onNewAnalysis)
                        .padding(.trailing, ModernTheme.Spacing.lg)
                        .padding(.bottom, ModernTheme.Spacing.xl)
                }
            }
        }
        .sheet(isPresented: $showFullImage) {
            if let imageURL = selectedImageURL {
                LuxuryImageDetailView(imageURL: imageURL)
            }
        }
    }
}

// MARK: - Results Background
struct ResultsBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            ModernTheme.background
                .ignoresSafeArea()
            
            // Animated gradient
            LinearGradient(
                colors: [
                    ModernTheme.secondary.opacity(0.05),
                    ModernTheme.tertiary.opacity(0.03),
                    ModernTheme.primary.opacity(0.02)
                ],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
            
            // Floating orbs
            GeometryReader { geometry in
                ForEach(0..<3) { index in
                    Circle()
                        .fill(ModernTheme.radialBlushGradient)
                        .frame(width: 150, height: 150)
                        .blur(radius: 50)
                        .offset(
                            x: CGFloat.random(in: -100...geometry.size.width),
                            y: CGFloat.random(in: -100...geometry.size.height)
                        )
                        .opacity(0.3)
                }
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Luxury Comment Card
struct LuxuryCommentCard: View {
    let comment: String
    @ObservedObject var audioManager: AudioPlayerManager
    let audioURL: URL?
    @Binding var isExpanded: Bool
    @State private var shimmerPhase: CGFloat = -100
    @State private var sparkleRotation: Double = 0
    @State private var sparkleOpacity: Double = 0.7
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.md) {
            // Header
            HStack {
                // Icon with glow
                ZStack {
                    Circle()
                        .fill(ModernTheme.primaryGradient)
                        .frame(width: 40, height: 40)
                        .blur(radius: 10)
                        .opacity(0.5)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(ModernTheme.primaryGradient)
                        .rotationEffect(.degrees(sparkleRotation))
                        .opacity(sparkleOpacity)
                }
                
                Text(localized(.aiStylistAnalysis))
                    .font(ModernTheme.Typography.headline)
                    .foregroundColor(ModernTheme.textPrimary)
                
                Spacer()
                
                // Expand/Collapse button
                Button {
                    withAnimation(ModernTheme.springAnimation) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(ModernTheme.primary)
                        .font(.system(size: 16, weight: .medium))
                        .rotationEffect(.degrees(isExpanded ? 0 : -180))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isExpanded)
                }
            }
            
            if isExpanded {
                VStack(spacing: ModernTheme.Spacing.md) {
                    // Comment with gradient background
                    Text(comment)
                        .font(ModernTheme.Typography.body)
                        .foregroundColor(ModernTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(ModernTheme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                                .fill(ModernTheme.primary.opacity(0.03))
                                .overlay(
                                    // Shimmer effect
                                    LinearGradient(
                                        colors: [
                                            Color.clear,
                                            ModernTheme.secondary.opacity(0.1),
                                            Color.clear
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .frame(width: 100)
                                    .offset(x: shimmerPhase)
                                    .mask(
                                        RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                                    )
                                )
                        )
                    
                    // Audio Controls
                    if audioURL != nil {
                        LuxuryAudioControls(audioManager: audioManager)
                    }
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                    removal: .scale(scale: 0.9).combined(with: .opacity)
                ))
            }
        }
        .padding(ModernTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.xl)
                .fill(ModernTheme.glassWhite)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.xl)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.xl)
                .stroke(ModernTheme.glassBorder, lineWidth: 1)
        )
        .shadow(
            color: ModernTheme.Shadow.medium.color,
            radius: ModernTheme.Shadow.medium.radius,
            x: 0,
            y: ModernTheme.Shadow.medium.y
        )
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                shimmerPhase = 300
            }
            
            // Sparkle animation for iOS 16
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                sparkleRotation = 15
                sparkleOpacity = 1.0
            }
        }
        .onChange(of: isExpanded) { newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.3)) {
                    sparkleRotation = -15
                }
            }
        }
    }
}

// MARK: - Luxury Audio Controls
struct LuxuryAudioControls: View {
    @ObservedObject var audioManager: AudioPlayerManager
    @State private var isHovering = false
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.md) {
            // Progress View
            AudioProgressView(audio: audioManager)
                .padding(.horizontal, ModernTheme.Spacing.sm)
            
            // Play Button
            Button {
                audioManager.toggle()
            } label: {
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(ModernTheme.secondaryGradient)
                        .frame(width: 64, height: 64)
                        .blur(radius: 20)
                        .opacity(audioManager.isPlaying ? 0.6 : 0.3)
                        .scaleEffect(audioManager.isPlaying ? 1.2 : 1.0)
                    
                    Circle()
                        .fill(ModernTheme.primaryGradient)
                        .frame(width: 56, height: 56)
                        .shadow(
                            color: ModernTheme.Shadow.colored.color,
                            radius: ModernTheme.Shadow.colored.radius,
                            x: 0,
                            y: ModernTheme.Shadow.colored.y
                        )
                    
                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .offset(x: audioManager.isPlaying ? 0 : 2)
                }
                .scaleEffect(isHovering ? 1.05 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { hovering in
                withAnimation(ModernTheme.springAnimation) {
                    isHovering = hovering
                }
            }
            
            Text(audioManager.isPlaying ? localized(.playingAnalysis) : localized(.listenToAnalysis))
                .font(ModernTheme.Typography.caption)
                .foregroundColor(ModernTheme.textSecondary)
        }
    }
}

// MARK: - Current Outfit Section
struct CurrentOutfitSection: View {
    let items: [FashionItem]
    @Binding var expandedItems: Set<UUID>
    
    var body: some View {
        VStack(alignment: .leading, spacing: ModernTheme.Spacing.md) {
            Text(LocalizationManager.shared.string(for: .currentOutfit))
                .font(ModernTheme.Typography.headline)
                .foregroundColor(ModernTheme.textPrimary)
                .padding(.horizontal)
            
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                LuxuryItemCard(
                    item: item,
                    isExpanded: expandedItems.contains(item.id),
                    animationDelay: Double(index) * 0.05,
                    onTap: {
                        withAnimation(ModernTheme.springAnimation) {
                            if expandedItems.contains(item.id) {
                                expandedItems.remove(item.id)
                            } else {
                                expandedItems.insert(item.id)
                            }
                        }
                    }
                )
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Luxury Item Card
struct LuxuryItemCard: View {
    let item: FashionItem
    let isExpanded: Bool
    let animationDelay: Double
    let onTap: () -> Void
    
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var appeared = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: ModernTheme.Spacing.sm) {
                // Header
                HStack {
                    // Icon with gradient background
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [item.categoryColor, item.categoryColor.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: item.categoryIcon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.localizedCategoryName(for: localizationManager.currentLanguage))
                            .font(ModernTheme.Typography.headline)
                            .foregroundColor(ModernTheme.textPrimary)
                        
                        Text(item.description)
                            .font(ModernTheme.Typography.caption)
                            .foregroundColor(ModernTheme.textSecondary)
                            .lineLimit(isExpanded ? nil : 1)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ModernTheme.textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                
                // Expanded Content
                if isExpanded {
                    VStack(alignment: .leading, spacing: ModernTheme.Spacing.md) {
                        // Color Analysis
                        DetailRow(
                            icon: "paintpalette.fill",
                            title: localized(.color),
                            content: item.colorAnalysis,
                            color: ModernTheme.secondary
                        )
                        
                        // Style Notes
                        DetailRow(
                            icon: "sparkles",
                            title: localized(.styleNotes),
                            content: item.styleNotes,
                            color: ModernTheme.tertiary
                        )
                    }
                    .padding(.top, ModernTheme.Spacing.sm)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.95).combined(with: .opacity),
                        removal: .scale(scale: 0.95).combined(with: .opacity)
                    ))
                }
            }
            .padding(ModernTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .fill(ModernTheme.glassWhite)
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .stroke(
                        isExpanded ? item.categoryColor.opacity(0.3) : ModernTheme.glassBorder,
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isExpanded ? item.categoryColor.opacity(0.1) : ModernTheme.Shadow.small.color,
                radius: isExpanded ? 12 : ModernTheme.Shadow.small.radius,
                x: 0,
                y: isExpanded ? 6 : ModernTheme.Shadow.small.y
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .offset(x: appeared ? 0 : -50)
            .opacity(appeared ? 1 : 0)
        }
        .buttonStyle(PlainButtonStyle())
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

// MARK: - Detail Row
struct DetailRow: View {
    let icon: String
    let title: String
    let content: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: ModernTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(ModernTheme.Typography.caption)
                    .foregroundColor(color)
                
                Text(content)
                    .font(ModernTheme.Typography.body)
                    .foregroundColor(ModernTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Suggestions Header
struct SuggestionsHeader: View {
    @State private var sparkleAnimation = false
    
    var body: some View {
        HStack {
            Text(LocalizationManager.shared.string(for: .styleSuggestions))
                .font(ModernTheme.Typography.headline)
                .foregroundColor(ModernTheme.textPrimary)
            
            Image(systemName: "sparkles")
                .font(.system(size: 18))
                .foregroundStyle(ModernTheme.secondaryGradient)
                .rotationEffect(.degrees(sparkleAnimation ? 15 : -15))
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true)
                    ) {
                        sparkleAnimation.toggle()
                    }
                }
        }
    }
}

// MARK: - Luxury Suggestion Card
struct LuxurySuggestionCard: View {
    let suggestion: FashionSuggestion
    let isSearchingImages: Bool
    let animationDelay: Double
    let onImageTap: (String) -> Void
    
    @State private var appeared = false
    @State private var selectedImageIndex: Int?
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: ModernTheme.Spacing.md) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(suggestion.item)
                        .font(ModernTheme.Typography.headline)
                        .foregroundColor(ModernTheme.textPrimary)
                    
                    Text(suggestion.reason)
                        .font(ModernTheme.Typography.callout)
                        .foregroundColor(ModernTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Add button
                ZStack {
                    Circle()
                        .fill(ModernTheme.secondaryGradient)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            
            // Image Gallery
            if let results = suggestion.searchResults, !results.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: ModernTheme.Spacing.sm) {
                        ForEach(Array(results.prefix(5).enumerated()), id: \.element.id) { index, result in
                            LuxuryImageThumbnail(
                                result: result,
                                isSelected: selectedImageIndex == index,
                                onTap: {
                                    selectedImageIndex = index
                                    onImageTap(result.imageUrl)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 2)
                }
            } else if isSearchingImages {
                // Loading skeleton
                HStack(spacing: ModernTheme.Spacing.sm) {
                    ForEach(0..<3) { _ in
                        RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                            .fill(ModernTheme.lightBlush)
                            .frame(width: 120, height: 120)
                            .shimmerEffect()
                    }
                }
            }
            
            // Search tag
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                Text(suggestion.searchQuery)
                    .font(ModernTheme.Typography.caption)
            }
            .foregroundColor(ModernTheme.textSecondary)
            .padding(.horizontal, ModernTheme.Spacing.sm)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(ModernTheme.primary.opacity(0.08))
            )
        }
        .padding(ModernTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.xl)
                .fill(ModernTheme.glassWhite)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.xl)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.xl)
                .stroke(ModernTheme.glassBorder, lineWidth: 1)
        )
        .shadow(
            color: ModernTheme.Shadow.small.color,
            radius: ModernTheme.Shadow.small.radius,
            x: 0,
            y: ModernTheme.Shadow.small.y
        )
        .scaleEffect(appeared ? 1 : 0.9)
        .opacity(appeared ? 1 : 0)
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

// MARK: - Luxury Image Thumbnail
struct LuxuryImageThumbnail: View {
    let result: SearchResult
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isLoaded = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            AsyncImage(url: URL(string: result.thumbnailUrl ?? result.imageUrl)) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                        .fill(ModernTheme.lightBlush)
                        .frame(width: 120, height: 120)
                        .shimmerEffect()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium))
                        .overlay(
                            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                                .stroke(
                                    isSelected ? ModernTheme.secondary : Color.clear,
                                    lineWidth: 3
                                )
                        )
                        .scaleEffect(isLoaded ? 1 : 0.9)
                        .opacity(isLoaded ? 1 : 0)
                        .onAppear {
                            withAnimation(ModernTheme.springAnimation) {
                                isLoaded = true
                            }
                        }
                case .failure:
                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                        .fill(ModernTheme.platinum.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(ModernTheme.textTertiary)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .shadow(
                color: isSelected ? ModernTheme.Shadow.colored.color : ModernTheme.Shadow.small.color,
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
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
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @State private var animatedTab = 0
    @State private var iconScales: [CGFloat] = [1.0, 1.0]
    
    private let tabs = [
        (icon: "doc.text.fill", title: LocalizedStringKey.aiStylistAnalysis),
        (icon: "sparkles", title: LocalizedStringKey.styleSuggestions)
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button {
                    withAnimation(ModernTheme.springAnimation) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: .medium))
                            .scaleEffect(iconScales[index])
                        
                        Text(LocalizationManager.shared.string(for: tab.title))
                            .font(ModernTheme.Typography.caption)
                    }
                    .foregroundColor(selectedTab == index ? ModernTheme.primary : ModernTheme.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, ModernTheme.Spacing.sm)
                    .background(
                        selectedTab == index ?
                        Capsule()
                            .fill(ModernTheme.primary.opacity(0.1))
                            .padding(.horizontal, ModernTheme.Spacing.xs) :
                        nil
                    )
                }
            }
        }
        .padding(ModernTheme.Spacing.xs)
        .background(
            Capsule()
                .fill(ModernTheme.glassWhite)
                .background(
                    .ultraThinMaterial,
                    in: Capsule()
                )
                .overlay(
                    Capsule()
                        .stroke(ModernTheme.glassBorder, lineWidth: 1)
                )
        )
        .shadow(
            color: ModernTheme.Shadow.small.color,
            radius: ModernTheme.Shadow.small.radius,
            x: 0,
            y: ModernTheme.Shadow.small.y
        )
        .onChange(of: selectedTab) { newValue in
            // Bounce animation for selected tab
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                iconScales[newValue] = 1.2
            }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7).delay(0.1)) {
                iconScales[newValue] = 1.0
            }
        }
    }
}

// MARK: - Floating Analysis Button
struct FloatingAnalysisButton: View {
    let action: () -> Void
    @State private var isPressed = false
    @State private var bounceAnimation = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ModernTheme.Spacing.sm) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 20, weight: .semibold))
                
                Text(LocalizationManager.shared.string(for: .analyzeNewOutfit))
                    .font(ModernTheme.Typography.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, ModernTheme.Spacing.lg)
            .padding(.vertical, ModernTheme.Spacing.md)
            .background(
                Capsule()
                    .fill(ModernTheme.primaryGradient)
                    .shadow(
                        color: ModernTheme.Shadow.colored.color,
                        radius: ModernTheme.Shadow.colored.radius,
                        x: 0,
                        y: ModernTheme.Shadow.colored.y
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .offset(y: bounceAnimation ? -5 : 0)
        }
        .buttonStyle(PlainButtonStyle())
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
                .easeInOut(duration: 2)
                .repeatForever(autoreverses: true)
            ) {
                bounceAnimation.toggle()
            }
        }
    }
}

// MARK: - Luxury Image Detail View
struct LuxuryImageDetailView: View {
    let imageURL: String
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                    .onTapGesture { dismiss() }
                
                // Image with pan and zoom
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = lastScale * value
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                }
                                .simultaneously(with:
                                    DragGesture()
                                        .onChanged { value in
                                            offset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                        }
                                        .onEnded { _ in
                                            lastOffset = offset
                                        }
                                )
                        )
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let mockAnalysis = FashionAnalysis(
        overallComment: "Your outfit perfectly captures a sophisticated yet approachable style! The combination of the navy blazer with white jeans creates a classic contrast that's ideal for a business meeting.",
        currentItems: [
            FashionItem(
                category: "top",
                description: "Navy blue blazer with structured shoulders",
                colorAnalysis: "Deep navy provides professional gravitas",
                styleNotes: "Well-fitted, appropriate for business settings"
            ),
            FashionItem(
                category: "bottom",
                description: "White straight-leg jeans",
                colorAnalysis: "Crisp white adds freshness",
                styleNotes: "Modern twist on traditional business wear"
            )
        ],
        suggestions: [
            FashionSuggestion(
                item: "Brown leather loafers",
                reason: "Would add warmth and complete the smart-casual look",
                searchQuery: "brown leather loafers women"
            )
        ]
    )
    
    FashionResultsView(
        analysis: mockAnalysis,
        audioManager: AudioPlayerManager(),
        audioURL: nil,
        isSearchingImages: false,
        onNewAnalysis: {}
    )
    .environmentObject(LocalizationManager.shared)
}
