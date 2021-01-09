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

//  MidiEndPoint.swift
//
//  CoreMIDI Swift wrapper
//
//  Created by Tristan Leblanc on 30/12/2020.

import Foundation
import CoreMIDI

// MARK: - Destinations

public extension SwiftMIDI {
    
    /// Returns the number of midi destinations
    static func getNumberOfDestinations() throws -> Int {
        let count = MIDIGetNumberOfDestinations()
        if count == 0 {
            throw SwiftMIDI.Errors.noDestinationInSystem
        }
        return count
    }
    
    /// Returns the destination at given index
    static func destination(at index: Int) throws -> MIDIEndpointRef {
        let numberOfDestinations = try getNumberOfDestinations()
        guard index >= 0 && index < numberOfDestinations else {
            throw SwiftMIDI.Errors.destinationIndexOutOfRange
        }
        return MIDIGetDestination(index)
    }
    
    /// Iterates through all destinations
    static func forEachDestination(_ block: (Int, MIDIEndpointRef)->Void) {
        for index in 0..<MIDIGetNumberOfDestinations() {
            block(index, MIDIGetDestination(index))
        }
    }
    
    /// Returns an array with all midi sestinations
    static var allDestinations: [MIDIEndpointRef] {
        var out = [MIDIEndpointRef]()
        for index in 0..<MIDIGetNumberOfDestinations() {
            out.append(MIDIGetDestination(index))
        }
        return out
    }

}

// MARK: - Sources

public extension SwiftMIDI {
    
    /// Returns the number of midi sources
    static func getNumberOfSources() throws -> Int {
        let count = MIDIGetNumberOfSources()
        if count == 0 {
            throw SwiftMIDI.Errors.noSourceInSystem
        }
        return count
    }

    /// Returns the source at given index
    static func source(at index: Int) throws -> MIDIEndpointRef {
        let numberOfSources = try getNumberOfSources()
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

