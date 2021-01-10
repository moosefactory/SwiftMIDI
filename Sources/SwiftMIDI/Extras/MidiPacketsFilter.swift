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

//  File.swift
//  Created by Tristan Leblanc on 09/01/2021.

import Foundation
import CoreMIDI

public class MidiPacketsFilter {
    
    public var settings: MidiFilterSettings
    
    public init(settings: MidiFilterSettings) {
        self.settings = settings
    }
    
    
    public class Output {
        /// The filtered packets
        public fileprivate(set) var packets: MIDIPacketList?
        
        /// Will contains channels that have received musical events
        public fileprivate(set) var activatedChannels = MidiChannelMask.none
        
        /// Will contains lower and higher notes triggered per channel.
        /// If channel bit is not set in activated channels, this has no meaning
        public fileprivate(set) var higherAndLowerNotes = [MidiRange].init(repeating: MidiRange(lower: 127 , higher: 0), count: 16)
        
        /// Last Real Time Message
        public fileprivate(set) var realTimeMessage: RealTimeMessageType = .none
        
        /// Last ProgramChange
        public fileprivate(set) var programChanges: MidiChannelsValues = .empty
        
        /// The time spent in the filter
        public fileprivate(set) var filteringTime: TimeInterval = 0
        
        /// Ticks received.
        /// If everything runs smoothly, there is always one tick, but if a stall occurs, buffer can contains several ticks
        public fileprivate(set) var ticks: UInt8 = 0
        
        public fileprivate(set) var timeStamp: MIDITimeStamp = 0
        
        init(packets: MIDIPacketList?) {
            self.packets = packets
        }
    }
    
    /// Returns the number of events with the given types, channels and range
    ///
    /// This function code is quite long, but performant.
    
