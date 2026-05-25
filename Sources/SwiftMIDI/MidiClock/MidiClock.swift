
//   /\/\__/\/\      MFFoundation
//   \/\/..\/\/      Swift Framework - v2.0
//      (oo)
//  MooseFactory     ©2007-2026 - Moose
//    Software
//  ------------------------------------------
//  􀈿 MidiClock.swift
//  􀐚 SwiftMIDI
//  􀓣 Created by Tristan Leblanc on 17/05/2026.

import Foundation

/// Midi Clock
///
/// - bpm : Beats per Minute ( default = 120 )
/// - ticksPerMidiTick : Number of midi ticks subdivision
///
public class MidiClock: CustomStringConvertible {
    
    public typealias Function = ( TimerTask.TimerBlockParam, TimeCounter)->Void    
        
    public var tempo: Double = 120.0 { didSet {
        beat = Beat(bpm: tempo, ticksPerMidiTick: ticksPerMidiTick)
    }}
    
    public var ticksPerMidiTick: Double = 32.0 { didSet {
        counter.timeDivision = makeTimeDivision()
        beat = Beat(bpm: tempo, ticksPerMidiTick: ticksPerMidiTick)
    }}
    
    public private(set) var beat = Beat() { didSet {
        timer.setInterval(beat.nanosecondsPerTick_UInt64)
    }}
        
    var block: Function
    
    public lazy var timer: TimerTask = {
        TimerTask(nanoseconds: beat.nanosecondsPerTick_UInt64,
                          block: { [weak self] timerBlockParam in
            guard let s = self else { return }
            s.counter.increment()
            s.block(timerBlockParam, s.counter)
        })
    }()
                
    public lazy var counter = TimeCounter(timeDivision: timeDivision)
    
    var timeDivision: TimeCounter.TimeDivision
    
    // MARK: - Initialization
    
    public init(tempo: Double = 120.0, ticksPerMidiTick: Double = 32.0, block: @escaping Function) {
        self.tempo = tempo
        self.ticksPerMidiTick = ticksPerMidiTick
        self.block = block
        self.timeDivision = TimeCounter.TimeDivision(division: 4,
                                                     subDivision: 4,
                                                     ticksPerMidiTick: UInt64(ticksPerMidiTick))
    }
    
    func makeTimeDivision() -> TimeCounter.TimeDivision {
        TimeCounter.TimeDivision(division: 4,
                                 subDivision: 4,
                                 ticksPerMidiTick: UInt64(ticksPerMidiTick))
    }
    // MARK: Control
    
    public func reset() {
        counter.reset()
    }
    
    public func setTempo(_ tempo: Double) {
        if self.tempo == tempo { return }
        self.tempo = tempo
    }
    
    public func start() {
            if timer.running {
                reset()
            } else {
                beat = Beat(bpm: tempo, ticksPerMidiTick: ticksPerMidiTick)
                timer.start()
            }
    }
    
    public func stop() {
        timer.stop()
    }
    
    public func pause() {
        timer.pause()
    }
    
    public var timerInfo: TimerTask.TimerBlockParam {
        timer.makeParameterBlock()
    }
    
    public var description: String {
        [
            "\(beat)"
        ].joined(separator: "\r")
    }
}
