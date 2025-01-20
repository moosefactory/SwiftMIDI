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

// SwiftMidi.swift
//
// CoreMIDI Swift Wrapper
//
// Created by Tristan Leblanc on 29/12/2020.

import Foundation
import CoreMIDI

@available(macOS 10.15, *)
public extension Notification.Name {
    static let MIDINetworkContactsDidChange = Notification.Name(MIDINetworkNotificationContactsDidChange)
}

/// SwiftMIDI
///
/// A swifty layer over the CoreMIDI framework

public struct SwiftMIDI {
    
    /// restart ( MIDIRestart )
    ///
    /// Stops and restarts MIDI I/O.
    ///
    /// This is useful for forcing CoreMIDI to ask its drivers to rescan for hardware.
    
    @available(macOS 10.1, *)
    public static func restart() throws {
        try coreMidi {
            MIDIRestart()
        }
    }
    
    /// findByUniqueID ( MIDIObjectFindByUniqueID )
    ///
    /// Locates a device, external device, entity, or endpoint by its uniqueID.
    ///
    /// - parameter: inUniqueID
    /// The uniqueID of the object to search for.  (This should
    /// be the result of an earlier call to MIDIObjectGetIntegerProperty
    /// for the property kMIDIPropertyUniqueID).
    ///
    /// - result: A (MIDIObjectRef, MIDIObjectType) tuple
    ///   - MIDIObjectRef: This should be cast to the appropriate type (MIDIDeviceRef, MIDIEntityRef, MIDIEndpointRef),
    /// according to MIDIObjectType.
    ///   - MIDIObjectType: On exit, the type of object which was found; undefined if none found.
    
    @available(macOS 10.2, *)
    public static func findByUniqueID(_ id: Int) throws -> (ref: MIDIObjectRef, type: MIDIObjectType) {
        var objectRef = MIDIObjectRef()
        var objectType = MIDIObjectType.destination
        try coreMidi {
            MIDIObjectFindByUniqueID(Int32(id), &objectRef, &objectType)
        }
        return (ref: objectRef, type: objectType)
    }
}

// MARK: - Global Functions -

/// Throw an exceptions if the status is not `noErr`

public func throwMidiErrorIfNeeded(_ err: OSStatus) throws {
    if err != noErr, let err = SwiftMIDI.MidiError(err) {
        throw err
    }
}

/// Transforms an osStatus result in a swift exception
///
/// Usage:
/// ```
/// try coreMidi {
///    <Function that returns an osStatus >
/// }

public func coreMidi(_ block: ()->OSStatus) throws {
    let err = block()
    //try throwMidiErrorIfNeeded(err)
}

