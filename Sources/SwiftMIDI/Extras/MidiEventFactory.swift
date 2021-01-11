//
//  File.swift
//  
//
//  Created by Tristan Leblanc on 11/01/2021.
//

import Foundation

public extension MidiEvent {
    
    
    static func noteOn(channel: UInt8, note: UInt8, velocity: UInt8) -> MidiEvent {
        MidiEvent(type: .noteOn, channel: channel, value1: note, value2: velocity)
    }

    static func noteOff(channel: UInt8, note: UInt8) -> MidiEvent {
        MidiEvent(type: .noteOff, channel: channel, value1: note)
    }

    static func control(channel: UInt8, number: UInt8, value: UInt8) -> MidiEvent {
        MidiEvent(type: .control, channel: channel, value1: number, value2: value)
    }
    
    // localControl : value = 0 or 127
    // polyOff : number of channels or 0 for number of channels of receiver
    static func channelMode(message: ChannelModeMessage, value: UInt8 = 0) -> MidiEvent {
        MidiEvent(type: .control, channel: 0, value1: message.rawValue, value2: value)
    }
}
