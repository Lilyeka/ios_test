//
//  FabricRequest.swift
//  TestAppD1
//
//  Created by  on 24/01/2019.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

class FabricRequest {
    
    let defaultSession = URLSession(configuration: .default)
    var errorMessage = ""
    var questions: [Item]? = []
    var answers: [AnswerItem]! = [AnswerItem()]
    
    func request(tagged stringTagged: String?, numberOfPageToLoad: Int, withBlock completionHandler: @escaping ([Item]?, String) -> Void) {
        let protocolHostPath = "https://api.stackexchange.com/2.2/questions"
        let parametrs = "order=desc&sort=activity&site=stackoverflow&key=G*0DJzE8SfBrKn4tMej85Q(("
        let stringURL = protocolHostPath + "?" + parametrs + "&pagesize=50&tagged=" + stringTagged! + String(format: "&page=%ld", numberOfPageToLoad)
        if CacheWithTimeInterval.objectForKey(stringURL) == nil {
            let stringURL = protocolHostPath + "?" + parametrs + "&pagesize=50&tagged=" + stringTagged! + String(format: "&page=%ld", numberOfPageToLoad)
            guard let url = URL(string: stringURL) else {
                return
            }
            let task: URLSessionDataTask = defaultSession.dataTask(with: url) {
                [weak self] (data, response, error) in
                if let error = error {
                    self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                } else if
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                        self?.updateSearchResults(data)
                        DispatchQueue.main.async {
                            completionHandler(self?.questions, self?.errorMessage ?? "")
                        }
                        CacheWithTimeInterval.set(data: data, for: stringURL)
                }
            }
            task.resume()
        } else {
            DispatchQueue.main.async {
                completionHandler(CacheWithTimeInterval.questionsForKey(stringURL), "")
            }
        }
    }

    func request(withQuestionID questionID: Int, withBlock completionHandler: @escaping ([AnswerItem]?, String) -> Void) {
        let protocolHostPath = "https://api.stackexchange.com/2.2/questions"
        let parametrs = "order=desc&sort=activity&site=stackoverflow&key=G*0DJzE8SfBrKn4tMej85Q(("
        let stringURL = String(format: "%@/%li/answers?%@&filter=!9YdnSMKKT", protocolHostPath, questionID, parametrs)
        guard let url = URL(string: stringURL) else {
            return
        }
        let task: URLSessionDataTask = defaultSession.dataTask(with: url) {
            [weak self] (data, response, error) in
            if let error = error {
                self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                self?.updateSearchResultsForAnswers(data)
                DispatchQueue.main.async {
                    completionHandler(self?.answers, self?.errorMessage ?? "")
                }
            }
        }
        task.resume()
    }

    // MARK: - Private Methods
    private func updateSearchResults(_ data: Data) {
        questions = [Item]()
        if let items = try? JSONDecoder().decode(Question.self, from: data).items {
            questions = items
        }
    }
    
    private func updateSearchResultsForAnswers(_ data: Data) {
        answers = [AnswerItem]()
        if let answerModel = try? JSONDecoder().decode(Answer.self, from: data) {
            answers = answerModel.items
        }
    }
    
}
