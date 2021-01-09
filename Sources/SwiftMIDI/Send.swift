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

//  Send.swift
//
// CoreMIDI Swift Wrapper
//
//  Created by Tristan Leblanc on 31/12/2020.

import Foundation
import CoreMIDI

public extension SwiftMIDI {
    
    /// Send Event List
    /// Sends MIDI events to a destination.
    ///
    /// - parameter port :
    /// The output port through which the MIDI is to be sent.
    /// - parameter dest
    /// The destination to receive the events.
    /// - parameter evtlist
    /// The MIDI events to be sent.
    ///
    /// Events with future timestamps are scheduled for future delivery.  CoreMIDI performs
    /// any needed MIDI merging.
    
    @available(macOS 11.0, iOS 14.0, *)
    static func send(port: MIDIPortRef, destination: MIDIEndpointRef, eventListPointer: UnsafePointer<MIDIEventList>) throws {
        try coreMidi {
            MIDISendEventList(port, destination, eventListPointer)
        }
    }
    
    /// Send PacketList
    /// Sends MIDI packets to a destination.
    ///
    /// - parameter port
    ///  The output port through which the MIDI is to be sent.
    /// - parameter dest
    ///  The destination to receive the events.
    /// - parameter pktlist
    ///  The MIDI events to be sent.
    ///
    /// Events with future timestamps are scheduled for future delivery.  CoreMIDI performs
    /// any needed MIDI merging.
    
    @available(macOS, introduced: 10.0, deprecated: 100000, renamed: "sendEventList(_:_:_:)")
    static func send(port: MIDIPortRef, destination: MIDIEndpointRef, packetListPointer: UnsafePointer<MIDIPacketList>) throws {
        try coreMidi {
            MIDISend(port, destination, packetListPointer)
        }
    }
    
    /// MIDISendSysex
    /// Sends a single system-exclusive event, asynchronously.
    ///
    /// - parameter request
    /// Contains the destination, and a pointer to the MIDI data to be sent.
    ///
    /// request->data must point to a single MIDI system-exclusive message, or portion thereof.
    
    @available(macOS 10.0, *)
    static func send(request: UnsafeMutablePointer<MIDISysexSendRequest>) throws {
        try coreMidi {
            MIDISendSysex(request)
        }
    }
    
    /// Flush Output
    /// Unschedules previously-sent packets.
    ///
    /// - parameter dest
    /// All pending events scheduled to be sent to this destination
    /// are unscheduled.  If NULL, the operation applies to
    /// all destinations.
    ///
    /// Clients may use MIDIFlushOutput to cancel the sending of packets that were previously
    ///scheduled for future delivery.
    
    @available(macOS 10.1, *)
    static func flushOutput(destination: MIDIEndpointRef) throws {
        try coreMidi {
            MIDIFlushOutput(destination)
        }
    }
}
