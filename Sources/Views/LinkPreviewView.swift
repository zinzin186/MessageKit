/*
 MIT License

 Copyright (c) 2017-2019 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

open class LinkPreviewView: UIView {
    lazy var imageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.numberOfLines = 0
        label.textColor = UIColor.fromHexCode("#1A1A1A")
        return label
    }()
    lazy var teaserLabel: UILabel = {
        let label: UILabel = .init()
        label.numberOfLines = 0
        label.textColor = UIColor.fromHexCode("#808080")
        return label
    }()

    private lazy var contentView: UIView = { [unowned self] in
        let view: UIView = .init(frame: .zero)
        return view
    }()
    
    init(frame: CGRect, tesaserHeight: CGFloat) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.fromHexCode("#F1F1F1")
        self.addSubview(imageView)
        self.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(teaserLabel)
        self.updateFrameSubviews(tesaserHeight: tesaserHeight)
    }
    
    func updateFrameSubviews(tesaserHeight: CGFloat) {
        let imageWidth: CGFloat = self.bounds.width
        let imageHeight: CGFloat = MKMessageConstant.Sizes.Preview.imageRatio * imageWidth
        imageView.frame = CGRect(0, 0, imageWidth, imageHeight)
        contentView.frame = CGRect(0, imageView.frame.maxY, imageWidth, self.bounds.height - imageHeight)
        
        let contentTextInset: UIEdgeInsets = MKMessageConstant.Sizes.Preview.contentTextInset
        titleLabel.frame = CGRect(contentTextInset.left, contentTextInset.top, contentView.frame.width - contentTextInset.horizontal, contentView.frame.height - tesaserHeight - contentTextInset.vertical - MKMessageConstant.Sizes.Preview.descPaddingTitle)
        teaserLabel.frame = CGRect(contentTextInset.left, titleLabel.frame.maxY + MKMessageConstant.Sizes.Preview.descPaddingTitle, contentView.frame.width - contentTextInset.horizontal, tesaserHeight)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
