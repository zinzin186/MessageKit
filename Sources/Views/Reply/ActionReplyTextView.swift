//
//  ActionReplyTextView.swift
//  MessageKit
//
//  Created by Din Vu Dinh on 10/10/20.
//

import Foundation

open class ActionReplyTextView: UIView {
    
lazy var messageLabel: UILabel = {[unowned self] in
      let label: UILabel = .init()
      label.numberOfLines = 0
      label.font = UIFont.systemFont(ofSize: 13)
      label.textColor = UIColor.fromHexCode("#808080")
      label.translatesAutoresizingMaskIntoConstraints = false
      return label
  }()
    

    init() {
        super.init(frame: .zero)
        self.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            messageLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            messageLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -25)
        ])
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
}
