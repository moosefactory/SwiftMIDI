//
//  Notes.swift
//  MidiCenter
//
//  Created by Tristan Leblanc on 30/12/2020.
//

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
    for value in 0...127 {
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
