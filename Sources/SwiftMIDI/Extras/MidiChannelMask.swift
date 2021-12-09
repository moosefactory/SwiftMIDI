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

//  MidiChannelMask.swift
//  Created by Tristan Leblanc on 08/01/2021.

import Foundation

/// MidiChannelMask
///
/// A mask used to filter channel
/// Each bit represent a channel

public typealias MidiChannelMask = UInt16

/// Channel Mask <-> Channels conversion
public extension MidiChannelMask {
    
    /// Returns the active channels
    var channels: [UInt8] {
        var out = [UInt8]()
        for i: UInt8 in 0...15 {
            if (self & (0x0001 << i)) > 0 {
                out.append(i)
            }
        }
        return out
    }
    
    /// Init with active channels
    init(channels: [UInt8]) {
        self = 0
        channels.forEach {
            if $0 < 16 {
                self |= (0x0001 << $0)
            }
        }
    }
    
    /// Init with one channel
    init(channel: UInt8) {
        self = 0x0001 << channel
    }
    
    static let all: MidiChannelMask = 0xFFFF
    static let none: MidiChannelMask = 0x0000
    static let channel1: MidiChannelMask = 0x0001
}

