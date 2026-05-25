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

public extension MIDIPacket {
    
    public var type: MidiEventType {
        guard let t = MidiEventType(rawValue: (data.0 & MidiEvent.typeMask)) else {
            fatalError("MidiEvent - Unrecognized Midi Event Type")
        }
        return t
    }
    
    public var status: UInt8 { data.0 }
    public var channel: UInt8 { data.0 & MidiEvent.channelMask }
    public var value1: UInt8 { data.1 }
    public var value2: UInt8 { data.2 }
    
    public var controlNumber: UInt8 { data.1 }
    public var controlValue: UInt8 { data.2 }
    
    public var noteNumber: UInt8 { data.1 }
    public var velocity: UInt8 { data.2 }
    
    public static func noteOn(note: UInt8, velocity: UInt8, channel: UInt8) -> MIDIPacket{
        var packet = MIDIPacket()
        packet.length = 3
        packet.data.0 = UInt8(0x90 + channel % 16)
        packet.data.1 = note
        packet.data.2 = velocity
        return packet
    }
    
    public static func noteOff(note: UInt8, velocity: UInt8 = 0, channel: UInt8) -> MIDIPacket{
        var packet = MIDIPacket()
        packet.length = 3
        packet.data.0 = UInt8(0x80 + channel % 16)
        packet.data.1 = note
        packet.data.2 = velocity
        return packet
    }
}


public class ShortMidiPacketBuffer: Codable, CustomStringConvertible{
    public var pageSize: Int = 768
    public var packets: [ShortMidiPacket]
    public var count: Int { packets.count }
    public var isEmpty: Bool { packets.isEmpty }
    
    // MAK: - Initialization
    
    public init(packets: [ShortMidiPacket]) {
        self.packets = packets
    }
    
    public init() {
        packets = [ShortMidiPacket].init(repeating: ShortMidiPacket(), count: pageSize)
        clear()
    }
    
    // MAK: - Packets array management
    
    public func clear() {
        packets.removeAll(keepingCapacity: true)
    }
    
    public func add(packet: MIDIPacket) {
        if packets.count < pageSize {
            packets.append(ShortMidiPacket(packet: packet))
        }
    }
    
    public func add(shortPacket: ShortMidiPacket) {
        if packets.count < pageSize {
            packets.append(shortPacket)
        }
        print("ShortMidiPacketBuffer.add :\r>>\(shortPacket)\r>>Size\(MemoryLayout.size(ofValue: packets))")
    }
    
    public func add(shortPackets: [ShortMidiPacket]) {
        if packets.count < (pageSize - shortPackets.count) {
            packets.append(contentsOf: shortPackets)
        }
    }
    
    public func remove(shortPackets: [ShortMidiPacket]) {
        let newPackets = packets.filter { packet in
            !shortPackets.contains(packet)
        }
        packets = newPackets
    }
    
    public func add(shortPacketBuffer: ShortMidiPacketBuffer) {
        if packets.count < (pageSize - shortPacketBuffer.count) {
            packets.append(contentsOf: shortPacketBuffer.packets)
        }
    }
    
    public func update(eventsToUpdate: [ShortMidiPacket]) {
        eventsToUpdate.forEach { event in
            if let index = indexOfPacket(with: event.id) {
                packets[index] = event
            }
        }
    }
    
    // MARK: - Access Packets
    
    public func packet(at index: Int) -> ShortMidiPacket? {
        if index >= 0 && index < packets.count {
            return packets[index]
        }
        return nil
    }
    
    public func packet(with id: UInt32) -> ShortMidiPacket? {
        packets.first { packet in
            packet.id == id
        }
    }
    
    public func indexOfPacket(with id: UInt32) -> Int? {
        packets.firstIndex(where: { packet in
            packet.id == id
        })
    }
    
    public func index(of packet: ShortMidiPacket) -> Int? {
        packets.firstIndex { $0 == packet }
    }
    
    public func forEach(_ block: (ShortMidiPacket)->Void) {
        packets.forEach { packet in
            block(packet)
        }
    }
    
    public func enumeratedForEach(_ block: (Int, ShortMidiPacket)->Void) {
        packets.enumerated().forEach { index, packet in
            block(index, packet)
        }
    }
    
