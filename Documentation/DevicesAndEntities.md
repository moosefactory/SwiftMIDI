# Devices and Entities


| ➡️ | SwiftMIDI | CoreMIDI |
| --- | ------------------ | ---------------------- |
| ✅ | getNumberOfDevices | MIDIGetNumberOfDevices |
| ✅ | getDevice | MIDIGetDevice |
| ✅ | getNumberOfExternalDevices | MIDIGetNumberOfExternalDevices |
| ✅ | getExternalDevice | MIDIGetExternalDevice |
| ✅ | getDevice | MIDIGetDevice | 
| ✅ | numberOfEntities | MIDIDeviceGetNumberOfEntities |
| ✅ | getEntity | MIDIDeviceGetEntity |
| ✅ | getNumberOfSources | MIDIEntityGetNumberOfSources
| ✅ | getSource | MIDIEntityGetSource |
| ✅ | getNumberOfDestinations | MIDIEntityGetNumberOfDestinations |
| ✅ | getDestination | MIDIEntityGetDestination |
| ✅ | getDevice | MIDIEntityGetDevice |
| | **Extension**| |
| 🆕 | numberOfDevices | |
| 🆕 | devices | |
| 🆕 | forEachDevice | |
| 🆕 | forEachEntity | |
| 🆕 | allEntities | |

## Devices

#### <font color='#1E72AD'>getNumberOfDevices()</font>

Returns the number of devices in the system.

```swift
static func getNumberOfDevices() throws -> Int
```

#### <font color='#1E72AD'>getDevice(at index:)</font>

Returns one of the devices in the system.

```swift
static func getDevice(at index: Int) throws -> MIDIDeviceRef
```

#### <font color='#1E72AD'>getExternalDevice(at index:)</font>

Returns one of the external devices in the system.

```swift
static func getExternalDevice(at index: Int) throws -> MIDIDeviceRef
```

#### <font color='#1E72AD'>getNumberOfExternalDevices()</font>

Returns the number of external MIDI devices in the system.

```swift
static func getNumberOfExternalDevices() throws -> Int
```

## Entities

#### <font color='#1E72AD'>getNumberOfEntities(for device:)</font>

Returns the number of entities in a given device.

```swift
static func getNumberOfEntities(for device: MIDIDeviceRef) throws -> Int
```

#### <font color='#1E72AD'>getEntity(for device:, at index:)</font>

Returns one of a given device's entities.

```swift
static func getEntity(for device: MIDIDeviceRef, at index: Int) throws -> MIDIEntityRef
```

## Entities Endpoints

#### <font color='#1E72AD'>numberOfSources(for entity:)</font>

Returns the number of sources in a given entity.

```swift
static func numberOfSources(for entity: MIDIEntityRef) throws -> Int
```

#### <font color='#1E72AD'>source(for entity:, at index:)</font>

Returns one of a given entity's sources.

```swift
static func source(for entity: MIDIEntityRef, at index: Int) throws -> MIDIEndpointRef
```

#### <font color='#1E72AD'>numberOfDestinations(for entity:)</font>

Returns the number of destinations in a given entity.

```swift
static func numberOfDestinations(for entity: MIDIEntityRef) throws -> Int
```

#### <font color='#1E72AD'>destination(for entity:)</font>

Returns one of a given entity's destinations.

```swift
static func destination(for entity: MIDIEntityRef, at index: Int) throws -> MIDIEndpointRef
```
## SwiftMIDI Extras

#### <font color='#1EAD72'>numberOfDevices</font>

Returns one of the devices in the system.

```swift
static var numberOfDevices: Int
```

#### <font color='#1EAD72'>devices</font>

Returns an array containing all midi devices in system.

```swift
static var devices: [MIDIDeviceRef]
```

#### <font color='#1E72AD'>forEachDevice(do closure:)</font>

Iterates through all devices in system.

```swift
static func forEachDevice(do closure: (Int, MIDIDeviceRef)->Void)
```

#### <font color='#1E72AD'>allDevices()</font>

Returns an array containing all midi devices in system.

```swift
static func allDevices() throws -> [MIDIDeviceRef]
```

#### <font color='#1E72AD'>forEachEntity(in device:, do closure:)</font>

Iterates through all entities in passed device ref.

```swift
static func forEachEntity(in device: MIDIDeviceRef, do closure: (Int, MIDIEntityRef)->Void) throws
```

#### <font color='#1E72AD'>allEntities(in device:)</font>

Returns an array containing all midi entities for passed device ref.

```swift
static func allEntities(in device: MIDIDeviceRef) throws -> [MIDIEntityRef]
```
