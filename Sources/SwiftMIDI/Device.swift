
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

    /// MIDIGetNumberOfExternalDevices
    /// Returns the number of external MIDI devices in the system.
    ///
    /// - returns The number of external devices in the system
    ///
    /// External MIDI devices are MIDI devices connected to driver endpoints via a standard MIDI
    /// cable. Their presence is completely optional, only when a UI (such as Audio MIDI Setup)
    /// adds them.

    @available(macOS 10.0, *)
    static func getNumberOfExternalDevices() throws -> Int {
        let numberOfDevices = MIDIGetNumberOfExternalDevices()
        guard numberOfDevices > 0 else {
            throw Errors.noDeviceInSystem
        }
        return numberOfDevices
    }

    /// MIDIGetExternalDevice
    /// Returns one of the external devices in the system.
    ///
    /// -parameter index
    /// The index of the device to return.
    ///
    /// - returns A reference to a device
    ///
    /// Use this to enumerate the external devices in the system.

    @available(macOS 10.0, *)
    static func getExternalDevice(at index: Int) throws -> MIDIDeviceRef {
        let ref = MIDIGetExternalDevice(index)
        guard ref != 0 else {
            throw Errors.externalDeviceIndexOutOfRange
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
    static func getNumberOfEntities(for device: MIDIDeviceRef) throws -> Int {
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
    static func getEntity(for device: MIDIDeviceRef, at index: Int) throws -> MIDIEntityRef {
        let ref = MIDIDeviceGetEntity(device, index)
        guard ref != 0 else {
            throw Errors.entityIndexOutOfRange
        }
        return ref
    }
    
    // MARK: - Access Entities Sources and Destinations
    
    /// MIDIEntityGetNumberOfSources
    /// Returns the number of sources in a given entity.
    ///
    /// - parameter entity
    /// The entity being queried
    ///
    /// - returns The number of sources the entity contains
    
    @available(macOS 10.0, *)
    static func numberOfSources(for entity: MIDIEntityRef) throws -> Int {
        let numberOfSources = MIDIEntityGetNumberOfSources(entity)
        guard numberOfSources > 0 else {
            throw Errors.entityIndexOutOfRange
        }
        return numberOfSources
    }

    /// MIDIEntityGetSource
    /// Returns one of a given entity's sources.
    ///
    /// - parameter entity
    /// The entity being queried.
    /// - parameter index
    /// The index of the source to return
    ///
    /// - returns A reference to a source, or NULL if an error occurred.

    @available(macOS 10.0, *)
    static func source(for entity: MIDIEntityRef, at index: Int) throws -> MIDIEndpointRef {
        let source = MIDIEntityGetSource(entity, index)
        guard source != 0 else {
            throw Errors.sourceIndexOutOfRange
        }
        return source
    }

    /// MIDIEntityGetNumberOfDestinations
    /// Returns the number of destinations in a given entity.
    ///
    /// - parameter entity
    /// The entity being queried
    ///
    /// - returns The number of destinations the entity contains

    @available(macOS 10.0, *)
    static func numberOfDestinations(for entity: MIDIEntityRef) throws -> Int {
        let numberOfDestinations = MIDIEntityGetNumberOfDestinations(entity)
        guard numberOfDestinations > 0 else {
            throw Errors.entityIndexOutOfRange
        }
        return numberOfDestinations
    }

    /// MIDIEntityGetDestination
    /// Returns one of a given entity's destinations.
    ///
    /// - parameter entity
    /// The entity being queried.
    /// - parameter index
    /// The index of the destination to return
    ///
    /// - returns A reference to a destination
    
    @available(macOS 10.0, *)
    static func destination(for entity: MIDIEntityRef, at index: Int) throws -> MIDIEndpointRef {
        let destination = MIDIEntityGetDestination(entity, index)
        guard destination != 0 else {
            throw Errors.destinationIndexOutOfRange
        }
        return destination
    }
}

// MARK: - SwiftMIDI extension -

public extension SwiftMIDI {
    
    /// Number of devices
    
    static var numberOfDevices: Int {
        return (try? getNumberOfDevices()) ?? 0
    }
    
    /// Devices
    
    static var devices: [MIDIDeviceRef] {
        return (try? allDevices()) ?? []
    }

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
    
    /// Iterates through all external devices in system
    
    static func forEachExternalDevice(do closure: (Int, MIDIDeviceRef)->Void) throws {
        let numberOfDevices = try getNumberOfExternalDevices()
        for index in 0..<numberOfDevices {
            if let device = try? SwiftMIDI.getExternalDevice(at: index) {
                closure(index, device)
            }
        }
    }
    

    /// Returns an array containing all external midi devices in system
    
    static func allExternalDevices() throws -> [MIDIDeviceRef] {
        var out = [MIDIDeviceRef]()
        try forEachExternalDevice { out.append($1) }
        return out
    }
    
    /// Iterates through all entities in passed device ref
    
    static func forEachEntity(in device: MIDIDeviceRef, do closure: (Int, MIDIEntityRef)->Void) throws {
        let numberOfEntities = try getNumberOfEntities(for: device)
        for index in 0..<numberOfEntities {
            if let entity = try? SwiftMIDI.getEntity(for: device, at: index) {
                closure(index, entity)
            }
        }
    }
    
    /// Iterates through all destinations in passed entity ref

    static func forEachDestination(in entity: MIDIEntityRef, do closure: (Int, MIDIEndpointRef)->Void) throws {
        let numberOfEndPoints = try numberOfDestinations(for: entity)
        for index in 0..<numberOfEndPoints {
            if let endPoint = try? SwiftMIDI.destination(for: entity, at: index) {
                closure(index, endPoint)
            }
        }
    }
    
    /// Iterates through all sources in passed entity ref

    static func forEachSource(in entity: MIDIEntityRef, do closure: (Int, MIDIEndpointRef)->Void) throws {
        let numberOfEndPoints = try numberOfSources(for: entity)
        for index in 0..<numberOfEndPoints {
            if let endPoint = try? SwiftMIDI.source(for: entity, at: index) {
                closure(index, endPoint)
            }
        }
    }
    
    /// Returns an array containing all midi entities for passed device ref
    
    static func allEntities(in device: MIDIDeviceRef) throws -> [MIDIEntityRef] {
        var out = [MIDIEntityRef]()
        try forEachEntity(in: device) { out.append($1) }
        return out
    }
    
    /// Returns an array containing all midi destinations for passed device ref
    
    static func allDestinations(in entity: MIDIEntityRef) throws -> [MIDIEndpointRef] {
        var out = [MIDIEntityRef]()
        try forEachDestination(in: entity) { out.append($1) }
        return out
    }
    
    /// Returns an array containing all midi sources for passed entity ref
    
    static func allSources(in entity: MIDIEntityRef) throws -> [MIDIEndpointRef] {
        var out = [MIDIEntityRef]()
        try forEachSource(in: entity) { out.append($1) }
        return out
    }
}
