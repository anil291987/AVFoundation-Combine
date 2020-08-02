//
//  ViewController.swift
//  AVFoundation-Combine
//
//  Created by József Vesza on 2020. 07. 16..
//  Copyright © 2020. József Vesza. All rights reserved.
//

import UIKit
import AVKit

import Combine

final class VideoPlayerViewController: AVPlayerViewController {
    
    /// A sample video URL
    ///
    /// **Big Buck Bunny (2008)**
    ///
    /// A recently awoken enormous and utterly adorable fluffy rabbit is heartlessly harassed by a flying squirrel's gang of rodents who are determined to squash his happiness.
    private let videoURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
    
    /// A `Set` to store all our `Publisher` susbcriptions
    private var subscriptions = Set<AnyCancellable>()
    
    /// A flag to keep track of whether the user is using `progressSlider` to scrub trough the video timeline. Used to prevent the thumb in the slider from jumping back and forth while `seek` is in progress.
    private var isProgressSliderScrubbing: Bool = false
    
    lazy private var customUI: VideoPlayerView = {
        VideoPlayerView()
    }()
    
    // MARK: UI setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "Background")
        showsPlaybackControls = false
        guard let contentOverlayView = contentOverlayView else {
            fatalError("`contentOverlayView` is required.")
        }
        customUI.translatesAutoresizingMaskIntoConstraints = false
        contentOverlayView.addSubview(customUI)
        [
            customUI.leadingAnchor.constraint(equalTo: contentOverlayView.leadingAnchor),
            customUI.trailingAnchor.constraint(equalTo: contentOverlayView.trailingAnchor),
            customUI.topAnchor.constraint(equalTo: contentOverlayView.topAnchor),
            customUI.bottomAnchor.constraint(equalTo: contentOverlayView.bottomAnchor),
        ].forEach { $0.isActive = true}
        
        customUI.playbackButton.addTarget(self, action: #selector(togglePlayback), for: .touchUpInside)
        
        customUI.progressSlider.addTarget(self, action: #selector(onSliderThumbTouchedDown), for: .touchDown)
        customUI.progressSlider.addTarget(self, action: #selector(onSliderThumbTouchedUp), for: .touchUpOutside)
        customUI.progressSlider.addTarget(self, action: #selector(onSliderThumbTouchedUp), for: .touchUpInside)
    }
    
    // MARK: UI Actions
    
    // MARK: Scubber
    
    @objc private func onSliderThumbTouchedDown() {
        isProgressSliderScrubbing = true
    }
    
    @objc private func onSliderThumbTouchedUp() {
        player?.seek(to: CMTime(seconds: Double(customUI.progressSlider.value), preferredTimescale: 1)) {[weak self] _ in
            self?.isProgressSliderScrubbing = false
        }
    }
    
    // MARK: Play / Pause button
    
    @objc private func togglePlayback() {
        player?.rate == 0.0 ? player?.play() : player?.pause()
    }
    
    // MARK: Video Player setup
    
    private func setupAVPlayer() {
        player = AVPlayer()
        
        player?.currentItemPublisher()
            .filter { $0 != nil }
            .sink {[weak self] _ in
                self?.subscribeToPlayerItemPublishers()
            }
            .store(in: &subscriptions)
        
        player?.playheadProgressPublisher()
            .filter {progress in
                !self.isProgressSliderScrubbing
            }
            .sink {[weak self] progress in
                self?.customUI.progressSlider.value = Float(progress)
            }
            .store(in: &subscriptions)
        
        let rateStream = player?.ratePublisher().share()
        
        rateStream?.receive(on: DispatchQueue.main)
            .map { $0 == 0.0 ? "Play" : "Pause" }
            .assign(to: \.accessibilityLabel, on: customUI.playbackButton)
            .store(in: &subscriptions)
        
        rateStream?.receive(on: DispatchQueue.main)
            .map { $0 == 0.0 ? UIImage(named: "Play") : UIImage(named: "Pause") }
            .sink {[weak self] image in
                self?.customUI.playbackButton.setImage(image, for: .normal)
            }
            .store(in: &subscriptions)
        
        // Load our sample video
        player?.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
    }
    
    private func subscribeToPlayerItemPublishers() {
        
        player?.isPlaybackLikelyToKeepUpPublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: \.isHidden, on: customUI.loadingIndicator)
            .store(in: &subscriptions)
        
        player?.isPlaybackBufferEmptyPublisher()
            .receive(on: DispatchQueue.main)
            .map { !$0 }
            .assign(to: \.isHidden, on: customUI.loadingIndicator)
            .store(in: &subscriptions)
        
        let statusStream = player?.statusPublisher().share()
        
        statusStream?.receive(on: DispatchQueue.main)
            .map { $0 == .readyToPlay }
            .assign(to: \.isEnabled, on: customUI.playbackButton)
            .store(in: &subscriptions)
        
        statusStream?.receive(on: DispatchQueue.main)
            .map { $0 == .readyToPlay }
            .assign(to: \.isEnabled, on: customUI.progressSlider)
            .store(in: &subscriptions)
        
        statusStream?.receive(on: DispatchQueue.main)
            .map { $0 == .readyToPlay ? 1.0 : 0.25 }
            .assign(to: \.alpha, on: customUI.playbackButton)
            .store(in: &subscriptions)
        
        statusStream?.receive(on: DispatchQueue.main)
            .map { $0 == .readyToPlay ? 0.5 : 1.0 }
            .assign(to: \.alpha, on: customUI.logoImageView)
            .store(in: &subscriptions)
        
        player?.durationPublisher()
            .map { $0.isNumeric ? Float($0.seconds) : 0.0 }
            .assign(to: \.maximumValue, on: customUI.progressSlider)
            .store(in: &subscriptions)
    }
    
    // MARK: Lifecycle overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAVPlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player?.play()
    }
}
