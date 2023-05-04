import Foundation
import Hitch

/*
@inlinable @inline(__always)
internal func strskip(string: HalfHitch, offset: Int, _ params: UInt8...) -> Int {
    var idx = offset
    for char in string.stride(from: offset, to: string.count) {
        guard char != 0 else { break }
        guard params.contains(char) else { break }
        idx += 1
    }
    return idx
}

@inlinable @inline(__always)
internal func strstrNoEscaped(string: HalfHitch,
                              offset: Int,
                              find: UInt8,
                              shouldUnescape: inout Bool) -> Int {
    // look forward for the matching character, not counting escaped versions of it
    var skipNext = false
    var idx = offset

    shouldUnescape = false
    for char in string.stride(from: offset, to: string.count) {
        guard char != 0 else { break }
        guard skipNext == false else {
            skipNext = false
            idx += 1
            continue
        }
        if char == .backSlash {
            shouldUnescape = true
            skipNext = true
            idx += 1
            continue
        }
        if char == find {
            return idx
        }
        idx += 1
    }
    return idx
}

@inlinable @inline(__always)
internal func strstr3(string: HalfHitch,
                      offset: Int,
                      b0: UInt8,
                      b1: UInt8,
                      b2: UInt8) -> Int {
    var idx = offset
    for char in string.stride(from: offset, to: string.count - 3) {
        if char == b0 && string[idx+1] == b1 && string[idx+2] == b2 {
            return idx
        }
        idx += 1
    }
    return idx
}

@inlinable @inline(__always)
internal func strstr2(string: HalfHitch,
                      offset: Int,
                      b0: UInt8,
                      b1: UInt8) -> Int {
    var idx = offset
    for char in string.stride(from: offset, to: string.count - 2) {
        if char == b0 && string[idx+1] == b1 {
            return idx
        }
        idx += 1
    }
    return idx
}
*/

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
internal func strpbrk2(_ raw: UnsafePointer<UInt8>,
                       _ end: UnsafePointer<UInt8>,
                       _ b0: UInt8,
                       _ b1: UInt8) -> UnsafePointer<UInt8> {
    var ptr = raw
    while ptr < end {
        if ptr.pointee == b0 || ptr.pointee == b1 {
            return ptr
        }
        ptr += 1
    }
    return end
}

@inlinable @inline(__always)
internal func strpbrk3(_ raw: UnsafePointer<UInt8>,
                       _ end: UnsafePointer<UInt8>,
                       _ b0: UInt8,
                       _ b1: UInt8,
                       _ b2: UInt8) -> UnsafePointer<UInt8> {
    var ptr = raw
    while ptr < end {
        if ptr.pointee == b0 || ptr.pointee == b1 || ptr.pointee == b2 {
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
    let minIdx = max(0, ptr - start - 20)
    let maxIdx = min(end - start, ptr - start + 20)
    let snip: Hitch = HalfHitch(source: halfHitch, from: minIdx, to: maxIdx).hitch()
    snip.replace(occurencesOf: "\n", with: "_")
    snip.replace(occurencesOf: "\r", with: "_")
    print(snip)
    print("                    ^                    ")
}
