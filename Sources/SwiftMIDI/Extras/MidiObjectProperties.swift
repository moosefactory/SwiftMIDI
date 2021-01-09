//
//  MidiObjectProperties.swift
//  Pulsar Lab
//
//  Created by Tristan Leblanc on 27/12/2019.
//  Copyright © 2019 Moose Factory Software. All rights reserved.
//

import Foundation
import CoreMIDI

public extension MIDIObjectRef {
    var properties: Properties {
        return Properties(object: self)
    }
}

/// A Properties lens
///
/// Usage :
/// ```
/// myObjectRef.properties.name
/// ```

public struct Properties {
    
    public private(set) var object: MIDIObjectRef
    
    public var isSet: Bool {
        return object != 0
    }
    
    // Strings
    public var name: String { return self[kMIDIPropertyName] }
    public var manufacturer: String { return self[kMIDIPropertyManufacturer] }
    public var model: String { return self[kMIDIPropertyModel] }
    public var driverOwner: String { return self[kMIDIPropertyDriverOwner] }
    public var image: String { return self[kMIDIPropertyImage] }
    public var driverDeviceEditorApp: String { return self[kMIDIPropertyDriverDeviceEditorApp] }
    public var displayName: String { return self[kMIDIPropertyDisplayName] }

    // Dictionaries
    @available(iOS 13, macOS 10.15, *)
    public var nameConfiguration: [String: AnyObject] { return self[kMIDIPropertyNameConfigurationDictionary] }

    // Integers
    public var uniqueID: Int { return self[kMIDIPropertyUniqueID] }
    public var deviceID: Int { return self[kMIDIPropertyDeviceID] }
    public var receiveChannels: Int { return self[kMIDIPropertyReceiveChannels] }
    public var transmitChannels: Int { return self[kMIDIPropertyTransmitChannels] }
    public var maxSysExSpeed: Int { return self[kMIDIPropertyMaxSysExSpeed] }
    public var advanceScheduleTimeMuSec: Int { return self[kMIDIPropertyAdvanceScheduleTimeMuSec] }
    public var isEmbeddedEntity: Int { return self[kMIDIPropertyIsEmbeddedEntity] }
    public var isBroadcast: Int { return self[kMIDIPropertyIsBroadcast] }
    public var singleRealtimeEntity: Int { return self[kMIDIPropertySingleRealtimeEntity] }
    public var connectionUniqueID: Int { return self[kMIDIPropertyConnectionUniqueID] }
    public var offline: Int { return self[kMIDIPropertyOffline] }
    public var isPrivate: Int { return self[kMIDIPropertyPrivate] }
    public var driverVersion: Int { return self[kMIDIPropertyDriverVersion] }
    public var supportsGeneralMIDI: Int { return self[kMIDIPropertySupportsGeneralMIDI] }
    public var supportsMMC: Int { return self[kMIDIPropertySupportsMMC] }
    public var canRoute: Int { return self[kMIDIPropertyCanRoute] }
    public var receivesClock: Int { return self[kMIDIPropertyReceivesClock] }
    public var receivesMTC: Int { return self[kMIDIPropertyReceivesMTC] }
    public var receivesNotes: Int { return self[kMIDIPropertyReceivesNotes] }
    public var receivesProgramChanges: Int { return self[kMIDIPropertyReceivesProgramChanges] }
    public var receivesBankSelectMSB: Int { return self[kMIDIPropertyReceivesBankSelectMSB] }
    public var receivesBankSelectLSB: Int { return self[kMIDIPropertyReceivesBankSelectLSB] }
    public var transmitsClock: Int { return self[kMIDIPropertyTransmitsClock] }
    public var transmitsMTC: Int { return self[kMIDIPropertyTransmitsMTC] }
    public var transmitsNotes: Int { return self[kMIDIPropertyTransmitsNotes] }
    public var transmitsProgramChanges: Int { return self[kMIDIPropertyTransmitsProgramChanges] }
    public var transmitsBankSelectMSB: Int { return self[kMIDIPropertyTransmitsBankSelectMSB] }
    public var transmitsBankSelectLSB: Int { return self[kMIDIPropertyTransmitsBankSelectLSB] }
    public var panDisruptsStereo: Int { return self[kMIDIPropertyPanDisruptsStereo] }
    public var isSampler: Int { return self[kMIDIPropertyIsSampler] }
    public var isDrumMachine: Int { return self[kMIDIPropertyIsDrumMachine] }
    public var isMixer: Int { return self[kMIDIPropertyIsMixer] }
    public var isEffectUnit: Int { return self[kMIDIPropertyIsEffectUnit] }
    public var maxReceiveChannels: Int { return self[kMIDIPropertyMaxReceiveChannels] }
    public var maxTransmitChannels: Int { return self[kMIDIPropertyMaxTransmitChannels] }
    public var supportsShowControl: Int { return self[kMIDIPropertySupportsShowControl] }
}

private extension Properties {
    subscript(propertyID: CFString) -> String {
        return (try? SwiftMIDI.getStringProperty(object: object, propertyID: propertyID as String)) ?? ""
    }

    subscript(propertyID: CFString) -> Int {
        return (try? SwiftMIDI.getIntegerProperty(object: object, propertyID: propertyID as String)) ?? 0
    }

    subscript(propertyID: CFString) -> [String: AnyObject] {
        return (try? SwiftMIDI.getDictionaryProperty(object: object, propertyID: propertyID as String)) ?? [:]
    }
}
