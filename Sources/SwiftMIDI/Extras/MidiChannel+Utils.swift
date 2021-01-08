/*--------------------------------------------------------------------------*/
/*   /\/\/\__/\/\/\        MooseFactory SwiftMidi - v1 .0                   */
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

//  MidiChannel+Utils.swift
//  Created by Tristan Leblanc on 06/01/2021.

import Foundation

/// A channel multiplexer matrix.
///
/// This can be used to propagate events from on channel to multiple channels

public struct MidiChannelMatrix {
    public var mask: [MidiChannelMask] = [
        MidiChannelMask(channel: 0),
        MidiChannelMask(channel: 1),
        MidiChannelMask(channel: 2),
        MidiChannelMask(channel: 3),
        MidiChannelMask(channel: 4),
        MidiChannelMask(channel: 5),
        MidiChannelMask(channel: 6),
        MidiChannelMask(channel: 7),
        MidiChannelMask(channel: 8),
        MidiChannelMask(channel: 9),
        MidiChannelMask(channel: 10),
        MidiChannelMask(channel: 11),
        MidiChannelMask(channel: 12),
        MidiChannelMask(channel: 13),
        MidiChannelMask(channel: 14),
        MidiChannelMask(channel: 15)
    ]
    
    public init() {}
}

/// MidiChannelsTranspose
///
/// A 16 transpose values that can be used to change note values coming from channels
public struct MidiChannelsTranspose {
    public var transpose = [0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0]
    
    public init() {}
}

public struct MidiChannelsTransposeMatrix {
    public var transpose = [
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose(),
        MidiChannelsTranspose()
    ]
    
    public init() {}
}

/// MidiCHannelMapper
///
/// A simple mapper that maps all channels set in input mask to all channels set in output mask
public struct MidiChannelMapper {
    public var inChannels: MidiChannelMask
    public var outChannels: MidiChannelMask
    
    public init(inChannels: MidiChannelMask, outChannels: MidiChannelMask? = nil) {
        self.inChannels = inChannels
        self.outChannels = outChannels ?? inChannels
    }
    
    public init(inChannel: UInt8, outChannel: UInt8? = nil) {
        self.inChannels = MidiChannelMask(channel: inChannel)
        self.outChannels = outChannel == nil
            ? inChannels
            : MidiChannelMask(channel: outChannel!)
    }
}
