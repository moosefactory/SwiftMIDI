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

//  Port.swift
//
//  CoreMIDI Swift Wrapper
//
//  Created by Tristan Leblanc on 30/12/2020.

import Foundation
import CoreMIDI

public extension SwiftMIDI {
    
    /// MIDIInputPortCreateWithBlock
    /// Creates an input port through which the client may receive incoming MIDI messages from any MIDI source.
    ///
    /// - parameter client : The client to own the newly-created port.
    /// - parameter portName : The name of the port.
    /// - parameter readBlock :
    /// The MIDIReadBlock which will be called with incoming MIDI, from sources connected to this port.
    ///
    /// - returns : The newly-created MIDIPort.
    ///
    /// After creating a port, use MIDIPortConnectSource to establish an input connection from
    /// any number of sources to your port.
    /// readBlock will be called on a separate high-priority thread owned by CoreMIDI.
    
    @available(macOS, introduced: 10.11, deprecated: 100000, renamed: "MIDIInputPortCreateWithProtocol(_:_:_:_:_:)")
    static func createInputPort(clientRef: MIDIClientRef, portName: String, readBlock: @escaping MIDIReadBlock) throws -> MIDIPortRef {
        var portRef: MIDIPortRef = 0
        try coreMidi {
            MIDIInputPortCreateWithBlock(clientRef,portName as CFString, &portRef, readBlock)
        }
        return portRef
    }
    
    /// MIDIOutputPortCreate
    /// Creates an output port through which the client may send outgoing MIDI messages to any MIDI destination.
    ///
    /// - parameter client : The client to own the newly-created port
    /// - parameter portName : The name of the port.
    ///
    /// - returns : the newly-created MIDIPort.
    ///
    /// Output ports provide a mechanism for MIDI merging.  CoreMIDI assumes that each output
    /// port will be responsible for sending only a single MIDI stream to each destination,
    /// although a single port may address all of the destinations in the system.
    ///
    /// Multiple output ports are only necessary when an application is capable of directing
    /// multiple simultaneous MIDI streams to the same destination.

    @available(macOS 10.0, *)
    static func createOutputPort(clientRef: MIDIClientRef, portName: String) throws -> MIDIPortRef {
        var portRef: MIDIPortRef = 0
        try coreMidi {
            MIDIOutputPortCreate(clientRef,portName as CFString, &portRef)
        }
        return portRef
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
