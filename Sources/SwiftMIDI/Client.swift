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

//  Client.swift
//
//  CoreMIDI Swift wrapper
//
//  Created by Tristan Leblanc on 30/12/2020.

import Foundation
import CoreMIDI

public extension SwiftMIDI {
    
    /// createClient
    /// Creates a MIDIClient object.
    ///
    /// - parameter name
    /// The client's name.
    /// - parameter outClient
    /// On successful return, points to the newly-created MIDIClientRef.
    /// - parameter notifyBlock
    /// An optional (may be NULL) block via which the client
    /// will receive notifications of changes to the system.
    ///
    /// Note that notifyBlock is called on a thread chosen by the implementation.
    /// Thread-safety is the block's responsibility.
    
    @available(macOS 10.11, *)
    static func createClient(name: String, with block: @escaping MIDINotifyBlock) throws -> MIDIClientRef {
        /// The CoreMIDI client ref
        var clientRef: MIDIClientRef = 0
        
        try coreMidi {
            MIDIClientCreateWithBlock(name as CFString, &clientRef, block)
        }
        return clientRef
    }    
}
