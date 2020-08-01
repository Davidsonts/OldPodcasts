//
//  PlayerService.swift
//  Podcasts
//
//  Created by Eugene Karambirov on 07/04/2019.
//  Copyright © 2019 Eugene Karambirov. All rights reserved.
//

import Foundation
import ModernAVPlayer

final class PlayerService {

    var playerState: ModernAVPlayer.State {
        player.state
    }

    var currentTime: Double {
        player.currentTime
    }

    private var metadata: ModernAVPlayerMediaMetadata?
    private var media: ModernAVPlayerMedia?
    private var player = ModernAVPlayer(loggerDomains: [.state, .error])

    func load(episode: Episode) {
        // TODO: - Add playing from fileURL
        guard
            let episodeURL = URL(string: episode.streamUrl.httpsUrlString),
            let imageURL = URL(string: episode.imageUrl?.httpsUrlString ?? "")
        else { return }

        metadata = ModernAVPlayerMediaMetadata(title: episode.title, artist: episode.author, remoteImageUrl: imageURL)
        media = ModernAVPlayerMedia(url: episodeURL, type: .stream(isLive: true), metadata: metadata)

        guard let media = media else { return }
        player.load(media: media, autostart: true)
    }

    // MARK: - Playing commands
    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func stop() {
        player.stop()
    }

    func rewind() {
        player.seek(position: -15)
    }

    func fastForward() {
        player.seek(position: 15)
    }

    func seek(to position: Double) {
        player.seek(position: position)
    }

//    func changeVolume(value: Double) {
//
//    }
}