    public func firstPacket(after time: MIDITimeStamp) -> ShortMidiPacket? {
        return packets.first { packet in
            packet.timeStamp > time
        }
    }
    
    public func firstPacket(after time: MIDITimeStamp) -> (Int, ShortMidiPacket)? {
        return packets.enumerated().first { index, packet in
            packet.timeStamp > time
        }
    }
    
    public var description: String {
        "ShortMidiPacketBuffer - \(count)/\(pageSize) \(packets.enumerated().map({"\r \($0.offset)\($0.element)"}).joined())"
    }
}

// MARK: - Short Midi Packet

public protocol ShortMidiPacketInfo {
    func copy() -> ShortMidiPacketInfo
}

public typealias ShortMidiPacketInfoID = UInt16

/// A reduced version of the midi packet
/// -> timeStamp  - 8 bytes
/// -> length     - 2 bytes -> 10
/// -> data       - 4 bytes  ( status,channel | note/cc | velocity/value | data.3  )
/// -> id         - 4 bytes
/// -> noteLength - 8 bytes
/// -> infoId     - 4 bytes
///--------------------------
/// ->
public struct ShortMidiPacket: Codable, Identifiable, Equatable, CustomStringConvertible, Sendable {
    
    public var description: String {
        "♩ \(timeStamp) - Status:\(status) - Note:\(noteNumber) - Velo:\(velocity) - Length:\(noteLength)"
    }
    
    static var next_id: UInt32 = 0
    
    static func nextId() -> UInt32 {
        next_id += 1
        return next_id
    }
    
    public static func == (lhs: ShortMidiPacket, rhs: ShortMidiPacket) -> Bool {
        lhs.id == rhs.id
    }
    
    public init(timeStamp: MIDITimeStamp = 0,
                data: (UInt8, UInt8, UInt8, UInt8) = (0,0,0,0),
                noteLength: UInt64 = 0,
                info: ShortMidiPacketInfoID = 0) {
        self.timeStamp = timeStamp
        self.data = data
        self.id = ShortMidiPacket.nextId()
        self.extra = noteLength & 0x00FFFFFF | UInt64(info << 48)
    }
    
    public var timeStamp: MIDITimeStamp = 0                     // 64 - 8
    public var data: (UInt8, UInt8, UInt8, UInt8) = (0,0,0,0)   // 32 - 4
    public private(set) var id: UInt32 = 0                                   // 32 - 4
    private var extra: UInt64 = 0                               // 64 - 8
    
    public var noteLength: UInt64 {
        get { extra & 0x00FFFFFF }
        set { extra = newValue & 0x00FFFFFF | UInt64(info << 48) }
    }
    
    public var info: UInt16 {
        get { UInt16(extra >> 48) }
        set { extra = noteLength & 0x00FFFFFF | UInt64(newValue << 48) }
    }
    
    /// JSON Keys
    enum CodingKeys: String, CodingKey {
        case timeStamp
        case data0
        case data1
        case data2
        case data3
        case extra
    }
    
    public init() {}
    
