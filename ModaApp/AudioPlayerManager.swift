//
//  AudioPlayerManager.swift
//  ModaApp
//
//  Created by Vahi Guner on 6/3/25.
//  Updated 6/3/25 – restore AVAudioSession configuration.
//
//  Observable wrapper around AVAudioPlayer.
//

import UIKit
import AVFoundation
import Combine

@MainActor
final class AudioPlayerManager: NSObject, ObservableObject {
    
    // MARK: Published state ---------------------------------------------------
    
    @Published private(set) var isPlaying   = false
    @Published private(set) var currentTime : TimeInterval = 0
    @Published private(set) var duration    : TimeInterval = 0
    
    // MARK: Internals ---------------------------------------------------------
    
    private var player : AVAudioPlayer?
    private var ticker : AnyCancellable?
    
    // MARK: Init --------------------------------------------------------------
    
    override init() {
        super.init()
        configureAudioSession()                 // 💡 key change
    }
    
    
    // MARK: Public API --------------------------------------------------------
    
    func load(fileURL: URL) throws {
        player = try AVAudioPlayer(contentsOf: fileURL)
        player?.delegate = self
        player?.prepareToPlay()
        duration = player?.duration ?? 0
        currentTime = 0
        isPlaying = false
    }
    
    func play() {
        guard let p = player else { return }
        try? AVAudioSession.sharedInstance().setActive(true)   // ensure active
        p.play()
        startTicker()
        isPlaying = true
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func pause() {
        player?.pause()
        stopTicker()
        isPlaying = false
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func toggle() { isPlaying ? pause() : play() }
    
    /// Seek to fractional position (0…1).
    func seek(to fraction: Double) {
        guard let p = player else { return }
        p.currentTime = fraction * p.duration
        currentTime  = p.currentTime
    }
    
    
    // MARK: - Private helpers -------------------------------------------------
    
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            print("Audio session setup failed:", error.localizedDescription)
        }
    }
    
    private func startTicker() {
        ticker = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, let p = player else { return }
                currentTime = p.currentTime
            }
    }
    
    private func stopTicker() { ticker?.cancel(); ticker = nil }
}


// MARK: - AVAudioPlayerDelegate ----------------------------------------------

extension AudioPlayerManager: AVAudioPlayerDelegate {
    
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer,
                                                 successfully flag: Bool) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            pause()
            currentTime = duration
        }
    }
}
