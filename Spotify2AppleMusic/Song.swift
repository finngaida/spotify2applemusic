//
//  Song.swift
//  Spotify2AppleMusic
//
//  Created by Mathias Quintero on 2/28/17.
//  Copyright © 2017 Finn Gaida. All rights reserved.
//

import Sweeft

struct SpotifySong {
    let name: String
    let artist: String
    let album: String
}

extension SpotifySong {
    
    init(from track: SPTTrack) {
        let artists = track.artists.flatMap { $0 as? SPTPartialArtist }
        self.init(name: track.name, artist: artists.first?.name ?? "Unknown Artists", album: track.album.name)
    }
    
}

struct Song {
    let name: String
    let artist: String
    let id: String
}

extension Song {
    
    static func initializer(for song: SpotifySong) -> (String) -> Song {
        return {
            return Song(name: song.name, artist: song.artist, id: $0)
        }
    }
    
}