    /// Init step from JSON container
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        timeStamp = try values.decode(MIDITimeStamp.self, forKey: .timeStamp)
        extra = try values.decode(UInt64.self, forKey: .extra)
        data.0 = try values.decode(UInt8.self, forKey: .data0)
        data.1 = try values.decode(UInt8.self, forKey: .data1)
        data.2 = try values.decode(UInt8.self, forKey: .data2)
        data.3 = try values.decode(UInt8.self, forKey: .data3)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(timeStamp, forKey: .timeStamp)
        try container.encode(extra, forKey: .extra)
        try container.encode(data.0, forKey: .data0)
        try container.encode(data.1, forKey: .data1)
        try container.encode(data.2, forKey: .data2)
        try container.encode(data.3, forKey: .data3)
    }
    
    /// Init from midi packet
    public init(packet: MIDIPacket) {
        self.timeStamp = packet.timeStamp
        self.extra = 0
        self.data.0 = packet.data.0
        self.data.1 = packet.data.1
        self.data.2 = packet.data.2
        self.data.3 = packet.data.3
    }
    
    public init(type: MidiEventType,
                timestamp: UInt64 = 0,
                channel: UInt8 = 0,
                value1: UInt8 = 0,
                value2: UInt8 = 0,
                noteLength: UInt64 = 0,
                info: ShortMidiPacketInfoID) {
        self.init(timeStamp: timestamp,
                  data: (type.rawValue & 0xF0 | channel & 0x0F, value1, value2, 0),
                  noteLength: noteLength,
                  info: info)
    }
    
    public func copy() -> ShortMidiPacket {
        var copy = self
        return copy
    }
    
    public var type: MidiEventType {
        guard let t = MidiEventType(rawValue: (data.0 & MidiEvent.typeMask)) else {
            fatalError("MidiEvent - Unrecognized Midi Event Type")
        }
        return t
    }
    
    public var status: UInt8 { data.0 }
    
    public var channel: UInt8 {
        get { data.0 & MidiEvent.channelMask }
        set { data.0 = (data.0 & MidiEvent.typeMask) | newValue }
    }
    public var value1: UInt8 { data.1 }
    public var value2: UInt8 { data.2 }
    
    public var controlNumber: UInt8 { data.1 }
    public var controlValue: UInt8 { data.2 }
    
    public var noteNumber: UInt8 {
        get { data.1 }
        set { data.1 = newValue }
    }
    
    public var velocity: UInt8 {
        get { data.2 }
        set { data.2 = newValue }
    }
    
    public func packet(with channel: UInt8?) -> MIDIPacket {
        let data0 = data.0
        var packet = MIDIPacket()
        packet.timeStamp = timeStamp
        packet.length = 3
        if let channel = channel {
            packet.data.0 = (data.0 & MidiEvent.typeMask) | channel
        } else {
            packet.data.0 = data.0
        }
        packet.data.1 = data.1
        packet.data.2 = data.2
        packet.data.3 = data.3
        return packet
    }
}

extension ShortMidiPacket {
    public static func noteOn(timeStamp: UInt64 = 0,
                              note: UInt8 = 36,
                              velocity: UInt8 = 80,
                              channel: UInt8 = 0,
                              noteLength: UInt64 = 0,
                              info: ShortMidiPacketInfoID = 0) -> ShortMidiPacket {
        ShortMidiPacket(type: .noteOn,
                        timestamp: timeStamp,
                        channel: channel,
                        value1: note,
                        value2: velocity,
                        noteLength: noteLength,
                        info: info)
    }
    
    public static func noteOff(timeStamp: UInt64 = 0,
                               note: UInt8 = 36,
                               velocity: UInt8 = 80,
                               channel: UInt8 = 0,
                               info: ShortMidiPacketInfoID = 0) -> ShortMidiPacket {
        ShortMidiPacket(type: .noteOn, timestamp: timeStamp, channel: channel, value1: note, info: info)
    }
}

/// MidiEvent
///
/// A musical midi event object used to manipulate common midi events

public struct MidiEvent {
    
    // The mask to apply to data[0] to get type and channel
    static let channelMask: UInt8 = 0x0F
    static let typeMask: UInt8 = 0xF0
    
    public var midiPacket: MIDIPacket {
        set {
            if newValue.length > 6 {
                fatalError("Trying to make ShortMidiPacket with more than 6 bytes of data")
            }
            packet = ShortMidiPacket(packet: newValue)
        }
        get {
            var midiPacket = MIDIPacket()
            midiPacket.timeStamp = packet.timeStamp
            midiPacket.length = 3
            midiPacket.data.0 = packet.data.0
            midiPacket.data.1 = packet.data.1
            midiPacket.data.2 = packet.data.2
            return midiPacket
        }
    }
    
    public var packet: ShortMidiPacket
    
    public var type: MidiEventType {
        guard let t = MidiEventType(rawValue: (packet.data.0 & MidiEvent.typeMask)) else {
            fatalError("MidiEvent - Unrecognized Midi Event Type")
        }
        return t
    }
    
    public var timestamp: UInt64 { packet.timeStamp }
    
    public var status: UInt8 { packet.data.0 }
    public var channel: UInt8 { packet.data.0 & MidiEvent.channelMask }
    public var value1: UInt8 { packet.data.1 }
    public var value2: UInt8 { packet.data.2 }
    
