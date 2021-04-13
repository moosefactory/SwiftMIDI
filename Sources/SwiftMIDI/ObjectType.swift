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

// ObjectType.swift
// CoreMIDI Swift Wrapper
// Created by Tristan Leblanc on 30/12/2020.

import Foundation
import CoreMIDI

public extension MIDIObjectType {
    
    /// Convert a CoreMIDI object reference to SwiftMIDI ObjectType
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
        
        public var isSource: Bool { return self == .source || self == .externalSource }
        public var isDestination: Bool { return self == .destination || self == .externalDestination }
        public var isDevice: Bool { return self == .device || self == .externalDevice }
        public var isEntity: Bool { return self == .entity || self == .externalEntity }
    }
}
