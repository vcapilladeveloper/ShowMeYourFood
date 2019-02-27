//
//  ConnectionEngine.swift
//  ConnectionModule
//
//  Created by Victor Capilla Developer on 23/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

// Manager to make the request to the API.
// In this project, all requests are GET type.
open class ConnectionEngine: NSObject {
    
    static var defaultSession: URLSession!
    static var dataGetTask: URLSessionDataTask?
    public typealias RequestResult = (_ data: Any?, _ error: Bool) -> Void
    
    // Function for make the request, default with GET method. Return reuslt in completionHandler 
    open class func getResult(_ url: URL, _ method: String = "GET", completionHandler: @escaping RequestResult) {
        // For prevent more than one task at the same time, I cancel previous task if exist
        dataGetTask?.cancel()

        defaultSession = URLSession(configuration: .default)
        var urlRequest = URLRequest(url: url)
       
        dataGetTask = defaultSession.dataTask(with: url) { data, response, error in
            if let response = response as? HTTPURLResponse { print(response.statusCode) }
            defer { self.dataGetTask = nil }
            if let error = error {
                completionHandler(data, true)
            } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode >= 200, response.statusCode <= 300 {
                print(data)
                completionHandler(data, false)
            } else {
                completionHandler(nil, true)
            }
        }
        // Execute the task
        defer {dataGetTask?.resume()}
    }
    
}
