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

//  Properties.swift
//
// CoreMIDI Swift Wrapper
//
//  Created by Tristan Leblanc on 31/12/2020.

import Foundation
import CoreMIDI

public extension SwiftMIDI {
    
    /// GetIntegerProperty
    /// Gets an object's integer-type property.
    ///
    /// - parameter obj : The object whose property is to be returned.
    /// - parameter propertyID :  Name of the property to return.
    ///
    /// - returns: On successful return, the Int value of the property.
    ///
    ///  (See the MIDIObjectRef documentation for information about properties.)
    
    @available(macOS 10.0, *)
    static func getIntegerProperty(object: MIDIObjectRef, propertyID: String) throws -> Int {
        var out: Int32 = 0
        try coreMidi {
            MIDIObjectGetIntegerProperty(object, propertyID as CFString, &out)
        }
        return Int(out)
    }
    
    /// SetIntegerProperty
    /// Sets an object's integer-type property.
    ///
    /// - parameter obj :  The object whose property is to be altered.
    /// - parameter propertyID :  Name of the property to set.
    /// - parameter value : The new Int value of the property
    ///
    ///  (See the MIDIObjectRef documentation for information about properties.)
    
    @available(macOS 10.0, *)
    static func setIntegerProperty(object: MIDIObjectRef, propertyID: String, value: Int) throws {
        try coreMidi {
            MIDIObjectSetIntegerProperty(object, propertyID as CFString, Int32(value))
        }
    }
    
    /// GetStringProperty
    /// Gets an object's string-type property.
    ///
    /// - parameter obj : The object whose property is to be returned.
    /// - parameter propertyID :  Name of the property to return.
    ///
    /// - returns : On successful return, the value of the property.
    ///
    /// (See the MIDIObjectRef documentation for information about properties.)
    
    @available(macOS 10.0, *)
    static func getStringProperty(object: MIDIObjectRef, propertyID: String) throws -> String? {
        var string: Unmanaged<CFString>?
        try coreMidi {
            MIDIObjectGetStringProperty(object, propertyID as CFString, &string)
        }
        return string?.takeRetainedValue() as String?
    }
    
    /// SetStringProperty
    /// Sets an object's string-type property.
    ///
    /// - parameter obj : The object whose property is to be altered.
    /// - parameter propertyID : Name of the property to set.
    ///
    /// - returns : The String value of the property.
    ///
    /// (See the MIDIObjectRef documentation for information about properties.)
    
    @available(macOS 10.0, *)
    static func setStringProperty(object: MIDIObjectRef, propertyID: String, value: String) throws {
        try coreMidi {
            MIDIObjectSetStringProperty(object, propertyID as CFString, value as CFString)
        }
    }
    
    /// GetDataProperty
    /// Gets an object's data-type property.
    ///
    /// - parameter obj :  The object whose property is to be returned.
    /// - parameter propertyID :  Name of the property to return.
    ///
    /// - returns : On successful return, the value of the property.
    ///
    /// (See the MIDIObjectRef documentation for information about properties.)
    
    @available(macOS 10.0, *)
    static func getDataProperty(object: MIDIObjectRef, propertyID: String) throws -> Data? {
        var data: Unmanaged<CFData>?
        
        try coreMidi {
            MIDIObjectGetDataProperty(object, propertyID as CFString, &data)
        }
        return data?.takeRetainedValue() as Data?
    }
    
    /// SetDataProperty
    /// Sets an object's data-type property.
    ///
    /// - parameter obj : The object whose property is to be altered.
    /// - parameter propertyID : Name of the property to set.
    /// - parameter data : New value of the property.
    ///
    /// (See the MIDIObjectRef documentation for information about properties.)
    
    @available(macOS 10.0, *)
    static func setDataProperty(object: MIDIObjectRef, propertyID: String, data: Data) throws {
        try coreMidi {
            MIDIObjectSetDataProperty(object, propertyID as CFString, data as CFData)
        }
    }
    
