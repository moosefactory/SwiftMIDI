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

//  MidiEndPoint.swift
//
//  CoreMIDI Swift wrapper
//
//  Created by Tristan Leblanc on 30/12/2020.

import Foundation
import CoreMIDI
    
// MARK: - Destinations

public extension SwiftMIDI {
    
    /// MIDIGetNumberOfDestinations
    /// Returns the number of destinations in the system.
    ///
    /// - returns  The number of destinations in the system

    @available(macOS 10.0, *)
    static func getNumberOfDestinations() throws -> Int {
        let count = MIDIGetNumberOfDestinations()
        if count == 0 {
            throw SwiftMIDI.Errors.noDestinationInSystem
        }
        return count
    }
    
    /// MIDIGetDestination
    /// Returns one of the destinations in the system.
    ///
    /// - parameter index
    /// The index of the destination to return
    ///
    /// - returns A reference to a destination, or NULL if an error occurred.

    @available(macOS 10.0, *)
    static func destination(at index: Int) throws -> MIDIEndpointRef {
        let numberOfDestinations = try getNumberOfDestinations()
        guard index >= 0 && index < numberOfDestinations else {
            throw SwiftMIDI.Errors.destinationIndexOutOfRange
        }
        return MIDIGetDestination(index)
    }
}

// MARK: - SwiftMIDI Extension

public extension SwiftMIDI {
    
    static var numberOfDestinations: Int {
        return (try? getNumberOfDestinations()) ?? 0
    }
    
    /// Returns an array with all midi sestinations
    static var allDestinations: [MIDIEndpointRef] {
        var out = [MIDIEndpointRef]()
        for index in 0..<MIDIGetNumberOfDestinations() {
            out.append(MIDIGetDestination(index))
        }
        return out
    }
    
    /// Iterates through all destinations
    static func forEachDestination(do block: (Int, MIDIEndpointRef)->Void) {
        for index in 0..<MIDIGetNumberOfDestinations() {
            block(index, MIDIGetDestination(index))
        }
    }
}

// MARK: - Sources

public extension SwiftMIDI {
    
    /// MIDIGetSource
    /// Returns one of the sources in the system.
    ///
    /// - parameter index : The index of the source to return
    /// - returns : A reference to a source

    @available(macOS 10.0, *)
    static func getNumberOfSources() throws -> Int {
        let count = MIDIGetNumberOfSources()
        if count == 0 {
            throw SwiftMIDI.Errors.noSourceInSystem
        }
        return count
    }

    /// MIDIGetNumberOfDestinations
    /// Returns the number of destinations in the system.
    ///
    /// - returns : The number of destinations in the system

    @available(macOS 10.0, *)
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
}


// MARK: - Access Endpoint Entity

public extension SwiftMIDI {

    /// MIDIEndpointGetEntity
    /// Returns an endpoint's entity.
    ///
    /// - parameter endPoint : The endpoint being queried.
    ///
    /// - returns the endpoint's owning entity
    ///
    /// Virtual sources and destinations don't have entities.

    @available(macOS 10.2, *)
    static func getEntity(for endpoint: MIDIEndpointRef) throws -> MIDIEntityRef {
        var ref: MIDIEntityRef = 0
        try coreMidi {
            MIDIEndpointGetEntity(endpoint, &ref)
        }
        return ref
    }
}
