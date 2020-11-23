//
//  ActionRemoveMessageView.swift
//  InputBarAccessoryView
//
//  Created by Din Vu Dinh on 10/10/20.
//

import UIKit

open class ActionRemoveMessageView: UIView {
    
    lazy var contentLabel: UILabel = {[unowned self] in
        let label: UILabel = .init()
        label.numberOfLines = 0
        label.font = UIFont.italicSystemFont(ofSize: 13)
        label.textColor = UIColor.fromHexCode("#808080")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(contentLabel)
        let contentInset = MKMessageConstant.ActionView.RemoveView.contentInset
        contentLabel.frame = CGRect(contentInset.left, contentInset.top, frame.width - contentInset.horizontal, frame.height - contentInset.vertical)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
}
