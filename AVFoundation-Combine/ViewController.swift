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

class ViewController: AVPlayerViewController {
    private let videoURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let player = AVPlayer(url: videoURL)
        
        player.playheadProgressPublisher()
            .sink { (time) in
                print("received playhead progress: \(time)")
            }
            .store(in: &subscriptions)
        
        player.statePublisher()
            .sink { state in
                print("received status:")
                switch state {
                case .unknown:
                    print(">> unknown")
                case .readyToPlay:
                    print(">> ready to play")
                case .failed:
                    print(">> failed")
                @unknown default:
                    print(">> other")
                }
            }
            .store(in: &subscriptions)
        
        self.player = player
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player?.play()
    }
}
