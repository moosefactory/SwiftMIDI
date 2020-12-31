//
//  SwiftMidi+Destination.swift
//  MidiCenter
//
//  Created by Tristan Leblanc on 30/12/2020.
//

import Foundation
import CoreMIDI

public extension SwiftMIDI {
    
    /// Returns the number of midi sources
    static var numberOfDestinations: Int {
        return MIDIGetNumberOfDestinations()
    }
    
    /// Returns the destination at given index
    static func destination(at index: Int) throws -> MIDIEndpointRef {
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
