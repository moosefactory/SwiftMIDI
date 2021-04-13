/*--------------------------------------------------------------------------*/
/*   /\/\/\__/\/\/\        MooseFactory SwiftMidi                   */
/*   \/\/\/..\/\/\/                                                         */
/*        |  |             (c)2021 Tristan Leblanc                          */
/*        (oo)             tristan@moosefactory.eu                          */
/* MooseFactory Software                                                    */
/*--------------------------------------------------------------------------*/
/*
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
 THE SOFTWARE. */
/*--------------------------------------------------------------------------*/

//  MidiChannel+Utils.swift
//  Created by Tristan Leblanc on 06/01/2021.

import Foundation

/// Channel Map structure
///
/// Channel map is used in filters to redirect from one channel to another.
/// It can be used as a merger if several channels are redirected to the same channel.
///
/// For multiplexing, use the MidiChannelMatrix

public struct MidiChannelsMap: Codable, Equatable {
    public var channels: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    
    public static let identity = MidiChannelsMap()
    
    public init() {}
    
    /// Create a channel map that redirects all input channels to unique output channel
    public init(channel: UInt8) {
        channels = [UInt8](repeating: channel, count: 16)
    }
}

/// MidiChannelsTranspose
///
/// A 16 transpose values array (in semitones) that can be used to change note values coming from channels
public struct MidiChannelsTranspose: Codable, Equatable {
    public var transpose: [Int16] = [Int16].init(repeating: Int16(0), count: 16)
    
    public static let identity = MidiChannelsTranspose()

    public init() {}
}

/// MidiChannelsControlValues
///
/// A 16 transpose values array (in semitones) that can be used to change note values coming from channels
public struct MidiChannelsControlValues: Codable, Equatable {
    public var controlStates: [AllControlsState] = [AllControlsState].init(repeating: .empty, count: 16)
    
    public static let empty = MidiChannelsControlValues()

    public init() {}
    
    public var hasAValue: Bool {
        if controlStates[0].hasValue { return true }
        if controlStates[1].hasValue { return true }
        if controlStates[2].hasValue { return true }
        if controlStates[3].hasValue { return true }
        if controlStates[4].hasValue { return true }
        if controlStates[5].hasValue { return true }
        if controlStates[6].hasValue { return true }
        if controlStates[7].hasValue { return true }
        
        if controlStates[8].hasValue { return true }
        if controlStates[9].hasValue { return true }
        if controlStates[10].hasValue { return true }
        if controlStates[11].hasValue { return true }
        if controlStates[12].hasValue { return true }
        if controlStates[13].hasValue { return true }
        if controlStates[14].hasValue { return true }
        if controlStates[15].hasValue { return true }
        return false
    }

}

public struct AllControlsState: Codable, Equatable {
    public var values: [Int16] = [Int16].init(repeating: Int16(-1), count: 120)
    
    public static let empty = AllControlsState()
    
    public init() {}
    
    public var hasValue: Bool {
        return (values.firstIndex { $0 >= 0 }) != nil
    }
    
    public var controlValues: [(UInt8, Int16)] {
        return values.enumerated().compactMap {
            guard $0.element >= 0 else { return nil }
            return (UInt8($0.offset), $0.element)
        }
    }
}

/// MidiChannelsValues
///
/// A 16 generic values that can be used to store any Midi Value  per channel data.
/// <0 means no value
public struct MidiChannelsValues: Codable, Equatable {
    public var values: [Int16] = [Int16].init(repeating: Int16(-1), count: 16)
    
    public static let empty = MidiChannelsValues()

    public func value(for channel: Int) -> Int16 {
        guard channel >= 0 && channel < 16 else {
            return 0
        }
        return values[Int(channel)]
    }
    
    public var hasAValue: Bool {
        if values[0] >= 0 { return true }
        if values[1] >= 0 { return true }
        if values[2] >= 0 { return true }
        if values[3] >= 0 { return true }
        if values[4] >= 0 { return true }
        if values[5] >= 0 { return true }
        if values[6] >= 0 { return true }
        if values[7] >= 0 { return true }
        
        if values[8] >= 0 { return true }
        if values[9] >= 0 { return true }
        if values[10] >= 0 { return true }
        if values[11] >= 0 { return true }
        if values[12] >= 0 { return true }
        if values[13] >= 0 { return true }
        if values[14] >= 0 { return true }
        if values[15] >= 0 { return true }
        return false
    }
    
    public init() {}
}

/// A channel multiplexer matrix.
///
/// This can be used to propagate events from on channel to multiple channels

public struct MidiChannelMatrix {
    public var mask: [MidiChannelMask] = [
        MidiChannelMask(channel: 0),
        MidiChannelMask(channel: 1),
        MidiChannelMask(channel: 2),
        MidiChannelMask(channel: 3),
        MidiChannelMask(channel: 4),
        MidiChannelMask(channel: 5),
        MidiChannelMask(channel: 6),
        MidiChannelMask(channel: 7),
        MidiChannelMask(channel: 8),
        MidiChannelMask(channel: 9),
        MidiChannelMask(channel: 10),
        MidiChannelMask(channel: 11),
        MidiChannelMask(channel: 12),
        MidiChannelMask(channel: 13),
        MidiChannelMask(channel: 14),
        MidiChannelMask(channel: 15)
    ]
    
    public init() {}
}

public struct MidiChannelsTransposeMatrix {
    public var transpose = [
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose()
    ]
    
    public init() {}
}


