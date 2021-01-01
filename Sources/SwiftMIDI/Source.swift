//
//  SwiftMIDI+Source.swift
//  MidiCenter
//
//  Created by Tristan Leblanc on 30/12/2020.
//

import Foundation
import CoreMIDI

public extension SwiftMIDI {
    
    /// Returns the number of midi sources
    static var numberOfSources: Int {
        return MIDIGetNumberOfSources()
    }
    
    /// Returns the source at given index
    static func source(at index: Int) throws -> MIDIEndpointRef {
        guard index >= 0 && index < numberOfSources else {
            throw SwiftMIDI.Errors.sourceIndexOutOfRange
        }
        return MIDIGetSource(index)
    }
    
    /// Iterates through all sources
    static func forEachSource(_ block: (Int, MIDIEndpointRef)->Void) {
        for index in 0..<MIDIGetNumberOfSources() {
            block(index, MIDIGetSource(index))
        }
    }
    
    /// Returns an array with all midi sources
    static var allSources: [MIDIEndpointRef] {
        var out = [MIDIEndpointRef]()
        for index in 0..<MIDIGetNumberOfSources() {
            out.append(MIDIGetSource(index))
        }
        return out
    }
    
    /// connectSource
    /// Establishes a connection from a source to a client's input port.
    
    /// - parameter port
    /// The port to which to create the connection.  This port's
    /// readProc is called with incoming MIDI from the source.
    /// - parameter source
    /// The source from which to create the connection.
    /// - parameter connRefCon
    /// This refCon is passed to the port's MIDIReadProc or MIDIReadBlock, as a way to
    /// identify the source.
    
    @available(macOS 10.0, *)
    static func connect(source: MIDIEndpointRef, to port: MIDIPortRef, refCon: UnsafeMutableRawPointer? = nil) throws {
        try coreMidi {
            MIDIPortConnectSource(port, source, refCon)
        }
    }
    
    /// disconnectSource
    /// Closes a previously-established source-to-input port  connection.
    ///
    /// - parameter port
    /// The port whose connection is being closed.
    /// - parameter source
    /// The source from which to close a connection to the
    /// specified port.
    @available(macOS 10.0, *)
    static func disconnect(source: MIDIEndpointRef, from port: MIDIPortRef) throws {
        try coreMidi {
            MIDIPortDisconnectSource(port, source)
        }
    }
}
