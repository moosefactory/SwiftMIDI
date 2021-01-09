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

//  Port.swift
//
//  CoreMIDI Swift Wrapper
//
//  Created by Tristan Leblanc on 30/12/2020.

import Foundation
import CoreMIDI

public extension SwiftMIDI {
    
    /// Creates an input port
    ///
    /// - parameter clientRef : The midi client ref
    /// - parameter portName : The port name, usually in reverse path style
    /// - parameter readBlock : The block that will receive incoming midi packets
    /// - returns : The created input port
    
    @available(macOS 10.11, *)
    static func createInputPort(clientRef: MIDIClientRef, portName: String, readBlock: @escaping MIDIReadBlock) throws -> MIDIPortRef {
        var portRef: MIDIPortRef = 0
        try coreMidi {
            MIDIInputPortCreateWithBlock(clientRef,portName as CFString, &portRef, readBlock)
        }
        return portRef
    }
    
    /// Creates an output port
    ///
    /// - parameter clientRef : The midi client ref
    /// - parameter portName : The port name, usually in reverse path style
    /// - returns : The created output port
    
    static func createOutputPort(clientRef: MIDIClientRef, portName: String) throws -> MIDIPortRef {
        var portRef: MIDIPortRef = 0
        try coreMidi {
            MIDIOutputPortCreate(clientRef,portName as CFString, &portRef)
        }
        return portRef
    }
}
