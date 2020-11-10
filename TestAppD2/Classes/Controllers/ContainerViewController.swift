//
//  ContainerViewController.swift
//  TestAppD1
//
//  Created by  on 24/01/2019.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var leadingTabelViewLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingTableViewLayoutConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        navigationItem.title = ArrayOfTags.shared[0]
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestedTagNotification(_:)), name: NSNotification.Name.requestedTagNotification, object: nil)
    }

    // MARK: - Notification
    @objc func requestedTagNotification(_ notification: NSNotification) {
        let requestedTag = notification.object as? String ?? ""
        title = requestedTag
    }
    // MARK: - IBAction
    @IBAction func menu(_ sender: Any) {
        if leadingTabelViewLayoutConstraint.constant == 0 {
            leadingTabelViewLayoutConstraint.constant = UIScreen.main.bounds.size.width / 2
            trailingTableViewLayoutConstraint.constant = UIScreen.main.bounds.size.width * -0.5
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .layoutSubviews, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            leadingTabelViewLayoutConstraint.constant = 0
            trailingTableViewLayoutConstraint.constant = 0
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .layoutSubviews, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }    
}
