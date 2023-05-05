import Foundation
import Hitch

internal let hitchNone: HalfHitch = ""

public extension Data {
    @inlinable @inline(__always)
    func parsed<T>(_ callback: (XmlElement?) -> T?) -> T? {
        return Studding.parsed(data: self, callback)
    }
}

public extension Hitch {
    @inlinable @inline(__always)
    func parsed<T>(_ callback: (XmlElement?) -> T?) -> T? {
        return Studding.parsed(hitch: self, callback)
    }
}

public extension HalfHitch {
    @inlinable @inline(__always)
    func parsed<T>(_ callback: (XmlElement?) -> T?) -> T? {
        return Studding.parsed(halfhitch: self, callback)
    }
}

public extension String {
    @inlinable @inline(__always)
    func parsed<T>(_ callback: (XmlElement?) -> T?) -> T? {
        return Studding.parsed(string: self, callback)
    }
}

public enum Studding {
    
    @inlinable @inline(__always)
    public static func parsed<T>(hitch: Hitch, _ callback: (XmlElement?) -> T?) -> T? {
        return Reader.parsed(hitch: hitch, callback)
    }

    @inlinable @inline(__always)
    public static func parsed<T>(halfhitch: HalfHitch, _ callback: (XmlElement?) -> T?) -> T? {
        return Reader.parsed(halfhitch: halfhitch, callback)
    }

    @inlinable @inline(__always)
    public static func parsed<T>(data: Data, _ callback: (XmlElement?) -> T?) -> T? {
        return Reader.parsed(data: data, callback)
    }

    @inlinable @inline(__always)
    public static func parsed<T>(string: String, _ callback: (XmlElement?) -> T?) -> T? {
        return Reader.parsed(string: string, callback)
    }

    @inlinable @inline(__always)
    public static func parse(halfhitch: HalfHitch) -> XmlElement? {
        return Reader.parse(halfhitch: halfhitch)
    }
}
