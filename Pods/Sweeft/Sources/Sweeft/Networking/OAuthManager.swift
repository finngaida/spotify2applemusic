//
//  File.swift
//  Pods
//
//  Created by Mathias Quintero on 2/27/17.
//
//

import Foundation

public struct OAuthManager<V: APIEndpoint>: API {
    
    public typealias Endpoint = V
    public let baseURL: String
    public let clientID: String
    public let secret: String
    public let useBasicHttp: Bool
    public let useJSON: Bool
    
    public init(baseURL: String, clientID: String, secret: String, useBasicHttp: Bool = true, useJSON: Bool = false) {
        self.baseURL = baseURL
        self.clientID = clientID
        self.secret = secret
        self.useBasicHttp = useBasicHttp
        self.useJSON = useJSON
    }
    
    func auth() -> Auth {
        if useBasicHttp {
            return BasicAuth(username: clientID, password: secret)
        } else {
            return NoAuth.standard
        }
    }
    
    func body(with grant: Grant) -> [String:String] {
        var dict = grant.dict.dictionaryWithoutOptionals(byDividingWith: id)
        if !useBasicHttp {
            dict["client_id"] = clientID
            dict["client_secret"] = secret
        }
        return dict
    }
    
    private func jsonRequest(to endpoint: Endpoint, auth: Auth, body: [String: String]) -> OAuth.Result {
        return doObjectRequest(with: .post,
                               to: endpoint,
                               auth: auth,
                               body: body.mapValues({ $0.json }).json)
    }
    
    private func queriedRequest(to endpoint: Endpoint, auth: Auth, body: [String:String]) -> OAuth.Result {
        return doObjectRequest(with: .post, to: endpoint, queries: body, auth: auth)
    }
    
    private func requestAuth(to endpoint: Endpoint, with grant: Grant) -> OAuth.Result {
        let auth = self.auth()
        let body = self.body(with: grant)
        if useJSON {
            return jsonRequest(to: endpoint, auth: auth, body: body)
        } else {
            return queriedRequest(to: endpoint, auth: auth, body: body)
        }
    }
    
    public func refresh(at endpoint: Endpoint, with auth: OAuth) -> OAuth.Result {
        return requestAuth(to: endpoint, with: .refreshToken(token: auth.refreshToken))
    }
    
    public func authenticate(at endpoint: Endpoint, authorizationCode code: String) -> OAuth.Result {
        return requestAuth(to: endpoint, with: .authorizationCode(code: code))
    }
    
    public func authenticate(at endpoint: Endpoint, username: String, password: String, scope: String...) -> OAuth.Result {
        let scope = scope.isEmpty ? nil : scope.join(with: " ")
        let grant: Grant = .password(username: username, password: password, scope: scope)
        return requestAuth(to: endpoint, with: grant)
    }
    
}

public extension API {
    
    func oauthManager(clientID: String, secret: String, useBasicHttp: Bool = true, useJSON: Bool = false) -> OAuthManager<Self.Endpoint> {
        return OAuthManager(baseURL: self.baseURL, clientID: clientID, secret: secret, useBasicHttp: useBasicHttp, useJSON: useJSON)
    }
    
}
