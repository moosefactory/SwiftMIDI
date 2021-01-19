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

// SwiftyMid+Thru.swift
//
//
//
// Created by Tristan Leblanc on 30/12/2020.

import Foundation
import CoreMIDI

extension MIDIThruConnectionParams {
    
    mutating func initialize() {
        var params = self
        SwiftMIDI.initializeThruConnectionParams(&params)
        self = params
    }
}

public extension SwiftMIDI {
    
    /// initializeThruConnectionParams
    /// Fills a MIDIThruConnectionParams with default values.
    ///
    /// - parameter inConnectionParams : The struct to be initialized.
    ///
    /// This convenience function fills the connection structure with default values: no endpoints,
    /// no transformations (mostly zeroes except for the channel map). Then, just filling in the
    /// source and adding one destination will create a simple, unmodified thru connection.
    
    @available(macOS 10.2, *)
    static func initializeThruConnectionParams(_ params: inout MIDIThruConnectionParams) {
        MIDIThruConnectionParamsInitialize(&params)
    }
    
    /// createMidiThruConnection
    /// Creates a thru connection.
    ///
    /// - parameter inPersistentOwnerID
    ///  If null, then the connection is marked as owned by the client
    /// and will be automatically disposed with the client.  if it is non-null, then it
    /// should be a unique identifier, e.g. "com.mycompany.MyCoolProgram".
    /// - parameter inConnectionParams
    /// A MIDIThruConnectionParams contained in a CFDataRef.
    /// - parameter outConnection
    /// On successful return, a reference to the newly-created connection.

    @available(macOS 10.2, *)
    static func createMidiThruConnection(name: String? = nil, params: MIDIThruConnectionParams? = nil) throws -> (MIDIThruConnectionRef, MIDIThruConnectionParams) {
        var connectionRef: MIDIThruConnectionRef = 0
        var params = params
        if params == nil {
            params = MIDIThruConnectionParams()
            MIDIThruConnectionParamsInitialize(&params!) // fill with defaults
        }
        
        let paramsData = withUnsafePointer(to: params) { p in
            Data(bytes: p, count: MIDIThruConnectionParamsSize(&params!))
        }
        
        try coreMidi {
            MIDIThruConnectionCreate(name == nil ? nil : name! as CFString,
                                     paramsData as CFData,
                                     &connectionRef)
        }
        
        return (connectionRef, params!)
    }
    
    /// getMidiThruConnectionParams
    /// Obtains a thru connection's MIDIThruConnectionParams.
    ///
    /// - parameter connection : The connection to be disposed.
    /// - parameter outConnectionParams:  On successful return, the connection's MIDIThruConnectionParams
    ///
    /// The returned CFDataRef contains a MIDIThruConnectionParams structure.
    
    @available(macOS 10.2, *)
    static func getMidiThruConnectionParams(connectionRef: MIDIThruConnectionRef) throws -> MIDIThruConnectionParams? {
        // 1 - allocate an unmanaged data
        var unmanagedData = Unmanaged.passUnretained(Data() as CFData)
        // 2 - Pass the data pointer to C API
        let err = MIDIThruConnectionGetParams(connectionRef, &unmanagedData)
        guard err == noErr else {
            return nil
        }
        // 3 - Extract the data from unmanaged data
        let data = unmanagedData.takeUnretainedValue() as Data
        // 4 - Remap to the swift type
        return data.withUnsafeBytes { bytes -> MIDIThruConnectionParams in
            UnsafeRawPointer(bytes).assumingMemoryBound(to: MIDIThruConnectionParams.self).pointee
        }
    }
    
    /// setMidiThruConnectionParams
    /// Alters a thru connection's MIDIThruConnectionParams.
    ///
    /// - parameter connection
    /// The connection to be modified.
    /// - parameter inConnectionParams
    /// The connection's new MIDIThruConnectionParams

    @available(macOS 10.2, *)
    static func setMidiThruConnectionParams(connectionRef: MIDIThruConnectionRef, params: MIDIThruConnectionParams) throws {
        let data = withUnsafePointer(to: params) { pointer in
            Data(bytes: pointer, count: MIDIThruConnectionParamsSize(pointer))
        }
        try coreMidi {
            MIDIThruConnectionSetParams(connectionRef, data as CFData)
        }
    }
    
    /// findMidiThruConnections
    /// Returns all of the persistent thru connections created by a client.
    ///
    /// - parameter PersistentOwnerID
    /// The ID of the owner whose connections are to be returned.
    /// - parameter outConnectionList
    /// On successful return, an array of MIDIThruConnectionRef's.
    
    @available(macOS 10.2, *)
    static func findMidiThruConnections(owner: String) throws -> [MIDIThruConnectionRef] {
        
        // 1 - allocate an unmanaged data reference
        var unmanagedData = Unmanaged.passUnretained(Data() as CFData)
        
        // 2 - Pass the data pointer to C API
        try coreMidi {
            MIDIThruConnectionFind(owner as CFString, &unmanagedData)
        }
        
        // 3 - Extract the CFData from unmanaged data
        // We prefer CFData here to access pointer and size
        let cfData = unmanagedData.takeUnretainedValue()
        guard let dataPtr = CFDataGetBytePtr(cfData) else {
            return []
        }
        
        // 4  - Compute the number of elements
        let dataSize = CFDataGetLength(cfData)
        let numberOfConnections = dataSize / MemoryLayout<MIDIThruConnectionRef>.stride
        
        // 5 - Rebound pointer from <Int8> to <MIDIThruConnectionRef>
        return dataPtr.withMemoryRebound(to: MIDIThruConnectionRef.self,
                                         capacity: numberOfConnections) { typedPtr in
            // Convert pointer to buffer pointer
            let bufferPointer = UnsafeBufferPointer(start: typedPtr, count: numberOfConnections)
            // Construct array
            return [MIDIThruConnectionRef].init(unsafeUninitializedCapacity: numberOfConnections) { refPtr, count in
                count = numberOfConnections
                for i in 0..<count {
                    refPtr[i] = bufferPointer[i]
                }
            }
        }
    }
    
    /// removeMidiThruConnection
    /// Disposes a thru connection.
    ///
    /// - parameterconnection : The connection to be disposed

    @available(macOS 10.2, *)
    static func removeMidiThruConnection(connectionRef: MIDIThruConnectionRef) throws {
        try coreMidi {
            MIDIThruConnectionDispose(connectionRef)
        }
    }
}
