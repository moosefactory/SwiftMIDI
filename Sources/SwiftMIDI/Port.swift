//
//  SwiftMIDI+Port.swift
//  MidiCenter
//
//  Created by Tristan Leblanc on 30/12/2020.
//

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
