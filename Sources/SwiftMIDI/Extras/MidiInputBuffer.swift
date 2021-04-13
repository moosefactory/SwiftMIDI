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

public class MidiInputBuffer: CustomStringConvertible {
    public var noteOffBuffer = [UInt16].init(repeating: 0, count: 256)
    public var numNoteOffs = 0
    public var noteOnBuffer = [UInt16].init(repeating: 0, count: 256)
    public var numNoteOns = 0
    public var count = 0

    public var time: UInt64 = 0
    public var offset: Int32 = 0

    public func clear(at time: UInt64, stepOffset: Int32) {
        self.time = time
        self.offset = stepOffset
        numNoteOffs = 0
        numNoteOns = 0
    }
    
    public func addNoteOn(pitch: UInt8, velocity: UInt8) {
        noteOnBuffer[numNoteOns] = (UInt16(pitch) << 8) | UInt16(velocity)
        numNoteOns += 1
    }
    
    public func addNoteOff(pitch: UInt8, velocity: UInt8) {
        noteOffBuffer[numNoteOffs] = (UInt16(pitch) << 8) | UInt16(velocity)
        numNoteOffs += 1
    }

    public var description: String {
        var onStr = "0x"
        for i in 0..<numNoteOns { onStr += String(noteOnBuffer[i], radix: 16, uppercase: true) }

        var offStr = "0x"
        for i in 0..<numNoteOffs { offStr += String(noteOffBuffer[i], radix: 16, uppercase: true) }

        return "BUFFER : t = \(time) - offset = \(offset)\r    ON \(onStr)\r    OFF : \(offStr)"
    }
}
