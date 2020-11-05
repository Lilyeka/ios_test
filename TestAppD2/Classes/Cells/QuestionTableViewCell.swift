//
//  QuestionTableViewCell.swift
//  TestAppD1
//
//  Created by  on 24/01/2019.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

class QuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var quesionLabel: UILabel!
    @IBOutlet weak var autorLabel: UILabel!
    @IBOutlet var dateModificationLabel: UILabel!
    @IBOutlet weak var numberOfAnswerLabel: UILabel!
    @IBOutlet weak var corneredView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        corneredView.layer.cornerRadius = 20
        corneredView.layer.masksToBounds = false
        corneredView.layer.shadowOpacity = 0.2
        corneredView.layer.shadowColor = UIColor.black.cgColor
        corneredView.layer.shadowOffset = CGSize.zero
        corneredView.layer.shadowRadius = 5
    }

    func fill(_ question: Item?) {
        quesionLabel.text = question?.title
        autorLabel.text = question?.owner?.display_name
        numberOfAnswerLabel.text = String(format: "%li", Int(question?.answer_count ?? 0))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm d-MM-yyyy"
        if let aFormat = question?.smartDateFormat {
            let aDate = Date.init(timeIntervalSince1970: TimeInterval(exactly: ((question?.last_activity_date)!))!)
            dateModificationLabel.text = "\(dateFormatter.string(from: aDate)) \(aFormat)"
        }
    }

}
