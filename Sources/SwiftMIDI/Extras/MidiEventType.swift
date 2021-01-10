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

//  MidiEventType.swift
//  Created by Tristan Leblanc on 08/01/2021.

import Foundation
import CoreMIDI

/// MidiEventType
///
/// The commons event types for musical midi events

public enum MidiEventType: UInt8, CustomStringConvertible {
    case noteOff = 0x80
    case noteOn = 0x90
    case polyAfterTouch = 0xA0
    case control = 0xB0
    case programChange = 0xC0
    case afterTouch = 0xD0
    case pitchBend = 0xE0
    case realTimeMessage = 0xF0

    /// dataLength
    ///
    /// The data length that follows the status (Type|Channel) byte
    
    public var dataLength: UInt8 {
        switch self {
        case .noteOff, .noteOn, .pitchBend, .control, .polyAfterTouch:
            return 2
        case .afterTouch, .programChange:
            return 1
        case .realTimeMessage:
            return 0
        }
    }
    
    /// description
    ///
    /// Returns the readable english description
    
    public var description: String {
        switch self {
        case .noteOn:
            return "Note On"
        case .noteOff:
            return "Note Off"
        case .polyAfterTouch:
            return "Polyphonic Aftertouch"
        case .control:
            return "Control"
        case .programChange:
            return "Program Change"
        case .afterTouch:
            return "Aftertouch"
        case .pitchBend:
            return "Pitch Bend Change"
        case .realTimeMessage:
            return "Real Time Message"
        }
    }
    
    /// maskBit
    ///
    /// Returns an event type mask with the right bit set
    
    public var maskBit: MidiEventTypeMask {
        switch self {
        case .noteOff:
            return .noteOff
        case .noteOn:
            return .noteOn
        case .polyAfterTouch:
            return .polyAfterTouch
        case .control:
            return .control
        case .programChange:
            return .programChange
        case .afterTouch:
            return .noteAfterTouch
        case .pitchBend:
            return .pitchBend
        case .realTimeMessage:
            return .realTimeMessage
        }
    }
}

/// MidiEventTypeMask
///
/// Represents the event types by bit.
/// This can be used to quickly filter events using bit masks

public struct MidiEventTypeMask: Codable, OptionSet, CustomStringConvertible {
    public var rawValue: UInt8 = 0
    
    public init(rawValue: UInt8 = 0xFF) { self.rawValue = rawValue }
    
    static public let noteOn = MidiEventTypeMask(rawValue: 0x01)
    static public let noteOff = MidiEventTypeMask(rawValue: 0x02)
    static public let note = MidiEventTypeMask(rawValue: 0x03)
    
    static public let polyAfterTouch = MidiEventTypeMask(rawValue: 0x04)
    static public let noteAfterTouch = MidiEventTypeMask(rawValue: 0x08)
    static public let afterTouch = MidiEventTypeMask(rawValue: 0x0C)
    
    static public let control = MidiEventTypeMask(rawValue: 0x10)
    static public let pitchBend = MidiEventTypeMask(rawValue: 0x20)
    static public let programChange = MidiEventTypeMask(rawValue: 0x40)
    
    static public let realTimeMessage = MidiEventTypeMask(rawValue: 0x80)
    
    static public let all = MidiEventTypeMask(rawValue: 0xFF)
    static public let allExceptedClock = MidiEventTypeMask(rawValue: 0x7F)
    
    public func contains(eventType: MidiEventType) -> Bool {
        return contains(eventType.maskBit)
    }

    public func contains(rawEventType: UInt8) -> Bool {
        switch rawEventType {
        case MidiEventType.noteOff.rawValue:
            return contains(.noteOff)
        case MidiEventType.noteOn.rawValue:
            return contains(.noteOn)
        case MidiEventType.polyAfterTouch.rawValue:
            return contains(.polyAfterTouch)
        case MidiEventType.control.rawValue:
            return contains(.control)
        case MidiEventType.programChange.rawValue:
            return contains(.programChange)
        case MidiEventType.afterTouch.rawValue:
            return contains(.noteAfterTouch)
        case MidiEventType.pitchBend.rawValue:
            return contains(.pitchBend)
        case MidiEventType.realTimeMessage.rawValue:
            return contains(.realTimeMessage)
        default:
            return true
        }
    }
    
    public var description: String {
        var out = [String]()
        if contains(.noteOff) {
            out += ["NoteOff"]
        }
        if contains(.noteOn) {
            out += ["NoteOn"]
        }
        if contains(.control) {
            out += ["Control"]
        }
        if contains(.polyAfterTouch) {
            out += ["Poly AfterTouch"]
        }
        if contains(.afterTouch) {
            out += ["AfterTouch"]
        }
        if contains(.programChange) {
            out += ["PgChange"]
        }
        if contains(.realTimeMessage) {
            out += ["Real Time Message"]
        }
        if contains(.pitchBend) {
            out += ["PitchBend"]
        }
        return "[" + out.joined(separator: ", ") + "]"
    }
}

public enum RealTimeMessageType: UInt8, Codable, CustomStringConvertible {
    case none = 0x00
    case clock = 0xF8
    case start = 0xFA
    case `continue` = 0xFB
    case stop = 0xFC
    case activeSensing = 0xFE
    case systemReset = 0xFF
    
    public var description: String {
        switch self {
        case .none:
            return "None"
        case .clock:
            return "Clock"
        case .start:
            return "Start"
        case .continue:
            return "Continue"
        case .stop:
            return "Stop"
        case .activeSensing:
            return "Active Sensing"
        case .systemReset:
            return "System Reset"
        }
    }
}
