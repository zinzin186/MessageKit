//
//  ContextMenuTVC.swift
//  ContextMenuSwift
//
//  Created by Umer Jabbar on 13/06/2020.
//  Copyright © 2020 Umer jabbar. All rights reserved.
//

import UIKit

open class ContextMenuCell: UITableViewCell {
    
    static let identifier = "ContextMenuCell"

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let stackView: UIStackView = {
        let stv = UIStackView(frame: .zero)
        stv.axis = .horizontal
        stv.alignment = .center
        stv.distribution = .fill
        stv.spacing = 12
        stv.translatesAutoresizingMaskIntoConstraints = false
        return stv
    }()
        
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    private func setupView() {
        self.contentView.addSubview(stackView)
        stackView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 14).isActive = true
        stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -10).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)

        iconImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        titleLabel.heightAnchor.constraint(equalTo: self.stackView.heightAnchor).isActive = true
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
//        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            self.contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        }else{
            self.contentView.backgroundColor = .clear
        }
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
        self.titleLabel.textColor = UIColor.black
        self.iconImageView.image = nil
        
    }
    
    open func configure(action: ContextMenuAction, style : ContextMenuConstants? = nil) {
        self.titleLabel.text = action.title
        self.titleLabel.numberOfLines = 0
        self.titleLabel.textColor = action.tintColor
        if let menuConstants = style {
            self.titleLabel.font = menuConstants.LabelDefaultFont
        }
        self.iconImageView.isHidden = (action.image == nil)
        iconImageView.image = action.image?.withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = action.tintColor
    }
    
}
