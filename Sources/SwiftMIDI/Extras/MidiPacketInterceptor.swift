//
//  MidiPacketsConverter.swift
//  MidiCenter
//
//  Created by Tristan Leblanc on 28/12/2020.
//

import Foundation
import CoreMIDI

/// MidiPacket Conversion/Transformation Object

public class MidiPacketInterceptor {
    
    var queue = DispatchQueue(label: "com.moosefactory.midicenter.packets", qos: .userInteractive, attributes: [], autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
    
    public static func unpackEvents(_ packetList: UnsafePointer<MIDIPacketList>, completion: ([MidiEvent])->Void) {
        var out = [MidiEvent]()
        let numPackets = packetList.pointee.numPackets
        var p = packetList.pointee.packet
        
        for _ in 0 ..< numPackets {
            if let type = MidiEventType(rawValue: (p.data.0 & 0xF0)) {
                let event = MidiEvent(type: type,
                                      timestamp: p.timeStamp,
                                      channel: (p.data.0 & 0x0F),
                                      value1: p.data.1,
                                      value2: p.data.2)
                out.append(event)
            }
            p = MIDIPacketNext(&p).pointee
        }
        completion(out)
    }
}
