//
//  File.swift
//  
//
//  Created by Tristan Leblanc on 12/08/2024.
//

import Foundation
import CoreMIDI

public extension MIDIPacket {
    
    var dataAsArray: [UInt8] {
        var ints: [UInt8] = []
        withUnsafePointer(to: data) { ptr in
            let data = Data(bytes: ptr, count: Int(length))
            var iter = data.makeIterator()
            var e: UInt8? = iter.next()
            while e != nil {
                ints.append(e!)
                e = iter.next()
            }
        }
        return ints
    }

    var dataAsIntsString: String {
        dataAsArray.reduce("") { partialResult, int in
            return partialResult+String(int, radix: 16)
        }
    }
}
