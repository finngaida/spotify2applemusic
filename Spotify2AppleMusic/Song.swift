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
    let artists: [String]
    let album: String
}

extension SpotifySong {
    
    init(from track: SPTTrack) {
        let artists = track.artists.flatMap { $0 as? SPTPartialArtist }
        self.init(name: track.name, artists: artists => { $0.name }, album: track.album.name)
    }
    
}

extension SpotifySong {
    
    var term: String {
        return "\(name) \(artists.first.?)"
    }
    
}

extension SpotifySong {
    
    func artistMatches(json: JSON) -> Bool {
        guard let artist = json["artistName"].string?.lowercased() else {
            return false
        }
        let artists = self.artists => { $0.lowercased() }
        return artists.join(with: " ").contains(artist) || !(artists |> artist.contains).isEmpty
    }
    
    func nameMatches(json: JSON) -> Bool {
        guard let name = json["name"].string?.songFormatted else {
            return false
        }
        let own = self.name.songFormatted
        return own.contains(name) || name.contains(own)
    }
    
    func albumMatches(json: JSON) -> Bool {
        guard let album = json["collectinName"].string?.songFormatted else {
            return false
        }
        return self.album.songFormatted.contains(album) || album.contains(self.album.songFormatted)
    }
    
}

extension String {
    
    var songFormatted: String {
        return lowercased().replacingOccurrences(of: " - ", with: " ").replacingOccurrences(of: "(", with: .empty).replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " single", with: "")
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
            return Song(name: song.name, artist: song.artists.first.?, id: $0)
        }
    }
    
}
