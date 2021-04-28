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

//  Notes.swift
//  Created by Tristan Leblanc on 30/12/2020.

import Foundation

/// Returns the note as a string
public extension UInt8 {
    var toNote: String { SwiftMidiNote[Int(self)]?.string ?? "!!" }
}

public struct SwiftMidiNote: CustomStringConvertible {
    public private(set) var number: Int
    public private(set) var numberInOctave: Int
    public private(set) var letter: String
    public private(set) var string: String
    public private(set) var stringWithoutOctave: String
    public private(set) var isWhite: Bool

    private static var _notes: [SwiftMidiNote]?
    
    public static var maxNotes = 256 { didSet {
        _notes = nil
    }}
    
    public static subscript (index: Int) -> SwiftMidiNote? {
        guard index >= 0 && index < maxNotes else { return nil }
        return all[index]
    }
    
    /// An array containing all notes as strings ["C0", "C#0", "D0", ...]
    /// associated to booleans indicating if note is white
    public static let all: [SwiftMidiNote] = {
        guard _notes == nil else { return _notes! }
        var noteLetters = ["C", "C", "D", "D", "E", "F", "F", "G", "G", "A", "A", "B"]
        var sharpLetters = ["", "#", "", "#", "", "", "#", "", "#", "", "#", ""]
        var notes = [SwiftMidiNote]()
        var octave = 0
        var n = 0
        for value in 0..<maxNotes {
            let noteLetter = noteLetters[n]
            let s = sharpLetters[n]
            let note = SwiftMidiNote(number: value, numberInOctave: value % 12,
                                     letter: "\(noteLetter)",
                                     string: "\(noteLetter)\(octave)\(s)",
                                     stringWithoutOctave: "\(noteLetter)\(s)",
                                     isWhite: s.isEmpty)
            notes.append(note)
            n += 1
            if n == 12 {
                n = 0
                octave += 1
            }
        }
        _notes = notes
        return notes
    }()
    
    /// Returns all white notes
    public static var whites: [SwiftMidiNote] {
        all.filter { $0.isWhite }
    }
    
    /// Returns all black notes
    public static var blacks: [SwiftMidiNote] {
        all.filter { !$0.isWhite }
    }
        
    /// Returns full string description ( note and octave )
    public var description: String {
        return string
    }
    
    // MARK: Common tests
    
    /// Returns true if note is a C
    public var isC: Bool { numberInOctave == 0 }

    /// Returns true if note is a black key
    public var isBlack: Bool { !isWhite }

    /// Returns true if note has a black key before
    public var hasBlackBefore: Bool { isWhite && numberInOctave != 0 && numberInOctave != 5 }


    /// Returns true if note has a black key after
    public var hasBlackAfter: Bool { isWhite && numberInOctave != 4 && numberInOctave != 11 }
}

