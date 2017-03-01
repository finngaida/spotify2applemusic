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
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var loader: UIView!
    
    var selections: [ImportSelection] = [.all]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.frame = CGRect(x: 0, y: self.view.frame.height - 5, width: self.view.frame.width, height: 5)
        statusLabel.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Spotify.shared.loginIfNeeded(viewController: self)
        Spotify.shared.playlists().onSuccess { selections in
            self.selections = [.all] + selections
            self.pickerView.reloadComponent(0)
        }
    }
    
    func setProgress(p: CGFloat) {
        if p == 1.0 {
            statusLabel.text = ""
        }
        UIView.animate(withDuration: 0.5) {
            self.loader.frame = CGRect(x: 0, y: self.loader.frame.origin.y, width: self.view.frame.width * p, height: self.loader.frame.height)
        }
    }
    
    @IBAction func go() {
        statusLabel.text = "Fetching Songs from Spotify"
        self.setProgress(p: 0)
        let index = pickerView.selectedRow(inComponent: 0)
        selections[index].songs().onSuccess { songs -> Promise<[Song], APIError> in
            self.statusLabel.text = "Finding Counterparts in Itunes"
            return Itunes().search(for: songs)
        }
        .future
        .onSuccess(call: self.handle)
    }
    
    func handle(songs: [Song]) {
        statusLabel.text = ""
        MPMediaLibrary.requestAuthorization { (status) in
            guard status == MPMediaLibraryAuthorizationStatus.authorized else { return print("not authorized") }
            let myPlaylistsQuery = MPMediaQuery.playlists()
            guard let playlists = myPlaylistsQuery.collections else { return }
            
            func continueWith(index: Int) {
                self.statusLabel.text = "Adding Songs to your Library"
                if let plist = playlists[index] as? MPMediaPlaylist {
                    var added = 0
                    songs => { song, index in
                        plist.addItem(withProductID: song.id, completionHandler: { (error) in
                            .main >>> {
                                added += 1
                                if error != nil {
                                    self.statusLabel.text = "Failed to add \(song.name) by \(song.artist)"
                                } else {
                                    self.statusLabel.text = "Added \(song.name) by \(song.artist)"
                                }
                                self.setProgress(p: CGFloat(added) / CGFloat(songs.count))
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

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selections.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return selections[row].description
    }
    
}

