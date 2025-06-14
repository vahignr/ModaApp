//
//  AnimationExtensions.swift
//  ModaApp
//
//  Custom animations and transitions for luxury UI
//

import SwiftUI

// MARK: - Custom Transitions

extension AnyTransition {
    static var luxurySlide: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .trailing)
                .combined(with: .opacity)
                .combined(with: .scale(scale: 0.95)),
            removal: .move(edge: .leading)
                .combined(with: .opacity)
                .combined(with: .scale(scale: 1.05))
        )
    }
    
    static var fadeScale: AnyTransition {
        AnyTransition.scale(scale: 0.8)
            .combined(with: .opacity)
    }
    
    static var hero: AnyTransition {
        AnyTransition.modifier(
            active: HeroTransitionModifier(progress: 0),
            identity: HeroTransitionModifier(progress: 1)
        )
    }
    
    static var glassReveal: AnyTransition {
        AnyTransition.modifier(
            active: GlassRevealModifier(progress: 0),
            identity: GlassRevealModifier(progress: 1)
        )
    }
}

// MARK: - Hero Transition Modifier

struct HeroTransitionModifier: ViewModifier {
    let progress: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(progress)
            .scaleEffect(0.5 + (progress * 0.5))
            .rotationEffect(.degrees((1 - progress) * 180))
            .blur(radius: (1 - progress) * 10)
    }
}

// MARK: - Glass Reveal Modifier

struct GlassRevealModifier: ViewModifier {
    let progress: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(progress)
            .scaleEffect(progress, anchor: .bottom)
            .blur(radius: (1 - progress) * 20)
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity((1 - progress) * 0.6),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)
            )
    }
}

// MARK: - Parallax Effect

struct ParallaxMotionModifier: ViewModifier {
    @State private var offset: CGSize = .zero
    var magnitude: CGFloat = 10
    
    func body(content: Content) -> some View {
        content
            .offset(x: offset.width * magnitude, y: offset.height * magnitude)
            .onAppear {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    offset = CGSize(width: 1, height: 1)
                }
            }
    }
}

// MARK: - Floating Animation

struct FloatingAnimationModifier: ViewModifier {
    @State private var isFloating = false
    var delay: Double = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -10 : 10)
            .animation(
                .easeInOut(duration: 2)
                .repeatForever(autoreverses: true)
                .delay(delay),
                value: isFloating
            )
            .onAppear {
                isFloating = true
            }
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.3),
                            Color.white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.3)
                    .offset(x: isAnimating ? geometry.size.width : -geometry.size.width * 0.3)
                    .allowsHitTesting(false)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Particle Effect View

struct ParticleEffectView: View {
    let particleCount: Int = 50
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var scale: CGFloat
        var opacity: Double
        var color: Color
        var velocity: CGVector
        var lifetime: Double
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: 10, height: 10)
                        .scaleEffect(particle.scale)
                        .opacity(particle.opacity)
                        .position(particle.position)
                        .blur(radius: (1 - particle.opacity) * 3)
                }
            }
            .onAppear {
                startEmitting(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func startEmitting(in size: CGSize) {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            createParticle(in: size)
            updateParticles()
        }
    }
    
    private func createParticle(in size: CGSize) {
        let particle = Particle(
            position: CGPoint(x: size.width / 2, y: size.height),
            scale: CGFloat.random(in: 0.5...1.5),
            opacity: 1.0,
            color: [ModernTheme.primary, ModernTheme.secondary, ModernTheme.accent].randomElement()!,
            velocity: CGVector(
                dx: CGFloat.random(in: -50...50),
                dy: CGFloat.random(in: -200 ... -100)  // Fixed: Added space around range operator
            ),
            lifetime: 3.0
        )
        particles.append(particle)
    }
    
    private func updateParticles() {
        withAnimation(.linear(duration: 0.1)) {
            particles = particles.compactMap { particle in
                var updated = particle
                updated.position.x += updated.velocity.dx * 0.1
                updated.position.y += updated.velocity.dy * 0.1
                updated.opacity -= 0.03
                updated.scale *= 0.98
                updated.lifetime -= 0.1
                
                return updated.lifetime > 0 ? updated : nil
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    func parallaxEffect(magnitude: CGFloat = 10) -> some View {
        modifier(ParallaxMotionModifier(magnitude: magnitude))
    }
    
    func floatingAnimation(delay: Double = 0) -> some View {
        modifier(FloatingAnimationModifier(delay: delay))
    }
    
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Gesture Modifiers

struct ElasticDragGesture: ViewModifier {
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    var onDragEnded: ((CGSize) -> Void)?
    
    func body(content: Content) -> some View {
        content
            .offset(dragOffset)
            .scaleEffect(isDragging ? 0.95 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: dragOffset)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        dragOffset = CGSize(
                            width: value.translation.width * 0.5,
                            height: value.translation.height * 0.5
                        )
                    }
                    .onEnded { value in
                        isDragging = false
                        onDragEnded?(value.translation)
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            dragOffset = .zero
                        }
                    }
            )
    }
}

extension View {
    func elasticDrag(onDragEnded: ((CGSize) -> Void)? = nil) -> some View {
        modifier(ElasticDragGesture(onDragEnded: onDragEnded))
    }
}
