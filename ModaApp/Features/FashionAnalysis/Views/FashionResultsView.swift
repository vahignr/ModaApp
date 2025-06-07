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
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.lg) {
            // Overall Comment Card
            OverallCommentCard(
                comment: analysis.overallComment,
                audioManager: audioManager,
                audioURL: audioURL
            )
            
            // Tab Selection
            CustomSegmentedControl(
                selection: $selectedTab,
                options: ["Current Outfit", "Style Suggestions"]
            )
            .padding(.horizontal)
            .onChange(of: selectedTab) { _, newValue in
                print("📱 Tab changed to: \(newValue == 0 ? "Current Outfit" : "Style Suggestions")")
            }
            
            // Tab Content - FIXED: Using conditional views instead of TabView
            Group {
                if selectedTab == 0 {
                    // Current Items Tab
                    CurrentItemsView(
                        items: analysis.currentItems,
                        expandedItems: $expandedItems
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
                } else {
                    // Suggestions Tab
                    SuggestionsView(
                        suggestions: analysis.suggestions,
                        isSearchingImages: isSearchingImages,
                        showFullImage: $showFullImage,
                        selectedImageURL: $selectedImageURL
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
            
            // New Analysis Button
            Button(action: onNewAnalysis) {
                PrimaryButton(
                    title: "Analyze New Outfit",
                    systemImage: "camera.fill",
                    style: .primary
                )
            }
            .padding(.horizontal, ModernTheme.Spacing.xl)
            .padding(.bottom, ModernTheme.Spacing.lg)
        }
        .sheet(isPresented: $showFullImage) {
            if let imageURL = selectedImageURL {
                ImageDetailView(imageURL: imageURL)
            }
        }
        .onAppear {
            print("📋 FashionResultsView appeared")
            print("   - Current items: \(analysis.currentItems.count)")
            print("   - Suggestions: \(analysis.suggestions.count)")
            for (index, suggestion) in analysis.suggestions.enumerated() {
                print("     \(index + 1). \(suggestion.item) - Has \(suggestion.searchResults?.count ?? 0) images")
            }
        }
    }
}

// MARK: - Overall Comment Card
struct OverallCommentCard: View {
    let comment: String
    @ObservedObject var audioManager: AudioPlayerManager
    let audioURL: URL?
    @State private var isExpanded = true
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundColor(ModernTheme.primary)
                
                Text("AI Stylist Analysis")
                    .font(ModernTheme.Typography.headline)
                    .foregroundColor(ModernTheme.textPrimary)
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(ModernTheme.primary)
                }
            }
            
            if isExpanded {
                // Comment Text
                Text(comment)
                    .font(ModernTheme.Typography.body)
                    .foregroundColor(ModernTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Audio Controls
                if audioURL != nil {
                    VStack(spacing: ModernTheme.Spacing.sm) {
                        AudioProgressView(audio: audioManager)
                        
                        HStack(spacing: ModernTheme.Spacing.md) {
                            Button {
                                audioManager.toggle()
                            } label: {
                                Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(ModernTheme.sageGradient)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(audioManager.isPlaying ? "Playing Analysis" : "Listen to Analysis")
                                    .font(ModernTheme.Typography.callout)
                                    .foregroundColor(ModernTheme.textPrimary)
                                
                                Text("AI Stylist Voice")
                                    .font(ModernTheme.Typography.caption)
                                    .foregroundColor(ModernTheme.textSecondary)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.top, ModernTheme.Spacing.xs)
                }
            }
        }
        .padding(ModernTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                .fill(ModernTheme.surface)
                .shadow(
                    color: ModernTheme.Shadow.medium.color,
                    radius: ModernTheme.Shadow.medium.radius,
                    x: ModernTheme.Shadow.medium.x,
                    y: ModernTheme.Shadow.medium.y
                )
        )
        .padding(.horizontal)
    }
}

// MARK: - Current Items View
struct CurrentItemsView: View {
    let items: [FashionItem]
    @Binding var expandedItems: Set<UUID>
    
    var body: some View {
        ScrollView {
            VStack(spacing: ModernTheme.Spacing.md) {
                if items.isEmpty {
                    Text("No outfit items detected")
                        .font(ModernTheme.Typography.body)
                        .foregroundColor(ModernTheme.textSecondary)
                        .padding()
                } else {
                    ForEach(items) { item in
                        CurrentItemCard(
                            item: item,
                            isExpanded: expandedItems.contains(item.id),
                            onTap: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    if expandedItems.contains(item.id) {
                                        expandedItems.remove(item.id)
                                    } else {
                                        expandedItems.insert(item.id)
                                    }
                                }
                            }
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, ModernTheme.Spacing.xxl)
        }
        .onAppear {
            print("📋 CurrentItemsView appeared with \(items.count) items")
        }
    }
}

// MARK: - Current Item Card
struct CurrentItemCard: View {
    let item: FashionItem
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: ModernTheme.Spacing.sm) {
            // Header
            HStack {
                Image(systemName: item.categoryIcon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(item.categoryColor)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.category.capitalized)
                        .font(ModernTheme.Typography.headline)
                        .foregroundColor(ModernTheme.textPrimary)
                    
                    Text(item.description)
                        .font(ModernTheme.Typography.caption)
                        .foregroundColor(ModernTheme.textSecondary)
                        .lineLimit(isExpanded ? nil : 1)
                }
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(ModernTheme.primary)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: ModernTheme.Spacing.sm) {
                    // Color Analysis
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Color", systemImage: "paintpalette")
                            .font(ModernTheme.Typography.caption)
                            .foregroundColor(ModernTheme.primary)
                        
                        Text(item.colorAnalysis)
                            .font(ModernTheme.Typography.body)
                            .foregroundColor(ModernTheme.textPrimary)
                    }
                    
                    // Style Notes
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Style Notes", systemImage: "sparkles")
                            .font(ModernTheme.Typography.caption)
                            .foregroundColor(ModernTheme.primary)
                        
                        Text(item.styleNotes)
                            .font(ModernTheme.Typography.body)
                            .foregroundColor(ModernTheme.textPrimary)
                    }
                }
                .padding(.top, ModernTheme.Spacing.xs)
            }
        }
        .padding(ModernTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                .fill(ModernTheme.surface)
                .shadow(
                    color: ModernTheme.Shadow.small.color,
                    radius: ModernTheme.Shadow.small.radius,
                    x: ModernTheme.Shadow.small.x,
                    y: ModernTheme.Shadow.small.y
                )
        )
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Suggestions View
struct SuggestionsView: View {
    let suggestions: [FashionSuggestion]
    let isSearchingImages: Bool
    @Binding var showFullImage: Bool
    @Binding var selectedImageURL: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: ModernTheme.Spacing.lg) {
                if suggestions.isEmpty {
                    Text("No suggestions available")
                        .font(ModernTheme.Typography.body)
                        .foregroundColor(ModernTheme.textSecondary)
                        .padding()
                } else {
                    ForEach(suggestions) { suggestion in
                        SuggestionCard(
                            suggestion: suggestion,
                            isSearchingImages: isSearchingImages,
                            onImageTap: { imageURL in
                                selectedImageURL = imageURL
                                showFullImage = true
                            }
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, ModernTheme.Spacing.xxl)
        }
        .onAppear {
            print("📋 SuggestionsView appeared with \(suggestions.count) suggestions")
            for (index, suggestion) in suggestions.enumerated() {
                let imageCount = suggestion.searchResults?.count ?? 0
                print("  \(index + 1). \(suggestion.item) - Has \(imageCount) images")
                if imageCount > 0 {
                    print("       First image: \(suggestion.searchResults?.first?.imageUrl.prefix(50) ?? "N/A")...")
                }
            }
        }
    }
}

