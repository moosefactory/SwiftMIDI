# MIDI Client

| ➡️ | SwiftMIDI | CoreMIDI |
| --- | ------------------ | ---------------------- |
| ❌ | | MIDIClientCreate |
| ✅ | createClient | MIDIClientCreateWithBlock |
| ✅ | disposeClient | MIDIClientDispose |

## Client

#### <font color='#1E72AD'> createClient(name: String, with block:)</font>

Creates a MIDIClient object.

```swift
createClient(name: String, with block: @escaping MIDINotifyBlock) throws -> MIDIClientRef
```

#### <font color='#1E72AD'> disposeClient(_ clientRef:)</font>

Disposes a MIDIClient object.

```swift
static func disposeClient(_ clientRef: MIDIClientRef) throws
```
