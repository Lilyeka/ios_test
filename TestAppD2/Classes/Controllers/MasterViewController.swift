//
//  ViewController.swift
//  TestAppD1
//
//  Created by  on 24/01/2019.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leadingTabelViewLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingTableViewLayoutConstraint: NSLayoutConstraint!
    // MARK: - Constants
    private let kCellIdentifier = "CellForQuestion"
    private let questionSevice = FabricRequest()
    
    // MARK: - Variables
    var questions: [Item]? = []
    var loadMoreStatus = false
    var numberOfPageToLoad: Int = 0
    var requestedTag = ""
    
    // MARK: - Views
    var activityIndicatorView: UIActivityIndicatorView!
    var refreshControl: UIRefreshControl?
    
    // MARK: - Recognisers
    var panRecognizer: UIPanGestureRecognizer?
    var screenEdgePanRecognizer: UIScreenEdgePanGestureRecognizer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        tableView.register(UINib(nibName: "QuestionTableViewCell", bundle: nil), forCellReuseIdentifier: kCellIdentifier)
        addRefreshControlOnTabelView()
        settingDynamicHeightForCell()
        addActivityIndicator()
        addNotificationObserver()
        requestedTag = ArrayOfTags.shared[0]
        definesPresentationContext = true
        questions = [Item]()
        loadQuestions()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath: IndexPath? = tableView.indexPathForSelectedRow
        let detailViewController = (segue.destination as? UINavigationController)?.topViewController as? DetailViewController
        let item = questions?[indexPath?.row ?? 0]
        detailViewController?.currentQuestion = item
        detailViewController?.loadAnswers()
        detailViewController?.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        detailViewController?.navigationItem.leftItemsSupplementBackButton = true
    }
    
    // MARK: - Private methods
    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestedTagNotification(_:)), name: NSNotification.Name.requestedTagNotification, object: nil)
    }
    private func loadQuestions() {
        numberOfPageToLoad = 1
        self.activityIndicatorView.startAnimating()
        questionSevice.request(tagged: requestedTag, numberOfPageToLoad: numberOfPageToLoad) { [unowned self] (questions, error) in
            if let questions = questions {
                self.questions = questions
                self.tableView.reloadData()
            }
            if !error.isEmpty {
                self.showErrorAlert(errorMessage: error)
            }
            self.activityIndicatorView.stopAnimating()
        }
        numberOfPageToLoad += 1
    }
    
    private func loadModeQuestions() {
        loadMoreStatus = true
        let bounds: CGRect = UIScreen.main.bounds
        activityIndicatorView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height - 50)
        activityIndicatorView.startAnimating()
        questionSevice.request(tagged: requestedTag, numberOfPageToLoad: numberOfPageToLoad) { [unowned self] (questions, error) in
            if let questions = questions {
                for q in questions {
                    self.questions?.append(q)
                }
                self.tableView.reloadData()
                self.numberOfPageToLoad += 1
                self.loadMoreStatus = false
            }
            if !error.isEmpty {
                self.showErrorAlert(errorMessage: error)
            }
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        }
    }
    
    private func addRefreshControlOnTabelView() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.reloadData), for: .valueChanged)
        refreshControl?.backgroundColor = UIColor.white
        if let refreshControl = refreshControl {
            tableView.addSubview(refreshControl)
        }
    }
    
    private func settingDynamicHeightForCell() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    private func addActivityIndicator() {
        activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.style = .gray
        let bounds: CGRect = UIScreen.main.bounds
        activityIndicatorView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        activityIndicatorView.hidesWhenStopped = true
        view.addSubview(activityIndicatorView)
    }
    
    private func showErrorAlert(errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc func reloadData() {
        loadQuestions()
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
       
    //MARK: -UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let actualPosition: CGFloat = scrollView.contentOffset.y
        let contentHeight: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
        if actualPosition >= contentHeight && actualPosition > 0 && loadMoreStatus == false {
            loadModeQuestions()
        }
    }

    // MARK: - Notification
    @objc func requestedTagNotification(_ notification: Notification?) {
        requestedTag = notification?.object as? String ?? ""
        loadQuestions()
    }
    
    // MARK: - IBAction
    @IBAction func slideMenu(_ sender: Any) {
        if leadingTabelViewLayoutConstraint.constant == 0 {
            leadingTabelViewLayoutConstraint.constant = UIScreen.main.bounds.size.width / 2
            trailingTableViewLayoutConstraint.constant = UIScreen.main.bounds.size.width * -0.5
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .layoutSubviews, animations: {
                self.view.layoutIfNeeded()
            })
            screenEdgePanRecognizer?.isEnabled = false
            panRecognizer?.isEnabled = true
            tableView.allowsSelection = false
        } else {
            leadingTabelViewLayoutConstraint.constant = 0
            trailingTableViewLayoutConstraint.constant = 0
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .layoutSubviews, animations: {
                self.view.layoutIfNeeded()
            })
            screenEdgePanRecognizer?.isEnabled = true
            panRecognizer?.isEnabled = false
            tableView.allowsSelection = true
        }
    }
}

// MARK: - UITableViewDataSource
extension MasterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath) as? QuestionTableViewCell
        if questions?.count ?? 0 > 0 {
            cell?.fill(questions?[indexPath.row])
        }
        return cell!
    }
}
// MARK: - UITableViewDelegate
extension MasterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DetailSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

