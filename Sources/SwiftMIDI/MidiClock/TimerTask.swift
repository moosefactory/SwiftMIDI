
//   /\/\__/\/\      MFFoundation
//   \/\/..\/\/      Swift Framework - v2.0
//      (oo)
//  MooseFactory     ©2007-2026 - Moose
//    Software
//  ------------------------------------------
//  􀈿 TimerTask.swift
//  􀐚 SwiftMIDI
//  􀓣 Created by Tristan Leblanc on 17/05/2026.

import Foundation

/// A periodic task that runs in a thread and waits for a given interval

public class TimerTask {
    
    /// Timer Status
    public struct Status: OptionSet {
        public let rawValue: UInt8
        
        static let running = Status(rawValue: 1 << 0)
        static let paused = Status(rawValue: 1 << 1)

        static let limitExceeded = Status(rawValue: 1 << 4)
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
    
    /// The structure that is sent to the timerBlock on each tick
    public struct TimerBlockParam: Sendable {
        public private(set) var hostTime: UInt64
        public private(set) var time: UInt64
        public private(set) var tickTime: UInt64
        public private(set) var tick: UInt32
        public private(set) var droppedFrames: UInt32
        public private(set) var drift: Int64
        public private(set) var driftFactor: Double

        public init(hostTime: UInt64 = 0,
                    startTime: UInt64 = 0,
                    tickTime: UInt64 = 0,
                    tick: UInt32 = 0,
                    droppedFrames: UInt32 = 0,
                    intervalInNanoseconds: Int64) {
            self.hostTime = hostTime
            self.time = hostTime - startTime
            self.tickTime = tickTime
            self.tick = tick
            self.droppedFrames = droppedFrames
            self.drift = Int64(Int64(time) - Int64(tickTime))
            self.driftFactor = Double(drift) / Double(intervalInNanoseconds)
        }
    }
    
    public private(set) var status = Status()
    
    /// The host time ( timestamp )
    var hostTime: UInt64 = mach_absolute_time()
    
    /// The number of elapsed ticks since start
    private var tick: UInt32 = 0
    
    /// The current tick theorical time ( tick x interval )
    private var tickTime: UInt64 = 0
    
    /// The timer the timer did start
    private var startTime: UInt64 = 0
    
    /// The number of dropped frames
    /// Some ticks may be skipped if the interval is too short to be satisfied
    private var dropFrames: UInt32 = 0
    
    /// The tick length in nanoseconds
    private var intervalInNanoseconds: UInt64
    
    /// The block to call at each frame - block is called on the clock queue
    private var block: ((TimerBlockParam) -> Void) = { _ in }
    
    /// The dispatch queue that we be used by the clock task
    private lazy var queue = DispatchQueue(label: "com.moosefactory.timertask",
                                           qos: .userInteractive,
                                           attributes: .concurrent,
                                           autoreleaseFrequency: .never,
                                           target: nil)
    
    // Core Swing
    
    /// Enables the core swing features
    public var enableCoreSwing: Bool = true
    
    /// The swings array.
    /// Offsets are stored for a complete loop ( 32 ticks x 24 miditicks x 4 beats )
    public var swings: [Double] = [] // an array of values [-1.0..1.0] -> +/-100% swing
    
    // Status accessors
    
    public private(set) var running: Bool {
        get { status.contains(.running) }
        set {
            if newValue { status.insert(.running) }
            else { status.remove(.running) }
        }
    }

    // MARK: - Life Cycle
    
    // Initialise a timer with a given interval ( nanoseconds per tick )
    public init(nanoseconds interval: UInt64,
                block: @escaping (TimerBlockParam) -> Void = { _ in }) {
        self.intervalInNanoseconds = interval
        self.block = block
    }
    
    func setInterval(_ interval: UInt64) {
        targetInterval = interval
    }
    
    var targetInterval: UInt64 = 0
    
    deinit {
        cancel()
    }
    
    // MARK: - Start
    
    public func start() -> TimerTask {
        var dt: Double = 0
        queue.async { [weak self] in
            guard let s = self else { return }
            s.reset()
            // Set the right time increment function
            let incFunction = s.enableCoreSwing && !s.swings.isEmpty
            ? { s.tickTime += UInt64(Double(s.intervalInNanoseconds) * s.swings[Int(s.tick) % (s.swings.count)]) }
            : { s.tickTime += s.intervalInNanoseconds }
            
            s.running = true

            while s.running {
                if s.targetInterval > 0 {
                    s.intervalInNanoseconds = s.targetInterval
                    s.targetInterval = 0
                }
                s.hostTime = mach_absolute_time()
                
                if s.startTime == 0 {
                    s.startTime = s.hostTime
                }
                
                // Capture current state and calls the block
                s.block(TimerBlockParam(hostTime: s.hostTime,
                                        startTime: s.startTime,
                                        tickTime: s.tickTime,
                                        tick: s.tick,
                                        droppedFrames: s.dropFrames,
                                        intervalInNanoseconds: Int64(s.intervalInNanoseconds)))
                
                // Compute next tick index and ideal time
                s.tick += 1
                
                incFunction()
                // dt = (dt == 0 ? Double(param.drift) : dt) * 0.995 + Double(param.drift) * 0.005
                //s.dropFrames = 0
                
                // Go to the next frame
                var absTickTime = s.tickTime + s.startTime
                
                                while mach_absolute_time() > absTickTime  {
                                    s.dropFrames += 1
                                    absTickTime += s.intervalInNanoseconds
                                }
                
                mach_wait_until(
                    UInt64( Int64(absTickTime) /*- Int64(dt)*/ )
                )
            }
        }
        return self
    }
    
    public func makeParameterBlock() -> TimerBlockParam {
        TimerBlockParam(hostTime: hostTime,
                        startTime: startTime,
                        tickTime: tickTime,
                        tick: tick,
                        droppedFrames: dropFrames, intervalInNanoseconds: Int64(intervalInNanoseconds))
    }
    
    // MARK: - Control
    
    public func resume() {
        running=true
    }
    
    public func pause() {
        running=false
    }
    
    public func stop() {
        running=false
        reset()
    }
    
    public func reset() {
        tick = 0
        tickTime = 0
        startTime = 0
        dropFrames = 0
        hostTime = mach_absolute_time()
    }
    
    public func cancel() {
        running=false
    }
    
    public func invalidate() {
        cancel()
    }
}