// MARK: - Suggestion Card
struct SuggestionCard: View {
    let suggestion: FashionSuggestion
    let isSearchingImages: Bool
    let onImageTap: (String) -> Void
    @State private var loadedImages: Set<String> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: ModernTheme.Spacing.md) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.item)
                        .font(ModernTheme.Typography.headline)
                        .foregroundColor(ModernTheme.textPrimary)
                    
                    Text(suggestion.reason)
                        .font(ModernTheme.Typography.callout)
                        .foregroundColor(ModernTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(ModernTheme.primary)
            }
            
            // Search Results Debug Info
            if let results = suggestion.searchResults {
                Text("Found \(results.count) images")
                    .font(ModernTheme.Typography.caption2)
                    .foregroundColor(ModernTheme.textTertiary)
                    .padding(.horizontal, ModernTheme.Spacing.xs)
            }
            
            // Search Results
            if let results = suggestion.searchResults, !results.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: ModernTheme.Spacing.sm) {
                        ForEach(results.prefix(5)) { result in // Limit to 5 images for performance
                            SearchResultImage(
                                result: result,
                                isLoaded: loadedImages.contains(result.imageUrl),
                                onTap: {
                                    print("🖼️ Image tapped: \(result.imageUrl)")
                                    onImageTap(result.imageUrl)
                                },
                                onLoad: { loadedImages.insert(result.imageUrl) }
                            )
                        }
                    }
                    .padding(.horizontal, ModernTheme.Spacing.xs)
                }
            } else if isSearchingImages {
                // Loading state
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: ModernTheme.Spacing.sm) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                                .fill(ModernTheme.lightSage)
                                .frame(width: 120, height: 120)
                                .overlay(
                                    ProgressView()
                                        .tint(ModernTheme.primary)
                                )
                        }
                    }
                    .padding(.horizontal, ModernTheme.Spacing.xs)
                }
            } else {
                // No results state
                Text("No images found for this suggestion")
                    .font(ModernTheme.Typography.caption)
                    .foregroundColor(ModernTheme.textTertiary)
                    .padding(.horizontal, ModernTheme.Spacing.xs)
            }
            
            // Search Query Tag
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                Text(suggestion.searchQuery)
                    .font(ModernTheme.Typography.caption)
            }
            .foregroundColor(ModernTheme.textSecondary)
            .padding(.horizontal, ModernTheme.Spacing.sm)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(ModernTheme.lightSage)
            )
        }
        .padding(ModernTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                .fill(ModernTheme.surface)
                .shadow(
                    color: ModernTheme.Shadow.small.color,
                    radius: ModernTheme.Shadow.small.radius,
                    x: ModernTheme.Shadow.small.x,
                    y: ModernTheme.Shadow.small.y
                )
        )
        .onAppear {
            print("🃏 SuggestionCard appeared for: \(suggestion.item)")
            print("   Search results count: \(suggestion.searchResults?.count ?? 0)")
        }
    }
}

