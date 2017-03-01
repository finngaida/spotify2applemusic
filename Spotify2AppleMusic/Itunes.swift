//
//  Itunes.swift
//  Spotify2AppleMusic
//
//  Created by Mathias Quintero on 3/1/17.
//  Copyright © 2017 Finn Gaida. All rights reserved.
//

import Sweeft

enum ItunesEndpoint: String, APIEndpoint {
    case search = "search"
}

struct Itunes: API {
    typealias Endpoint = ItunesEndpoint
    let baseURL: String = "https://itunes.apple.com/WebObjects/MZStore.woa/wa/"
}

extension Itunes {
    
    func search(for song: SpotifySong) -> Promise<Song?, APIError> {
        return doJSONRequest(to: .search,
                             headers: ["X-Apple-Store-Front" : "143446-10,32 ab:rSwnYxS0 t:music2", "X-Apple-Tz" : "7200"],
                             queries: ["clientApplication": "MusicPlayer", "term": song.name]).nested { json, promise in
                                
                                
                                let possibleSongs = json["storePlatformData"]["lockup"]["results"].dict => lastArgument |> { $0["kind"].string == "song" }
                                let matchingSongs = possibleSongs |> { (item: JSON) in
                                    return item["artistName"].string?.lowercased() == song.artist.lowercased() && item["name"].string?.lowercased() == song.name.lowercased()
                                }
                                let albumMatchingSongs = matchingSongs |> { $0["collectinName"].string?.lowercased() == song.album.lowercased() }
                                let dict = albumMatchingSongs.first ?? matchingSongs.first
                                let song = dict?["id"].string | Song.initializer(for: song)
                                promise.success(with: song)
        }
    }
    
    func search(for songs: [SpotifySong]) -> Promise<[Song], APIError> {
        return BulkPromise(promises: songs => { self.search(for: $0) }).nested {
            return $0.flatMap { $0 }
        }
    }
    
}
