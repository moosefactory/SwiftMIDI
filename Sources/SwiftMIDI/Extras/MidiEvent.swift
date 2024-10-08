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

//  MidiEvent
//  Created by Tristan Leblanc on 28/12/2020.

import Foundation
import CoreMIDI

/// MidiEvent
///
/// A musical midi event object used to manipulate common midi events

public struct MidiEvent {
    public let type: MidiEventType
    public let timestamp: UInt64
    public let channel: UInt8
    public let status: UInt8
    public let value1: UInt8
    public let value2: UInt8
    
    public let subType: MidiEventSubType
    
    public var numberOfDataBytes: UInt8
    public var midiPacketSource: MIDIPacket?
    
    /// channelMode
    ///
    /// - returns channel mode message or nil if not a channel mode event
    public var channelMode: ChannelModeMessage? {
        guard type == .control else { return nil }
        return ChannelModeMessage(rawValue: value1)
    }
    
    // The mask to apply to data[0] to get type and channel
    static let channelMask: UInt8 = 0x0F
    static let typeMask: UInt8 = 0xF0
    
    public var formatedToMilliseconds: String {
        let d = DateFormatter()
        //d.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        d.dateFormat = "HH:mm:ss.SSS"
        return d.string(from: Date(timeIntervalSince1970: Double(timestamp) / 1000000000))
    }
    
    public init?(midiPacket: MIDIPacket) {
        guard let t = MidiEventType(rawValue: (midiPacket.data.0 & 0xF0)) else { return nil }
        self.init(type: t,
                  timestamp: midiPacket.timeStamp,
                  channel: midiPacket.data.0 & 0x0F,
                  value1: midiPacket.data.1,
                  value2: midiPacket.data.2)
        midiPacketSource = midiPacket
    }
    
    public init(type: MidiEventType, timestamp: UInt64 = 0, channel: UInt8, value1: UInt8, value2: UInt8 = 0) {
        self.type = type
        self.timestamp = timestamp
        self.channel = channel
        self.value1 = value1
        self.value2 = value2
        self.numberOfDataBytes = type.dataLength
        let status = (type.rawValue & 0xF0) | (channel & 0x0F)
        self.status = status
        
        if (status >= SystemCommonMessage.midiTimeCode.rawValue) && (status <= SystemCommonMessage.endOfExclusive.rawValue) {
            subType = .systemCommon
            return
        }
        if type == .control {
            if value1 >= ChannelModeMessage.allSoundOff.rawValue && value1 <= ChannelModeMessage.poly.rawValue {
                subType = .channelMode
                return
            }
        }
        subType = .musical
    }
}

extension MidiEvent: CustomStringConvertible {
    
    public var description: String {
        let chanStr = String(" \(channel)".suffix(2))
        let val1 = String("  \(value1)".suffix(3))
        let val2 = String("  \(value2)".suffix(3))
        switch type {
        
        case .noteOn:
            let note = String("  \(value1.asNoteString)".suffix(3))
            return " Note On     \(note)     Value: \(val1)   Velo: \(val2)  CH:\(chanStr) "
        case .noteOff:
            let note = String("  \(value1.asNoteString)".suffix(3))
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
        case .realTimeMessage:
            return " Clock 1/24 Note "
        }
    }
}

// MARK: - Utilities

public extension MidiEvent {
    
    var noteParams: NoteObject {
        return NoteObject(note: value1, velocity: value2)
    }
    
    var controlParams: ControlObject {
        return ControlObject(number: value1, value: value2)
    }
    /// noteOff
    ///
    /// Returns current event with noteOff type.
    /// This has sense only for noteOn events.
    
    func noteOff() -> MidiEvent {
        return MidiEvent(type: .noteOff, timestamp: timestamp, channel: channel, value1: value1, value2: 0)
    }
    
    /// bytes
    /// Returns the exact bytes to append to midi message
    ///
    /// - parameter channel :
    /// Override the event channel if needed
    /// - parameter runningStatus :
    /// Pass the previous status in message. If status of this event is equal to runningstatus,
    /// then we don't re-encode the status in the message ( see MIDI Porotocol - Running status )
    ///
    /// - returns (Data, newRunningStatus)
    /// Returns the bytes to add, and the new running status to use in next encoding
    func bytes(channel: UInt8?, runningStatus: UInt8) -> ([UInt8], UInt8) {
        let status = type.rawValue | (channel ?? self.channel)
        if status == runningStatus {
            switch type.dataLength {
            case 0:
                return ([], status)
            case 1:
                return ([value1], status)
            case 2:
                return ([value1, value2], status)
            default:
                return ([], status)
            }
        }
        switch type.dataLength {
        case 0:
            return ([status], status)
        case 1:
            return ([status, value1], status)
        case 2:
            return ([status, value1, value2], status)
        default:
            return ([], status)
        }
    }
    
    func midiPacket(channel: UInt8? = nil) -> MIDIPacket {
        var packet = MIDIPacket()
        packet.timeStamp = 0
        packet.length = UInt16(type.dataLength)
        packet.data.0 = type.rawValue | (channel ?? self.channel)
        switch type.dataLength {
        case 1:
            packet.data.1 = value1
        case 2:
            packet.data.1 = value1
            packet.data.2 = value2
        default:
            break
        }

        return packet
    }
}

public extension Array where Element == MidiEvent {
    
    /// Returns all noteOffs for noteOns in target array
    var asNotesOff: [MidiEvent] {
        var out = [MidiEvent]()
        for event in self where event.type == .noteOn {
            out.append(event.noteOff())
        }
        return out
    }
        
    func asPacketList(channelOverride: UInt8? = nil) -> MIDIPacketList? {
        return MidiEventsEncoder.encodePacketList(with: self, channelOverride: channelOverride)
    }

}