    private func preflight(in packetList: UnsafePointer<MIDIPacketList>) -> (UInt32, UInt32, UInt32) {
        var numberOfEvents: UInt32 = 0
        var dataSize: UInt32 = 0
        var p = packetList.pointee.packet
        let numberOfPackets = packetList.pointee.numPackets
        
        
        // Scan the midi data and cut if necessary
        
        var currentStatus: UInt8 = 0
        var type: UInt8 = 0
        var channel: UInt8 = 0
        // true if current byte is velocity
        var byteSelector: Bool = false
        // true if the whole event is skipped
        var skipTrain = false
        
        var skipNote: Bool = false
        var byte: UInt8 = 0
        var checkedStatus: Bool = false
        var keepStatus: Bool = false
        
        for _ in 0 ..< numberOfPackets {
            withUnsafeBytes(of: p.data) { bytes in
                // In some cases, like pausing xCode, it looks like the packet size can grow far beyond the limit
                // so we only process the first 256 bytes. I'm not sure of what I am doing here,
                // but I'm sure it crashes if i >= 256
                for i in 0..<min(Int(p.length), 256) {
                    byte = UInt8(bytes[i])
                    
                    // Read Status Byte if needed
                    
                    // 1 - read status
                    
                    if byte & 0xF0 >= 0x80  {
                        
                        // We keep status only if subsequent events are kept
                        keepStatus = false
                        
                        currentStatus = byte
                        type = currentStatus & 0xF0
                        channel = currentStatus & 0x0F
                        
                        skipNote = false
                        // Reset the skip flag
                        skipTrain = false
                        
                        byteSelector = false
                        checkedStatus = false
                        if type == MidiEventType.realTimeMessage.rawValue {
                            if !settings.eventTypes.contains(rawEventType: type) {
                                continue
                            }
                            dataSize += 1
                            numberOfEvents += 1
                        }
                        
                        continue
                    }
                    
                    // 2 - If not status, then check if we are skipping this event
                    
                    if skipTrain { continue }
                    
                    // 3 - We have an event - filter by channel and type
                    
                    // Continue skip if status has already be checked
                    if !checkedStatus {
                        checkedStatus = true
                        
                        // filter events
                        if !settings.eventTypes.contains(rawEventType: type) {
                            skipTrain = true
                            continue
                        }
                        
                        // filter channel
                        if (settings.channels & (0x0001 << channel)) == 0 {
                            skipTrain = true
                            continue
                        }
                    } else {
                        if skipTrain { continue }
                    }
                    
                    // 4 - So far so good, now we are in potentially kept events data.
                    //     We only filter notes
                    
                    switch type {
                    
                    // 2 data byte events
                    
                    // If we deal with noteOns, then we filter range and velocity
                    case MidiEventType.noteOn.rawValue:
                        // Check if current byte is note or velocity
                        if byteSelector {
                            if !skipNote {
                                skipNote = byte < settings.velocityRange.lower
                                    || byte > settings.velocityRange.higher
                                
                                // Still not skip the note, we count it to
                                if !skipNote {
                                    dataSize += 2
                                    numberOfEvents += 1
                                    if (!keepStatus) {
                                        keepStatus = true
                                        dataSize += 1
                                    }
                                } else {
                                    // reset skipNote for the next note
                                    skipNote = false
                                }
                            } else {
                                // reset skipNote for the next note
                                skipNote = false
                            }
                            // Next byte will be note number
                            byteSelector = false
                        } else {
                            skipNote = byte < settings.noteRange.lower
                                || byte > settings.noteRange.higher
                            // Next byte will be velocity
                            byteSelector = true
                        }
                        
                    case MidiEventType.noteOff.rawValue:
                        
                        // Check if current byte is note or velocity ( no meaning on note off, but still there )
                        if byteSelector {
                            dataSize += 2
                            numberOfEvents += 1
                            byteSelector = false
                            if (!keepStatus) {
                                keepStatus = true
                                dataSize += 1
                            }
                        } else {
                            byteSelector = true
                        }
                        
                    case MidiEventType.control.rawValue:
                        
                        // Check if current byte is control number or value
                        if byteSelector {
                            dataSize += 2
                            numberOfEvents += 1
                            byteSelector = false
                            if (!keepStatus) {
                                keepStatus = true
                                dataSize += 1
                            }
                        } else {
                            byteSelector = true
                        }
                        
                    case MidiEventType.pitchBend.rawValue:
                        
                        // Check if current byte is control number or value
                        if byteSelector {
                            dataSize += 2
                            numberOfEvents += 1
                            byteSelector = false
                            if (!keepStatus) {
                                keepStatus = true
                                dataSize += 1
                            }
                        } else {
                            byteSelector = true
                        }
                        
                    case MidiEventType.polyAfterTouch.rawValue:
                        
                        if byteSelector {
                            dataSize += 2
                            numberOfEvents += 1
                            byteSelector = false
                            if (!keepStatus) {
                                keepStatus = true
                                dataSize += 1
                            }
                        } else {
                            byteSelector = true
                        }
                        
                    // 1 data byte events
                    
                    case MidiEventType.afterTouch.rawValue:
                        if (!keepStatus) {
                            keepStatus = true
                            dataSize += 1
                        }
                        dataSize += 1
                        numberOfEvents += 1
                        
                    case MidiEventType.programChange.rawValue:
                        if (!keepStatus) {
                            keepStatus = true
                            dataSize += 1
                        }
                        dataSize += 1
                        numberOfEvents += 1
                        
                    // 0 data byte events
                    
                    case MidiEventType.realTimeMessage.rawValue:
                        break
                    default:
                        break
                    } // End switch
                    
                } // End scan
            }
            
            // Go to next packet ( should never happen for musical events )
            p = MIDIPacketNext(&p).pointee
        }
        
        return (numberOfPackets, numberOfEvents, dataSize)
    }
    
    // MARK: - Filtering
    
    /// filter
    ///
    /// Returns a filtered list of MIDI Packets
    ///
    /// THIS ONLY WORK WITH ONE MIDI PACKET - DO NOT PASS SYSEX THROUGH THIS
    
