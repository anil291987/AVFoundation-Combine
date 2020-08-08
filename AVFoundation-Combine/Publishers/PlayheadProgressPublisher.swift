//
//  PlayheadProgressPublisher.swift
//  AVFoundation-Combine
//
//  Created by József Vesza on 2020. 07. 16..
//  Copyright © 2020. József Vesza. All rights reserved.
//

import Foundation
import Combine
import AVKit

public extension Publishers {
    struct PlayheadProgressPublisher: Publisher {
        public typealias Output = TimeInterval
        public typealias Failure = Never
        
        private let interval: TimeInterval
        private let player: AVPlayer
        
        init(interval: TimeInterval = 0.25, player: AVPlayer) {
            self.player = player
            self.interval = interval
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = PlayheadProgressSubscription(subscriber: subscriber,
                                                            interval: interval,
                                                            player: player)
            subscriber.receive(subscription: subscription)
        }
    }
    
    private final class PlayheadProgressSubscription<S: Subscriber>: Subscription where S.Input == TimeInterval {
        private var subscriber: S?
        private var requested: Subscribers.Demand = .none
        private var timeObserverToken: Any? = nil
        
        private let interval: TimeInterval
        private let player: AVPlayer
        
        private let lock = NSRecursiveLock()
        
        init(subscriber: S, interval: TimeInterval = 0.25, player: AVPlayer) {
            self.player = player
            self.subscriber = subscriber
            self.interval = interval
        }
        
        func request(_ demand: Subscribers.Demand) {
            withLock {
                processDemand(demand)
            }
        }
        
        private func processDemand(_ demand: Subscribers.Demand) {
            requested += demand
            guard timeObserverToken == nil, requested > .none else { return }
            
            let interval = CMTime(seconds: self.interval, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
                self?.sendValue(time)
            }
        }
        
        private func sendValue(_ time: CMTime) {
            withLock {
                guard let subscriber = subscriber, requested > .none else { return }
                requested -= .max(1)
                let newDemand = subscriber.receive(time.seconds)
                requested += newDemand
            }
        }
        
        func cancel() {
            withLock {
                if let timeObserverToken = timeObserverToken {
                    player.removeTimeObserver(timeObserverToken)
                }
                timeObserverToken = nil
                subscriber = nil
            }
        }
        
        private func withLock(_ operation: () -> Void) {
            lock.lock()
            defer { lock.unlock() }
            operation()
        }
    }
}

