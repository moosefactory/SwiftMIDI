//
//  ObjectType.swift
//  MidiCenter
//
//  Created by Tristan Leblanc on 30/12/2020.
//

import Foundation
import CoreMIDI

public extension MIDIObjectType {
    
    var swifty: SwiftMIDI.ObjectType {
        return SwiftMIDI.ObjectType(self)
    }
}

/// Swifty CoreMidi object type
///
/// Use MIDIObjectType.swifty to access value the swifty way, with string description and syntax style

public extension SwiftMIDI {
    
    enum ObjectType: Int, CustomStringConvertible {
        case other = -1
        case device
        case entity
        case source
        case destination
        
        case externalDevice = 0x10
        case externalEntity = 0x11
        case externalSource = 0x12
        case externalDestination = 0x13
        
        /// Returns the CoreMidi value
        var ref: MIDIObjectType {
            return MIDIObjectType(rawValue: Int32(rawValue)) ?? .other
        }
        
        /// Init with CoreMidi type.
        ///
        /// This function is not available outside of this file. Use .swifty
        fileprivate init(_ coreMidiType: MIDIObjectType) {
            self = SwiftMIDI.ObjectType(rawValue: Int(coreMidiType.rawValue)) ?? .other
        }
        
        public var description: String {
            switch self {
            case .other:
                return "Other"
            case .device:
                return "Device"
            case .entity:
                return "Entity"
            case .source:
                return "Source"
            case .destination:
                return "Destination"
            case .externalDevice:
                return "External Device"
            case .externalEntity:
                return "External Entity"
            case .externalSource:
                return "External Source"
            case .externalDestination:
                return "External Destination"
            }
        }
    }
}
