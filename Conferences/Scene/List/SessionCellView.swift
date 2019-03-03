//
//  Conferences
//
//  Created by Timon Blask on 12/02/19.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa

final class SessionCellView: NSTableCellView {
    private weak var imageDownloadOperation: Operation?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var colorContainer: NSView = {
        let v = NSView()
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor.green.cgColor
        v.width(0.7)

        return v
    }()

    override func prepareForReuse() {
        self.imageDownloadOperation?.cancel()

        super.prepareForReuse()
    }

    private lazy var nowPlayingImage: NSImageView = {
        let v = NSImageView()

        v.imageScaling = .scaleAxesIndependently
        v.image = NSImage(named: "speaker")
        v.isHidden = true

        v.height(15)
        v.width(15)

        return v
    }()

    private lazy var thumbnailImageView: NSImageView = {
        let v = NSImageView()

        v.imageScaling = .scaleAxesIndependently
        v.width(85)

        return v
    }()

    private lazy var titleLabel: NSTextField = {
        let l = NSTextField(labelWithString: "")
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.textColor = .primaryText
        l.cell?.backgroundStyle = .dark
        l.lineBreakMode = .byTruncatingTail
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return l
    }()

    private lazy var subtitleLabel: NSTextField = {
        let l = NSTextField(labelWithString: "")
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryText
        l.lineBreakMode = .byTruncatingTail

        return l
    }()

    private lazy var contextLabel: NSTextField = {
        let l = NSTextField(labelWithString: "")
        l.font = .systemFont(ofSize: 12)
        l.textColor = .tertiaryText
        l.lineBreakMode = .byTruncatingTail

        return l
    }()

    private lazy var textStackView: NSStackView = {
        let v = NSStackView(views: [self.titleLabel, self.subtitleLabel, self.contextLabel])

        v.orientation = .vertical
        v.alignment = .leading
        v.distribution = .fill
        v.spacing = 0

        return v
    }()


    private lazy var progressView: TrackColorView = {
        let v = TrackColorView()

        v.isHidden = true
        v.color = NSColor.lightGray
        v.width(4)

        return v
    }()

    private lazy var watchtedIndicator: NSImageView = {
        let v = NSImageView()

        v.isHidden = true
        v.image = #imageLiteral(resourceName: "watched-tick")
        v.width(10)
        v.height(10)

        return v
    }()

    private lazy var progressStackView: NSStackView = {
        let v = NSStackView(views: [self.progressView, self.watchtedIndicator])

        self.watchtedIndicator.centerY(to: v)

        return v
    }()

    private lazy var stackView: NSStackView = {
        let v = NSStackView(views: [self.textStackView, self.progressStackView])

        self.progressView.trailing(to: v)

        return v
    }()

    private func configureView() {
        addSubview(colorContainer)
        addSubview(thumbnailImageView)
        addSubview(nowPlayingImage)
        addSubview(stackView)

        nowPlayingImage.leading(to: self, offset: 10)
        nowPlayingImage.centerY(to: self)

        colorContainer.leading(to: nowPlayingImage, offset: 30)
        colorContainer.topToSuperview()
        colorContainer.bottomToSuperview()

        thumbnailImageView.top(to: self, offset: 6)
        thumbnailImageView.bottom(to: self, offset: -6)
        thumbnailImageView.leadingToTrailing(of: colorContainer, offset: 20)

        progressStackView.top(to: stackView)
        progressStackView.bottom(to: stackView)

        stackView.top(to: thumbnailImageView)
        stackView.bottom(to: thumbnailImageView)
        stackView.leadingToTrailing(of: thumbnailImageView, offset: 6)
        stackView.trailing(to: self, offset: -40)
    }

    func configureView(with model: TalkModel) {
        titleLabel.stringValue = model.title

        subtitleLabel.stringValue = "\(model.speaker.firstname) \(model.speaker.lastname)"
        contextLabel.stringValue = model.tags.filter { !$0.contains("2019") && !$0.contains("2018") && !$0.contains("2017") && !$0.contains("2016")}.joined(separator: " • ")

        colorContainer.layer?.backgroundColor = NSColor(hexString: model.highlightColor).cgColor

        progressView.isHidden = true
        watchtedIndicator.isHidden = true
        nowPlayingImage.isHidden = true

        if let progress = model.progress {

            if model.currentlyPlaying {
                nowPlayingImage.isHidden = false
            }

            if progress.relativePosition == 1 && progress.watched {
                watchtedIndicator.isHidden = false
            } else if progress.relativePosition > 0 {
                progressView.isHidden = false
                progressView.hasValidProgress = true
                progressView.progress = progress.relativePosition
            }
        }


        guard let imageUrl = URL(string: model.previewImage) else { return }
        self.imageDownloadOperation?.cancel()
        self.thumbnailImageView.image = NSImage(named: "placeholder")

        self.imageDownloadOperation = ImageDownloadCenter.shared.downloadImage(from: imageUrl, thumbnailHeight: 150) { [weak self] url, _, thumb in
            guard url == imageUrl, thumb != nil else { return }

            self?.thumbnailImageView.image = thumb
        }
    }


}
