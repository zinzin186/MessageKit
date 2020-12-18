//
//  DonateView.swift
//  MessageKit
//
//  Created by Din Vu Dinh on 10/11/20.
//

open class DonateView: UIView {
    
    let imageViewCoin: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon-gcoin-suffix", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
        
    let lblAmountCoin: UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.font = MKMessageConstant.Fonts.amountDonate
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init() {
        super.init(frame: .zero)
        let contentInset = MKMessageConstant.ContentInsets.donate
        let coinIconSize = MKMessageConstant.Sizes.Donate.iconCoin
        self.backgroundColor = MKMessageConstant.Colors.Donate.background
        self.addSubview(imageViewCoin)
        NSLayoutConstraint.activate([
            imageViewCoin.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -contentInset.right),
            imageViewCoin.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageViewCoin.widthAnchor.constraint(equalToConstant: coinIconSize.width),
            imageViewCoin.heightAnchor.constraint(equalToConstant: coinIconSize.height)
        ])
        self.addSubview(lblAmountCoin)
        NSLayoutConstraint.activate([
            lblAmountCoin.trailingAnchor.constraint(equalTo: imageViewCoin.leadingAnchor, constant: -4),
            lblAmountCoin.topAnchor.constraint(equalTo: self.topAnchor, constant: contentInset.top),
            lblAmountCoin.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -contentInset.bottom),
            lblAmountCoin.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: contentInset.left),
        ])
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
}
