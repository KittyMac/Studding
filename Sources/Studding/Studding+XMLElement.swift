import Foundation
import Hitch

public final class XmlElement: CustomStringConvertible {
    public var name: HalfHitch = hitchNone
    public var text: HalfHitch = hitchNone
    public var cdata: [HalfHitch] = []
    public var attributeNames: [HalfHitch] = []
    public var attributeValues: [HalfHitch] = []
    public var children: [XmlElement] = []
    
    public init(name: HalfHitch,
                text: HalfHitch = "",
                cdata: [HalfHitch] = [],
                attributes: [HalfHitch: HalfHitch] = [:],
                children: [XmlElement] = []) {
        self.name = name
        self.text = text
        self.cdata = cdata
        self.children = children
        
        attributeNames = []
        attributeValues = []
        
        let keys = attributes.keys.sorted()
        for key in keys {
            if let value = attributes[key] {
                attributeNames.append(key)
                attributeValues.append(value)
            }
        }
    }
    
    internal init() {
        self.name = hitchNone
        self.text = hitchNone
        self.cdata = []
        self.attributeNames = []
        self.attributeValues = []
        self.children = []
    }
    
    @inlinable @inline(__always)
    public var iterAttributes: AttributesIterator {
        return AttributesIterator(keyArray: attributeNames,
                                  valueArray: attributeValues)
    }
    
    @inlinable @inline(__always)
    public var description: String {
        return exportTo(hitch: Hitch(capacity: 1024)).description
    }

    @inlinable @inline(__always)
    public func toString() -> String {
        return exportTo(hitch: Hitch(capacity: 1024)).toString()
    }

    @inlinable @inline(__always)
    public func toHitch() -> Hitch {
        return exportTo(hitch: Hitch(capacity: 1024))
    }
    
    @discardableResult
    @inlinable @inline(__always)
    public func exportTo(hitch: Hitch) -> Hitch {
        
        if hitch.count == 0 {
            hitch.append(#"<?xml version="1.0" encoding="UTF-8" ?>"#)
        }
        
        hitch.append(.lessThan)
        hitch.append(name)
        
        for (key, value) in iterAttributes {
            hitch.append(.space)
            hitch.append(key)
            hitch.append(.equal)
            hitch.append(.doubleQuote)
            hitch.append(value)
            hitch.append(.doubleQuote)
        }
        
        if children.isEmpty {
            if text.count > 0 {
                hitch.append(.greaterThan)
                hitch.append(text)
                hitch.append(.lessThan)
                hitch.append(.forwardSlash)
                hitch.append(name)
                hitch.append(.greaterThan)
            } else if cdata.count > 0 {
                hitch.append(.greaterThan)
                for data in cdata {
                    hitch.append("<![CDATA[")
                    hitch.append(data)
                    hitch.append("]]>")
                }
                hitch.append(.lessThan)
                hitch.append(.forwardSlash)
                hitch.append(name)
                hitch.append(.greaterThan)
            } else {
                hitch.append(.forwardSlash)
                hitch.append(.greaterThan)
            }
        } else {
            hitch.append(.greaterThan)
            for child in children {
                child.exportTo(hitch: hitch)
            }
            hitch.append(.lessThan)
            hitch.append(.forwardSlash)
            hitch.append(name)
            hitch.append(.greaterThan)
        }
        
        return hitch
    }
    
    @inlinable @inline(__always)
    public func toJson() -> Hitch {
        return exportJsonTo(hitch: Hitch(capacity: 1024))
    }
    
    @discardableResult
    @inlinable @inline(__always)
    public func exportJsonTo(hitch: Hitch) -> Hitch {
        
        func append(hitch other: HalfHitch) {
            for char in other {
                switch char {
                case .newLine:
                    hitch.append(.backSlash)
                    hitch.append(.n)
                case .carriageReturn:
                    hitch.append(.backSlash)
                    hitch.append(.r)
                case .doubleQuote:
                    hitch.append(.backSlash)
                    hitch.append(.doubleQuote)
                default:
                    hitch.append(char)
                }
            }
        }
        
        hitch.append(.openBracket)
        
        hitch.append(.doubleQuote)
        hitch.append("xmlElement")
        hitch.append(.doubleQuote)
        hitch.append(.colon)
        hitch.append(.doubleQuote)
        append(hitch: name)
        hitch.append(.doubleQuote)
        hitch.append(.comma)
        
        for (key, value) in iterAttributes {
            hitch.append(.doubleQuote)
            append(hitch: key)
            hitch.append(.doubleQuote)
            hitch.append(.colon)
            hitch.append(.doubleQuote)
            append(hitch: value)
            hitch.append(.doubleQuote)
            hitch.append(.comma)
        }
        
        if text.count > 0 {
            hitch.append(.doubleQuote)
            hitch.append("xmlText")
            hitch.append(.doubleQuote)
            hitch.append(.colon)
            hitch.append(.doubleQuote)
            append(hitch: text)
            hitch.append(.doubleQuote)
            hitch.append(.comma)
        }
        
        if children.isEmpty == false {
            hitch.append(.doubleQuote)
            hitch.append("xmlChildren")
            hitch.append(.doubleQuote)
            hitch.append(.colon)
            hitch.append(.openBrace)
            for child in children {
                child.exportJsonTo(hitch: hitch)
                hitch.append(.comma)
            }
            if hitch.last == .comma {
                hitch.count -= 1
            }
            hitch.append(.closeBrace)
        }
        
        if hitch.last == .comma {
            hitch.count -= 1
        }
        
        hitch.append(.closeBracket)
        
        return hitch
    }
}

// Attributes
extension XmlElement {
    
