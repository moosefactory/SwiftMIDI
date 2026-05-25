//   /\/\__/\/\      MFFoundation
//   \/\/..\/\/      Swift Framework - v2.0
//      (oo)
//  MooseFactory     ©2007-2026 - Moose
//    Software
//  ------------------------------------------
//  􀈿 Beat.swift
//  􀐚 SwiftMIDI
//  􀓣 Created by Tristan Leblanc on 24/05/2026.

import Foundation

/// A beat is a structure ( sendable ) created each time the tempo is changed.
///
/// It stores necessary constants to set up and run the timers
/// This saves few operations and conversions in the loop and offers convenient accesors to useful constants

public struct Beat: CustomStringConvertible, Sendable {
    
    static let numberOfMidiTicksPerBeat = 24
    static let numberOfMidiTicksPerBeat_d = 24.0
    
    static let nsPerS: Double = 1000000000
    static let nsPerS_u: UInt64 = 1000000000
    static let sPerM: Double = 60.0
    static let sPerM_u: UInt64 = 60

    /// Initialise a beat structure
    public init(bpm: Double = 120, ticksPerMidiTick: Double = 32) {
        self.bpm = bpm
        self.ticksPerMidiTick = ticksPerMidiTick
        
        nanosecondsPerBeat = Beat.sPerM * Beat.nsPerS / bpm
        nanosecondsPerMidiTick = nanosecondsPerBeat / Beat.numberOfMidiTicksPerBeat_d
        nanosecondsPerTick = nanosecondsPerMidiTick / ticksPerMidiTick
        nanosecondsPerTick_UInt64 = UInt64(nanosecondsPerTick)
    }
    
    /// The number of beats ( Quarter Notes ) per minute
    public let bpm: Double

    /// The timer subdivision, based on midi clock rate ( 24 midi ticks / beat )
    public let ticksPerMidiTick: Double
    
    /// The beat duration in nanoseconds
    public let nanosecondsPerBeat: Double
    
    /// The midi tick duration in nanoseconds
    public let nanosecondsPerMidiTick: Double
    
    /// The tick duration in nanoseconds - the quantum interval in the system.
    public let nanosecondsPerTick: Double
    
    /// The tick duration in nanoseconds expressed as UInt64 ( time stamp format ) - the quantum interval in the system.
    public let nanosecondsPerTick_UInt64: UInt64

    // MARK: - Utilities
    
    /// Computed secondsPerBeat
    public var secondsPerBeat: Double { Beat.sPerM / bpm }
    
    /// Computed secondsPerMidiTick
    public var secondsPerMidiTick: Double { secondsPerBeat / Beat.numberOfMidiTicksPerBeat_d }
    
    /// Computed secondsPerTick
    public var secondsPerTick: Double { secondsPerMidiTick / secondsPerMidiTick }
    
    /// Returns text description ( CustomStringConvertible protocol )
    public var description: String {
        [
            "BPM\t\(bpm)",
            "Resolution\t\(Int(ticksPerMidiTick)) ( \(Int(ticksPerMidiTick)*24) ticks/QN )",
            "ms / beat\t\(Int(secondsPerBeat * 1000))",
            "ms / midiTick\t\(Double( Int(secondsPerMidiTick * 100000)) / 100.0)",
            "ms / tick\t\(Double( Int(secondsPerTick * 100000)) / 100.0)",
            "ns / beat\t\(UInt(nanosecondsPerBeat))",
            "ns / midiTick\t\(UInt(nanosecondsPerMidiTick))",
            "ns / tick\t\(nanosecondsPerTick_UInt64)"
        ].joined(separator: "\r")
    }
}
