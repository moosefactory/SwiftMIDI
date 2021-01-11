# Endpoints



| ➡️ | SwiftMIDI | CoreMIDI |
| --- | ------------------ | ---------------------- |
| ✅ | getNumberOfDestinations | MIDIGetNumberOfDestinations |
| ✅ | destination | MIDIGetDestination |
| ✅ | getNumberOfSources | MIDIGetNumberOfSources |
| ✅ | getSource | MIDIGetSource |
| ✅ | getEntity | MIDIEndpointGetEntity | 
| | **Extension**| |
| 🆕 | numberOfDestinations | |
| 🆕 | allDestinations | |
| 🆕 | forEachDestination | |
| 🆕 | numberOfSources | |
| 🆕 | allSources | |
| 🆕 | forEachSource | |

## Destinations

#### <font color='#1E72AD'>getNumberOfDestinations()</font>

Returns the number of destinations in the system.

```swift
static func getNumberOfDestinations() throws -> Int
```

#### <font color='#1E72AD'>destination(at index:)</font>

Returns one of the destinations in the system.

```swift
static func destination(at index: Int) throws -> MIDIEndPointRef
```

#### <font color='#1EAD72'>numberOfDestinations</font>

Returns the number of destinations in the system.

```swift
static var numberOfDestinations: Int
```

#### <font color='#1EAD72'>allDestinations</font>

Returns an array containing the destinations in the system.

```swift
static var allDestinations: [MIDIEndpointRef]
```

#### <font color='#1E72AD'> forEachDestination(do block:)</font>

Iterates through all destinations

```swift
static func forEachDestination(do block: (Int, MIDIEndpointRef)->Void)
```

## Sources

#### <font color='#1E72AD'>getNumberOfSources()</font>

Returns the number of sources in the system.

```swift
static func getNumberOfSources() throws -> Int
```

#### <font color='#1E72AD'>source(at index:)</font>

Returns one of the sources in the system.

```swift
static func source(at index: Int) throws -> MIDIEndPointRef
```

#### <font color='#1EAD72'>numberOfSources</font>

Returns the number of sources in the system.

```swift
static var numberOfSources: Int
```

#### <font color='#1EAD72'>allSources</font>

Returns an array containing the sources in the system.

```swift
static var allSources: [MIDIEndpointRef]
```

#### <font color='#1E72AD'> forEachSource(do block:)</font>

Iterates through all sources

```swift
static func forEachSource(do block: (Int, MIDIEndpointRef)->Void)
```

## Endpoint's Entity 

#### <font color='#1E72AD'>getEntity(for endpoint:)</font>

Returns an endpoint's entity.

```swift
static func getEntity(for endpoint: MIDIEndpointRef) throws -> MIDIEntityRef
```

