import Foundation
import Hitch

internal let hitchNone: HalfHitch = ""

public extension Data {
    @inlinable
    func parsed<T>(_ callback: (XmlElement?) -> T?) -> T? {
        return Studding.parsed(data: self, callback)
    }
}

public extension Hitch {
    @inlinable
    func parsed<T>(_ callback: (XmlElement?) -> T?) -> T? {
        return Studding.parsed(hitch: self, callback)
    }
}

public extension HalfHitch {
    @inlinable
    func parsed<T>(_ callback: (XmlElement?) -> T?) -> T? {
        return Studding.parsed(halfhitch: self, callback)
    }
}

public extension String {
    @inlinable
    func parsed<T>(_ callback: (XmlElement?) -> T?) -> T? {
        return Studding.parsed(string: self, callback)
    }
}

public enum Studding {
    
    @inlinable
    public static func parsed<T>(hitch: Hitch, _ callback: (XmlElement?) -> T?) -> T? {
        return Reader.parsed(hitch: hitch, callback)
    }

    @inlinable
    public static func parsed<T>(halfhitch: HalfHitch, _ callback: (XmlElement?) -> T?) -> T? {
        return Reader.parsed(halfhitch: halfhitch, callback)
    }

    @inlinable
    public static func parsed<T>(data: Data, _ callback: (XmlElement?) -> T?) -> T? {
        return Reader.parsed(data: data, callback)
    }

    @inlinable
    public static func parsed<T>(string: String, _ callback: (XmlElement?) -> T?) -> T? {
        return Reader.parsed(string: string, callback)
    }

    @inlinable
    public static func parse(halfhitch: HalfHitch) -> XmlElement? {
        return Reader.parse(halfhitch: halfhitch)
    }
}
