//: Playground - noun: a place where people can play

import UIKit

enum E: Error {
    case dam(s:String)
}

let base = "https://itunes.apple.com/WebObjects/MZStore.woa/wa/search?clientApplication=MusicPlayer&term="

func search(name: String) throws {
    
    guard let path = name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else { throw E.dam(s:"path") }
    guard let url = URL(string: base+path) else { throw E.dam(s:"URL") }
    let jsonData = try NSData(contentsOf: url, options: NSData.ReadingOptions.mappedIfSafe)
//    let json = try JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.allowFragments)
    let json = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)
    
    print("\(json)")
}

do {
    try search(name: "call me maybe")
} catch let e {
    print("oops \(e)")
}