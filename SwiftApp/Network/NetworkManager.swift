//
//  NetworkManager.swift
//  GuardianRPM
//
//  Created by Mathews on 25/10/17.
//  Copyright © 2017 guardian. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper


/// The network manager employs two different network routes.
/// 1. Authenticated network calls
///    For web services with an authentication token, use the alamofire route.
///    Use the sessionRequest(urlEndPoint: String, parameters: [String: Any], methodType: HTTPMethod, encoding: ParameterEncoding) -> DataRequest; method to route the requests through alamofire session manager.
///    The Alamofire session manager handles the authorization token expiry and the succeeding refresh of the token.
///
/// 2. UnAuthenticated network calls
///    For web services without an authentication token, use the NSURL session route.
///    Use the fireNetworkService(_ url: URLConvertible, method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: HTTPHeaders? = nil, completionHandler: @escaping (URLResponse?, Data?)-> Void); method to route the requests through alamofire session manager.
///    These calls are routed through the deafult NSURLSession without URL caching

//MARK:- Network Manager Web Service requests
class NetworkManager {
    
    func login(parameter: [String: String], completionHandler: @escaping (_ status: APIErrorStatus, _ responseObject: BaseResponse?) -> Void) {
        let urlStr = NetworkConstants.serverUrl + NetworkConstants.login
        self.fireNetworkService(urlStr, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: self.getHTTPHeaders()) { (response, data) in
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                    let loginResponse = Mapper<BaseResponse>().map(JSON: json)
                    
                    DispatchQueue.main.async {
                        completionHandler(self.getErrorStatusForHTTPResponse(response as? HTTPURLResponse), loginResponse)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completionHandler(.failure, nil)
                    }
                }
            }
            catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completionHandler(.failure, nil)
                }
            }
        }
    }
    
    func getNotificationList(parameter: [String: Any], completionHandler: @escaping (_ status: APIErrorStatus, _ responseObject: BaseResponse?) -> Void) {
        
        self.sessionRequest(urlEndPoint: NetworkConstants.serverUrl + "your sub url", parameters: parameter, methodType: .get, encoding: URLEncoding.default).responseObject { (response: DataResponse<BaseResponse>) in
            completionHandler(self.getErrorStatusForHTTPResponse(response.response), response.result.value)
        }
    }
    
}

// MARK: - Network Manager Routers
extension NetworkManager {
    
    /// Routes the web service through Alamofire session manager
    ///
    /// - Parameters:
    ///   - urlEndPoint: HTTP request url
    ///   - parameters: HTTP request body parameters
    ///   - methodType: HTTP request method
    ///   - encoding: parameter encoding
    /// - Returns: Alamofire data request
    func sessionRequest(urlEndPoint: String, parameters: [String: Any], methodType: HTTPMethod, encoding: ParameterEncoding) -> DataRequest {
        
        let accessToken = UserDefaults.standard.value(forKey: StringKeyConstants.accessTokenKey) as? String
        let refreshToken = UserDefaults.standard.value(forKey: StringKeyConstants.refreshTokenKey) as? String
        if accessToken != nil {
            let sessionManager = Alamofire.SessionManager.default
            let retrier = OAuth2Handler(baseURLString: NetworkConstants.serverUrl.removingPercentEncoding!,
                                        accessToken: accessToken ?? "",
                                        refreshToken: refreshToken  ?? "")
            sessionManager.adapter = retrier
            sessionManager.retrier = retrier
            
            return sessionManager.request(urlEndPoint, method: methodType, parameters: parameters, encoding: encoding, headers: self.getHTTPHeaders()).validate(statusCode: 200..<401)
        }else {
            
            return Alamofire.request(urlEndPoint, method: methodType, parameters: parameters, encoding: encoding, headers: self.getHTTPHeaders()).validate(statusCode: 200..<401)
        }
    }
    
    /// Fires the network service using custom NSURLSession
    /// Method doesnot employ Alamofire Network Manager
    /// URLCaching is not employed and hence session logouts are handled
    ///
    /// - Parameters:
    ///   - url:                The URL.
    ///   - method:             The HTTP method. `.get` by default.
    ///   - parameters:         The parameters. `nil` by default.
    ///   - encoding:           The parameter encoding. `URLEncoding.default` by default.
    ///   - headers:            The HTTP headers. `nil` by default.
    ///   - completionHandler:  Returns the URLResponse and Data objects if available
    func fireNetworkService(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        completionHandler: @escaping (URLResponse?, Data?)-> Void) {
        
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: config)
        do {
            var urlRequest = try URLRequest(url: url, method: method, headers: headers)
            switch method {
            case .post:
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .put:
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            default:
                break
            }
            if let parameter = parameters {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameter, options: .prettyPrinted)
            }
            let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                completionHandler(response, data)
            })
            task.resume()
            session.finishTasksAndInvalidate()
        }
        catch {
            print(error.localizedDescription)
            completionHandler(nil, nil)
        }
    }
    
    /// Uploads the image to the server as multipart form data
    ///
    /// - Parameters:
    ///   - referenceId: reference ID of the image
    ///   - reference: reference type of the image
    ///   - image: image to be uploaded
    ///   - completionHandler: completion handler
    func uploadImageToServer(referenceId: String, reference: String, image: UIImage, completionHandler: @escaping (_ status: APIErrorStatus, _ responseObject: BaseResponse?) -> Void)  {
        if let data = UIImageJPEGRepresentation(image,0.5) {
            var headers = self.getHTTPHeaders()
            headers["reference"] = reference
            headers["referenceid"] = referenceId
            
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(data, withName: "file", fileName: "file", mimeType: "image/jpeg")
            },
                to: "Your File Upload URL",
                method: .post,
                headers: headers,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseObject { (response: DataResponse<BaseResponse>) in
                            completionHandler(self.getErrorStatusForHTTPResponse(response.response), response.result.value)
                        }
                    case .failure(let encodingError):
                        debugPrint(encodingError)
                    }
            })
        }
    }
}

extension NetworkManager {
    
    /// Analyses HTTP status code and returns API error status
    ///
    /// - Parameter response: HTTP URL response
    /// - Returns: API Error status for corresponding HTTP status code
    func getErrorStatusForHTTPResponse(_ response: HTTPURLResponse?) -> APIErrorStatus{
        var status = 0
        if let res = response{
            status = res.statusCode
        }
        if (status == 401) {
            return .sessionExpired
        }
        else if (status >= 200 && status < 300) {
            return .success
        } else if (status >= 300 && status < 500) {
            return .failure
        } else {
            return .networkError
        }
    }
    
    
    /// Configures the http header for the network call
    ///
    /// - Returns: returns the configured header dictionary
    func getHTTPHeaders() -> Dictionary<String, String> {
        var httpHeader = [String: String]()
        return httpHeader
    }
    
    /// Retrieves the access token from response header and saves it
    ///
    /// - Parameter response: HTTP response
    func saveAccessToken(_ response: HTTPURLResponse) {
        let headers = response.allHeaderFields
        if let token = headers["Authorization"] as? String {
            UserDefaults.standard.set(String(format: "%@", token), forKey: StringKeyConstants.accessTokenKey)
        }
    }
}

