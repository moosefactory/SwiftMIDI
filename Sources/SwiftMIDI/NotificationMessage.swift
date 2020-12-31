//
//  NotificationMessage.swift
//  MidiCenter
//
//  Created by Tristan Leblanc on 30/12/2020.
//

import Foundation
import CoreMIDI

public enum NotificationMessage: Int, CustomStringConvertible {
    
    case unknown
    case setupChanged
    case objectAdded
    case objectRemoved
    case propertyChanged
    case thruConnectionChanged
    case serialPortOwnerChanged
    case ioError

    init(_ coreMidiMessage: MIDINotificationMessageID) {
        self = NotificationMessage(rawValue: Int(coreMidiMessage.rawValue)) ?? .unknown
    }

    public var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .setupChanged:
            return "Setup Changed"
        case .objectAdded:
            return "Object Added"
        case .objectRemoved:
            return "Object Removed"
        case .propertyChanged:
            return "Property Changed"
        case .thruConnectionChanged:
            return "Thru Connection Changed"
        case .serialPortOwnerChanged:
            return "Port Owner Changed"
        case .ioError:
            return "IO Error"
        }
    }
}

