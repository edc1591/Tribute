//
//  Tribute.swift
//  Tribute
//
//  Created by Sash Zats on 11/26/15.
//  Copyright © 2015 Sash Zats. All rights reserved.
//

import Foundation


public struct Attributes {
    typealias RawAttributes = [String: AnyObject]
    
    public enum TextEffect {
        case letterpress
    }
    
    public enum GlyphDirection {
        case vertical
        case horizontal
    }
    
    public enum Stroke {
        case notFilled(width: Float)
        case filled(width: Float)
    }
    
    public var alignment: NSTextAlignment?
    public var backgroundColor: UIColor?
    public var baseline: Float?
    public var color: UIColor?
    public var direction: GlyphDirection?
    public var expansion: Float?
    public var font: UIFont?
    public var kern: Float?
    public var leading: Float?
    public var ligature: Bool?
    public var obliqueness: Float?
    public var strikethrough: NSUnderlineStyle?
    public var strikethroughColor: UIColor?
    public var stroke: Stroke?
    public var strokeColor: UIColor?
    public var textEffect: TextEffect?
    public var underline: NSUnderlineStyle?
    public var underlineColor: UIColor?
    public var URL: Foundation.URL?
    
    public var lineBreakMode: NSLineBreakMode?
    public var lineHeightMultiplier: Float?
    public var paragraphSpacingAfter: Float?
    public var paragraphSpacingBefore: Float?
    public var headIndent: Float?
    public var tailIndent: Float?
    public var firstLineHeadIndent: Float?
    public var minimumLineHeight: Float?
    public var maximumLineHeight: Float?
    public var hyphenationFactor: Float?
    public var allowsTighteningForTruncation: Bool?
}

private extension Attributes.TextEffect {
    init?(stringValue: String) {
        if stringValue == NSTextEffectLetterpressStyle {
            self = .letterpress
        } else {
            return nil
        }
    }
    
    var stringValue: String {
        switch self {
        case .letterpress:
            return NSTextEffectLetterpressStyle
        }
    }
}

private extension Attributes.Stroke {
    init(floatValue: Float) {
        if floatValue < 0 {
            self = .filled(width: -floatValue)
        } else {
            self = .notFilled(width: floatValue)
        }
    }
    
    var floatValue: Float {
        switch self {
        case let .notFilled(width):
            return width
        case let .filled(width):
            return -width
        }
    }
}

private extension Attributes.GlyphDirection {
    init?(intValue: Int) {
        switch intValue {
        case 0:
            self = .horizontal
        case 1:
            self = .vertical
        default:
            return nil
        }
    }
    
    var intValue: Int {
        switch self {
        case .horizontal:
            return 0
        case .vertical:
            return 1
        }
    }
}

extension Attributes {

    init(rawAttributes attributes: RawAttributes) {
        self.backgroundColor = attributes[NSBackgroundColorAttributeName] as? UIColor
        self.baseline = attributes[NSBaselineOffsetAttributeName] as? Float
        self.color = attributes[NSForegroundColorAttributeName] as? UIColor
        if let direction = attributes[NSVerticalGlyphFormAttributeName] as? Int {
            self.direction = GlyphDirection(intValue: direction)
        }
        self.expansion = attributes[NSExpansionAttributeName] as? Float
        self.font = attributes[NSFontAttributeName] as? UIFont
        if let ligature = attributes[NSLigatureAttributeName] as? Int {
            self.ligature = (ligature == 1)
        }
        self.kern = attributes[NSKernAttributeName] as? Float
        self.obliqueness = attributes[NSObliquenessAttributeName] as? Float
        
        if let paragraph = attributes[NSParagraphStyleAttributeName] as? NSParagraphStyle {
            self.alignment = paraStyleCompare(paragraph) { $0.alignment }
            self.leading = paraStyleCompare(paragraph) { Float($0.lineSpacing) }
            self.lineHeightMultiplier = paraStyleCompare(paragraph) { Float($0.lineHeightMultiple) }
            self.paragraphSpacingAfter = paraStyleCompare(paragraph) { Float($0.paragraphSpacing) }
            self.paragraphSpacingBefore = paraStyleCompare(paragraph) { Float($0.paragraphSpacingBefore) }
            self.headIndent = paraStyleCompare(paragraph) { Float($0.headIndent) }
            self.tailIndent = paraStyleCompare(paragraph) { Float($0.tailIndent) }
            self.firstLineHeadIndent = paraStyleCompare(paragraph) { Float($0.firstLineHeadIndent) }
            self.minimumLineHeight = paraStyleCompare(paragraph) { Float($0.minimumLineHeight) }
            self.maximumLineHeight = paraStyleCompare(paragraph) { Float($0.maximumLineHeight) }
            self.hyphenationFactor = paraStyleCompare(paragraph) { Float($0.hyphenationFactor) }
            if #available(iOS 9.0, *) {
                self.allowsTighteningForTruncation = paraStyleCompare(paragraph) { $0.allowsDefaultTighteningForTruncation }
            }
        }
        
