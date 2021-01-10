
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

//  Device.swift
//
//  CoreMIDI Swift Wrapper
//
//  Created by Tristan Leblanc on 10/01/2021.

import Foundation
import CoreMIDI

// MARK: - CoreMIDI wrapper

public extension SwiftMIDI {
    
    // MARK: - Devices
    
    /// MIDIGetNumberOfDevices
    /// Returns the number of devices in the system.
    ///
    /// - returns The number of devices in the system
    
    @available(macOS 10.0, *)
    static func getNumberOfDevices() throws -> Int {
        let numberOfDevices = MIDIGetNumberOfDevices()
        guard numberOfDevices > 0 else {
            throw Errors.noDeviceInSystem
        }
        return numberOfDevices
    }
    
    /// MIDIGetDevice
    /// Returns one of the devices in the system.
    ///
    /// - parameter index
    /// The index of the device to return.
    ///
    /// - returns A reference to a device
    ///
    /// Use this to enumerate the devices in the system.
    ///
    /// To enumerate the entities in the system, you can walk through the devices, then walk
    /// through the devices' entities.
    ///
    /// Note: If a client iterates through the devices and entities in the system, it will not
    /// ever visit any virtual sources and destinations created by other clients.  Also, a
    /// device iteration will return devices which are "offline" (were present in the past but
    /// are not currently present), while iterations through the system's sources and
    /// destinations will not include the endpoints of offline devices.
    ///
    /// Thus clients should usually use MIDIGetNumberOfSources, MIDIGetSource,
    /// MIDIGetNumberOfDestinations and MIDIGetDestination, rather iterating through devices and
    /// entities to locate endpoints.

    @available(macOS 10.0, *)
    static func getDevice(at index: Int) throws -> MIDIDeviceRef {
        let ref = MIDIGetDevice(index)
        guard ref != 0 else {
            throw Errors.deviceIndexOutOfRange
        }
        return ref
    }

    // MARK: - Entities
    
    /// MIDIDeviceGetNumberOfEntities
    /// Returns the number of entities in a given device.
    ///
    /// - parameter device
    /// The device being queried.
    ///
    /// - returns The number of entities the device contains
    
    @available(macOS 10.0, *)
    static func getNumberOfEntities(in device: MIDIDeviceRef) throws -> Int {
        let numberOfEntities = MIDIDeviceGetNumberOfEntities(device)
        guard numberOfEntities > 0 else {
            throw Errors.noEntityInSystem
        }
        return numberOfEntities
    }
    
    /// MIDIDeviceGetEntity
    /// Returns one of a given device's entities.
    ///
    /// - parameter device
    /// The device being queried.
    /// - parameter index
    /// The index of the entity to return
    ///
    /// - returns A reference to an entity

    @available(macOS 10.0, *)
    static func getEntity(in device: MIDIDeviceRef, at index: Int) throws -> MIDIEntityRef {
        let ref = MIDIDeviceGetEntity(device, index)
        guard ref != 0 else {
            throw Errors.entityIndexOutOfRange
        }
        return ref
    }
}

// MARK: - SwiftMIDI extension

public extension SwiftMIDI {
    
    /// Iterates through all devices in system
    
    static func forEachDevice(do closure: (Int, MIDIDeviceRef)->Void) throws {
        let numberOfDevices = try getNumberOfDevices()
        for index in 0..<numberOfDevices {
            if let device = try? SwiftMIDI.getDevice(at: index) {
                closure(index, device)
            }
        }
    }
    
    /// Returns an array containing all midi devices in system
    
    static func allDevices() throws -> [MIDIDeviceRef] {
        var out = [MIDIDeviceRef]()
        try forEachDevice { out.append($1) }
        return out
    }
    
    /// Iterates through all entities in passed device ref
    
    static func forEachEntity(in device: MIDIDeviceRef, do closure: (Int, MIDIEntityRef)->Void) throws {
        let numberOfEntities = try getNumberOfEntities(in: device)
        for index in 0..<numberOfEntities {
            if let entity = try? SwiftMIDI.getEntity(in: device, at: index) {
                closure(index, entity)
            }
        }
    }
    
    /// Returns an array containing all midi entities for passed device ref
    
    static func allEntities(in device: MIDIDeviceRef) throws -> [MIDIEntityRef] {
        var out = [MIDIEntityRef]()
        try forEachEntity(in: device) { out.append($1) }
        return out
    }
}
