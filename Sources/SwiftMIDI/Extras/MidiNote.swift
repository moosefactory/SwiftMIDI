//
//  MidiNote.swift
//  MidiCenter
//
//  Created by Tristan Leblanc on 28/12/2020.
//

import Foundation
import CoreMIDI



struct NoteParams: CustomStringConvertible, CustomDebugStringConvertible {

    var debugDescription: String {
        return "\(note.toNote) (\(note) \(velocity))"
    }

    var description: String {
        return "\(note.toNote)-\(velocity)"
    }

    var note: UInt8 = 36
    var velocity: UInt8 = 100

    mutating func set(note: UInt8) {
        self.note = note
    }

    mutating func set(velocity: UInt8) {
        self.velocity = velocity
    }
    
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

    // A unique note id
    func noteID(for channel: UInt) -> UInt16 {
        return UInt16(channel) << 8 + UInt16(note)
    }
    
}