    public var controlNumber: UInt8 { packet.data.1 }
    public var controlValue: UInt8 { packet.data.2 }
    
    public var noteNumber: UInt8 { packet.data.1 }
    public var velocity: UInt8 { packet.data.2 }
    
    public var subType: MidiEventSubType {
        if (status >= SystemCommonMessage.midiTimeCode.rawValue) && (status <= SystemCommonMessage.endOfExclusive.rawValue) {
            return .systemCommon
        }
        
        switch type {
        case .noteOff:
            return .musical
        case .noteOn:
            return .musical
        case .polyAfterTouch:
            return .musical
        case .control:
            if value1 >= ChannelModeMessage.allSoundOff.rawValue && value1 <= ChannelModeMessage.poly.rawValue {
                return .channelMode
            }
            return .musical
        case .programChange:
            return .musical
        case .afterTouch:
            return .musical
        case .pitchBend:
            return .musical
        case .realTimeMessage:
            return .systemCommon
        }
        if type == .control {
            if value1 >= ChannelModeMessage.allSoundOff.rawValue && value1 <= ChannelModeMessage.poly.rawValue {
                return .channelMode
            }
        }
    }
    
    public var numberOfDataBytes: UInt16 { 3 }
    
    /// channelMode
    ///
    /// - returns channel mode message or nil if not a channel mode event
    public var channelMode: ChannelModeMessage? {
        guard type == .control else { return nil }
        return ChannelModeMessage(rawValue: value1)
    }
    
    public var formatedToMilliseconds: String {
        let d = DateFormatter()
        //d.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        d.dateFormat = "HH:mm:ss.SSS"
        return d.string(from: Date(timeIntervalSince1970: Double(timestamp) / 1000000000))
    }
    
    //    public init?(midiPacket: MIDIPacket) {
    //        guard let t = MidiEventType(rawValue: (midiPacket.data.0 & 0xF0)) else { return nil }
    //        self.init(type: t,
    //                  timestamp: midiPacket.timeStamp,
    //                  channel: midiPacket.data.0 & 0x0F,
    //                  value1: midiPacket.data.1,
    //                  value2: midiPacket.data.2)
    //        midiPacketSource = midiPacket
    //    }
    //
    public init(type: MidiEventType,
                timestamp: UInt64 = 0,
                channel: UInt8,
                value1: UInt8,
                value2: UInt8 = 0,
                info: ShortMidiPacketInfoID = 0) {
        packet = ShortMidiPacket(type: type,
                                 timestamp: timestamp,
                                 channel: channel,
                                 value1: value1,
                                 value2: value2,
                                 info: info)
    }
    
    public init(with packet: MIDIPacket, info: ShortMidiPacketInfoID = 0) {
        self.packet = ShortMidiPacket(type: packet.type,
                                      timestamp: packet.timeStamp,
                                      channel: packet.channel,
                                      value1: packet.value1,
                                      value2: packet.value2,
                                      info: info)
    }
    
    public init(with packet: ShortMidiPacket) {
        self.packet = packet
    }
}

extension MidiEvent: CustomStringConvertible {
    
    public var name: String {
        type.name
    }
    
    public var emojiDot: String {
        type.emojiDot
    }
    
    public var description: String {
        stringWithValues
    }
    
    public var stringWithValues: String {
        let chanStr = String(" \(channel+1)".suffix(2))
        let val1 = String("  \(value1)".suffix(3))
        let val2 = String("  \(value2)".suffix(3))
        switch type {
        case .noteOn:
            let note = String("  \(value1.asNoteString)".suffix(3))
            return "\(emojiDot) \(name) Note: \(val1) [\(note)] Velocity: \(val2)  CH:\(chanStr) "
        case .noteOff:
            let note = String("  \(value1.asNoteString)".suffix(3))
            return "\(emojiDot) \(name) Note: \(val1) [\(note)] CH:\(chanStr) "
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
        default:
            return "\(emojiDot) \(name) Value 1: \(val1) Value 2: \(val2)  CH:\(chanStr) "
            
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
        MidiEvent.noteOff(channel: channel, note: noteNumber)
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
