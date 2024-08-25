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

//  ControlObject.swift
//  Created by Tristan Leblanc on 25/08/2024.

import Foundation
import CoreMIDI

/// ControlObject
///
/// A simple midi control object

public struct ControlObject: CustomStringConvertible, CustomDebugStringConvertible {

    public var number: UInt8
    public var value: UInt8

    public var debugDescription: String {
        return "Ctrl-\(number) = (\(value))"
    }

    public var description: String {
        return "Ctrl-\(number) = (\(value))"
    }
    
    public mutating func set(number: UInt8) {
        self.number = number
    }

    public mutating func set(value: UInt8) {
        self.value = value
    }
    
}

// MARK: - Control <-> Packet

public extension NoteObject {
    
     func controlPacket(for channel: UInt8) -> MIDIPacket {
        var packet = MIDIPacket()
         packet.length = 3
         packet.data.1 = note
         packet.data.2 = velocity
         packet.data.0 = MidiEventType.control.rawValue + (channel & 0x0F)
        return packet
    }
}

// MARK: - Control <-> MidiEvent

public extension ControlObject {
    
    func controlEvent(for channel: UInt8) -> MidiEvent {
        return MidiEvent.control(channel: channel, number: number, value: value)
    }
}

public extension MidiEvent {

    var control: ControlObject? {
        guard type == .control else {
            return nil
        }
        return ControlObject(number: value1, value: value2)
    }
}
