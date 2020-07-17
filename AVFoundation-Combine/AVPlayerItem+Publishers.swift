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

extension AVPlayerItem {
    func isPlaybackLikelyToKeepUpPublisher() -> Publishers.PlayerItemIsPlaybackLikelyToKeepUpPublisher {
        Publishers.PlayerItemIsPlaybackLikelyToKeepUpPublisher(playerItem: self)
    }
}
