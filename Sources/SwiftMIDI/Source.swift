//
//  SwiftMIDI+Source.swift
//  MidiCenter
//
//  Created by Tristan Leblanc on 30/12/2020.
//

import Foundation
import CoreMIDI

public extension SwiftMIDI {
    
    /// Returns the number of midi sources
    static var numberOfSources: Int {
        return MIDIGetNumberOfSources()
    }
    
    /// Returns the source at given index
    static func source(at index: Int) throws -> MIDIEndpointRef {
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
    
    static func connect(source: MIDIEndpointRef, to port: MIDIPortRef, refCon: UnsafeMutableRawPointer? = nil) throws {
        try coreMidi {
            MIDIPortConnectSource(port, source, refCon)
        }
    }
}