        if let strikethrough = attributes[NSStrikethroughStyleAttributeName] as? Int {
            self.strikethrough = NSUnderlineStyle(rawValue: strikethrough)
        }
        self.strikethroughColor = attributes[NSStrikethroughColorAttributeName] as? UIColor
        if let strokeWidth = attributes[NSStrokeWidthAttributeName] as? Float {
            self.stroke = Stroke(floatValue: strokeWidth)
        }
        self.strokeColor = attributes[NSStrokeColorAttributeName] as? UIColor
        if let textEffect = attributes[NSTextEffectAttributeName] as? String {
            self.textEffect = TextEffect(stringValue: textEffect)
        }
        if let underline = attributes[NSUnderlineStyleAttributeName] as? Int {
            self.underline = NSUnderlineStyle(rawValue: underline)
        }
        self.underlineColor = attributes[NSUnderlineColorAttributeName] as? UIColor
        self.URL = attributes[NSLinkAttributeName] as? Foundation.URL
    }
    
    /// convenience method for comparing attributes on `paragraph` vs `defaultParagrah`
    fileprivate func paraStyleCompare<U: Equatable>(_ paragraph: NSParagraphStyle, trans: (NSParagraphStyle) -> U) -> U? {
        let x = trans(paragraph)
        let y = trans(NSParagraphStyle.default)
        return (x == y) ? nil : x
    }
}

// MARK: Convenience methods
extension Attributes {
    public var fontSize: Float? {
        set {
            if let newValue = newValue {
                self.font = currentFont.withSize(CGFloat(newValue))
            } else {
                self.font = nil
            }
        }
        get {
            return Float(currentFont.pointSize)
        }
    }
    
    public var bold: Bool {
        set {
            setTrait(.traitBold, enabled: newValue)
        }
        get {
            return currentFont.fontDescriptor.symbolicTraits.contains(.traitBold)
        }
    }
    
    public var italic: Bool {
        set {
            setTrait(.traitItalic, enabled: newValue)
        }
        get {
            return currentFont.fontDescriptor.symbolicTraits.contains(.traitItalic)
        }
    }
    
    fileprivate mutating func setTrait(_ trait: UIFontDescriptorSymbolicTraits, enabled: Bool) {
        let font = currentFont
        let descriptor = font.fontDescriptor
        var traits = descriptor.symbolicTraits
        if enabled {
            traits.insert(trait)
        } else {
            traits.remove(trait)
        }
        let newDescriptor = descriptor.withSymbolicTraits(traits)
        self.font = UIFont(descriptor: newDescriptor!, size: font.pointSize)
    }
    
    fileprivate static let defaultFont = UIFont.systemFont(ofSize: 12)
    fileprivate var currentFont: UIFont {
        if let font = self.font {
            return font
        } else {
            return Attributes.defaultFont
        }
    }
}

extension Attributes {
    mutating public func reset() {
        backgroundColor = nil
        baseline = nil
        color = nil
        direction = nil
        expansion = nil
        font = nil
        ligature = nil
        kern = nil
        obliqueness = nil
        alignment = nil
        leading = nil
        strikethrough = nil
        strikethroughColor = nil
        stroke = nil
        strokeColor = nil
        textEffect = nil
        underline = nil
        underlineColor = nil
        URL = nil
        
        lineBreakMode = nil
        lineHeightMultiplier = nil
        paragraphSpacingAfter = nil
        paragraphSpacingBefore = nil
        headIndent = nil
        tailIndent = nil
        firstLineHeadIndent = nil
        minimumLineHeight = nil
        maximumLineHeight = nil
        hyphenationFactor = nil
        allowsTighteningForTruncation = nil
    }
}


extension Attributes {
    var rawAttributes: RawAttributes {
        var result: RawAttributes = [:]
        result[NSBackgroundColorAttributeName] = backgroundColor
        result[NSBaselineOffsetAttributeName] = baseline as AnyObject?
        result[NSForegroundColorAttributeName] = color
        result[NSVerticalGlyphFormAttributeName] = direction?.intValue as AnyObject?
        result[NSExpansionAttributeName] = expansion as AnyObject?
        result[NSFontAttributeName] = font
        result[NSKernAttributeName] = kern as AnyObject?
        if let ligature = ligature {
            result[NSLigatureAttributeName] = ligature ? 1 as AnyObject? : 0 as AnyObject?
        }
        if let paragraph = retrieveParagraph() {
            result[NSParagraphStyleAttributeName] = paragraph
        }
        result[NSStrikethroughStyleAttributeName] = strikethrough?.rawValue as AnyObject?
        result[NSStrikethroughColorAttributeName] = strikethroughColor
        result[NSStrokeWidthAttributeName] = stroke?.floatValue as AnyObject?
        result[NSStrokeColorAttributeName] = strokeColor
        result[NSObliquenessAttributeName] = obliqueness as AnyObject?
        result[NSTextEffectAttributeName] = textEffect?.stringValue as AnyObject?
        result[NSUnderlineStyleAttributeName] = underline?.rawValue as AnyObject?
        result[NSUnderlineColorAttributeName] = underlineColor
        result[NSLinkAttributeName] = URL as AnyObject?
        
        return result
    }