    @inlinable @inline(__always)
    public func attr(name: String) -> HalfHitch? {
        guard let index = attributeNames.firstIndex(of: HalfHitch(string: name)) else { return nil }
        return attributeValues[index]
    }
    
    @inlinable @inline(__always)
    public func attr(name: StaticString) -> HalfHitch? {
        guard let index = attributeNames.firstIndex(of: HalfHitch(stringLiteral: name)) else { return nil }
        return attributeValues[index]
    }
    
    @inlinable @inline(__always)
    public func attr(name: HalfHitch) -> HalfHitch? {
        guard let index = attributeNames.firstIndex(of: name) else { return nil }
        return attributeValues[index]
    }
    
    
    @inlinable @inline(__always)
    public subscript (name: String) -> XmlElement? {
        get {
            let halfHitch = HalfHitch(string: name)
            for child in children where child.name == halfHitch {
                return child
            }
            return nil
        }
    }
    
    @inlinable @inline(__always)
    public subscript (name: StaticString) -> XmlElement? {
        get {
            let halfHitch = HalfHitch(stringLiteral: name)
            for child in children where child.name == halfHitch {
                return child
            }
            return nil
        }
    }
    
    @inlinable @inline(__always)
    public subscript (name: HalfHitch) -> XmlElement? {
        get {
            for child in children where child.name == name {
                return child
            }
            return nil
        }
    }
    
    @inlinable @inline(__always)
    public subscript (index: Int) -> XmlElement? {
        get {
            guard index >= 0 && index < children.count else { return nil }
            return children[index]
        }
    }
    
    public struct AttributesIterator: Sequence, IteratorProtocol {
        @usableFromInline
        internal var index = -1
        
        @usableFromInline
        internal let countMinusOne: Int
        
        @usableFromInline
        internal let keyArray: [HalfHitch]
        
        @usableFromInline
        internal let valueArray: [HalfHitch]
        
        @usableFromInline
        internal init(keyArray: [HalfHitch], valueArray: [HalfHitch]) {
            self.keyArray = keyArray
            self.valueArray = valueArray
            countMinusOne = keyArray.count - 1
#if DEBUG
            if keyArray.count != valueArray.count {
                fatalError("key and value arrays should be the same length")
            }
#endif
        }
        
        @inlinable @inline(__always)
        public mutating func next() -> (HalfHitch, HalfHitch)? {
            guard index < countMinusOne else { return nil }
            index += 1
            return (keyArray[index], valueArray[index])
        }
    }
}
