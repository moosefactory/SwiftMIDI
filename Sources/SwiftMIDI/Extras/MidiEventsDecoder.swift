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

//  MidiEventsDecoder.swift
//  Created by Tristan Leblanc on 08/01/2021.

import Foundation
import CoreMIDI

public class MidiEventsDecoder {
    
    var packetSizeLimit: UInt32 = 4096
    
    public init() {
        
    }
    
    public func unpackEvents(_ packetList: UnsafePointer<MIDIPacketList>,
                                    channelMask: MidiChannelMask = .all,
                                    completion: ([MidiEvent])->Void) {
        var out = [MidiEvent]()
        
        let numPackets = min(packetList.pointee.numPackets, packetSizeLimit)
        
        
        var p = packetList.pointee.packet
        
        for _ in 0 ..< numPackets {
            if (channelMask & (0x0001 << (p.data.0 & 0x0F))) > 0,
               let event = MidiEvent(midiPacket: p) {
                out.append(event)
            }
            p = MIDIPacketNext(&p).pointee
        }
        completion(out)
    }
}
