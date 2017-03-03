//
//  ImportSelection.swift
//  Spotify2AppleMusic
//
//  Created by Mathias Quintero on 3/1/17.
//  Copyright © 2017 Finn Gaida. All rights reserved.
//

import Sweeft

enum ImportSelection {
    case all
    case playlist(SPTPartialPlaylist)
}

extension ImportSelection {
    
    var description: String {
        switch self {
        case .all:
            return "All Your Music"
        case .playlist(let playlist):
            return playlist.name
        }
    }
    
}

extension ImportSelection {
    
    func songs() -> Promise<[SpotifySong], APIError> {
        switch self {
        case .all:
            return Spotify.shared.fetchSongs()
        case .playlist(let playlist):
            return Spotify.shared.songs(in: playlist)
        }
    }
    
}
