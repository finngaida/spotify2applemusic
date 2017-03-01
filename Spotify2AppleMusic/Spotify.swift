//
//  Spotify.swift
//  Spotify2AppleMusic
//
//  Created by Mathias Quintero on 2/28/17.
//  Copyright © 2017 Finn Gaida. All rights reserved.
//

import UIKit
import SafariServices
import Sweeft

class Spotify {
    
    static var shared = Spotify()
    
    lazy var auth: SPTAuth! = {
        let auth = SPTAuth.defaultInstance()
        auth?.clientID = "987ecaba09cd47b1af5ecc13ad675aa9"
        let url = URL(string: "spotify2appleMusic://login/")
        auth?.redirectURL = url
        auth?.sessionUserDefaultsKey = "spotify session"
        auth?.requestedScopes = [SPTAuthUserLibraryReadScope]
        return auth
    }()
    
    var authViewController: UIViewController?
    
    var isLoggedIn: Bool {
        return auth.session?.isValid() ?? false
    }
    
    private init() {
    }
    
    private func handlePages<Item>(_ page: SPTListPage)  -> Promise<[Item], APIError>  {
        let promise = Promise<[Item], APIError>()
        let items = page.items.flatMap { $0 as? Item }
        if page.hasNextPage {
            page.requestNextPage(withAccessToken: auth.session.accessToken) { error, result in
                guard let result = result as? SPTListPage, error == nil else {
                    promise.error(with: .unknown(error: error!))
                    return
                }
                self.handlePages(result).nest(to: promise) { songs in
                    return items + songs
                }
            }
        } else {
            promise.success(with: items)
        }
        return promise
    }
    
    func playlists() -> Promise<[ImportSelection], APIError> {
        let promise = Promise<[ImportSelection], APIError>()
        guard let session = auth.session else {
            promise.error(with: .noData)
            return promise
        }
        SPTPlaylistList.playlists(forUser: session.canonicalUsername, withAccessToken: session.accessToken) { error, result in
            guard let result = result as? SPTListPage, error == nil else {
                promise.error(with: .unknown(error: error!))
                return
            }
            self.handlePages(result).nested({ $0 => ImportSelection.playlist }).nest(to: promise, using: id)
        }
        return promise
    }
    
    func songs(in playlist: SPTPartialPlaylist) -> Promise<[SpotifySong], APIError> {
        let promise = Promise<[SpotifySong], APIError>()
        SPTPlaylistSnapshot.playlist(withURI: playlist.uri, accessToken: auth.session.accessToken) { error, result in
            guard let result = result as? SPTPlaylistSnapshot, error == nil else {
                promise.error(with: .unknown(error: error!))
                return
            }
            let tracks = result.tracksForPlayback().flatMap { $0 as? SPTPlaylistTrack }
            let songs = tracks => SpotifySong.init(from:)
            promise.success(with: songs)
        }
        return promise
    }
    
    func fetchSongs() -> Promise<[SpotifySong], APIError> {
        let promise = Promise<[SpotifySong], APIError>()
        guard let session = auth.session else {
            promise.error(with: .noData)
            return promise
        }
        SPTYourMusic.savedTracksForUser(withAccessToken: session.accessToken) { error, result in
            guard let result = result as? SPTListPage, error == nil else {
                promise.error(with: .unknown(error: error!))
                return
            }
            self.handlePages(result).nested({ $0 => SpotifySong.init(from:) }).nest(to: promise, using: id)
        }
        return promise
    }
    
    func loginIfNeeded(viewController: UIViewController) {
        guard let session = auth.session, session.isValid() else {
            let url = auth.spotifyWebAuthenticationURL()
            authViewController = SFSafariViewController(url: url!)
            guard let vc = authViewController else {
                return
            }
            viewController.present(vc, animated: true)
            return
        }
    }
    
    func callback(url: URL) -> Bool {
        auth.handleAuthCallback(withTriggeredAuthURL: url) { error, session in
            self.authViewController?.dismiss(animated: true)
        }
        return true
    }
    
}
