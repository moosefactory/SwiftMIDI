//
//  SwiftMIDI+Notifications.swift
//  MidiCenter
//
//  Created by Tristan Leblanc on 30/12/2020.
//

import Foundation
import CoreMIDI

public protocol AnySwiftMIDINotification: CustomStringConvertible {
    var notificationPointer: UnsafePointer<MIDINotification> { get set }
}

public extension AnySwiftMIDINotification {
    var message: NotificationMessage { return NotificationMessage(notificationPointer.pointee.messageID) }
    var id: Int { return Int(notificationPointer.pointee.messageID.rawValue) }
    var size: Int { return Int(notificationPointer.pointee.messageSize) }
    
    var description: String {
        let components = [
            "Type: \(message) (\(id))",
            "Data Size: \(size)",
        ]
        return "Midi Notification : " + components.joined()
    }
}

public protocol SwiftMIDINotification: AnySwiftMIDINotification {
    associatedtype NotificationType
}

public extension SwiftMIDINotification {
    var notification: NotificationType {
        
        let pointee = notificationPointer.withMemoryRebound(to: NotificationType.self, capacity: 1) {
            $0.pointee
        }
        return pointee
        
    }
}

/// The object associated to add/remove midi notifications
///
/// We keep the CoreMidi values in the structure, to stay tight with the CoreMidi FrameWork.
///
/// Use type.swifty to access the Swifty value, with string description and syntax style

public struct MidiNotificationObject {
    public let ref: MIDIObjectRef
    public let type: MIDIObjectType
    public let parentRef: MIDIObjectRef
    public let parentType: MIDIObjectType
    
    var isDevice: Bool { return type == .device || type == .externalDevice }
    var isEntity: Bool { return type == .entity || type == .externalEntity }
    var isSource: Bool { return type == .source || type == .externalSource }
    var isDestination: Bool { return type == .destination || type == .externalDestination }
}

public extension SwiftMIDI {
    
    struct Notification {
        
        public struct SetUpChanged: SwiftMIDINotification  {
            public typealias NotificationType = MIDINotification
            public var notificationPointer: UnsafePointer<MIDINotification>
        }
        
        public struct ObjectAdded: SwiftMIDINotification  {
            public typealias NotificationType = MIDIObjectAddRemoveNotification
            public var notificationPointer: UnsafePointer<MIDINotification>
            
            public var object: MidiNotificationObject {
                    return MidiNotificationObject(ref: notification.child,
                                                  type: notification.childType,
                                                  parentRef: notification.parent,
                                                  parentType: notification.parentType)
            }
            
            public var description: String {
                let components = [
                    "Type: \(message) (\(id))",
                    "Data Size: \(size)",
                    "Child: \(notification.child)",
                    "Child Type: \(notification.childType.swifty)",
                    "Parent Ref: \(notification.parent)",
                    "Parent Type: \(notification.parentType.swifty)"
                ]
                return "Midi Object Added Notification : " + components.joined(separator: "; ")
            }
        }

        public struct ObjectRemoved: SwiftMIDINotification  {
            public typealias NotificationType = MIDIObjectAddRemoveNotification
            public var notificationPointer: UnsafePointer<MIDINotification>
            
            public var object: MidiNotificationObject {
                    return MidiNotificationObject(ref: notification.child,
                                                  type: notification.childType,
                                                  parentRef: notification.parent,
                                                  parentType: notification.parentType)
            }
            
            public var description: String {
                let components = [
                    "Type: \(message) (\(id))",
                    "Data Size: \(size)",
                    "Child: \(notification.child)",
                    "Child Type: \(notification.childType.swifty)",
                    "Parent Ref: \(notification.parent)",
                    "Parent Type: \(notification.parentType.swifty)"
                ]
                return "Midi Object Removed Notification : " + components.joined(separator: "; ")
            }

        }

        public struct PropertyChanged: SwiftMIDINotification  {
            public typealias NotificationType = MIDIObjectPropertyChangeNotification
            public var notificationPointer: UnsafePointer<MIDINotification>
            
            public var description: String {
                var components = [
                    "Type: \(message) (\(id))",
                    "Data Size: \(size)",
                    "Object Ref: \(notification.object)",
                    "Object Type: \(notification.objectType.swifty)",
                    "Property: \(notification.propertyName.takeRetainedValue() as String)",
                ]
                
                if (notification.propertyName.takeRetainedValue() as String)  == "apple.midirtp.session" {
                    components += ["<MIDI Connected>"]
                }

                return "Midi Property Changed Notification : " + components.joined(separator: "; ")
            }
        }

        public struct ThruConnectionChanged: SwiftMIDINotification  {
            public typealias NotificationType = MIDINotification
            public var notificationPointer: UnsafePointer<MIDINotification>
        }

        public struct SerialPortOwnerChanged: SwiftMIDINotification  {
            public typealias NotificationType = MIDINotification
            public var notificationPointer: UnsafePointer<MIDINotification>
        }

        public struct IOError: SwiftMIDINotification  {
            public typealias NotificationType = MIDIIOErrorNotification
            public var notificationPointer: UnsafePointer<MIDINotification>
            
            public var description: String {
                let components = [
                    "Type: \(message) (\(id))",
                    "Data Size: \(size)",
                    "Device Ref: \(notification.driverDevice)",
                    "Error: \(notification.errorCode)",
                ]
                return "Midi IOError Notification : " + components.joined(separator: "; ")
            }

        }

        public struct Unknown: SwiftMIDINotification  {
            public typealias NotificationType = MIDINotification
            public var notificationPointer: UnsafePointer<MIDINotification>
        }

        public static func make(with coreMidiNotificationPointer: UnsafePointer<MIDINotification>) -> AnySwiftMIDINotification {
            switch coreMidiNotificationPointer.pointee.messageID {
            case .msgSetupChanged:
                return SetUpChanged(notificationPointer: coreMidiNotificationPointer)
            case .msgObjectAdded:
                return ObjectAdded(notificationPointer: coreMidiNotificationPointer)
            case .msgObjectRemoved:
                return ObjectRemoved(notificationPointer: coreMidiNotificationPointer)
            case .msgPropertyChanged:
                return PropertyChanged(notificationPointer: coreMidiNotificationPointer)
            case .msgThruConnectionsChanged:
                return ThruConnectionChanged(notificationPointer: coreMidiNotificationPointer)
            case .msgSerialPortOwnerChanged:
                return SerialPortOwnerChanged(notificationPointer: coreMidiNotificationPointer)
            case .msgIOError:
                return IOError(notificationPointer: coreMidiNotificationPointer)
            @unknown default:
                return Unknown(notificationPointer: coreMidiNotificationPointer)
            }
        }
    }
}
