/*--------------------------------------------------------------------------*/
/*   /\/\/\__/\/\/\        MooseFactory SwiftMidi                   */
/*   \/\/\/..\/\/\/                                                         */
/*        |  |             (c)2021 Tristan Leblanc                          */
/*        (oo)             tristan@moosefactory.eu                          */
/* MooseFactory Software                                                    */
/*--------------------------------------------------------------------------*/
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE. */
/*--------------------------------------------------------------------------*/

//  MidiFilter.swift
//  Created by Tristan Leblanc on 08/01/2021.

import Foundation
import CoreMIDI

public class MidiFilterSettings: Codable, Equatable, CustomStringConvertible {
    
    public var enabled: Bool = true
    
    // MARK: - Filtering parameters
    
    /// Channels Filter
    public var channels: MidiChannelMask = .all {
        didSet { updateIsThrough() }
    }
    
    /// Event Types Filter
    public var eventTypes: MidiEventTypeMask = .all {
        didSet { updateIsThrough() }
    }
    
    /// Note Range Filter
    public var noteRange: MidiRange = .full {
        didSet { updateIsThrough() }
    }
    
    /// Velocity Range Filter
    public var velocityRange: MidiRange = .full {
        didSet { updateIsThrough() }
    }

    
    /// Velocity Range Filter
    public var globalTranspose: Int16 = 0 {
        didSet { updateIsThrough() }
    }

    public var tracksActivatedChannels: Bool = true {
        didSet { updateIsThrough() }
    }
    
    public var tracksHigherAndLowerNotes: Bool = true {
        didSet { updateIsThrough() }
    }
    
    // MARK: - Inline operations
    
    /// Channels Mapper
    ///
    /// Will redirect each channel to the channel in the array.
    /// Identity maps each channel to itself
    
    public var channelsMap: MidiChannelsMap = .identity {
        didSet { updateIsThrough() }
    }
    
    /// Channels Transposer
    ///
    /// Will apply a transposition to each channel

    public var channelsTranspose: MidiChannelsTranspose = .identity {
        didSet { updateIsThrough() }
    }
    
    
    public private(set) var isPassThrough: Bool = true
    
    public var willPassThrough: Bool { return !enabled || isPassThrough }
    
    public var limitTo127Banks: Bool = true
    
    public init(channels: MidiChannelMask = .all,
                eventTypes: MidiEventTypeMask = .all,
                noteRange: MidiRange = .full,
                velocityRange: MidiRange = .full,
                channelsMap: MidiChannelsMap = .identity,
                channelsTranspose: MidiChannelsTranspose = .identity,
                globalTranspose: Int16 = 0) {
        self.channels = channels
        self.eventTypes = eventTypes
        self.noteRange = noteRange
        self.velocityRange = velocityRange
        self.channelsMap = channelsMap
        self.channelsTranspose = channelsTranspose
        self.globalTranspose = globalTranspose
        updateIsThrough()
    }
    
    func updateIsThrough() {
        isPassThrough = channels == .all
            && eventTypes == .all
            && noteRange == .full
            && velocityRange == .full
            && channelsMap == .identity
            && channelsTranspose == .identity
            && globalTranspose == 0
            && !(tracksActivatedChannels || tracksHigherAndLowerNotes)
    }
    
    public var description: String {
        var chanStr = "|"
        for i in 0..<16 {
            if channels & (0x0001 << i) > 0 {
                chanStr += String("0\(i)".suffix(2))
            } else {
                chanStr += "  "
            }
            chanStr += "|"
        }
        return "Midi Filter:\r\(chanStr)\r\(eventTypes)\r\(noteRange) - \(velocityRange)"
    }
    
    public static func == (lhs: MidiFilterSettings, rhs: MidiFilterSettings) -> Bool {
        return lhs.channels == rhs.channels
            && lhs.eventTypes == rhs.eventTypes
            && lhs.noteRange == rhs.noteRange
            && lhs.velocityRange == rhs.velocityRange
    }
}

@available(macOS 10.15, *)
extension MidiFilterSettings: ObservableObject {
    
}
