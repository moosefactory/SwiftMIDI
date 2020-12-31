//
//  SwiftyCoreMidi.swift
//  MidiCenter
//
//  Created by Tristan Leblanc on 29/12/2020.
//

import Foundation
import CoreMIDI

@available(macOS 10.15, *)
public extension Notification.Name {
    static let MIDINetworkContactsDidChange = Notification.Name(MIDINetworkNotificationContactsDidChange)
}

/// SwiftMIDI
///
/// A swifty layer over the CoreMIDI framework

public struct SwiftMIDI {
    
    public static let shared = SwiftMIDI()
    
    /// restart
    /// Stops and restarts MIDI I/O.
    ///
    /// This is useful for forcing CoreMIDI to ask its drivers to rescan for hardware.
    
    @available(macOS 10.1, *)
    public static func restart() throws {
        try coreMidi {
            MIDIRestart()
        }
    }
}

// MARK: - Global Functions -

/// Throw an exceptions if the status is not `noErr`

public func throwMidiErrorIfNeeded(_ err: OSStatus) throws {
    if err != noErr, let err = SwiftMIDI.MidiError(err) {
        throw err
    }
}

/// Transforms an osStatus result in a swift exception
///
/// Usage:
/// ```
/// try coreMidi {
///    <Function that returns an osStatus >
/// }

public func coreMidi(_ block: ()->OSStatus) throws {
    let err = block()
    try throwMidiErrorIfNeeded(err)
}
