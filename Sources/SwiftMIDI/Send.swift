//
//  SwiftMIDI+Send.swift
//  MidiCenter
//
//  Created by Tristan Leblanc on 31/12/2020.
//

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