    public func filter(packetList: UnsafePointer<MIDIPacketList>) -> Output {
        
        if settings.willPassThrough { return Output(packets: packetList.pointee) }
        
        let chrono = Date()
        
        // Get final number of events
        let (numberOfPackets, count, dataSize) = preflight(in: packetList)
        guard count > 0 else {
            return Output(packets: nil) }
        
        var outPackets = MIDIPacketList()
        let writePacketPtr = MIDIPacketListInit(&outPackets)
        
        let output = Output(packets: outPackets)
        
        let targetBytes = [UInt8].init(unsafeUninitializedCapacity: Int(dataSize)) { (targetBytes, count) in
            count = Int(dataSize)
            
            var writeIndex = 0
            
            var p = packetList.pointee.packet
            
            // Scan the midi data and cut if necessary
            
            var currentStatus: UInt8 = 0
            var type: UInt8 = 0
            var channel: UInt8 = 0
            // true if current byte is velocity
            var byteSelector: Bool = false
            // true if the whole event is skipped
            var skipTrain = false
            
            // the length of data bytes following the status byte
            // if 0, then we can remove the status byte
            var skipNote: Bool = false
            var byte: UInt8 = 0
            
            var data1: UInt8 = 0
            var note: Int16 = 0
            
            var wroteStatus: Bool = false
            
            for _ in 0 ..< numberOfPackets {
                output.timeStamp = p.timeStamp
                withUnsafeBytes(of: p.data) { bytes in
                    for i in 0..<min(Int(p.length), 256) {
                        byte = UInt8(bytes[i])
                        
                        // Read Status Byte if needed
                        
                        // 1 - read status
                        
                        if byte & 0xF0 >= 0x80  {
                            currentStatus = byte
                            type = currentStatus & 0xF0
                            channel = currentStatus & 0x0F
                            
                            skipNote = false
                            // Reset the skip flag
                            skipTrain = false
                            byteSelector = false
                            
                            /// We write status only if some data are kept
                            wroteStatus = false
                            data1 = 0
                            
                            // Process data-less types
                            
                            // Clock - if clock are not filtered and clock channel match, we process clock
                            if type == MidiEventType.realTimeMessage.rawValue {
                                if !settings.eventTypes.contains(rawEventType: type) {
                                    continue
                                }
                                
                                if currentStatus == RealTimeMessageType.clock.rawValue {
                                    output.ticks += 1
                                }
                                else {
                                    output.realTimeMessage = RealTimeMessageType(rawValue: currentStatus) ?? .none
                                }
                                
                                // --- WRITE ----
                                
                                targetBytes[writeIndex] = byte
                                writeIndex += 1
                            }
                            else {
                                if settings.tracksActivatedChannels {
                                    output.activatedChannels |= (0x0001 << channel)
                                }
                            }
                            
                            continue
                        }
                        
                        // 2 - If not status, then check if we are skipping this event
                        
                        if skipTrain { continue }
                        
                        // 3 - We have an event - filter by channel and type
                        
                        // filter events
                        if !settings.eventTypes.contains(rawEventType: type) {
                            skipTrain = true
                            continue
                        }
                        
                        // filter channel
                        if (settings.channels & (0x0001 << channel)) == 0 {
                            skipTrain = true
                            continue
                        }
                        
                        // 4 - So far so good, now we are in potentially kept events data.
                        //     We only filter notes
                        
                        switch type {
                        
                        // 2 data byte events
                        
                        // If we deal with noteOns, then we filter range and velocity
                        case MidiEventType.noteOn.rawValue:
                            // Check if current byte is note or velocity
                            if byteSelector {
                                if !skipNote {
                                    skipNote = byte < settings.velocityRange.lower
                                        || byte > settings.velocityRange.higher
                                    
                                    // Still not skip the note, we count it
                                    if !skipNote {
                                        // Transpose
                                        note = Int16(data1)
                                        if settings.globalTranspose != 0 {
                                            note = note + settings.globalTranspose
                                        }
                                        if settings.channelsTranspose.transpose[Int(channel)] != 0 {
                                            note = note + settings.channelsTranspose.transpose[Int(channel)]
                                        }
                                        if note <= 0 {
                                            data1 = 0
                                        } else if note >= 127 {
                                            data1 = 127
                                        } else {
                                            data1 = UInt8(note)
                                        }
                                        
                                        
                                        // Record higher and lower notes
                                        if settings.tracksHigherAndLowerNotes {
                                            if data1 < output.higherAndLowerNotes[Int(channel)].lower {
                                                output.higherAndLowerNotes[Int(channel)].lower = data1
                                            }
                                            if data1 > output.higherAndLowerNotes[Int(channel)].higher {
                                                output.higherAndLowerNotes[Int(channel)].higher = data1
                                            }
                                        }
                                        
                                        // --- WRITE ----
                                        if !wroteStatus {
                                            wroteStatus = true
                                            targetBytes[writeIndex] = (currentStatus & 0xF0)
                                                | (settings.channelsMap.channels[Int(channel)] & 0x0F)
                                            writeIndex += 1
                                        }
                                        targetBytes[writeIndex] = data1
                                        writeIndex += 1
                                        targetBytes[writeIndex] = byte
                                        writeIndex += 1
                                        // -------------
                                        
                                    } else {
                                        // reset skipNote for the next note
                                        skipNote = false
                                    }
                                } else {
                                    // reset skipNote for the next note
                                    skipNote = false
                                }
                                // Next byte will be note number
                                byteSelector = false
                            } else {
                                skipNote = byte < settings.noteRange.lower
                                    || byte > settings.noteRange.higher
                                // Will be written if velocity is accepted
                                data1 = byte
                                // Next byte will be velocity
                                byteSelector = true
                            }
                            
                        case MidiEventType.noteOff.rawValue:
                            
                            // Check if current byte is note or velocity ( no meaning on note off, but still there )
                            if byteSelector {
                                // Transpose
                                note = Int16(data1)
                                if settings.globalTranspose != 0 {
                                    note = note + settings.globalTranspose
                                }
                                if settings.channelsTranspose.transpose[Int(channel)] != 0 {
                                    note = note + settings.channelsTranspose.transpose[Int(channel)]
                                }
                                if note <= 0 {
                                    data1 = 0
                                } else if note >= 127 {
                                    data1 = 127
                                } else {
                                    data1 = UInt8(note)
                                }
                                
                                // --- WRITE ----
                                if !wroteStatus {
                                    wroteStatus = true
                                    targetBytes[writeIndex] = (currentStatus & 0xF0)
                                        | (settings.channelsMap.channels[Int(channel)] & 0x0F)
                                    writeIndex += 1
                                }
                                targetBytes[writeIndex] = data1
                                writeIndex += 1
                                targetBytes[writeIndex] = byte
                                writeIndex += 1
                                // -------------
                                
                                byteSelector = false
                            } else {
                                data1 = byte
                                byteSelector = true
                            }
                            
                        case MidiEventType.control.rawValue:
                            
                            // Check if current byte is control number or value
                            if byteSelector {
                                // --- WRITE ----
                                if !wroteStatus {
                                    wroteStatus = true
                                    targetBytes[writeIndex] = (currentStatus & 0xF0)
                                        | (settings.channelsMap.channels[Int(channel)] & 0x0F)
                                    writeIndex += 1
                                }
                                targetBytes[writeIndex] = data1
                                writeIndex += 1
                                targetBytes[writeIndex] = byte
                                writeIndex += 1
                                // -------------
                                
                                byteSelector = false
                            } else {
                                data1 = byte
                                byteSelector = true
                            }
                            
                        case MidiEventType.pitchBend.rawValue:
                            
                            // Check if current byte is control number or value
                            if byteSelector {
                                // --- WRITE ----
                                if !wroteStatus {
                                    wroteStatus = true
                                    targetBytes[writeIndex] = (currentStatus & 0xF0)
                                        | (settings.channelsMap.channels[Int(channel)] & 0x0F)
                                    writeIndex += 1
                                }
                                
                                targetBytes[writeIndex] = data1
                                writeIndex += 1
                                targetBytes[writeIndex] = byte
                                writeIndex += 1
                                // -------------
                                
                                byteSelector = false
                            } else {
                                data1 = byte
                                byteSelector = true
                            }
                            
                        case MidiEventType.polyAfterTouch.rawValue:
                            
                            if byteSelector {
                                // --- WRITE ----
                                if !wroteStatus {
                                    wroteStatus = true
                                    targetBytes[writeIndex] = (currentStatus & 0xF0)
                                        | (settings.channelsMap.channels[Int(channel)] & 0x0F)
                                    writeIndex += 1
                                }
                                targetBytes[writeIndex] = data1
                                writeIndex += 1
                                targetBytes[writeIndex] = byte
                                writeIndex += 1
                                // -------------
                                
                                byteSelector = false
                            } else {
                                data1 = byte
                                byteSelector = true
                            }
                            
                        // 1 data byte events
                        
                        case MidiEventType.afterTouch.rawValue:
                            // --- WRITE ----
                            if !wroteStatus {
                                wroteStatus = true
                                targetBytes[writeIndex] = (currentStatus & 0xF0)
                                    | (settings.channelsMap.channels[Int(channel)] & 0x0F)
                                writeIndex += 1
                            }
                            
                            targetBytes[writeIndex] = byte
                            writeIndex += 1
                        // -------------
                        
                        case MidiEventType.programChange.rawValue:
                            
                            output.programChanges.values[Int(channel)] = Int16(byte)
                            // --- WRITE ----
                            if !wroteStatus {
                                wroteStatus = true
                                targetBytes[writeIndex] = (currentStatus & 0xF0)
                                    | (settings.channelsMap.channels[Int(channel)] & 0x0F)
                                writeIndex += 1
                            }
                            
                            targetBytes[writeIndex] = byte
                            writeIndex += 1
                        // -------------
                        
                        // 0 data byte events
                        
                        case MidiEventType.realTimeMessage.rawValue:
                            break
                        default:
                            break
                        } // End switch
                        
                    } // End scan
                }
                // Go to next packet ( should never happen for musical events )
                p = MIDIPacketNext(&p).pointee
            }
        }
        
        MIDIPacketListAdd(&outPackets, Int(14 + dataSize), writePacketPtr, output.timeStamp, Int(dataSize), targetBytes)
        
        output.filteringTime = -chrono.timeIntervalSinceNow
        output.packets = outPackets
        return output
    }
}

