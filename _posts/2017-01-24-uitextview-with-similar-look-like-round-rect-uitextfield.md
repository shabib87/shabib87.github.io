---
title: "UITextView with similar look like rounded UITextField with dynamic height"
description: "How to build a rounded UITextView with placeholder support and dynamic height behavior for iOS forms."
date: 2017-01-24
permalink: /uitextview-with-similar-look-like-round-rect-uitextfield/
categories:
  - blog
  - programming
  - ios-programming
  - objective-c
  - swift
  - ios-programming
tags:
  - code
  - coding
  - development
  - expanding-textview
  - expanding-uitextview
  - ios
  - ios-programming
  - ipad
  - iphone
  - objective-c
  - programming
last_modified_at: 2017-01-24 01:12:42 +0000
---

Ever wanted to use an UITextView that looks like a rounded UITextFiled? Also, wished it will grow it’s height as you type your text? Well, you are in luck! Here is the swift file you will need.

> [TextViewWithPlaceholderAndExpandingHeight.swift](https://gist.github.com/shabib87/9fdf03eab6bd34f19452163273bb850d#file-textviewwithplaceholderandexpandingheight-swift)

```swift
/*

 TextViewWithPlaceholderAndExpandingHeight.swift
 TextViewWithPlaceholderAndExpandingHeight
 Created by Shabib Hossain on 1/24/17.

 Copyright (c) 2017 shabib87 <shabib.sust@gmail.com>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.

 */

import Foundation
import UIKit

class TextViewWithPlaceholderAndExpandingHeight: UITextView {

    @IBInspectable var placeHolderText: String!
    @IBInspectable var placeHolderColor: UIColor!

    private var placeHolderLabel: UILabel!
    private let defaultColor = UIColor(red:199.0/255.0, green:199.0/255.0, blue:205.0/255.0, alpha:1.0)
    private let UIPlaceholderTextChangeAnimationDuraiton = 0.25
    private let UIPlaceHolderLabelTag = 1901
    private let kMaxHeightForTextView = 90.0

    var currentDynamicHeight: CGFloat {
        get {
            return self.bounds.height
        }
    }

    override var text: String! {
        didSet {
            self.viewWithTag(self.UIPlaceHolderLabelTag)?.alpha = 0.0
            self.updateHeight()
        }
    }

    override func draw(_ rect: CGRect) {
        if !self.placeHolderText.isEmpty {
            if self.placeHolderLabel == nil {
                setupPlaceholderLabel()
            }
            self.placeHolderLabel.text = self.placeHolderText
            self.placeHolderLabel.sizeToFit()
            self.sendSubview(toBack: self.placeHolderLabel)
        }
        if self.text.isEmpty && !(self.placeHolderLabel.text?.isEmpty)! {
            self.viewWithTag(self.UIPlaceHolderLabelTag)?.alpha = 1
        }
        super.draw(rect)
    }

    private func setupPlaceholderLabel() {
        self.placeHolderLabel = UILabel(frame: CGRect(x: 8, y: 4, width: self.bounds.size.width - 16, height: 0))
        self.placeHolderLabel.lineBreakMode = .byWordWrapping
        self.placeHolderLabel.numberOfLines = 0
        self.placeHolderLabel.font = self.font
        self.placeHolderLabel.backgroundColor = .clear
        self.placeHolderLabel.textColor = self.placeHolderColor
        self.placeHolderLabel.alpha = 0
        self.placeHolderLabel.tag = self.UIPlaceHolderLabelTag
        self.addSubview(self.placeHolderLabel)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupPlaceholder()
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.setupPlaceholder()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupPlaceholder()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }

    private func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let whitescpaceSet = NSCharacterSet.whitespaces
        let range = string.rangeOfCharacter(from: whitescpaceSet)
        if let _ = range {
            return false
        } else {
            return true
        }
    }

    private func setupPlaceholder() {
        if self.placeHolderText == nil {
            self.placeHolderText = ""
        }
        if self.placeHolderColor == nil {
            self.placeHolderColor = defaultColor
        }
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 0.5
        self.layer.borderColor = defaultColor.cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(self.textChanged), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }

    @objc private func textChanged(notification: Notification?) {
        if self.placeHolderText.isEmpty {
            return
        }
        UIView.animate(withDuration: UIPlaceholderTextChangeAnimationDuraiton) {
            if self.text.isEmpty {
                self.viewWithTag(self.UIPlaceHolderLabelTag)?.alpha = 1.0
            } else {
                self.viewWithTag(self.UIPlaceHolderLabelTag)?.alpha = 0.0
            }
            self.updateHeight()
        }
    }

    private func updateHeight() {
        let fixedWidth = self.bounds.size.width
        let newSize = self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = self.frame
        var height = newSize.height
        if Double(newSize.height) >= kMaxHeightForTextView {
            height = CGFloat(kMaxHeightForTextView)
        }
        let maxWidth = CGFloat(fmax(Double(newSize.width), Double(fixedWidth)))
        newFrame.size = CGSize(width: maxWidth, height:height)
        self.frame = newFrame
        self.scrollRangeToVisible(NSMakeRange(self.text.characters.count, 0))
    }
}
```
