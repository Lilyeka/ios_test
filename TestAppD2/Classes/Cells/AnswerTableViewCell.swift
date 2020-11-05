//
//  AnswerTableViewCell.swift
//  TestAppD1
//
//  Created by  on 24/01/2019.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

class AnswerTableViewCell: UITableViewCell {

    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var lastActivityDateLabel: UILabel!
    @IBOutlet weak var numberOfVotesLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    func fill(_ answer: AnswerItem?) {
        backgroundColor = UIColor.white
        var answerBody = answer?.body
        let attributedString = NSMutableAttributedString(string: answer?.body ?? "")
        let pattern = "<code>[^>]+</code>"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let matches = regex?.matches(in: answerBody ?? "", options: [], range: NSRange(location: 0, length: answerBody?.count ?? 0))
        for match in matches ?? [] {
                attributedString.addAttribute(.backgroundColor, value: UIColor(red: 0, green: 110.0 / 255.0, blue: 200.0 / 255.0, alpha: 0.5), range: match.range)
            if let aSize = UIFont(name: "Courier", size: 17) {
                attributedString.addAttribute(.font, value: aSize, range: match.range)
            }
        }
        var cycle: Bool = true
        while cycle {
            if let aSearch = (answerBody as NSString?)?.range(of: "<[^>]+>", options: .regularExpression), aSearch.location != NSNotFound {
                attributedString.removeAttribute(.backgroundColor, range: aSearch)
                attributedString.replaceCharacters(in: aSearch, with: "\n")
                answerBody = (answerBody as NSString?)?.replacingCharacters(in: aSearch, with: "\n")
            } else {
                cycle = false
            }
        }
        answerLabel.attributedText = attributedString
        authorLabel.text = answer?.owner?.display_name
        numberOfVotesLabel.text = String(format: "%li", Int(answer?.score ?? 0))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm d-MM-yyyy"
        if let last_activity_date = answer?.last_activity_date {
            lastActivityDateLabel.text = "\(dateFormatter.string(from: Date.init(timeIntervalSince1970: TimeInterval(exactly: last_activity_date)!)))"
        }
        checkImageView.isHidden = (answer?.is_accepted != nil) ?? true
    }
    
}
