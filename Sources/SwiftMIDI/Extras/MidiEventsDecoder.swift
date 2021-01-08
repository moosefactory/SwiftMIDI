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

//  MidiEventsDecoder.swift
//  Created by Tristan Leblanc on 08/01/2021.

import Foundation
import CoreMIDI

class MidiEventsDecoder {
    
    public static func unpackEvents(_ packetList: UnsafePointer<MIDIPacketList>,
                                    channelMask: MidiChannelMask = .all,
                                    channelMap: MidiChannelMapper? = nil,
                                    completion: ([MidiEvent])->Void) {
        var out = [MidiEvent]()
        let numPackets = packetList.pointee.numPackets
        var p = packetList.pointee.packet
        
        for _ in 0 ..< numPackets {
            if (channelMask & (0x0001 << (p.data.0 & 0x0F))) > 0,
               let type = MidiEventType(rawValue: (p.data.0 & 0xF0)) {
                let event = MidiEvent(type: type,
                                      timestamp: p.timeStamp,
                                      channel: (p.data.0 & 0x0F),
                                      value1: p.data.1,
                                      value2: p.data.2)
                out.append(event)
            }
            p = MIDIPacketNext(&p).pointee
        }
        completion(out)
    }
}
