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

//  MidiEventTypeMaskSelector.swift
//  Created by Tristan Leblanc on 08/01/2021.


import Foundation

/// MidiEventTypeMaskSelector
///
/// Predefined event type masks. Nice to have to make mask presets popup menus

public enum MidiEventTypeMaskSelector: String, Codable, CaseIterable {
    
    case notes
    case pitchBend
    case controls
    case afterTouch
    case programChange
    case clock
    
    public var identifier: String {
        switch self {
        case .notes:
            return "notes"
        case .pitchBend:
            return "pitchBend"
        case .controls:
            return "controls"
        case .afterTouch:
            return "afterTouch"
        case .programChange:
            return "programChange"
        case .clock:
            return "clock"
        }
    }
    
    public init(with identifier: String) {
        switch identifier {
        case "notes":
            self = .notes
        case "pitchBend":
            self = .pitchBend
        case "controls":
            self = .controls
        case "afterTouch":
            self = .afterTouch
        case "programChange":
            self = .programChange
        case "clock":
            self = .clock
        default:
            self = .notes
        }
    }
    
    static var allStrings: [String] { return MidiEventTypeMaskSelector.allCases.map { $0.description }}
    
    public var mask: MidiEventTypeMask {
        switch self {
        case .notes:
            return .note
        case .pitchBend:
            return .pitchBend
        case .controls:
            return .control
        case .afterTouch:
            return .afterTouch
        case .programChange:
            return .programChange
        case .clock:
            return .realTimeMessage
        }
    }
    
}

extension MidiEventTypeMaskSelector: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notes:
            return "Notes"
        case .pitchBend:
            return "Pitch Bend"
        case .controls:
            return "Controls"
        case .afterTouch:
            return "Aftertouch"
        case .programChange:
            return "Program Change"
        case .clock:
            return "Clock"
        }
    }
}
