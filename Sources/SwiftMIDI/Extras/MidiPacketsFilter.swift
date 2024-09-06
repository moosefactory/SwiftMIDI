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
    
    public var filterState: FilterState
    
    
    /// A tap to receive midi events as MidiEvent objects
    public var eventsTap: ((MidiEvent)->Void)?
    
    /// A tap to receive midiInputBuffers
    ///
    /// MidiInputBuffer is an intermediary between raw packets and midi events.
    ///
    /// It represents the midi input in a more convenient format.
    /// It does not create events objects, but rather stores events by types in a primitive format ( Array of Ints )
    /// This is usefull for recording, to catch events with an accurate timing
    
    public var midiInputBufferTap: ((MidiInputBuffer)->Void)?
    
    /// writePacketsToOutput
    /// If this is true, the filter will allocate a MidiPacketList containing only filtered packets.
    
    public var writePacketsToOutput: Bool = true
    
    public init(settings: MidiFilterSettings) {
        self.settings = settings
        self.filterState = FilterState()
    }
    
    
    /// Some devices send one packet per midi event ( Like Kurzweil PC3K ) - By the way it is wrong
    /// So we keep some usefull information from previous packet
    public struct FilterState {
        var lsbValue: UInt8 = 0xFF
        var msbValue: UInt8 = 0xFF
        
        // Initial bank is 0 - so real program number won't be correct until a bank select is received on each channel
        var bank: MidiChannelsValues = .empty
    }
    
    /// The filter output contains the filtered packets, but it also keeps some relevant values that the client can use
    public class Output {
        /// The filtered packets
        public fileprivate(set) var packets: MIDIPacketList?
        
        /// Last packet timestamp
        public fileprivate(set) var timeStamp: MIDITimeStamp = 0
        
        /// Will contains channels that have received musical events
        public fileprivate(set) var activatedChannels = MidiChannelMask.none
        
        /// Will contains lower and higher notes triggered per channel.
        /// If channel bit is not set in activated channels, this has no meaning
        public fileprivate(set) var higherAndLowerNotes = [MidiRange].init(repeating: MidiRange(lower: 127 , higher: 0), count: 16)
        
        /// Last control values
        public fileprivate(set) var controlValues: MidiChannelsControlValues = .empty
        
        /// Last Real Time Message
        public fileprivate(set) var realTimeMessage: RealTimeMessageType = .none
        
        /// Last ProgramChange
        public fileprivate(set) var programChanges: MidiChannelsValues = .empty
        
        /// Last BankSelect
        public fileprivate(set) var bankSelect: MidiChannelsValues = .empty
        
        /// Last PitchBend
        public fileprivate(set) var pitchBend: MidiChannelsValues = .empty
        
        /// The time spent in the filter
        public fileprivate(set) var filteringTime: TimeInterval = 0
        
        /// Ticks received.
        /// If everything runs smoothly, there is always one tick, but if a stall occurs, buffer can contains several ticks
        public fileprivate(set) var ticks: UInt8 = 0
        
        /// Returns the fractionnal pitch bend ( [-1.0..+1.0] )
        public func pitchBend(for channel: Int) -> Float {
            return Float(pitchBend.value(for: channel)) / Float(0x3FFF) * 2 - 1
        }
        
        /// Returns the program number as displayed on the device ( > to 127 if bank > 0 )
        public func programNumber(for channel: Int) -> Int {
            let bank = bankSelect.values[Int(channel)]
            let pgm = programChanges.value(for: channel)
            return Int(bank) * 128 + Int(pgm)
        }
        
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
        var type: MidiEventType = .notSet
        var channel: UInt8 = 0
        // true if current byte is velocity
        var byteSelectorIsVelocity: Bool = false
        // true if the whole event is skipped
        var skipTrain = false
        
        var skipNote: Bool = false
        var byte: UInt8 = 0
        var checkedStatus: Bool = false
        var keepStatus: Bool = false
        
        
        for _ in 0 ..< min(numberOfPackets, 128) {
            withUnsafeBytes(of: p.data) { bytes in
                // In some cases, like pausing from xCode, it looks like the packet size can grow far beyond the limit
                // so we only process the first 256 bytes. I'm not sure of what I am doing here,
                // but I'm sure it crashes if i >= 256
                for i in 0..<min(Int(p.length), bytes.count) {
                    byte = UInt8(bytes[i])
                    
                    // Read Status Byte if needed
                    
                    // 1 - read status
                    
                    if byte & 0xF0 >= 0x80  {
                        
                        // We keep status only if subsequent events are kept
                        keepStatus = false
                        
                        currentStatus = byte
                        channel = currentStatus & 0x0F
                        
                        skipNote = false
                        // Reset the skip flag
                        skipTrain = false
                        
                        byteSelectorIsVelocity = false
                        checkedStatus = false
                        
                        type = MidiEventType(statusByte: currentStatus) ?? .notSet

                        if type == MidiEventType.realTimeMessage{
                            if !settings.eventTypes.contains(eventType: type) {
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
                        if !settings.eventTypes.contains(eventType: type) {
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
                    case .noteOn:
                        // Check if current byte is note or velocity
                        if byteSelectorIsVelocity {
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
                            byteSelectorIsVelocity = false
                        } else {
                            skipNote = byte < settings.noteRange.lower
                                || byte > settings.noteRange.higher
                            // Next byte will be velocity
                            byteSelectorIsVelocity = true
                        }
                        
                    case .noteOff:
                        
                        // Check if current byte is note or velocity ( no meaning on note off, but still there )
                        if byteSelectorIsVelocity {
                            dataSize += 2
                            numberOfEvents += 1
                            byteSelectorIsVelocity = false
                            if (!keepStatus) {
                                keepStatus = true
                                dataSize += 1
                            }
                        } else {
                            byteSelectorIsVelocity = true
                        }
                        
                    case .control:
                        
                        // Check if current byte is control number or value
                        if byteSelectorIsVelocity {
                            dataSize += 2
                            numberOfEvents += 1
                            byteSelectorIsVelocity = false
                            if (!keepStatus) {
                                keepStatus = true
                                dataSize += 1
                            }
                        } else {
                            byteSelectorIsVelocity = true
                        }
                        
                    case .pitchBend:
                        
                        // Check if current byte is control number or value
                        if byteSelectorIsVelocity {
                            dataSize += 2
                            numberOfEvents += 1
                            byteSelectorIsVelocity = false
                            if (!keepStatus) {
                                keepStatus = true
                                dataSize += 1
                            }
                        } else {
                            byteSelectorIsVelocity = true
                        }
                        
                    case .polyAfterTouch:
                        
                        if byteSelectorIsVelocity {
                            dataSize += 2
                            numberOfEvents += 1
                            byteSelectorIsVelocity = false
                            if (!keepStatus) {
                                keepStatus = true
                                dataSize += 1
                            }
                        } else {
                            byteSelectorIsVelocity = true
                        }
                        
                    // 1 data byte events
                    
                    case .afterTouch:
                        if (!keepStatus) {
                            keepStatus = true
                            dataSize += 1
                        }
                        dataSize += 1
                        numberOfEvents += 1
                        
                    case .programChange:
                        if (!keepStatus) {
                            keepStatus = true
                            dataSize += 1
                        }
                        dataSize += 1
                        numberOfEvents += 1
                        
                    // 0 data byte events
                    
                    case .realTimeMessage:
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
    
    public func filter(packetList: UnsafePointer<MIDIPacketList>) -> MidiPacketsFilter.Output {
        if settings.willPassThrough { return Output(packets: packetList.pointee) }
        
        let chrono = Date()
        
        // Get final number of events
        let (numberOfPackets, count, dataSize) = preflight(in: packetList)
        
        guard count > 0 else {
            return Output(packets: nil) }
        
        var outPackets = MIDIPacketList()
        let writePacketPtr = MIDIPacketListInit(&outPackets)
        
        let output = Output(packets: outPackets)
        
        // The size needed for output packets
        // If we don't write output, we allocate a single byte to run the loop
        let outDataSize = writePacketsToOutput ? Int(dataSize) : 1
        
        let midiInputBuffer: MidiInputBuffer? = midiInputBufferTap == nil ? nil : MidiInputBuffer()
        
        
        let targetBytes = [UInt8].init(unsafeUninitializedCapacity: outDataSize) { (targetBytes, count) in
            count = Int(targetBytes.count)
            
            var writeIndex = 0
            var cancelled: Bool = false
            var p = packetList.pointee.packet
            
            func writeByte(byte: UInt8) {
                if writeIndex >= count {
                    print("[MIDI FILTER] Wrong write index \(writeIndex) ( size: \(outDataSize) )- line \(#line) in \(#file)")
                    cancelled = true
                } else {
                    targetBytes[writeIndex] = byte
                    writeIndex += 1
                }
            }

            // Scan the midi data and cut if necessary
            
            var currentStatus: UInt8 = 0
            var type: UInt8 = 0
            var channel: UInt8 = 0
            // true if current byte is velocity
            var byteSelector: Bool = false
            
            // Special control byte selector, to handle bank changes
            var controlByteSelector: Bool = false
            // true if the whole event is skipped
            var skipTrain = false
            
            // the length of data bytes following the status byte
            // if 0, then we can remove the status byte
            var skipNote: Bool = false
            var byte: UInt8 = 0
            
            var data1: UInt8 = 0
            var note: Int16 = 0
            
            // Tells if the status byte has already been written we keep an event
            // ( running status requires only one status byte before a train of events of the same type )
            var wroteStatus: Bool = false
            
            // The control number being scanned. We need it to capture 2 significant bytes controls
            var controlNumber: UInt8 = 0
            
            var lastTimeStamp: UInt64?
            var meanTimeStamp: Double?
            
            func collectTimeStampDelta(_ delta: UInt64) {
                if let mts = meanTimeStamp {
                    meanTimeStamp = mts * 0.9 + Double(delta) * 0.1
                    print("Mean Time: \(mts)")
                }
                else { meanTimeStamp = Double(delta) }
            }
            
            for _ in 0 ..< numberOfPackets {

                if p.length == 0 { continue }
                
                if let lts = lastTimeStamp, p.timeStamp < lts { collectTimeStampDelta(lts - p.timeStamp)
                }
                
                lastTimeStamp = p.timeStamp
                output.timeStamp = p.timeStamp
                
                withUnsafeBytes(of: p.data) { bytes in
                    for i in 0..<min(bytes.count, Int(p.length)) {
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
                            
                            controlNumber = 0
                            
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
                                
                                if writePacketsToOutput {
                                    writeByte(byte: byte)
                                }
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
                        
                        // Process bank select. We process it apart since the type is a control, but the real event type is a program change
                        
                        if type == MidiEventType.control.rawValue {
                            
                            // If we filter control we skip this, unless we receve a program change
                            // If we filter program changes, we skip this too unless we have a control
                            if !settings.eventTypes.contains(.control) && (byte != 00 || byte != 32) {
                                skipTrain = true
                                continue
                            } else if !settings.eventTypes.contains(.programChange) && (byte == 00 || byte == 32) {
                                skipTrain = true
                                continue
                            }
                            
                            if controlByteSelector == false {
                                controlNumber = byte
                                controlByteSelector = true
                            }
                            // We process single or two values controls ( number < 64 )
                            else if controlNumber < 120 {
                                
                                // Two values control - we read first value and wait for next byte to complete and capture
                                
                                if controlNumber < 64 {
                                    controlByteSelector = false
                                    
                                    if controlNumber >= 32 && controlNumber < 64 && filterState.lsbValue == 0xFF {
                                        filterState.lsbValue = byte
                                    }
                                    else if controlNumber >= 0 && controlNumber < 32 && filterState.msbValue == 0xFF {
                                        filterState.msbValue = byte
                                    }
                                    
                                    if filterState.msbValue != 0xFF && filterState.lsbValue != 0xFF {
                                        if controlNumber == 0 || controlNumber == 32 {
                                            let shiftedMSB = settings.limitTo127Banks ? 0 : Int16(filterState.msbValue << 7)
                                            let bankNumber = shiftedMSB | Int16(filterState.lsbValue)
                                            filterState.lsbValue = 0xFF
                                            filterState.msbValue = 0xFF
                                            filterState.bank.values[Int(channel)] = bankNumber
                                        }
                                    }
                                }
                                
                                // MARK: - Control number >= 64 : Single value control
                                
                                else {
                                    output.controlValues.controlStates[Int(channel)].values[Int(controlNumber)] = Int16(byte)
                                    if let mib = midiInputBuffer {
                                        mib.addControl(cc1: controlNumber, cc2: byte)
                                    }

                                    controlNumber = 0
                                }
                            }
                            
                            
                        } else {
                            // If a control in the 0..63 range has been caught without msb or lsb, we capture the value
                            if controlNumber > 0 {
                                output.controlValues.controlStates[Int(channel)].values[Int(controlNumber)] = Int16(byte)
                                if let mib = midiInputBuffer {
                                    mib.addControl(cc1: controlNumber, cc2: byte)
                                }
                                // Reset control number
                                controlNumber = 0
                            }
                        }
                        
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
                                        
                                        if writePacketsToOutput {
                                            if !wroteStatus {
                                                wroteStatus = true
                                                writeByte(byte:  (currentStatus & 0xF0)
                                                            | (settings.channelsMap.channels[Int(channel)] & 0x0F))
                                            }
                                            writeByte(byte: data1)
                                            writeByte(byte: byte)
                                        }
                                        
                                        print("[MIDI FILTER] Midi Event Type: \(type) - dataSize:\(dataSize) bytes.count:\(bytes.count) count: \(numberOfPackets) wroteToOutput:\(writePacketsToOutput)")

                                        if let tap = eventsTap {
                                            tap(MidiEvent(type: .noteOn, timestamp: p.timeStamp,
                                                          channel: settings.channelsMap.channels[Int(channel)] & 0x0F,
                                                          value1: data1, value2: byte))
                                        }
                                        if let mib = midiInputBuffer {
                                            mib.addNoteOn(pitch: data1, velocity: byte)
                                        }
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
                                
                                if writePacketsToOutput {
                                    if !wroteStatus {
                                        wroteStatus = true
                                        writeByte(byte: (currentStatus & 0xF0)
                                                    | (settings.channelsMap.channels[Int(channel)] & 0x0F))
                                    }
                                    writeByte(byte: data1)
                                    writeByte(byte: byte)
                                }
                                // -------------
                                
                                print("[MIDI FILTER] Midi Event Type: \(type) - dataSize:\(dataSize) bytes.count:\(bytes.count) count: \(numberOfPackets) wroteToOutput:\(writePacketsToOutput)")

                                if let tap = eventsTap {
                                    tap(MidiEvent(type: .noteOff, timestamp: p.timeStamp,
                                                  channel: settings.channelsMap.channels[Int(channel)] & 0x0F,
                                                  value1: data1, value2: byte))
                                }
                                if let mib = midiInputBuffer {
                                    mib.addNoteOff(pitch: data1, velocity: byte)
                                }
                                
                                byteSelector = false
                            } else {
                                data1 = byte
                                byteSelector = true
                            }
                            
                        case MidiEventType.control.rawValue:
                            
                            // Check if current byte is control number or value
                            if byteSelector {
                                // --- WRITE ----
                                if writePacketsToOutput {
                                    if !wroteStatus {
                                        wroteStatus = true
                                        writeByte(byte: (currentStatus & 0xF0)
                                                    | (settings.channelsMap.channels[Int(channel)] & 0x0F))
                                    }
                                    writeByte(byte: data1)
                                    writeByte(byte: byte)
                                }
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
                                if writePacketsToOutput {
                                    if !wroteStatus {
                                        wroteStatus = true
                                        writeByte(byte: (currentStatus & 0xF0)
                                                    | (settings.channelsMap.channels[Int(channel)] & 0x0F))
                                    }
                                    
                                    writeByte(byte: data1)
                                    writeByte(byte: byte)
                                }
                                // -------------
                                
                                output.pitchBend.values[Int(channel)] = ( Int16(data1) + Int16(byte) << 7)
                                
                                byteSelector = false
                            } else {
                                data1 = byte
                                byteSelector = true
                            }
                            
                        case MidiEventType.polyAfterTouch.rawValue:
                            
                            if byteSelector {
                                // --- WRITE ----
                                if writePacketsToOutput {
                                    if !wroteStatus {
                                        wroteStatus = true
                                        writeByte(byte: (currentStatus & 0xF0)
                                                    | (settings.channelsMap.channels[Int(channel)] & 0x0F))
                                    }
                                    
                                    writeByte(byte: data1)
                                    writeByte(byte: byte)
                                }
                                // -------------
                                
                                byteSelector = false
                            } else {
                                data1 = byte
                                byteSelector = true
                            }
                            
                        // 1 data byte events
                        
                        case MidiEventType.afterTouch.rawValue:
                            // --- WRITE ----
                            if writePacketsToOutput {
                                if !wroteStatus {
                                    wroteStatus = true
                                    writeByte(byte: (currentStatus & 0xF0)
                                                | (settings.channelsMap.channels[Int(channel)] & 0x0F))
                                }
                                
                                writeByte(byte: byte)
                            }
                        // -------------
                        
                        case MidiEventType.programChange.rawValue:
                            
                            output.programChanges.values[Int(channel)] = Int16(byte)
                            // --- WRITE ----
                            if writePacketsToOutput {
                                if !wroteStatus {
                                    wroteStatus = true
                                    writeByte(byte: (currentStatus & 0xF0)
                                                | (settings.channelsMap.channels[Int(channel)] & 0x0F))
                                }
                                
                                writeByte(byte: byte)
                                
                            }
                        // -------------
                        
                        // 0 data byte events
                        
                        case MidiEventType.realTimeMessage.rawValue:
                            break
                        default:
                            break
                        } // End switch
                        
                    } // End scan
                }
                
                // If a controlNumber that potentially takes 2 bytes is set and has not be completed, we capture the value
                
                if controlNumber > 0 && controlNumber < 64 {
                    output.controlValues.controlStates[Int(channel)].values[Int(controlNumber)] = Int16(byte)
                    if let mib = midiInputBuffer {
                        mib.addControl(cc1: controlNumber, cc2: byte)
                    }

                    controlNumber = 0
                }
                
                if !cancelled {
                    // Go to next packet ( should never happen for musical events )
                    p = MIDIPacketNext(&p).pointee
                }
            }
            
            if let mib = midiInputBuffer, let tap = midiInputBufferTap {
                tap(mib)
            }
        }
        
        MIDIPacketListAdd(&outPackets, Int(14 + dataSize), writePacketPtr, output.timeStamp, Int(dataSize), targetBytes)
        
        output.bankSelect = filterState.bank
        output.filteringTime = -chrono.timeIntervalSinceNow
        output.packets = outPackets
        return output
    }
}

