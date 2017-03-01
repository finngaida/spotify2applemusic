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

extension JSON {
    
    var isSong: Bool {
        let offers = self["offers"].array => { $0["price"].double } |> { $0 == 0.0 }
        return self["kind"].string == "song" && !offers.isEmpty
    }
    
}

extension Itunes {
    
    func search(for song: SpotifySong) -> Promise<Song?, APIError> {
        return doJSONRequest(to: .search,
                             headers: ["X-Apple-Store-Front" : "143446-10,32 ab:rSwnYxS0 t:music2", "X-Apple-Tz" : "7200"],
                             queries: ["clientApplication": "MusicPlayer", "term": song.term, "entity": "song"]).nested { json, promise in
                                
                                
                                let songs = json["storePlatformData"]["lockup"]["results"].dict => lastArgument |> { $0.isSong }
                                let possibleSongs = songs |> song.artistMatches
                                let matchingSongs = possibleSongs |> song.nameMatches
                                let albumMatchingSongs = matchingSongs |> song.albumMatches
                                let dict = albumMatchingSongs.first ?? matchingSongs.first
                                if dict == nil {
                                    print("Didn't find \(song.term)")
                                }
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
