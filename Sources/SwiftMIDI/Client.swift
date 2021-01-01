//
//  SwiftMIDI+Client.swift
//  MidiCenter
//
//  Created by Tristan Leblanc on 30/12/2020.
//

import Foundation
import CoreMIDI

public extension SwiftMIDI {
    
    /// createClient
    /// Creates a MIDIClient object.
    ///
    /// - parameter name
    /// The client's name.
    /// - parameter outClient
    /// On successful return, points to the newly-created MIDIClientRef.
    /// - parameter notifyBlock
    /// An optional (may be NULL) block via which the client
    /// will receive notifications of changes to the system.
    ///
    /// Note that notifyBlock is called on a thread chosen by the implementation.
    /// Thread-safety is the block's responsibility.
    
    @available(macOS 10.11, *)
    static func createClient(name: String, with block: @escaping MIDINotifyBlock) throws -> MIDIClientRef {
        var clientRef: MIDIClientRef = 0
        try coreMidi {
            MIDIClientCreateWithBlock(name as CFString, &clientRef, block)
        }
        return clientRef
    }
    
}
