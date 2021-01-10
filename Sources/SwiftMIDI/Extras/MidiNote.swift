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

//  MidiNote.swift
//  Created by Tristan Leblanc on 28/12/2020.

import Foundation
import CoreMIDI

/// MidiNote
///
/// A simple midi note object

public struct MidiNote: CustomStringConvertible, CustomDebugStringConvertible {

    public var note: UInt8 = 36
    public var velocity: UInt8 = 100

    public var debugDescription: String {
        return "\(note.toNote) (\(note) \(velocity))"
    }

    public var description: String {
        return "\(note.toNote)-\(velocity)"
    }
    
    public mutating func set(note: UInt8) {
        self.note = note
    }

    public mutating func set(velocity: UInt8) {
        self.velocity = velocity
    }
    
    // A unique note id
    func noteID(for channel: UInt) -> UInt16 {
        return UInt16(channel) << 8 + UInt16(note)
    }
    
}

// MARK: - Note <-> Packet

public extension MidiNote {
    
     func noteOnPacket(for channel: UInt8) -> MIDIPacket {
        var noteOnPacket = MIDIPacket()
        noteOnPacket.length = 3
        noteOnPacket.data.1 = note
        noteOnPacket.data.2 = velocity
        noteOnPacket.data.0 = MidiEventType.noteOn.rawValue + (channel & 0x0F)
        return noteOnPacket
    }

    func noteOffPacket(for channel: UInt8) -> MIDIPacket {
        var noteOffPacket = MIDIPacket()
        noteOffPacket.length = 3
        noteOffPacket.data.1 = note
        noteOffPacket.data.2 = 0
        noteOffPacket.data.0 = MidiEventType.noteOff.rawValue + (channel & 0x0F)
        return noteOffPacket
    }
}

// MARK: - Note <-> MidiEvent

public extension MidiNote {
    
    func noteOnEvent(for channel: UInt8) -> MidiEvent {
        return MidiEvent.noteOn(channel: channel, note: note, velocity: velocity)
    }

    func noteOffEvent(for channel: UInt8) -> MidiEvent {
        return MidiEvent.noteOff(channel: channel, note: note)
    }
}

public extension MidiEvent {
    
    var note: MidiNote? {
        guard type == .noteOn else {
            return nil
        }
        return MidiNote(note: value1, velocity: value2)
    }
}
