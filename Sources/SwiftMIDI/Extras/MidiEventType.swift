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

    public var isNote: Bool {
        return self == .noteOn || self == .noteOff
    }
    
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

public enum MidiEventSubType: Int, Codable, CustomStringConvertible {
    case musical
    case bankSelect
    case channelMode
    case systemCommon
    
    public var description: String {
        switch self {
        case .musical:
            return "Musical"
        case .bankSelect:
            return "Bank Select"
        case .channelMode:
            return "Channel Mode"
        case .systemCommon:
            return "System Common"
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

public enum ChannelModeMessage: UInt8, Codable, CustomStringConvertible {
    case allSoundOff = 0x78
    case resetAll = 0x79
    case localControl = 0x80
    case allNoteOff = 0x81
    case omniOff = 0x82
    case omniOn = 0x83
    case mono = 0x84
    case poly = 0x85
    
    public var description: String {
        switch self {
        case .allSoundOff:
            return "All Sound Off"
        case .resetAll:
            return "Reset All Controllers"
        case .localControl:
            return "Local Control"
        case .allNoteOff:
            return "All Notes Off"
        case .omniOff:
            return "Omni Off"
        case .omniOn:
            return "Omni On"
        case .mono:
            return "Monophonic"
        case .poly:
            return "Polyphonic"
        }
    }
}

public enum SystemCommonMessage: UInt8, Codable, CustomStringConvertible {
    case midiTimeCode = 0xF1
    case songPositionPointer = 0xF2
    case songSelect = 0xF3
    case tuneRequest = 0xF6
    case endOfExclusive = 0xF7
    
    public var description: String {
        switch self {
        
        case .midiTimeCode:
            return "MTC - MIDI Time Code Quarter Frame"
        case .songPositionPointer:
            return "Song Position Pointer"
        case .songSelect:
            return "Song Select"
        case .tuneRequest:
            return "Tune Request"
        case .endOfExclusive:
            return "EOX - End of Exclusive"
        }
    }
    
}

public enum SequencerStatus: Int, CustomStringConvertible {
    case stopped
    case running
    case paused
    
    public var description: String {
        switch self {
        case .stopped:
            return "Stopped"
        case .running:
            return "Running"
        case .paused:
            return "Paused"
        }
    }
}

public enum ControlNumbers: UInt8, Codable, CustomStringConvertible {
    case bankSelect
    case modulation
    case breath
    case control_3
    case footController
    case portamentoTime
    case dataEntryMSB
    case channelVolume
    case balance
    case control_9
    case pan
    case expressionController
    case effectControl1
    case effectControl2
    case control_14
    case control_15
    
    case general_1
    case general_2
    case general_3
    case general_4
    
    case control_20
    case control_21
    case control_22
    case control_23
    case control_24
    case control_25
    case control_26
    case control_27
    case control_28
    case control_29
    case control_30
    case control_31
    
    // LSB
    
    case bank_LSB
    case LSB_1
    case LSB_2
    case LSB_3
    case LSB_4
    case LSB_5
    case LSB_6
    case LSB_7
    case LSB_8
    case LSB_9
    case LSB_10
    case LSB_11
    case LSB_12
    case LSB_13
    case LSB_14
    case LSB_15
    case LSB_16
    case LSB_17
    case LSB_18
    case LSB_19
    case LSB_20
    case LSB_21
    case LSB_22
    case LSB_23
    case LSB_24
    case LSB_25
    case LSB_26
    case LSB_27
    case LSB_28
    case LSB_29
    case LSB_30
    case LSB_31
    
    case damperPedal
    case portamentoOnOff
    
    case sostenuto
    case softPedal
    case legatoFootSwitch
    case hold2
    case soundControl_1
    case soundControl_2
    case soundControl_3
    case soundControl_4
    case soundControl_5
    case soundControl_6
    case soundControl_7
    case soundControl_8
    case soundControl_9
    case soundControl_10
    
    case general_5
    case general_6
    case general_7
    case general_8
    
    case portamentoControl
    
    case control_85
    case control_86
    case control_87
    case control_88
    case control_89
    case control_90
    
    case effectDepth_1
    case effectDepth_2
    case effectDepth_3
    case effectDepth_4
    case effectDepth_5
    
    case dataIncrement
    case dataDecrement
    
    case nonRegisteredParamLSB
    case nonRegisteredParamMSB

    case registeredParamLSB
    case registeredParamMSB
    
    case control_102
    case control_103
    case control_104
    case control_105
    case control_106
    case control_107
    case control_108
    case control_109
    case control_110
    case control_111
    case control_112
    case control_113
    case control_114
    case control_115
    case control_116
    case control_117
    case control_118
    case control_119
    
    case channelMode_allSoundOff
    case channelMode_resetAllControllers
    case channelMode_localControls
    case channelMode_allNoteOff
    case channelMode_omniOff
    case channelMode_omniOn
    case channelMode_polyOff
    case channelMode_polyOn

    case invalid
    
    public var description: String {
        switch self {
        case .bankSelect:
        return "Bank Select"
        case .modulation:
            return "Modulation Wheel"
        case .breath:
        return "Breath Controller"
        case .footController:
        return "Foot Controller"
        case .portamentoTime:
        return "Portamento Time"
        case .dataEntryMSB:
        return "Data entry MSB"
        case .channelVolume:
            return "Channel Volume"
        case .balance:
            return "Balance"
        case .pan:
            return "Pan"
        case .expressionController:
            return "Expression Controller"
        case .effectControl1:
            return "Effect Control 1"
        case .effectControl2:
            return "Effect Control 2"
            
        case .damperPedal:
            return "Damper Pedal"
        case .portamentoOnOff:
            return "Portamento On/Off"
        case .bank_LSB:
            return "Bank LSB"
        case .sostenuto:
            return "Sostuneto"
        case .softPedal:
            return "Soft Pedal"
        case .legatoFootSwitch:
            return "Legato Foot Switch"
        case .hold2:
            return "Hold"
        case .soundControl_1:
            return "Sound Control 1"
        case .soundControl_2:
            return "Sound Control 2"
        case .soundControl_3:
            return "Sound Control 3"
        case .soundControl_4:
            return "Sound Control 4"
        case .soundControl_5:
            return "Sound Control 5"
        case .soundControl_6:
            return "Sound Control 6"
        case .soundControl_7:
            return "Sound Control 7"
        case .soundControl_8:
            return "Sound Control 8"
        case .soundControl_9:
            return "Sound Control 9"
        case .soundControl_10:
            return "Sound Control 10"
        case .general_1:
            return "General 1"
        case .general_2:
            return "General 2"
        case .general_3:
            return "General 3"
        case .general_4:
            return "General 4"
        case .general_5:
            return "General 5"
        case .general_6:
            return "General 6"
        case .general_7:
            return "General 7"
        case .general_8:
            return "General 8"
        case .portamentoControl:
            return "Portamento Control"
        case .effectDepth_1:
            return "Effect Depth 1"
        case .effectDepth_2:
            return "Effect Depth 2"
        case .effectDepth_3:
            return "Effect Depth 3"
        case .effectDepth_4:
            return "Effect Depth 4"
        case .effectDepth_5:
            return "Effect Depth 5"
        case .dataIncrement:
            return "Data Increment"
        case .dataDecrement:
            return "Data Decrement"
        case .nonRegisteredParamLSB:
            return "Non-Registered Param LSB"
        case .nonRegisteredParamMSB:
            return "Non-Registered Param MSB"
        case .registeredParamLSB:
            return "Registered Param LSB"
        case .registeredParamMSB:
            return "Registered Param MSB"
        case .channelMode_allSoundOff:
            return "ChannelMode All SOund Off"
        case .channelMode_resetAllControllers:
            return "ChannelMode Reset"
        case .channelMode_localControls:
            return "ChannelMode Local"
        case .channelMode_allNoteOff:
            return "ChannelMode All Note Off"
        case .channelMode_omniOff:
            return "ChannelMode Omni Off"
        case .channelMode_omniOn:
            return "ChannelMode Omni On"
        case .channelMode_polyOff:
            return "ChannelMode Poly Off"
        case .channelMode_polyOn:
            return "ChannelMode Poly On"
        case .invalid:
            return "Invalid"
        default:
            return "Undefined"
        }
    }
}
