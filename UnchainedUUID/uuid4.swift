//
//  uuid4.swift
//  twohundred
//
//  Created by Johannes Schriewer on 21/11/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

#if os(Linux)
    import Glibc
    import BSD
#else
    import Darwin.C
#endif

import UnchainedString

extension UInt8 {
    func hexString(padded padded:Bool = true) -> String {
        let dict:[Character] = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
        var result = ""

        let c1 = Int(self >> 4)
        let c2 = Int(self & 0xf)

        if c1 == 0 && padded {
            result.append(dict[c1])
        } else if c1 > 0 {
            result.append(dict[c1])
        }
        result.append(dict[c2])

        if (result.characters.count == 0) {
            return "0"
        }
        return result
    }
}

/// UUID (Random class)
public class UUID4: Equatable {
    private var bytes:[UInt8]!

    /// Initialize random UUID
    public init() {
        self.bytes = [UInt8](repeating: 0, count: 16)
        for i in 0..<16 {
            self.bytes[i] = UInt8(arc4random_uniform(256))
        }
        self.bytes[6] = self.bytes[6] & 0x0f + 0x40
        self.bytes[8] = self.bytes[8] & 0x3f + 0x80
    }

    /// Initialize UUID from bytes
    ///
    /// - parameter bytes: 16 bytes of UUID data
    /// - returns: nil if the bytes are no valid UUID
    public init?(bytes: [UInt8]) {
        guard (bytes.count == 16) &&
              (bytes[6] & 0xf0 == 0x40) &&
              (bytes[8] & 0xc0 == 0x80) else {
            return nil
        }
        self.bytes = bytes
    }

    /// Initialize UUID from string
    ///
    /// - parameter string: string in default UUID representation
    public init?(string: String) {
        self.bytes = [UInt8](repeating: 0, count: 16)
        let components = string.split("-")
        if components.count != 5 {
            return nil
        }

        var byte = 0
        for comp in components {
            var characters = comp.characters
            for _ in 0..<(comp.characters.count / 2) {
                guard let c1 = characters.popFirst(),
                      let c2 = characters.popFirst() else {
                        return nil
                }

                let c = UInt8("\(c1)\(c2)", radix: 16)!

                self.bytes[byte] = c
                byte += 1
            }
        }

        if byte != 16 {
            return nil
        }
    }
}

/// UUIDs are equal when all bytes are equal
public func ==(lhs: UUID4, rhs: UUID4) -> Bool {
    var same = true
    for i in 0..<16 {
        if lhs.bytes[i] != rhs.bytes[i] {
            same = false
            // do not break here for constant time comparison of UUID
        }
    }
    return same
}

/// Printable UUID
extension UUID4: CustomStringConvertible {

    /// "Human readable" version of the UUID
    public var description: String {
        return "\(bytes[0].hexString())\(bytes[1].hexString())\(bytes[2].hexString())\(bytes[3].hexString())-\(bytes[4].hexString())\(bytes[5].hexString())-\(bytes[6].hexString())\(bytes[7].hexString())-\(bytes[8].hexString())\(bytes[9].hexString())-\(bytes[10].hexString())\(bytes[11].hexString())\(bytes[12].hexString())\(bytes[13].hexString())\(bytes[14].hexString())\(bytes[15].hexString())".uppercased()
    }
}

/// Hashing extension for UUID
extension UUID4: Hashable {
    /// calculate hash value from UUID
    public var hashValue: Int {
        var hash: Int = 0
        hash += Int(self.bytes[0] ^ self.bytes[8])
        hash += Int(self.bytes[1] ^ self.bytes[9])  >> 8
        hash += Int(self.bytes[2] ^ self.bytes[10]) >> 16
        hash += Int(self.bytes[3] ^ self.bytes[11]) >> 24
        hash += Int(self.bytes[4] ^ self.bytes[12]) >> 32
        hash += Int(self.bytes[5] ^ self.bytes[13]) >> 40
        hash += Int(self.bytes[6] ^ self.bytes[14]) >> 48
        hash += Int(self.bytes[7] ^ self.bytes[15]) >> 56

        return hash
    }
}
