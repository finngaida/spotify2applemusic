//
//  OAuth.swift
//  Pods
//
//  Created by Mathias Quintero on 1/4/17.
//
//

import Foundation

public struct OAuth: Auth {
    
    let token: String
    let tokenType: String
    let refreshToken: String?
    let expirationDate: Date?
    
    var isExpired: Bool {
        guard let expirationDate = expirationDate else {
            return false
        }
        return expirationDate < .now
    }
    
    public func apply(to request: inout URLRequest) {
        request.addValue("\(tokenType) \(token)", forHTTPHeaderField: "Authorization")
    }
    
}

extension OAuth: Deserializable {
    
    public init?(from json: JSON) {
        guard let token = json["access_token"].string,
            let tokenType = json["token_type"].string else {
                return nil
        }
        self.init(token: token, tokenType: tokenType,
                  refreshToken: json["refresh_token"].string, expirationDate: json["expiration"].date())
    }
    
}

extension OAuth: StatusSerializable {
    
    public init?(from status: [String : Any]) {
        guard let token = status["token"] as? String,
            let tokenType = status["tokenType"] as? String else {
                return nil
        }
        self.init(token: token, tokenType: tokenType, refreshToken: (status["refresh"] as? String),
                  expirationDate: (status["expiration"] as? String)?.date())
    }
    
    public var serialized: [String : Any] {
        var dict = [
            "token": token,
            "tokenType": tokenType
        ]
        dict["refresh"] <- refreshToken
        dict["expiration"] <- expirationDate?.string()
        return dict
    }
    
}

extension OAuth {
    
    public func store(using key: String) {
        OAuthStatus.key = OAUTHStatusKey(name: key)
        OAuthStatus.value = self
    }
    
    public static func stored(with key: String) -> OAuth? {
        OAuthStatus.key = OAUTHStatusKey(name: key)
        return OAuthStatus.value
    }
    
}

struct OAUTHStatusKey: StatusKey {
    let name: String
    
    var rawValue: String {
        return "OAUTH-\(name)"
    }
}

struct OAuthStatus: OptionalStatus {
    typealias Value = OAuth
    static var key = OAUTHStatusKey(name: "shared")
}
