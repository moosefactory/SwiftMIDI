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
    var toNote: String { SwiftMIDINotes[Int(self)] }
}

/// An array containing all notes as strings ["C0", "C#0", "D0", ...]
public let SwiftMIDINotes: [String] = {
    var noteLetters = ["C", "C", "D", "D", "E", "F", "F", "G", "G", "A", "A", "B"]
    var sharpLetters = ["", "#", "", "#", "", "", "#", "", "#", "", "#", ""]
    var notes = [String]()
    var octave = 0
    var n = 0
    for value in 0...255 {
        let note = noteLetters[n]
        let s = sharpLetters[n]
        notes.append("\(note)\(octave)\(s)")
        n += 1
        if n == 12 {
            n = 0
            octave += 1
        }
    }
    return notes
}()
