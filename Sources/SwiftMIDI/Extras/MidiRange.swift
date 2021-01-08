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

//  MidiRange.swift
//  Created by Tristan Leblanc on 08/01/2021.

import Foundation
import CoreMIDI

public struct NoteRange: Codable, Equatable, CustomStringConvertible {
    public var lowerNote: UInt8 = 0
    public var higherNote: UInt8 = 127
    
    public init(lowerNote: UInt8 = 0, higherNote: UInt8 = 127) {
        self.lowerNote = min(127, lowerNote)
        self.higherNote = min(max(self.lowerNote, higherNote), 127)
    }
    
    public static let full = NoteRange()
    
    public var description: String {
        return "Note Range : [\(lowerNote)..\(higherNote)]"
    }
}

public struct VelocityRange: Codable, Equatable, CustomStringConvertible {
    public var lowerVelocity: UInt8 = 0
    public var higherVelocity: UInt8 = 127
    
    public init(lowerVelocity: UInt8 = 0, higherVelocity: UInt8 = 127) {
        self.lowerVelocity = min(127, lowerVelocity)
        self.higherVelocity = min(max(self.lowerVelocity, higherVelocity), 127)
    }
    
    public static let full = VelocityRange()
    
    public var description: String {
        return "Velo Range : [\(lowerVelocity)..\(higherVelocity)]"
    }
}
