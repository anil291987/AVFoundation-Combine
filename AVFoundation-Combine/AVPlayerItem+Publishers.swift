//
//  AVPlayerItem+Publishers.swift
//  AVFoundation-Combine
//
//  Created by Juan Carlos Ospina Gonzalez on 17/07/2020.
//  Copyright © 2020 József Vesza. All rights reserved.
//

import Foundation
import Combine
import AVKit

public extension AVPlayerItem {
    
    /// Publisher for the `isPlaybackLikelyToKeepUp` property.
    /// - Returns: Publisher for the `isPlaybackLikelyToKeepUp` property.
    func isPlaybackLikelyToKeepUpPublisher() -> Publishers.PlayerItemIsPlaybackLikelyToKeepUpPublisher {
        Publishers.PlayerItemIsPlaybackLikelyToKeepUpPublisher(playerItem: self)
    }
    
    /// Publisher for the `status` property.
    /// - Returns: Publisher for the `status` property.
    func statusPublisher() -> Publishers.PlayerItemStatusPublisher {
        Publishers.PlayerItemStatusPublisher(playerItem: self)
    }
}