    fileprivate func isAnyNotNil(_ objects: Any? ...) -> Bool {
        for object in objects {
            if object != nil {
                return true
            }
        }
        return false
    }
    
    
    fileprivate func retrieveParagraph() -> NSMutableParagraphStyle? {
        if !isAnyNotNil(leading, alignment, lineBreakMode, lineHeightMultiplier,
            paragraphSpacingAfter, paragraphSpacingBefore, headIndent, tailIndent,
            firstLineHeadIndent, minimumLineHeight, maximumLineHeight, hyphenationFactor,
            allowsTighteningForTruncation) {
                return nil
        }
        let paragraph = NSMutableParagraphStyle()
        
        if let leading = leading { paragraph.lineSpacing = CGFloat(leading) }
        if let leading = leading { paragraph.lineSpacing = CGFloat(leading) }
        if let alignment = alignment { paragraph.alignment = alignment }
        if let lineBreakMode = lineBreakMode { paragraph.lineBreakMode = lineBreakMode }
        if let lineHeightMultiplier = lineHeightMultiplier { paragraph.lineHeightMultiple = CGFloat(lineHeightMultiplier) }
        if let paragraphSpacingAfter = paragraphSpacingAfter { paragraph.paragraphSpacing = CGFloat(paragraphSpacingAfter) }
        if let paragraphSpacingBefore = paragraphSpacingBefore { paragraph.paragraphSpacingBefore = CGFloat(paragraphSpacingBefore) }
        if let headIndent = headIndent { paragraph.headIndent = CGFloat(headIndent) }
        if let tailIndent = tailIndent { paragraph.tailIndent = CGFloat(tailIndent) }
        if let firstLineHeadIndent = firstLineHeadIndent { paragraph.firstLineHeadIndent = CGFloat(firstLineHeadIndent) }
        if let minimumLineHeight = minimumLineHeight { paragraph.minimumLineHeight = CGFloat(minimumLineHeight) }
        if let maximumLineHeight = maximumLineHeight { paragraph.maximumLineHeight = CGFloat(maximumLineHeight) }
        if let hyphenationFactor = hyphenationFactor { paragraph.hyphenationFactor = hyphenationFactor }
        if #available(iOS 9.0, *) {
            if let allowsTighteningForTruncation = allowsTighteningForTruncation { paragraph.allowsDefaultTighteningForTruncation = allowsTighteningForTruncation }
        }
        return paragraph
    }
}


extension NSAttributedString {
    var runningAttributes: [String: AnyObject]? {
        guard length > 0 else {
            return nil
        }
        return attributes(at: length - 1, effectiveRange: nil) as [String : AnyObject]?
    }
    
    fileprivate var fullRange: NSRange {
        return NSRange(location: 0, length: length)
    }
}


public extension NSMutableAttributedString {
    public typealias AttributeSetter = (_ attributes: inout Attributes) -> Void
    
    public func add(_ text: String, setter: AttributeSetter? = nil) -> NSMutableAttributedString {
        var attributes = runningOrNewAttributes
        setter?(&attributes)
        return add(text, attributes: attributes)
    }
    
    var runningOrNewAttributes: Attributes {
        if let runningAttributes = self.runningAttributes {
            return Attributes(rawAttributes: runningAttributes)
        } else {
            return Attributes()
        }
    }
    
    func add(_ text: String, attributes: Attributes) -> NSMutableAttributedString {
        let attributedString = NSAttributedString(string: text, attributes: attributes.rawAttributes)
        append(attributedString)
        return self
    }
}

public extension NSMutableAttributedString {
    public func add(_ image: UIImage, bounds: CGRect? = nil, setter: AttributeSetter? = nil) -> NSMutableAttributedString {
        var attributes = runningOrNewAttributes
        setter?(&attributes)
        let attachment = NSTextAttachment()
        attachment.image = image
        if let bounds = bounds {
            attachment.bounds = bounds
        }
        let string = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        string.addAttributes(attributes.rawAttributes, range: string.fullRange)
        append(string)
        return self
    }
}
