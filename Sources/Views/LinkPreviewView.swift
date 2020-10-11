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
        imageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: LinkPreviewMessageSizeCalculator.imageRatio),
//            imageView.widthAnchor.constraint(equalToConstant: LinkPreviewMessageSizeCalculator.imageViewSize),
//            imageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])

        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var teaserLabel: UILabel = {
        let label: UILabel = .init()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var contentView: UIView = { [unowned self] in
        let view: UIView = .init(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: LinkPreviewMessageSizeCalculator.previewPaddingTopBottom),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                          constant: 0),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -LinkPreviewMessageSizeCalculator.previewPaddingTopBottom)
        ])

        return view
    }()

    init() {
        super.init(frame: .zero)

        contentView.addSubview(titleLabel)
        let paddingLeftRight: CGFloat = LinkPreviewMessageSizeCalculator.paddingLeftRight
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: paddingLeftRight),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -paddingLeftRight)
        ])

        contentView.addSubview(teaserLabel)
        NSLayoutConstraint.activate([
            teaserLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,  constant: paddingLeftRight),
            teaserLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: LinkPreviewMessageSizeCalculator.previewDescPaddingTitle),
            teaserLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,  constant: -paddingLeftRight),
            teaserLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
//        teaserLabel.setContentHuggingPriority(.init(249), for: .vertical)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
