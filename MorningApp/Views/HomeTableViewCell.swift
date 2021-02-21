//
//  HomeTableViewCell.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/02/19.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    var usertext: String? {
        didSet {
            guard let text = usertext else { return }
            let width = estimateFrameForTextView(text: text).width + 20
            
            userTextWidthConstraint.constant = width
            userTextView.text = text
        }
    }

    @IBOutlet weak var userImgeView: UIImageView!
    @IBOutlet weak var userTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userTextWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        userImgeView.layer.cornerRadius = 25
        userTextView.layer.cornerRadius = 10
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    private func estimateFrameForTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
    }

}
