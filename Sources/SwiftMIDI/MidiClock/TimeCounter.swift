
//   /\/\__/\/\      MFFoundation
//   \/\/..\/\/      Swift Framework - v2.0
//      (oo)
//  MooseFactory     ©2007-2026 - Moose
//    Software
//  ------------------------------------------
//  􀈿 TimeCounter.swift
//  􀐚 SwiftMIDI
//  􀓣 Created by Tristan Leblanc on 17/05/2026.

public class TimeCounter {
    
    public struct Signal: OptionSet {
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        public let rawValue: UInt8
    
        public static let CLOCK_SIGNAL_MIDI = Signal(rawValue: 1<<1)
        public static let CLOCK_SIGNAL_STEP = Signal(rawValue: 1<<2)
        public static let CLOCK_SIGNAL_BEAT = Signal(rawValue: 1<<3)
        public static let CLOCK_SIGNAL_BAR = Signal(rawValue: 1<<4)
    
        public static let CLOCK_SIGNAL_FRAME = Signal(rawValue: 1<<5)
        public static let CLOCK_SIGNAL_LAST_BAR_BEAT = Signal(rawValue: 1<<6)
        public static let CLOCK_SIGNAL_HALF_BEAT = Signal(rawValue: 1<<7)
        public static let CLOCK_SIGNAL_SEQUENCER_STOP = Signal(rawValue: 1<<8)
        
        public var string: String {
            [
                contains(.CLOCK_SIGNAL_BAR) ? "•" : ".",
                contains(.CLOCK_SIGNAL_BEAT) ? "•" : ".",
                contains(.CLOCK_SIGNAL_STEP) ? "•" : ".",
                contains(.CLOCK_SIGNAL_MIDI) ? "•" : "."
            ].joined(separator: "")
        }
    }
    
    public struct TimeDivision {
        
        public static let standardMidiTicksPerQuarterNote: UInt8 = 24
        
        public init(division: UInt8 = 4,
                      subDivision: UInt8 = 4,
                      ticksPerMidiTick: UInt64) {
            self.division = division
            self.subDivision = subDivision
            self.midiTicksPerStep = TimeDivision.standardMidiTicksPerQuarterNote / subDivision
            self.ticksPerMidiTick = 32
        }
        
        public let division: UInt8
        public let subDivision: UInt8
        public let midiTicksPerStep: UInt8
        public let ticksPerMidiTick: UInt64
    }
    
    public var string: String { "\(bar):\(beat):\(step)" }
    public var stringWithMidiTick: String { "\(bar):\(beat):\(step):\(midiTick)" }

        
    public var timeDivision: TimeDivision
    
    func reset() {
        tick = 0
        midiTick = 0
        step = 0
        beat = 0
        bar = 0
    }
    
    public init(tick: UInt64 = 0, timeDivision: TimeDivision = TimeDivision(ticksPerMidiTick: 32)) {
        self.tick = tick
        self.timeDivision = timeDivision
        let midiTicks: UInt64 = UInt64(tick / UInt64(timeDivision.ticksPerMidiTick))
        
        midiTick = UInt8(midiTicks % UInt64(timeDivision.midiTicksPerStep))
        if midiTick == 0 {
            signal.insert(.CLOCK_SIGNAL_MIDI)
        }
        
        let steps = UInt64(midiTicks / UInt64(timeDivision.midiTicksPerStep))
        step = UInt8(steps % UInt64(timeDivision.subDivision))
        if step == 0 {
            signal.insert(.CLOCK_SIGNAL_STEP)
        }
        
        let beats = UInt64(steps / UInt64(timeDivision.subDivision))
        beat = UInt8(beats % UInt64(timeDivision.division))
        if beat == 0 {
            signal.insert(.CLOCK_SIGNAL_BEAT)
        }
        
        bar = UInt32(beats / UInt64(timeDivision.division))
    }
    
    func increment() {
        tick += 1
        signal = Signal()
        if tick % timeDivision.ticksPerMidiTick == 0 {
            signal.insert(.CLOCK_SIGNAL_MIDI)
            midiTick += 1
            if midiTick % timeDivision.midiTicksPerStep == 0 {
                midiTick = 0
                step += 1
                signal.insert(.CLOCK_SIGNAL_STEP)
                if step % timeDivision.subDivision == 0 {
                    step = 0
                    beat += 1
                    signal.insert(.CLOCK_SIGNAL_BEAT)
                    if beat % timeDivision.division == 0 {
                        beat = 0
                        bar += 1
                        signal.insert(.CLOCK_SIGNAL_BAR)
                    }
                }
            }
        }
    }

    /// Total number of elapsed since loop start ( controlled by client )
    public private(set) var tick: UInt64 = 0
    
    // MARK: - Midi Counter
    
    /// Midi ticks in beat - set to 24 ticks per quarter note ( beat)
    public private(set) var midiTick: UInt8 = 0

    /// Step in beat - in range [0..<'timeDivision.subDivision']
    public private(set) var step: UInt8 = 0
    
    /// Beat ( Quarter Note ) - in range [0..<'timeDivision.division']
    public private(set) var beat: UInt8 = 0
    
    /// Bar ( Quarter Note ) - in range [0..<'timeDivision.division']
    public private(set) var bar: UInt32 = 0

    // MARK: - Frames
    
    public private(set) var fps24: Double = 0
    public private(set) var fps60: Double = 0

    // MARK: - Time
    
    /// Signal is a bit flag that can be used to quick test particular positions
    /// CLOCK_SIGNAL_MIDI : clock hits a midi tick
    /// CLOCK_SIGNAL_STEP : clock hits a step ( 'timeDivision.subDivision' steps per beat )
    /// CLOCK_SIGNAL_BEAT : clock hits a beat ( quarter note )
    /// CLOCK_SIGNAL_BAR : clock hits a bar ( 'timeDivision.division' beats )
    public private(set) var signal = Signal()
    
}

extension TimeCounter: CustomStringConvertible {
    public var description: String {
        string
    }
}
