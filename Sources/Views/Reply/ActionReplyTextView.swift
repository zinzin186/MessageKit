//
//  ActionReplyTextView.swift
//  MessageKit
//
//  Created by Din Vu Dinh on 10/10/20.
//

import Foundation

open class ActionReplyTextView: UIView {
    
    lazy var contentLabel: UILabel = {[unowned self] in
        let label: UILabel = .init()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.fromHexCode("#808080")
      return label
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(contentLabel)
        let contentInset = MKMessageConstant.ActionView.ReplyView.contentTextInset
        contentLabel.frame = CGRect(contentInset.left, contentInset.top, frame.width - contentInset.horizontal, frame.height - contentInset.vertical)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
