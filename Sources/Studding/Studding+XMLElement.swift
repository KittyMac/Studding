import Foundation
import Hitch

public final class XMLElement: CustomStringConvertible {
    public var name: HalfHitch = hitchNone
    public var text: HalfHitch = hitchNone
    public var attributeNames: [HalfHitch] = []
    public var attributeValues: [HalfHitch] = []
    public var children: [XMLElement] = []
    
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
            hitch.append(.forwardSlash)
            hitch.append(.greaterThan)
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
}

// Attributes
extension XMLElement {
    
    @inlinable @inline(__always)
    subscript (attribute: HalfHitch) -> HalfHitch? {
        get {
            guard let index = attributeNames.firstIndex(of: attribute) else { return nil }
            return attributeValues[index]
        }
    }
    
    @inlinable @inline(__always)
    subscript (index: Int) -> (HalfHitch,HalfHitch)? {
        get {
            guard index >= 0 && index < attributeValues.count else { return nil }
            return (attributeNames[index], attributeValues[index])
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
