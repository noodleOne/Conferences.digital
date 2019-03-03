//
//  PUIButton.swift
//  PlayerUI
//
//  Created by Guilherme Rambo on 29/04/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

import Cocoa

public final class PUIButton: NSControl {

    public var isToggle = false

    public var activeTintColor: NSColor = .playerHighlight {
        didSet {
            needsDisplay = true
        }
    }

    public var tintColor: NSColor = .buttonColor {
        didSet {
            needsDisplay = true
        }
    }

    public var state: NSControl.StateValue = .off {
        didSet {
            needsDisplay = true
        }
    }

    public var showsMenuOnLeftClick = false
    public var showsMenuOnRightClick = false
    public var sendsActionOnMouseDown = false

    public var image: NSImage? {
        didSet {
            guard let image = image else { return }

            if image.isTemplate {
                maskImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
            } else {
                maskImage = nil
            }

            invalidateIntrinsicContentSize()
        }
    }

    public var alternateImage: NSImage? {
        didSet {
            guard let alternateImage = alternateImage else { return }

            if alternateImage.isTemplate {
                alternateMaskImage = alternateImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
            } else {
                alternateMaskImage = nil
            }

            invalidateIntrinsicContentSize()
        }
    }

    private var maskImage: CGImage? {
        didSet {
            needsDisplay = true
        }
    }

    private var alternateMaskImage: CGImage? {
        didSet {
            needsDisplay = true
        }
    }

    public override func draw(_ dirtyRect: NSRect) {
        if let maskImage = maskImage {
            if let alternateMaskImage = alternateMaskImage, state == .on {
                drawMask(alternateMaskImage)
            } else {
                drawMask(maskImage)
            }
        } else {
            if let alternateImage = alternateImage, state == .on {
                drawImage(alternateImage)
            } else {
                drawImage(image)
            }
        }
    }

    private func drawMask(_ maskImage: CGImage) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }

        ctx.clip(to: bounds, mask: maskImage)

        if shouldDrawHighlighted || state == .on || shouldAlwaysDrawHighlighted {
            ctx.setFillColor(activeTintColor.cgColor)
        } else if !isEnabled {
            let color = shouldAlwaysDrawHighlighted ? activeTintColor : tintColor
            ctx.setFillColor(color.withAlphaComponent(0.5).cgColor)
        } else {
            ctx.setFillColor(tintColor.cgColor)
        }

        ctx.fill(bounds)
    }

    private func drawImage(_ image: NSImage?) {
        image?.draw(in: bounds)
    }

    public override var intrinsicContentSize: NSSize {
        if let image = image {
            return image.size
        } else {
            return NSSize(width: -1, height: -1)
        }
    }

    private var shouldDrawHighlighted: Bool = false {
        didSet {
            needsDisplay = true
        }
    }

    public var shouldAlwaysDrawHighlighted: Bool = false {
        didSet {
            needsDisplay = true
        }
    }

    public override var isEnabled: Bool {
        didSet {
            needsDisplay = true
        }
    }

    public override func mouseDown(with event: NSEvent) {
        guard isEnabled else { return }

        guard !showsMenuOnLeftClick else {
            showMenu(with: event)
            return
        }

        shouldDrawHighlighted = true

        if !sendsActionOnMouseDown {
            window?.trackEvents(matching: [.leftMouseUp, .leftMouseDragged], timeout: NSEvent.foreverDuration, mode: .eventTracking) { event, stop in
                if event?.type == .leftMouseUp {
                    self.shouldDrawHighlighted = false
                    stop.pointee = true
                }
            }
        }

        if let action = action, let target = target {
            if isToggle {
                state = (state == .on) ? .off : .on
            }
            NSApp.sendAction(action, to: target, from: self)
        }
    }

    public override func rightMouseDown(with event: NSEvent) {
        guard showsMenuOnRightClick else {
            return
        }
        showMenu(with: event)
    }

    private func showMenu(with event: NSEvent) {
        guard let menu = menu else { return }

        menu.popUp(positioning: nil, at: .zero, in: self)
    }

    public override var effectiveAppearance: NSAppearance {
        if #available(OSX 10.14, *) {
            return super.effectiveAppearance
        } else {
            return NSAppearance(named: .vibrantDark)!
        }
    }

    public override var allowsVibrancy: Bool {
        return true
    }

    public override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }

}
