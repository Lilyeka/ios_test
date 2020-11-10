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
    
    let answersService = FabricRequest()
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: "AnswerTableViewCell", bundle: nil), forCellReuseIdentifier: kAnswerCellIdentifier)
        tableView.register(UINib(nibName: "QuestionTableViewCell", bundle: nil), forCellReuseIdentifier: kQuestionCellIdentifier)
        addRefreshControlOnTabelView()
        settingDynamicHeightForCell()
        addActivityIndicator()
        activityIndicatorView.startAnimating()
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        loadAnswers()
    }
    
    // MARK: - Public
    func loadAnswers() {
        guard let questionId = currentQuestion.question_id else {return}
        answersService.request(withQuestionID: questionId) {
            [unowned self] (answers, errorMessage) in
            if let answers = answers {
                self.answers = answers
                self.tableView.reloadData()
            }
            if !errorMessage.isEmpty {
                self.showErrorAlert(errorMessage: errorMessage)
            }
            self.activityIndicatorView.stopAnimating()
            if self.refreshControl != nil {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, h:mm a"
                let title = "Last update: \(formatter.string(from: Date()))"
                let attrsDictionary = [NSAttributedString.Key.foregroundColor : UIColor.black]
                let attributedTitle = NSAttributedString(string: title, attributes: attrsDictionary)
                self.refreshControl?.attributedTitle = attributedTitle
                self.refreshControl?.endRefreshing()
            }
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
    
    func showErrorAlert(errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}
