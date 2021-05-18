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

//  MidiEventsEncoder.swift
//  Created by Tristan Leblanc on 08/01/2021.

import Foundation
import CoreMIDI

/// MidiEventsEncoder
///
/// Encode a midi events array into a MIDIPacketList
public class MidiEventsEncoder {
    
    static public func encodePacketList(with events: [MidiEvent],
                                        channelOverride: UInt8? = nil) -> MIDIPacketList? {
        let numberOfEvents: UInt32 = UInt32(events.count)
        guard numberOfEvents > 0 else { return nil }
        
        var dataSize: Int = 0
        // We could preflight the events list to only allocate the needed size, but the overhead is not worth it, since majority of musical events will be 3 bytes long, and there is rarely a huge number of events
        let bytes = [UInt8].init(unsafeUninitializedCapacity: 3 * Int(numberOfEvents)) { (pointer, count) in
            // The number of data bytes in the message
            var numBytes = 0
            // The status byte of the last event
            // According to MIDI protocol running status, we don't have to repeat the status if
            // type and channels are equal ( status byte equals )
            var runningStatus: UInt8 = 0
            for event in events.sorted(by: { return $0.status < $1.status} ) {
                let channel = channelOverride ?? event.channel
                let status: UInt8 = (event.type.rawValue & 0xF0) | (channel & 0x0F)
                // Encode status if needed
                if status != runningStatus {
                    runningStatus = status
                    pointer[numBytes] = status
                    numBytes += 1
                }
                // Encode values
                if event.numberOfDataBytes > 0 {
                    pointer[numBytes] = event.value1
                    numBytes += 1
                }
                if event.numberOfDataBytes > 1 {
                    pointer[numBytes] = event.value2
                    numBytes += 1
                }
            }
            dataSize = numBytes
            count = numBytes
        }
        
        var outPackets = MIDIPacketList()
        let writePacketPtr = MIDIPacketListInit(&outPackets)
        MIDIPacketListAdd(&outPackets, Int(14 + dataSize), writePacketPtr, 0, dataSize, bytes)
        return outPackets
    }
}
