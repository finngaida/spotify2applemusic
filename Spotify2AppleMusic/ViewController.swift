//
//  ViewController.swift
//  Spotify2AppleMusic
//
//  Created by Finn Gaida on 28/02/2017.
//  Copyright © 2017 Finn Gaida. All rights reserved.
//

import UIKit
import Sweeft
import MediaPlayer

class ViewController: UIViewController {
    
    @IBOutlet weak var loader: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.frame = CGRect(x: 0, y: self.view.frame.height - 5, width: self.view.frame.width, height: 5)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Spotify.shared.loginIfNeeded(viewController: self)
    }
    
    func setProgress(p: CGFloat) {
        UIView.animate(withDuration: 0.2) { 
            self.loader.frame = CGRect(x: 0, y: self.loader.frame.origin.y, width: self.view.frame.width * p, height: self.loader.frame.height)
        }
    }
    
    @IBAction func go() {
        
        Spotify.shared.fetchSongs().onSuccess { songs in
            return ItunesAPI().search(for: songs)
        }
        .future
        .onSuccess(call: self.handle)
    }
    
    func handle(songs: [String]) {
        MPMediaLibrary.requestAuthorization { (status) in
            guard status == MPMediaLibraryAuthorizationStatus.authorized else { return print("not authorized") }
            let myPlaylistsQuery = MPMediaQuery.playlists()
            guard let playlists = myPlaylistsQuery.collections else { return }
            
            self.setProgress(p: 0)
            
            func continueWith(index: Int) {
                if let plist = playlists[index] as? MPMediaPlaylist {
                    songs => { id, index in
                        plist.addItem(withProductID: id, completionHandler: { (error) in
                            if let e = error { print("\(id) didn't end so well: \(e)") }
                            else {
                                print("added \(index): \(id)")
                                self.setProgress(p: CGFloat(index + 1) / CGFloat(songs.count))
                            }
                        })
                    }
                }
            }
            
            
            let action = UIAlertController(title: "Choose your playlist", message: "add \(songs.count) tracks", preferredStyle: .actionSheet)
            for (i, playlist) in playlists.enumerated() {
                let name = playlist.value(forProperty: MPMediaPlaylistPropertyName) ?? "no name"
                
                action.addAction(UIAlertAction(title: "\(name)", style: .default, handler: { _ in
                    continueWith(index: i)
                }))
            }
            action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(action, animated: true, completion: nil)
        }
    }
    
}

