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
        
        /// The time spent in the filter
        public fileprivate(set) var filteringTime: TimeInterval = 0
        
        
        /// Ticks received.
        /// If everything runs smoothly, there is always one tick, but if a stall occurs, buffer can contains several ticks
        public fileprivate(set) var ticks: UInt8 = 0
        
        init(packets: MIDIPacketList?) {
            self.packets = packets
        }
    }

    /// Returns the number of events with the given types, channels and range
    ///
    /// This function code is quite long, but performant.
    
    private func preflight(in packetList: UnsafePointer<MIDIPacketList>) -> (UInt32, UInt32) {
        var numberOfEvents: UInt32 = 0
        var dataSize: UInt32 = 0
        var p = packetList.pointee.packet
        let length = Int(p.length)
        for _ in 0 ..< packetList.pointee.numPackets {
            
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
            var trainLength: UInt32 = 0
            var trainDataSize: UInt32 = 0
            var skipNote: Bool = false
            var byte: UInt8 = 0
            var checkedStatus: Bool = false
            
            withUnsafeBytes(of: &p.data) { bytes in
                for i in 0..<length {
                    byte = UInt8(bytes[i])
                    
                    // Read Status Byte if needed
                    
                    // 1 - read status
                    
                    if byte & 0xF0 >= 0x80  {
                        
                        // Got a new status, deal with previously read events train
                        if trainLength > 0 {
                            dataSize += trainDataSize + 1 // for status byte
                            numberOfEvents += trainLength
                        }
                        
                        currentStatus = byte
                        type = currentStatus & 0xF0
                        channel = currentStatus & 0x0F
                        
                        skipNote = false
                        // Reset the skip flag
                        skipTrain = false
                        // Reset train
                        trainLength = 0
                        trainDataSize = 0
                        byteSelector = false
                        checkedStatus = false
                        
                        // Process data-less, channel-less types
                        if type == MidiEventType.realTimeMessage.rawValue {
                            if !settings.eventTypes.contains(rawEventType: type) {
                                continue
                            }
                            
                            trainLength += 1
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
                                    trainDataSize += 2
                                    trainLength += 1
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
                            trainDataSize += 2
                            trainLength += 1
                            byteSelector = false
                        } else {
                            byteSelector = true
                        }
                        
                    case MidiEventType.control.rawValue:
                        
                        // Check if current byte is control number or value
                        if byteSelector {
                            trainDataSize += 2
                            trainLength += 1
                            byteSelector = false
                        } else {
                            byteSelector = true
                        }
                        
                    case MidiEventType.pitchBend.rawValue:
                        
                        // Check if current byte is control number or value
                        if byteSelector {
                            trainDataSize += 2
                            trainLength += 1
                            byteSelector = false
                        } else {
                            byteSelector = true
                        }
                        
                    case MidiEventType.polyAfterTouch.rawValue:
                        
                        if byteSelector {
                            trainDataSize += 2
                            trainLength += 1
                            byteSelector = false
                        } else {
                            byteSelector = true
                        }
                        
                    // 1 data byte events
                    
                    case MidiEventType.afterTouch.rawValue:
                        trainDataSize += 1
                        trainLength += 1
                        
                    case MidiEventType.programChange.rawValue:
                        trainDataSize += 1
                        trainLength += 1
                        
                    // 0 data byte events
                    
                    case MidiEventType.realTimeMessage.rawValue:
                        break
                    default:
                        break
                    } // End switch
                    
                } // End scan
                
                // If last train has data, add it
                if trainLength > 0 {
                    dataSize += trainDataSize + 1 // for status byte
                    numberOfEvents += trainLength
                }
            }
            
            // Go to next packet ( should never happen for musical events )
            p = MIDIPacketNext(&p).pointee
        }
        
        return (numberOfEvents, dataSize)
    }
    
    // MARK: - Filtering
    
    /// filter
    ///
    /// Returns a filtered list of MIDI Packets
    ///
    /// THIS ONLY WORK WITH ONE MIDI PACKET - DO NOT PASS SYSEX THROUGH THIS
    
    public func filter(packetList: UnsafePointer<MIDIPacketList>) -> Output {
        
        if settings.willPassThrough { return Output(packets: packetList.pointee) }
        
        var chrono = Date()

        // Get final number of events
        let (count, dataSize) = preflight(in: packetList)
        guard count > 0 else { return Output(packets: nil) }
        
        var outPackets = MIDIPacketList()
        let writePacketPtr = MIDIPacketListInit(&outPackets)
        
        let output = Output(packets: outPackets)
        
        let targetBytes = [UInt8].init(unsafeUninitializedCapacity: Int(dataSize)) { (targetBytes, count) in
            count = Int(dataSize)
            
            var writeIndex = 0
            
            var p = packetList.pointee.packet
            for _ in 0 ..< packetList.pointee.numPackets {
                
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
                var trainLength: UInt32 = 0
                var trainDataSize: UInt32 = 0
                var skipNote: Bool = false
                var byte: UInt8 = 0
                
                var data1: UInt8 = 0
                var note: Int16 = 0
                
                var wroteStatus: Bool = false
                
                withUnsafeBytes(of: &p.data) { bytes in
                    for i in 0..<Int(p.length) {
                        byte = UInt8(bytes[i])
                        
                        // Read Status Byte if needed
                        
                        // 1 - read status
                        
                        if byte & 0xF0 >= 0x80  {
                            
                            // Got a new status, deal with previously read events train
                            if trainLength > 0 {
                                
                                // --- WRITE ----
                                // Write index is on previous event byte, advance by one
                                // if train length is 0, previous status byte will be over-written
                                writeIndex += 1
                                // -------------
                            }
                            
                            currentStatus = byte
                            type = currentStatus & 0xF0
                            channel = currentStatus & 0x0F
                            
                            skipNote = false
                            // Reset the skip flag
                            skipTrain = false
                            // Reset train
                            trainLength = 0
                            trainDataSize = 0
                            byteSelector = false
                            
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

                                trainLength += 1
                                targetBytes[writeIndex] = byte
                                
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
                        
                        // We have chances to keep events, write status in target bytes
                        if !wroteStatus {
                            wroteStatus = true
                            targetBytes[writeIndex] = (currentStatus & 0xF0)
                                | (settings.channelsMap.channels[Int(channel)] & 0x0F)
                            
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
                                    
                                    // Still not skip the note, we count it
                                    if !skipNote {
                                        trainDataSize += 2
                                        trainLength += 1
                                        
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
                                        writeIndex += 1
                                        targetBytes[writeIndex] = data1
                                        writeIndex += 1
                                        targetBytes[writeIndex] = byte
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
                                trainDataSize += 2
                                trainLength += 1
                                
                                
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
                                writeIndex += 1
                                targetBytes[writeIndex] = data1
                                writeIndex += 1
                                targetBytes[writeIndex] = byte
                                // -------------
                                
                                byteSelector = false
                            } else {
                                data1 = byte
                                byteSelector = true
                            }
                            
                        case MidiEventType.control.rawValue:
                            
                            // Check if current byte is control number or value
                            if byteSelector {
                                trainDataSize += 2
                                trainLength += 1
                                
                                // --- WRITE ----
                                writeIndex += 1
                                targetBytes[writeIndex] = data1
                                writeIndex += 1
                                targetBytes[writeIndex] = byte
                                // -------------
                                
                                byteSelector = false
                            } else {
                                data1 = byte
                                byteSelector = true
                            }
                            
                        case MidiEventType.pitchBend.rawValue:
                            
                            // Check if current byte is control number or value
                            if byteSelector {
                                trainDataSize += 2
                                trainLength += 1
                                
                                // --- WRITE ----
                                writeIndex += 1
                                targetBytes[writeIndex] = data1
                                writeIndex += 1
                                targetBytes[writeIndex] = byte
                                // -------------
                                
                                byteSelector = false
                            } else {
                                data1 = byte
                                byteSelector = true
                            }
                            
                        case MidiEventType.polyAfterTouch.rawValue:
                            
                            if byteSelector {
                                trainDataSize += 2
                                trainLength += 1
                                
                                // --- WRITE ----
                                writeIndex += 1
                                targetBytes[writeIndex] = data1
                                writeIndex += 1
                                targetBytes[writeIndex] = byte
                                // -------------
                                
                                byteSelector = false
                            } else {
                                data1 = byte
                                byteSelector = true
                            }
                            
                        // 1 data byte events
                        
                        case MidiEventType.afterTouch.rawValue:
                            trainDataSize += 1
                            trainLength += 1
                            
                            // --- WRITE ----
                            writeIndex += 1
                            targetBytes[writeIndex] = byte
                        // -------------
                        
                        case MidiEventType.programChange.rawValue:
                            trainDataSize += 1
                            trainLength += 1
                            
                            // --- WRITE ----
                            writeIndex += 1
                            targetBytes[writeIndex] = byte
                        // -------------
                        
                        // 0 data byte events
                        
                        case MidiEventType.realTimeMessage.rawValue:
                            break
                        default:
                            break
                        } // End switch
                        
                    } // End scan
                }
            }
            // Go to next packet ( should never happen for musical events )
            p = MIDIPacketNext(&p).pointee
        }
        
        MIDIPacketListAdd(&outPackets, Int(14 + dataSize), writePacketPtr, 0, Int(dataSize), targetBytes)
        
        output.filteringTime = -chrono.timeIntervalSinceNow
        
        return output
    }
}