// MARK: - Search Result Image
struct SearchResultImage: View {
    let result: SearchResult
    let isLoaded: Bool
    let onTap: () -> Void
    let onLoad: () -> Void
    
    var body: some View {
        AsyncImage(url: URL(string: result.thumbnailUrl ?? result.imageUrl)) { phase in
            switch phase {
            case .empty:
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                    .fill(ModernTheme.lightSage)
                    .frame(width: 120, height: 120)
                    .overlay(
                        ProgressView()
                            .tint(ModernTheme.primary)
                    )
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium))
                    .onAppear {
                        print("✅ Image loaded successfully: \(result.imageUrl.prefix(50))...")
                        onLoad()
                    }
            case .failure(let error):
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                    .fill(ModernTheme.lightSage)
                    .frame(width: 120, height: 120)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .foregroundColor(ModernTheme.textTertiary)
                            Text("Failed")
                                .font(.caption2)
                                .foregroundColor(ModernTheme.textTertiary)
                        }
                    )
                    .onAppear {
                        print("❌ Image failed to load: \(error.localizedDescription)")
                        print("   URL: \(result.imageUrl)")
                    }
            @unknown default:
                EmptyView()
            }
        }
        .overlay(
            VStack {
                Spacer()
                if !result.title.isEmpty {
                    Text(result.title)
                        .font(ModernTheme.Typography.caption2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(4)
                        .lineLimit(2)
                        .padding(4)
                }
            }
        )
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Custom Segmented Control
struct CustomSegmentedControl: View {
    @Binding var selection: Int
    let options: [String]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selection = index
                    }
                } label: {
                    Text(option)
                        .font(ModernTheme.Typography.callout)
                        .fontWeight(selection == index ? .semibold : .regular)
                        .foregroundColor(selection == index ? .white : ModernTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, ModernTheme.Spacing.sm)
                        .background(
                            selection == index ? ModernTheme.primary : Color.clear
                        )
                }
            }
        }
        .background(ModernTheme.lightSage)
        .cornerRadius(ModernTheme.CornerRadius.medium)
    }
}

// MARK: - Image Detail View
struct ImageDetailView: View {
    let imageURL: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                        .tint(.white)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
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
}
