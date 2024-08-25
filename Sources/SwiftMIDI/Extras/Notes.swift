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
    var asNoteString: String { SwiftMidiNote[Int(self)]?.string ?? "!!" }
}

// MARK: - Not Saved

extension Int {
    var isWhiteNote: Bool {
        return !isBlackNote
    }
    var isBlackNote: Bool {
        let m = self % 12
        return m == 1 || m == 3 || m == 6 || m == 8 || m == 10
    }
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

public extension SwiftMidiNote {
    
    static let MiddleC = 48

    static let C0 = 0
    static let Cs0 = 1
    static let D0 = 2
    static let Ds0 = 3
    static let E0 = 4
    static let F0 = 5
    static let Fs0 = 6
    static let G0 = 7
    static let Gs0 = 8
    static let A0 = 9
    static let As0 = 10
    static let B0 = 11
    
    static let C1 = 12
    static let Cs1 = 13
    static let D1 = 14
    static let Ds1 = 15
    static let E1 = 16
    static let F1 = 17
    static let Fs1 = 18
    static let G1 = 19
    static let Gs1 = 20
    static let A1 = 21
    static let As1 = 22
    static let B1 = 23
    
    static let C2 = 24
    static let Cs2 = 25
    static let D2 = 26
    static let Ds2 = 27
    static let E2 = 28
    static let F2 = 29
    static let Fs2 = 30
    static let G2 = 31
    static let Gs2 = 32
    static let A2 = 33
    static let As2 = 34
    static let B2 = 35

    static let C3 = 36
    static let Cs3 = 37
    static let D3 = 38
    static let Ds3 = 39
    static let E3 = 40
    static let F3 = 41
    static let Fs3 = 42
    static let G3 = 43
    static let Gs3 = 44
    static let A3 = 45
    static let As3 = 46
    static let B3 = 47
    
    static let C4 = 48
    static let Cs4 = 49
    static let D4 = 50
    static let Ds4 = 51
    static let E4 = 52
    static let F4 = 53
    static let Fs4 = 54
    static let G4 = 55
    static let Gs4 = 56
    static let A4 = 57
    static let As4 = 58
    static let B4 = 59
    
    static let C5 = 60
    static let Cs5 = 61
    static let D5 = 62
    static let Ds5 = 63
    static let E5 = 64
    static let F5 = 65
    static let Fs5 = 66
    static let G5 = 67
    static let Gs5 = 68
    static let A5 = 69
    static let As5 = 70
    static let B5 = 71
    
    static let C6 = 72
    static let Cs6 = 73
    static let D6 = 74
    static let Ds6 = 75
    static let E6 = 76
    static let F6 = 77
    static let Fs6 = 78
    static let G6 = 79
    static let Gs6 = 80
    static let A6 = 81
    static let As6 = 82
    static let B6 = 83
    
    static let C7 = 84
    static let Cs7 = 85
    static let D7 = 86
    static let Ds7 = 87
    static let E7 = 88
    static let F7 = 89
    static let Fs7 = 90
    static let G7 = 91
    static let Gs7 = 92
    static let A7 = 93
    static let As7 = 94
    static let B7 = 95
    
    static let C8 = 96
    static let Cs8 = 97
    static let D8 = 98
    static let Ds8 = 99
    static let E8 = 100
    static let F8 = 101
    static let Fs8 = 102
    static let G8 = 103
    static let Gs8 = 104
    static let A8 = 105
    static let As8 = 106
    static let B8 = 107
    
    static let C9 = 108
    static let Cs9 = 109
    static let D9 = 110
    static let Ds9 = 111
    static let E9 = 112
    static let F9 = 113
    static let Fs9 = 114
    static let G9 = 115
    static let Gs9 = 116
    static let A9 = 117
    static let As9 = 118
    static let B9 = 119
    
    static let C10 = 120
    static let Cs10 = 121
    static let D10 = 122
    static let Ds10 = 123
    static let E10 = 124
    static let F10 = 125
    static let Fs10 = 126
    static let G10 = 127

}
