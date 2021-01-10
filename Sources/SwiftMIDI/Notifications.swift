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

// Notifications.swift
//
// CoreMIDI Swift Wrapper
//
// Created by Tristan Leblanc on 30/12/2020.


import Foundation
import CoreMIDI

public protocol SwiftMIDINotification: CustomStringConvertible {
    var description: String { get }
}

public extension SwiftMIDI {
    
    struct Notification {
        
        //MARK: - Notifications Parameters

        /// The object associated to add/remove midi notifications
        ///
        /// We keep the CoreMidi object references in the structure
        /// Use type.swifty to access the Swifty value, with string description and syntax style
        
        public struct Object {
            public let ref: MIDIObjectRef
            public let type: MIDIObjectType
            public let parentRef: MIDIObjectRef
            public let parentType: MIDIObjectType
            
            var isDevice: Bool { return type == .device || type == .externalDevice }
            var isEntity: Bool { return type == .entity || type == .externalEntity }
            var isSource: Bool { return type == .source || type == .externalSource }
            var isDestination: Bool { return type == .destination || type == .externalDestination }
        }
        
        /// The property associated to property changed notification
        ///
        /// We keep the CoreMidi object references in the structure
        /// Use type.swifty to access the Swifty value, with string description and syntax style
        
        public struct Property {
            public var object: MIDIObjectRef
            public var objectType: MIDIObjectType
            public var propertyName: String
        }
        
        //MARK: - Notifications
        
        /// Setup Changed
        
        public struct SetUpChanged: SwiftMIDINotification  {
            public var description: String {
                return "Set Up Changed Notification"
            }
        }
        
        /// ObjectAdded
        
        public struct ObjectAdded: SwiftMIDINotification  {
            public var object: Object
            
            init(notification: MIDIObjectAddRemoveNotification) {
                object = Object(ref: notification.child,
                                type: notification.childType,
                                parentRef: notification.parent,
                                parentType: notification.parentType)
            }
            
            public var description: String {
                let components = [
                    "Child: \(object.ref)",
                    "Child Type: \(object.type.swifty)",
                    "Parent Ref: \(object.parentRef)",
                    "Parent Type: \(object.parentType.swifty)"
                ]
                return "Midi Object Added Notification : " + components.joined(separator: "; ")
            }
        }
        
        /// ObjectRemoved
        
        public struct ObjectRemoved: SwiftMIDINotification  {
            public var object: Object
            
            init(notification: MIDIObjectAddRemoveNotification) {
                object = Object(ref: notification.child,
                                type: notification.childType,
                                parentRef: notification.parent,
                                parentType: notification.parentType)
            }
            
            public var description: String {
                let components = [
                    "Child: \(object.ref)",
                    "Child Type: \(object.type.swifty)",
                    "Parent Ref: \(object.parentRef)",
                    "Parent Type: \(object.parentType.swifty)"
                ]
                return "Midi Object Removed Notification : " + components.joined(separator: "; ")
            }
        }
        
        /// PropertyChanged
        
        public struct PropertyChanged: SwiftMIDINotification  {
            public var object: Property
            
            init(notification:MIDIObjectPropertyChangeNotification) {
                object = Property(object: notification.object,
                                  objectType: notification.objectType,
                                  propertyName: notification.propertyName.takeUnretainedValue() as String)
            }
            
            public var description: String {
                let components = [
                    "Child: \(object.object)",
                    "Child Type: \(object.objectType.swifty)",
                    "Property: \(object.propertyName)"
                ]
                return "Midi Property Changed Notification : " + components.joined(separator: "; ")
            }
        }
        
        /// ThruConnectionChanged
        
        public struct ThruConnectionChanged: SwiftMIDINotification  {
            public var description: String {
                return "Thru Connection Changed  Notification"
            }
        }
        
        /// SerialPortOwnerCHanged
        
        public struct SerialPortOwnerChanged: SwiftMIDINotification  {
            public var description: String {
                return "Serial Port Owner Changed Notification"
            }
        }
        
        public struct IOError: SwiftMIDINotification  {
            
            public var description: String {
                //                let components = [
                //                    "Type: \(message) (\(id))",
                //                    "Data Size: \(size)",
                //                    "Device Ref: \(notification.driverDevice)",
                //                    "Error: \(notification.errorCode)",
                //                ]
                return "Midi IOError Notification : "// + components.joined(separator: "; ")
            }
            
        }
        
        /// make
        ///
        /// Create a SwiftMidiNotification from CoreMIDI notification
        
        public static func make(with coreMidiNotificationPointer: UnsafePointer<MIDINotification>) -> SwiftMIDINotification? {
            
            switch coreMidiNotificationPointer.pointee.messageID {
            case .msgSetupChanged:
                return SetUpChanged()
            case .msgObjectAdded:
                let notif = coreMidiNotificationPointer.withMemoryRebound(to: MIDIObjectAddRemoveNotification.self, capacity: 1) {
                    $0.pointee
                }
                return ObjectAdded(notification: notif )
            case .msgObjectRemoved:
                let notif = coreMidiNotificationPointer.withMemoryRebound(to: MIDIObjectAddRemoveNotification.self, capacity: 1) {
                    $0.pointee
                }
                return ObjectRemoved(notification: notif)
            case .msgPropertyChanged:
                let notif = coreMidiNotificationPointer.withMemoryRebound(to: MIDIObjectPropertyChangeNotification.self, capacity: 1) {
                    $0.pointee
                }
                return PropertyChanged(notification: notif)
            case .msgThruConnectionsChanged:
                return ThruConnectionChanged()
            case .msgSerialPortOwnerChanged:
                return SerialPortOwnerChanged()
            case .msgIOError:
                return IOError()
            @unknown default:
                return nil
            }
        }
    }
}
