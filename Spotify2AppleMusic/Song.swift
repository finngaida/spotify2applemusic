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

enum ItunesEndpoint: String, APIEndpoint {
    case search = "search"
}

struct ItunesAPI: API {
    typealias Endpoint = ItunesEndpoint
    let baseURL: String = "https://itunes.apple.com/WebObjects/MZStore.woa/wa/"
}

extension ItunesAPI {
    
    func search(for song: SpotifySong) -> Promise<String?, APIError> {
        return doJSONRequest(to: .search,
                             headers: ["X-Apple-Store-Front" : "143446-10,32 ab:rSwnYxS0 t:music2", "X-Apple-Tz" : "7200"],
                             queries: ["clientApplication": "MusicPlayer", "term": song.name]).nested { json, promise in
                       
                                
            let possibleSongs = json["storePlatformData"]["lockup"]["results"].dict => lastArgument |> { $0["kind"].string == "song" }
            let matchingSongs = possibleSongs |> { (item: JSON) in
                return item["artistName"].string?.lowercased() == song.artist.lowercased() && item["name"].string?.lowercased() == song.name.lowercased() && item["collectionName"].string?.lowercased() == song.album.lowercased()
            }
            promise.success(with: matchingSongs.first?["id"].string)
        }
    }
    
    func search(for songs: [SpotifySong]) -> String.Results {
        return BulkPromise(promises: songs => { self.search(for: $0) }).nested {
            return $0.flatMap { $0 }
        }
    }
    
}
