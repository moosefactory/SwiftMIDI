//  MidiChannelMask.swift
//  Created by Tristan Leblanc on 08/01/2021.

import Foundation

/// MidiChannelMask
///
/// A mask used to filter channel
/// Each bit represent a channel

public typealias MidiChannelMask = UInt16

/// Channel Mask <-> Channels conversion
extension MidiChannelMask {
    
    /// Returns the active channels
    public var channels: [UInt8] {
        var out = [UInt8]()
        for i: UInt8 in 0...15 {
            if (self & (0x0001 << i)) > 0 {
                out.append(i)
            }
        }
        return out
    }
    
    /// Init with active channels
    public init(channels: [UInt8]) {
        self = 0
        channels.forEach {
            self |= (0x0001 << $0)
        }
    }
    
    /// Init with one channel
    public init(channel: UInt8) {
        self = 0x0001 << channel
    }
    
    public static let all: MidiChannelMask = 0xFFFF
    public static let none: MidiChannelMask = 0x0000
    public static let channel1: MidiChannelMask = 0x0001
}
