# SwiftMIDI
![Icon](Icon.png)

**SwiftMIDI** is a swifty syntaxic sugar that help to integrate **CoreMidi** in swift projects.

**SwiftMIDI** is a simple framework. It that does only wrap principal CoreMIDI functions and add few logic and omdern swift definitions for common midi operations.

The main purpose of this framework is to 

- Replace calls returning OSStatus by throwing function
- Replace UnsafeMutablePointer output parameters by classic function results
- Few syntax changes in function names and return types to follow modern swift standards

```swift
func findMidiThruConnections(owner: String) throws -> [MIDIThruConnectionRef]?
```

instead of 

```swift
func MIDIThruConnectionFind(_ inPersistentOwnerID: CFString, _ outConnectionList: UnsafeMutablePointer<Unmanaged<CFData>>) -> OSStatus
```

## SwiftMidiCenter

SwiftMidiCenter is a higher level package, based on the **SwiftMidi** framework, that makes midi devices and connections easier.

It also propose some more system oriented features like default storage and configurations management.

[https://github.com/moosefactory/SwiftMidiCenter](https://github.com/moosefactory/SwiftMidiCenter)

You can see both working in a sample project developed in SwiftUI : **SwiftMidiCenter App**

[https://github.com/moosefactory/MidiCenterApp](https://github.com/moosefactory/MidiCenterApp)

![Scheme](Documentation/SwiftMIDI_ReadMe_Scheme.jpg)

## <font color='#1E72AD'>Installation</font>

**SwiftMIDI** is distributed as a Swift Package

## <font color='#1E72AD'>Author</font>

Tristan Leblanc <tristan@moosefactory.eu>

**MooseFactory Software**

***

## <font color='#1E72AD'>License</font>

SwiftMIDI is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

***


## <font color='#1E72AD'>History</font>

First Commit:
v1.0.0 : 2021-01-01 at Midnight, Paris Time. Happy New Year :)
