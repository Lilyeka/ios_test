//
//  FabricRequest.swift
//  TestAppD1
//
//  Created by  on 24/01/2019.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

class FabricRequest: NSObject {
    
    class func request(tagged stringTagged: String?, numberOfPageToLoad: Int, withBlock completionHandler: @escaping (_ data: Data?) -> Void) {
        let protocolHostPath = "https://api.stackexchange.com/2.2/questions"
        let parametrs = "order=desc&sort=activity&site=stackoverflow&key=G*0DJzE8SfBrKn4tMej85Q(("
        let stringURL = protocolHostPath + "?" + parametrs + "&pagesize=50&tagged=" + stringTagged! + String(format: "&page=%ld", numberOfPageToLoad)
        if CacheWithTimeInterval.objectForKey(stringURL) == nil {
            let stringURL = protocolHostPath + "?" + parametrs + "&pagesize=50&tagged=" + stringTagged! + String(format: "&page=%ld", numberOfPageToLoad)
            var request = URLRequest(url: URL(string: stringURL)!)
            request.httpMethod = "GET"
            let defaultConfiguration = URLSessionConfiguration.default
            let defaultSession = URLSession(configuration: defaultConfiguration)
            let task: URLSessionDataTask = defaultSession.dataTask(with: request) { (data, response, error) in
                completionHandler(data)
                CacheWithTimeInterval.set(data: data, for: stringURL)
            }
            task.resume()
        } else {
            completionHandler(CacheWithTimeInterval.objectForKey(stringURL))
        }
    }
    
    class func request(withQuestionID questionID: Int, withBlock completionHandler: @escaping (_ data: Data?) -> Void) {
        let protocolHostPath = "https://api.stackexchange.com/2.2/questions"
        let parametrs = "order=desc&sort=activity&site=stackoverflow&key=G*0DJzE8SfBrKn4tMej85Q(("
        let stringURL = String(format: "%@/%li/answers?%@&filter=!9YdnSMKKT", protocolHostPath, questionID, parametrs)
        var request = URLRequest(url: URL(string: stringURL)!)
        request.httpMethod = "GET"
        let defaultConfiguration = URLSessionConfiguration.default
        let defaultSession = URLSession(configuration: defaultConfiguration, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = defaultSession.dataTask(with: request) { (data, response, error) in
            completionHandler(data)
        }
        task.resume()
    }
}
