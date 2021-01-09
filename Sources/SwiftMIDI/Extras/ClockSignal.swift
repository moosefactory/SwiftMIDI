/*--------------------------------------------------------------------------*/
/*   /\/\/\__/\/\/\        MooseFactory SwiftMidi - v1 .0                   */
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

//  ClockSignal.swift
//  Created by Tristan Leblanc on 06/01/2021.

import Foundation
import CoreMIDI

/// ClockSignal
///
/// Use to extract clock ticks from a MidiPacketList
public struct ClockSignal {
    public var ticks: Int = 0
    public var quarterNotes: Int { ticks / 24 }
    public var timeStamp: MIDITimeStamp?
    public var channelMask: MidiChannelMask
    
    public var didReceive: Bool { return ticks > 0 }
}

extension ClockSignal: CustomStringConvertible {
    
    public var description: String {
        guard let ts = timeStamp else {
            return "No Clock Signal Received"
        }
        return "Clock Signal - Received \(ticks) - last time: \(ts) - channels: \(channelMask) - QuarterNotes: \(quarterNotes)"
    }
}
