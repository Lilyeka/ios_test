//
//  MenuViewController.swift
//  TestAppD1
//
//  Created by  on 24/01/2019.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var menuTableView: UITableView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        menuTableView.delegate = self
        menuTableView.dataSource = self
    }
}
 
// MARK: - UITableViewDataSource
extension MenuViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArrayOfTags.shared.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellForMenuTableView", for: indexPath)
        cell.textLabel?.text = ArrayOfTags.shared[indexPath.row]
        return cell
    }
}
// MARK: - UITableViewDelegate
extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: NSNotification.Name.requestedTagNotification,
                                        object: ArrayOfTags.shared[indexPath.row])
    }
}
