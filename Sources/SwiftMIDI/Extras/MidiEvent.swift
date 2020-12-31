//
//  MidiEvent.swift
//  MidiCenter
//
//  Created by Tristan Leblanc on 28/12/2020.
//

import Foundation
import CoreMIDI

public enum MidiEventType: UInt8, CustomStringConvertible {
    case noteOff = 0x80
    case noteOn = 0x90
    case polyAfterTouch = 0xA0
    case control = 0xB0
    case programChange = 0xC0
    case afterTouch = 0xD0
    case pitchBend = 0xE0
    case clock = 0xF0

    public var description: String {
        switch self {
        case .noteOn:
            return "Note On"
        case .noteOff:
            return "Note Off"
        case .polyAfterTouch:
            return "Polyphonic Key Pressure (Aftertouch)"
        case .control:
            return "Control"
        case .programChange:
            return "Program Change"
        case .afterTouch:
            return "Channel Pressure (Aftertouch)"
        case .pitchBend:
            return "Pitch Bend Change"
        case .clock:
            return "Clock"
        }
    }
}

public struct MidiEvent: CustomStringConvertible {
    public var type: MidiEventType
    public var timestamp: UInt64
    public var channel: UInt8
    public var value1: UInt8
    public var value2: UInt8

    public init(type: MidiEventType, timestamp: UInt64, channel: UInt8, value1: UInt8, value2: UInt8) {
        self.type = type
        self.timestamp = timestamp
        self.channel = channel
        self.value1 = value1
        self.value2 = value2
    }
    
    func packet(_ channel: UInt8?) -> MIDIPacket {
        var packet = MIDIPacket()
        packet.timeStamp = 0
        packet.data.0 = type.rawValue | (channel ?? self.channel)
        packet.data.1 = value1
        packet.data.2 = value2
        packet.length = 3
        return packet
    }

    public var description: String {
        let chanStr = String(" \(channel)".suffix(2))
        let val1 = String("  \(value1)".suffix(3))
        let val2 = String("  \(value2)".suffix(3))
        switch type {
        
        case .noteOn:
            let note = String("  \(value1.toNote)".suffix(3))
            return " Note On     \(note)     Value: \(val1)   Velo: \(val2)  CH:\(chanStr) "
        case .noteOff:
            let note = String("  \(value1.toNote)".suffix(3))
            return " Note Off    \(note)     Value: \(val1)              CH:\(chanStr) "
        case .polyAfterTouch:
            return " PolyAfterTouch  Value: \(val2) Number: \(val1) CH:\(chanStr) "
        case .control:
            return " Control         Value: \(val2) Number: \(val1) CH:\(chanStr) "
        case .programChange:
            return " Pg Change       Value: \(val2) Number: \(val1) CH:\(chanStr) "
        case .afterTouch:
            return " AfterTouch      Value: \(val2) Number: \(val1) CH:\(chanStr) "
        case .pitchBend:
            let pitch = ( UInt16(value1) + UInt16(value2) << 7)
            let pitchStr = String("    \(pitch)".suffix(4))
            let fractionalPitch = Int( 100 * (( Float(pitch) / Float(0x3FFF) * 2) - 1))
            let fractionalPitchString = "   \(fractionalPitch)%".suffix(4)

            return " Pitch   \(fractionalPitchString)   Value: \(pitchStr) (\(val1),\(val2)) CH:\(chanStr)  "
        case .clock:
            return " Clock 1/24 Note "
        }
    }

    var noteParams: NoteParams {
        return NoteParams(note: value1, velocity: value2)
    }
}
