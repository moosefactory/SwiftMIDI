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
//
// MidiInputBuffer
// Created by Tristan Leblanc on 27/02/2021.

import Foundation
import CoreMIDI

public extension UInt16 {
    public var noteAndVelocity: (UInt8, UInt8) {
        return (UInt8(self>>8), UInt8(self&0xFF))
    }
    
    public var note: UInt8 {
        return UInt8(self>>8)
    }
    
    public var velocity: UInt8 {
        return UInt8(self&0xFF)
   }
}

public typealias FourUInt8 = (UInt8, UInt8, UInt8, UInt8)

public class MidiInputBuffer: CustomStringConvertible {
    
    public var noteOffBuffer = [FourUInt8].init(repeating: (0,0,0,0), count: 256)
    public var numNoteOffs = 0
    public var noteOnBuffer = [FourUInt8].init(repeating: (0,0,0,0), count: 256)
    public var numNoteOns = 0
    public var numControls = 0
    public var count = 0

    public var controlsBuffer = [FourUInt8].init(repeating: (0,0,0,0), count: 256)
    public var time: UInt64 = 0
    public var offset: Int32 = 0

    public var lastControl: FourUInt8? {
        guard numControls > 0 else { return nil }
        return controlsBuffer[numControls-1]
    }
    
    public var lastNoteOn: FourUInt8? {
        guard numNoteOns > 0 else { return nil }
        return noteOnBuffer[numNoteOns-1]
    }

    public func process(noteOn: @escaping (FourUInt8)->Void,
                 noteOff: @escaping (FourUInt8)->Void,
                 control: @escaping (FourUInt8)->Void) {
        for i in 0..<numNoteOns {
            noteOn(noteOnBuffer[i])
        }
        for i in 0..<numNoteOffs {
            noteOff(noteOffBuffer[i])
        }
        for i in 0..<numControls{
            control(self.controlsBuffer[i])
        }
    }
    
    public var isEmpty: Bool {
        numNoteOns == 0 && numNoteOffs == 0 && numControls == 0
    }
    
    public func clear(at time: UInt64, stepOffset: Int32) {
        self.time = time
        self.offset = stepOffset
        numNoteOffs = 0
        numNoteOns = 0
        numControls = 0
    }
    
    var events = [MidiEvent]()
    var numEvents: Int = 0
    
    public func addEvent(_ event: MidiEvent) {
        events.append(event)
        numEvents += 1
        switch event.type {
        case .noteOn:
            noteOnBuffer[numNoteOns] = (event.value1,event.value2,event.channel,event.type.rawValue)
            numNoteOns += 1
        case .noteOff:
            noteOnBuffer[numNoteOffs] = (event.value1,event.value2,event.channel,event.type.rawValue)
            numNoteOffs += 1
        case .control:
            controlsBuffer[numControls] = (event.value1,event.value2,event.channel,event.type.rawValue)
            numControls += 1
        default:
            break
        }
    }
    
    public func addControl(cc1: UInt8, cc2: UInt8, channel: UInt8) {
        controlsBuffer[numControls] = (cc1,cc2,channel, MidiEventType.control.rawValue)
        numControls += 1
    }
    
    public func addNoteOn(pitch: UInt8, velocity: UInt8, channel: UInt8) {
        noteOnBuffer[numNoteOns] = (pitch,velocity,channel, MidiEventType.noteOn.rawValue)
        numNoteOns += 1
    }

    public func addNoteOff(pitch: UInt8, velocity: UInt8, channel: UInt8) {
        noteOffBuffer[numNoteOffs] = (pitch,0,channel, MidiEventType.noteOff.rawValue)
        numNoteOffs += 1
    }

    public var description: String {
        var onStr = "0x"
        for i in 0..<numNoteOns { onStr += String(noteOnBuffer[i].0, radix: 16, uppercase: true) }

        var offStr = "0x"
        for i in 0..<numNoteOffs { offStr += String(noteOffBuffer[i].0, radix: 16, uppercase: true) }

        return "BUFFER : t = \(time) - offset = \(offset)\r    ON \(onStr)\r    OFF : \(offStr)\r    noteOn:\(numNoteOns) noteOff:\(numNoteOffs) controls:\(numControls)"
    }
}