    /// GetDictionaryProperty
    /// Gets an object's dictionary-type property.
    ///
    /// - parameter obj : The object whose property is to be returned.
    /// - parameter propertyID : Name of the property to return.
    /// - parameter outDict : On successful return, the value of the property.
    /// - resultAn OSStatus result code.
    ///
    ///  (See the MIDIObjectRef documentation for information about properties.)
    
    @available(macOS 10.2, *)
    static func getDictionaryProperty(object: MIDIObjectRef, propertyID: String) throws -> [String: AnyObject]? {
        var dict: Unmanaged<CFDictionary>?
        
        try coreMidi {
            MIDIObjectGetDictionaryProperty(object, propertyID as CFString, &dict)
        }
        return dict?.takeRetainedValue() as? [String: AnyObject]
    }
    
    /// SetDictionaryProperty
    /// Sets an object's dictionary-type property.
    ///
    /// - parameter obj : The object whose property is to be altered.
    /// - parameter propertyID : Name of the property to set.
    /// - parameter dict : New value of the property.
    ///
    ///  (See the MIDIObjectRef documentation for information about properties.)
    
    @available(macOS 10.2, *)
    static func setDictionaryProperty(object: MIDIObjectRef, propertyID: String, dictionary: [String: AnyObject]) throws {
        try coreMidi {
            MIDIObjectSetDictionaryProperty(object, propertyID as CFString, dictionary as CFDictionary)
        }
    }
    
    /// GetProperties
    ///  Gets all of an object's properties.
    ///
    /// - parameter obj : The object whose properties are to be returned.
    /// - parameter deep : true if the object's child objects are to be included
    /// (e.g. a device's entities, or an entity's endpoints).
    ///
    /// - returns : a CFPropertyList of all of an object's properties.
    /// The property list may be a dictionary or an array.
    /// Dictionaries map property names (CFString) to values, which may
    /// be CFNumber, CFString, or CFData.  Arrays are arrays of such values.
    ///
    /// Properties which an object inherits from its owning object (if any) are not included.
    
    @available(macOS 10.1, *)
    static func getProperties(object: MIDIObjectRef, propertyID: String, deep: Bool) throws -> [String: AnyObject]? {
        var propertyList: Unmanaged<CFPropertyList>?
        try coreMidi {
            MIDIObjectGetProperties(object, &propertyList, deep)
        }
        return propertyList?.takeUnretainedValue() as? [String: AnyObject]
    }
    
    /// RemoveProperty
    /// Removes an object's property.
    ///
    /// - parameter obj : The object whose property is to be removed.
    /// - parameter propertyID : The property to be removed.
    
    @available(macOS 10.2, *)
    static func removeProperty(object: MIDIObjectRef, propertyID: String) throws {
        try coreMidi {
            MIDIObjectRemoveProperty(object, propertyID as CFString)
        }
    }
}


extension Properties {
    
    static func getMidiObjects(object: MIDIObjectRef, propertyID: String) throws -> [MIDIObjectRef] {
        guard let data = try SwiftMIDI.getDataProperty(object: object, propertyID: propertyID) else {
            return []
        }
        
        let numberOfObjects = data.count / MemoryLayout<MIDIUniqueID>.size
//
//
//        let objects = [MIDIUniqueID]()
//
//        data.withUnsafeBytes() { bytes in
//            let rawBuffer = UnsafeRawBufferPointer(start: bytes, count: data.count)
//            rawBuffer.withMemoryBound(to: MIDIUniqueID.self, capacity: numberOfObjects) { bufferPointer in
//                return [MIDIThruConnectionRef].init(unsafeUninitializedCapacity: numberOfObjects) { objectPtr, count in
//                    count = numberOfObjects
//                    for i in 0..<count {
//                        objectPtr[i] = bufferPointer[i]
//                    }
//                }
//            }
//        }
        
        return []
    }
}
