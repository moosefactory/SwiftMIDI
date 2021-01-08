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

//  MidiPacketsInterceptor.swift
//  Created by Tristan Leblanc on 28/12/2020.

import Foundation
import CoreMIDI

/// MidiPacket Conversion/Transformation Object

public typealias PacketsProcessBlock = (UnsafePointer<MIDIPacketList>)->Void

public class MidiPacketInterceptor {
    
    
//    static var queue = DispatchQueue(label: "com.moosefactory.midicenter.packets", qos: .userInteractive, attributes: [], autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
        
    public static func filter(_ packetList: UnsafePointer<MIDIPacketList>,
                              channelMask: MidiChannelMask,
                              eventTypeMask: MidiEventTypeMask,
                              transpose: MidiChannelsTranspose,
                              channelMatrix: MidiChannelMatrix,
                              transposeMatrix: MidiChannelsTransposeMatrix) -> MIDIPacketList {
        
        var p = packetList.pointee.packet
        var outPackets = MIDIPacketList()
        var writePacketPtr = MIDIPacketListInit(&outPackets)
        
        var listSizeInBytes = 0
        
        for _ in 0 ..< packetList.pointee.numPackets {
            
            // filter events
            let type = p.data.0 & MidiEvent.typeMask
            if !eventTypeMask.contains(rawEventType: type) { continue }
            
            
            // filter channel
            let channel = p.data.0 & MidiEvent.channelMask
            if (channelMask & (0x0001 << channel)) == 0 { continue }
                        
            var writePacket = p
            for bitIndex in 0..<16 {
                if (channelMatrix.mask[Int(channel)] & (0x0001 << bitIndex)) > 0 {
                    // Adapt list size accordingly to current architecture
                    listSizeInBytes += Int(MemoryLayout<MIDIPacket>.stride)
                    
                    // Override channel
                    writePacket.data.0 = (writePacket.data.0 & MidiEvent.typeMask) | (UInt8(bitIndex) & MidiEvent.channelMask )
                    
                    if type == MidiEventType.noteOn.rawValue || type == MidiEventType.noteOff.rawValue {
                        let transposed = Int(writePacket.data.1) + transposeMatrix.transpose[Int(channel)].transpose[bitIndex]
                        writePacket.data.1 = UInt8(max(min(255,transposed), 0))
                    }
                    print("\(type) \(p.data.0)  > \(writePacket.data.0)")
                    if type == MidiEventType.noteOff.rawValue {
                       print("")
                    }
                    writePacketPtr = MIDIPacketListAdd(&outPackets, listSizeInBytes, writePacketPtr, p.timeStamp, Int(writePacket.length), &writePacket.data.0)
                }
            }
            p = MIDIPacketNext(&p).pointee
        }
        return outPackets
    }
    
    
    /// extractTicks
    ///
    /// Filter the data to keep only clock signals for the given channels
    ///
    /// - parameter packetList: The midi data to process
    /// - parameter channelMask: The channels to filter
    /// - parameter completion: The completion closure, that passes a ClockSignal object containing the number of ticks received and the last timestamp
    
    public static func extractTicks(_ packetList: UnsafePointer<MIDIPacketList>, channelMask: MidiChannelMask = .all, completion: (ClockSignal)->Void) {
        let numPackets = packetList.pointee.numPackets
        var p = packetList.pointee.packet
        var clk = ClockSignal(channelMask: channelMask)
        for _ in 0 ..< numPackets {
            // filter channel and keep only clock event
            if (channelMask & (0x0001 << (p.data.0 & 0x0F))) > 0,
               (p.data.0 & 0xF0) != 0xF0 { continue }
            clk.timeStamp = p.timeStamp
            clk.ticks += 1
            p = MIDIPacketNext(&p).pointee
        }
        if clk.didReceive {
            completion(clk)
        }
    }
    
    /// extractTranspose
    ///
    /// Filter the data to keep only clock signals for the given channels
    ///
    /// - parameter packetList: The midi data to process
    /// - parameter channelMask: The channels to filter
    /// - parameter completion: The completion closure, that passes the last transpose note value
    
    public static func extractTranspose(_ packetList: UnsafePointer<MIDIPacketList>, channelMask: MidiChannelMask = .all, completion: (UInt8)->Void) {
        let numPackets = packetList.pointee.numPackets
        var p = packetList.pointee.packet
        var transpose: UInt8?
        for _ in 0 ..< numPackets {
            // filter channel and keep only clock event
            if (channelMask & (0x0001 << (p.data.0 & 0x0F))) > 0,
               (p.data.0 & 0xF0) != 0x90 { continue }
            transpose = p.data.1
            p = MIDIPacketNext(&p).pointee
        }
        if transpose != nil {
            completion(transpose!)
        }
    }
}
