//
//  DetailViewController.swift
//  TestAppD1
//
//  Created by  on 24/01/2019.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let kQuestionCellIdentifier = "CellForQuestion"
    private let kAnswerCellIdentifier = "CellForAnswer"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleNavigationItem: UINavigationItem!
    var refreshControl: UIRefreshControl!
    var activityIndicatorView: UIActivityIndicatorView!
    var answers: [AnswerItem]! = [AnswerItem()]
    var currentQuestion: Item!
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: "AnswerTableViewCell", bundle: nil), forCellReuseIdentifier: kAnswerCellIdentifier)
        tableView.register(UINib(nibName: "QuestionTableViewCell", bundle: nil), forCellReuseIdentifier: kQuestionCellIdentifier)
        addRefreshControlOnTabelView()
        settingDynamicHeightForCell()
        addActivityIndicator()
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if answers.count == 0 {
            activityIndicatorView.startAnimating()
        }
        return answers.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: kQuestionCellIdentifier, for: indexPath) as? QuestionTableViewCell
            cell?.fill(currentQuestion)
            titleNavigationItem.title = "\(String(describing: currentQuestion.title))"
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: kAnswerCellIdentifier, for: indexPath) as? AnswerTableViewCell
            var answer: AnswerItem?
            answer = answers?[indexPath.row - 1]
            cell?.fill(answer)
            return cell!
        }
    }
    
    @objc func reloadData() {
        tableView.reloadData()
        if refreshControl != nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, h:mm a"
            let title = "Last update: \(formatter.string(from: Date()))"
            let attrsDictionary = [NSAttributedString.Key.foregroundColor : UIColor.black]
            let attributedTitle = NSAttributedString(string: title, attributes: attrsDictionary)
            refreshControl?.attributedTitle = attributedTitle
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Public
    func loadAnswers() {
        FabricRequest.request(withQuestionID: currentQuestion.question_id!) { data in
            self.reload(inTableView: data)
        }
    }

    // MARK: - Private
    func addActivityIndicator() {
        activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.style = .gray
        let bounds: CGRect = UIScreen.main.bounds
        activityIndicatorView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        activityIndicatorView.hidesWhenStopped = true
        view.addSubview(activityIndicatorView)
    }
    
    func addRefreshControlOnTabelView() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.reloadData), for: .valueChanged)
        refreshControl?.backgroundColor = UIColor.white
        if let aControl = refreshControl {
            tableView.addSubview(aControl)
        }
    }
    
    func settingDynamicHeightForCell() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    func reload(inTableView jsonData: Data?) {
        answers = [AnswerItem]()
        if let answerModel = try? JSONDecoder().decode(Answer.self, from: jsonData!) {
            answers = answerModel.items
        }
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            self.activityIndicatorView.stopAnimating()
        })
    }

}
