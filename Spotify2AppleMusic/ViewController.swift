//
//  ViewController.swift
//  Spotify2AppleMusic
//
//  Created by Finn Gaida on 28/02/2017.
//  Copyright © 2017 Finn Gaida. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func go() {
        guard let csv = parseCSV() else { return print("no csv") }
        
        MPMediaLibrary.requestAuthorization { (status) in
            guard status == MPMediaLibraryAuthorizationStatus.authorized else { return print("not authorized") }
            let myPlaylistsQuery = MPMediaQuery.playlists()
            guard let playlists = myPlaylistsQuery.collections else { return }
            
            for playlist in playlists {
                let name = playlist.value(forProperty: MPMediaPlaylistPropertyName) ?? "no name"
                let uuid = playlist.value(forProperty: MPMediaPlaylistPropertyPersistentID) ?? "no id"
                
                if let u = uuid as? UInt64, u == 16952020737016090427 {
                    print("Name: \(name), UUID: \(uuid)")
                    
                    if let plist = playlist as? MPMediaPlaylist {
                        
                        for id in csv {
                            plist.addItem(withProductID: id, completionHandler: { (error) in
                                if let e = error { print("\(id) didn't end so well: \(e)") }
                                else { print("added \(id)") }
                            })
                        }
                    }
                }
                
            }
        }
    }
    
    func parseCSV() -> [String]? {
        
        do {
            let str = try String(contentsOfFile: Bundle.main.path(forResource: "itunes", ofType: "csv")!)
            let ids = str.components(separatedBy: "\n")
            return ids
        } catch let e {
            print("error \(e)")
            return nil
        }
    }
    
}

