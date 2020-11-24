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
//        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
        
    lazy var lblAmountCoin: UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.font = MKMessageConstant.Fonts.amountDonate
//        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

//    public override init(frame: CGRect) {
//        super.init(frame: frame)
//        let contentInset = MKMessageConstant.ContentInsets.donate
//        let coinIconSize = MKMessageConstant.Sizes.Donate.iconCoin
//        self.backgroundColor = MKMessageConstant.Colors.Donate.background
//        self.addSubview(imageViewCoin)
//        imageViewCoin.frame = CGRect(frame.width - coinIconSize.width - contentInset.right, frame.midY - coinIconSize.height/2, coinIconSize.width, coinIconSize.height)
//        self.addSubview(lblAmountCoin)
//        lblAmountCoin.frame = CGRect(contentInset.left, contentInset.top, imageViewCoin.frame.maxX - 4, frame.height - contentInset.vertical)
//    }
    init() {
        super.init(frame: .zero)
        self.backgroundColor = MKMessageConstant.Colors.Donate.background
        self.addSubview(imageViewCoin)
        self.addSubview(lblAmountCoin)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let contentInset = MKMessageConstant.ContentInsets.donate
        let coinIconSize = MKMessageConstant.Sizes.Donate.iconCoin
        self.addSubview(imageViewCoin)
        imageViewCoin.frame = CGRect(frame.width - coinIconSize.width - contentInset.right, self.bounds.midY - coinIconSize.height/2, coinIconSize.width, coinIconSize.height)
        self.addSubview(lblAmountCoin)
        lblAmountCoin.frame = CGRect(contentInset.left, contentInset.top, imageViewCoin.frame.maxX - 4 - contentInset.horizontal, self.bounds.height - contentInset.vertical)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
}

