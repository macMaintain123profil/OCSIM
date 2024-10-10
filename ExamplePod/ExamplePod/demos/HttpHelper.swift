//
//  HttpHelper.swift
//  ExamplePod
//
//  Created by flow on 10/10/24.
//

import Foundation
class HttpHelper {
    public static let shared = HttpHelper()
    
    static let host = "https://test-biz.68chat.co"
    
    typealias FromResponseBlock = (_ result: [String: Any]?, _ error: Error? ) -> Void
    var reqDict: [String: URLSessionDataTask] = [:]
    static func formRequest(url: String, paramsDict: [String: String], authName: String? = nil, authPwd: String? = nil, handler: FromResponseBlock? = nil) {
        let boundary = UUID().uuidString

        // Create the URL
        guard let url = URL(string: url) else { return }

        // Create a URLRequest object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Prepare the form data
        let httpBody = {
            var body = Data()
            for (rawName, rawValue) in paramsDict {
                if !body.isEmpty {
                    body.append("\r\n".data(using: .utf8)!)
                }
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                let disposition = "Content-Disposition: form-data; name=\"\(rawName)\"\r\n".data(using: .utf8)!
                body.append(disposition)
                body.append("\r\n".data(using: .utf8)!)
                let value = rawValue.data(using: .utf8)!
                body.append(value)
            }
            body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            return body
        }()
        if let authName = authName, authName.count > 0,
           let authPwd = authPwd, authPwd.count > 0 {
            let loginString = "\(authName):\(authPwd)"
            let loginData = loginString.data(using: .utf8)
            let base64LoginString = loginData?.base64EncodedString() ?? ""
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = httpBody
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                handler?(nil, error)
                HttpHelper.shared.reqDict.removeValue(forKey: boundary)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("Response Code: \(httpResponse.statusCode)")
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseString)")
                if let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    handler?(result, nil)
                    print(result)
                    HttpHelper.shared.reqDict.removeValue(forKey: boundary)
                    return
                }
            }
            handler?(nil, error)
            HttpHelper.shared.reqDict.removeValue(forKey: boundary)
        }
        HttpHelper.shared.reqDict[boundary] = task
        task.resume()
    }
    
    static func bearerTokenRequest(url: String, accessToken: String, handler: FromResponseBlock? = nil) {
           let boundary = UUID().uuidString

           // Create the URL
           guard let url = URL(string: url) else { return }

           // Create a URLRequest object
           var request = URLRequest(url: url)
           request.httpMethod = "GET"
           request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
           
           let task = URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   print("Error: \(error)")
                   handler?(nil, error)
                   HttpHelper.shared.reqDict.removeValue(forKey: boundary)
                   return
               }
               if let httpResponse = response as? HTTPURLResponse {
                   print("Response Code: \(httpResponse.statusCode)")
               }
               if let data = data, let responseString = String(data: data, encoding: .utf8) {
                   print("Response Data: \(responseString)")
                   if let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                       handler?(result, nil)
                       print(result)
                       HttpHelper.shared.reqDict.removeValue(forKey: boundary)
                       return
                   }
               }
               handler?(nil, error)
               HttpHelper.shared.reqDict.removeValue(forKey: boundary)
           }
           HttpHelper.shared.reqDict[boundary] = task
           task.resume()
       }
}
