//
//  SwiftMIDI+Client.swift
//  MidiCenter
//
//  Created by Tristan Leblanc on 30/12/2020.
//

import Foundation
import CoreMIDI

public extension SwiftMIDI {
    
    @available(macOS 10.11, *)
    static func createClient(name: String, with block: @escaping MIDINotifyBlock) throws -> MIDIClientRef {
        var clientRef: MIDIClientRef = 0
        try coreMidi {
            MIDIClientCreateWithBlock(name as CFString, &clientRef, block)
        }
        return clientRef
    }
    
}
