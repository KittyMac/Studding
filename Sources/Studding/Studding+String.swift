import Foundation
import Hitch


@inlinable @inline(__always)
internal func strstr3(_ raw: UnsafePointer<UInt8>,
                      _ end: UnsafePointer<UInt8>,
                      _ b0: UInt8,
                      _ b1: UInt8,
                      _ b2: UInt8) -> UnsafePointer<UInt8> {
    var ptr = raw
    while ptr < end - 3 {
        if ptr.pointee == b0 &&
            (ptr + 1).pointee == b1 &&
            (ptr + 2).pointee == b2 {
            return ptr
        }
        ptr += 1
    }
    return end
}

@inlinable @inline(__always)
internal func strstr2(_ raw: UnsafePointer<UInt8>,
                      _ end: UnsafePointer<UInt8>,
                      _ b0: UInt8,
                      _ b1: UInt8) -> UnsafePointer<UInt8> {
    var ptr = raw
    while ptr < end - 2 {
        if ptr.pointee == b0 &&
            (ptr + 1).pointee == b1 {
            return ptr
        }
        ptr += 1
    }
    return end
}

@inlinable @inline(__always)
internal func strstr1(_ raw: UnsafePointer<UInt8>,
                      _ end: UnsafePointer<UInt8>,
                      _ b0: UInt8) -> UnsafePointer<UInt8> {
    var ptr = raw
    while ptr < end {
        if ptr.pointee == b0 {
            return ptr
        }
        ptr += 1
    }
    return end
}

@inlinable @inline(__always)
internal func strstr(_ raw: UnsafePointer<UInt8>,
                     _ end: UnsafePointer<UInt8>,
                     _ match: HalfHitch) -> UnsafePointer<UInt8> {
    var ptr = raw
    while ptr < end {
        if match.startsAt(raw: ptr, count: end - ptr) {
            return ptr
        }
        ptr += 1
    }
    return end
}


@inlinable @inline(__always)
internal func strncmp(_ raw: UnsafePointer<UInt8>,
                      _ end: UnsafePointer<UInt8>,
                      _ match: HalfHitch) -> Int {
    return match.startsAt(raw: raw, count: end - raw) ? 0 : 1
}

@inlinable @inline(__always)
internal func strpbrk(_ raw: UnsafePointer<UInt8>,
                      _ end: UnsafePointer<UInt8>,
                      _ params: UInt8...) -> UnsafePointer<UInt8> {
    var ptr = raw
    while ptr < end {
        if params.contains(ptr.pointee) {
            return ptr
        }
        ptr += 1
    }
    return end
}

@inlinable @inline(__always)
internal func isspace(_ c: UInt8) -> Bool {
    return c == .space || c == .newLine || c == .carriageReturn || c == .tab || c == .lineFeed
}

@inlinable @inline(__always)
internal func printAround(halfHitch: HalfHitch,
                          start: UnsafePointer<UInt8>,
                          end: UnsafePointer<UInt8>,
                          ptr: UnsafePointer<UInt8>) {
    let minIdx = max(0, ptr - start - 2)
    let maxIdx = min(end - start, ptr - start + 2)
    let snip: Hitch = HalfHitch(source: halfHitch, from: minIdx, to: maxIdx).hitch()
    snip.replace(occurencesOf: "\n", with: "_")
    snip.replace(occurencesOf: "\r", with: "_")
    print(snip)
    print("  ^  ")
}
