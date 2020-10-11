//
//  DonateView.swift
//  MessageKit
//
//  Created by Din Vu Dinh on 10/11/20.
//

open class DonateView: UIView {
    
    var imageViewCoin: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon-gcoin-suffix", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
        
    lazy var lblAmountCoin: UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.fromHexCode("#9E57D1")
        let padding: CGFloat = 12
        self.addSubview(imageViewCoin)
        let coinImageSize: CGFloat = 16.0
        NSLayoutConstraint.activate([
            imageViewCoin.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
            imageViewCoin.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageViewCoin.widthAnchor.constraint(equalToConstant: coinImageSize),
            imageViewCoin.heightAnchor.constraint(equalToConstant: coinImageSize)
        ])
        self.addSubview(lblAmountCoin)
        NSLayoutConstraint.activate([
            lblAmountCoin.trailingAnchor.constraint(equalTo: imageViewCoin.leadingAnchor, constant: -5),
            lblAmountCoin.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            lblAmountCoin.heightAnchor.constraint(equalToConstant: 22),
            lblAmountCoin.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
        ])
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
}

