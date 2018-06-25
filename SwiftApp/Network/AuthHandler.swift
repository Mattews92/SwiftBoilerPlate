//
//  AuthHandler.swift
//  SwiftApp
//
//  Created by Mathews on 25/06/18.
//  Copyright © 2018 Mathews. All rights reserved.
//

import Foundation
import Alamofire

class OAuth2Handler: RequestAdapter, RequestRetrier {
    private typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?, _ refreshToken: String?) -> Void
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return SessionManager(configuration: configuration)
    }()
    
    private let lock = NSLock()
    
    private var baseURLString: String
    private var accessToken: String
    private var refreshToken: String
    
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    // MARK: - Initialization
    
    public init(baseURLString: String, accessToken: String, refreshToken: String) {
        self.baseURLString = baseURLString
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    // MARK: - RequestAdapter
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(baseURLString) {
            var urlRequest = urlRequest
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            return urlRequest
        }
        
        return urlRequest
    }
    
    // MARK: - RequestRetrier
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                refreshTokens { [weak self] succeeded, accessToken, refreshToken in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
                    
                    if let accessToken = accessToken, let refreshToken = refreshToken {
                        strongSelf.accessToken = accessToken
                        strongSelf.refreshToken = refreshToken
                    }
                    
                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        } else {
            if request.retryCount == 3 {
                completion(false, 0.0)
                return
            }
            completion(true, 0.0)
            print("Request failed")
        }
    }
    
    // MARK: - Private - Refresh Tokens
    
    private func refreshTokens(completion: @escaping RefreshCompletion) {
        
        guard !isRefreshing else { return }
        isRefreshing = true
        let urlString = "\(baseURLString)"  + "\(NetworkConstants.refreshToken)"
        let params: [String: String] = ["refresh_token": self.refreshToken]
        sessionManager.request(urlString, method: .post, parameters: params, encoding: JSONEncoding.default, headers: [:])
            .responseJSON { [weak self] response in
                guard let strongSelf = self else { return }
                
                if
                    let json = response.result.value as? [String: Any],
                    let data = json["data"] as? [String: Any],
                    let accessToken = data["access_token"] as? String,
                    let refreshToken = data["refresh_token"] as? String
                {
                    UserDefaults.standard.set(String(format: "%@", accessToken), forKey: StringKeyConstants.accessTokenKey)
                    UserDefaults.standard.set(String(format: "%@", refreshToken), forKey: StringKeyConstants.refreshTokenKey)
                    completion(true, accessToken, refreshToken)
                }
                else {
                    if (response.response?.statusCode == 401) {
                        (UIApplication.shared.delegate as? AppDelegate)?.logoutAction(isSessionExpired: true)
                    }
                    completion(false, nil, nil)
                }
                
                strongSelf.isRefreshing = false
        }
    }
}
