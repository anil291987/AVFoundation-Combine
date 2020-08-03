//
//  AVPlayer+Publishers.swift
//  AVFoundation-Combine
//
//  Created by József Vesza on 2020. 07. 16..
//  Copyright © 2020. József Vesza. All rights reserved.
//

import Foundation
import Combine
import AVKit

public extension AVPlayer {
    
    // MARK: AVPlayer Publishers
    
    /// Publisher tracking playhead progress updates on `AVPlayer`
    /// - Returns: Publisher tracking playhead progress updates on `AVPlayer`
    func playheadProgressPublisher(interval: TimeInterval = 0.25) -> AnyPublisher<TimeInterval, Never> {
        Publishers.PlayheadProgressPublisher(interval: interval, player: self).eraseToAnyPublisher()
    }
    
    /// Publisher for the `rate` property.
    /// The current playback rate.
    /// - Returns: Publisher for the `rate` property.
    func ratePublisher() -> AnyPublisher<Float, Never> {
        publisher(for: \.rate).eraseToAnyPublisher()
    }
    
    /// Publisher for the `currentItem` property
    /// The player’s current player item.
    /// - Returns: Publisher for the `currentItem` property
    func currentItemPublisher() -> AnyPublisher<AVPlayerItem?, Never> {
         publisher(for: \.currentItem).eraseToAnyPublisher()
    }
    
    // MARK: AVPlayerItem Publishers
    
    /// Publisher for the `status` property in `AVPlayer.currentItem`
    /// A status that indicates whether the player can be used for playback.
    /// - Returns: Publisher for the `status` property in `AVPlayer.currentItem`
    func statusPublisher() -> AnyPublisher<AVPlayerItem.Status, Never> {
        guard let currentItem = currentItem else {
            return Empty().eraseToAnyPublisher()
        }
        return currentItem.statusPublisher()
    }
    
    /// Publisher for the `isPlaybackLikelyToKeepUp` property in `AVPlayer.currentItem`
    /// A Boolean value that indicates whether the item will likely play through without stalling.
    /// - Returns: Publisher for the `isPlaybackLikelyToKeepUp` property in `AVPlayer.currentItem`
    func isPlaybackLikelyToKeepUpPublisher() -> AnyPublisher<Bool, Never> {
        guard let currentItem = currentItem else {
            return Empty().eraseToAnyPublisher()
        }
        return currentItem.isPlaybackLikelyToKeepUpPublisher()
    }
    
    /// Publisher for the `isPlaybackBufferEmpty` property.
    /// A Boolean value that indicates whether playback has consumed all buffered media and that playback will stall or end.
    /// - Returns: Publisher for the `isPlaybackBufferEmpty` property.
    func isPlaybackBufferEmptyPublisher() -> AnyPublisher<Bool, Never> {
        guard let currentItem = currentItem else {
            return Empty().eraseToAnyPublisher()
        }
        return currentItem.isPlaybackBufferEmptyPublisher()
    }
    
    /// Publisher for the `duration` property
    func durationPublisher() -> AnyPublisher<CMTime, Never> {
        guard let currentItem = currentItem else {
            return Empty().eraseToAnyPublisher()
        }
        return currentItem.durationPublisher()
    }
}
