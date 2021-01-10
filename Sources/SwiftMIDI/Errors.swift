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

//  SwiftMIDI+Errors.swift
//
//  CoreMIDI Swift Wrapper
//
//  Created by Tristan Leblanc on 30/12/2020.
//

import Foundation
import CoreMIDI

public extension SwiftMIDI {
    
    enum Errors: Error, CustomStringConvertible {
        
        /// SwiftMIDIErrors
        case noSourceInSystem
        case sourceIndexOutOfRange
        
        case noDestinationInSystem
        case destinationIndexOutOfRange
        
        case noEntityInSystem
        case entityIndexOutOfRange
        
        case noDeviceInSystem
        case noExternalDeviceInSystem
        case deviceIndexOutOfRange
        case externalDeviceIndexOutOfRange


        /// To use when checking MIDIObjectRef before use it in core midi
        case sourceRefNotSet
        case inputPortRefNotSet

        case cantAllocatePacketList
        
        public var description: String {
            let prefix = "CoreMidi Error - "

            switch self {
            case .noSourceInSystem:
                return "\(prefix)No Midi Source in System"
            case .sourceIndexOutOfRange:
                return "\(prefix)Source Index Out Of Range"

            case .noDestinationInSystem:
                return "\(prefix)No Midi Destination in System"
            case .destinationIndexOutOfRange:
                return "\(prefix)Destination Index Out Of Range"

            case .noEntityInSystem:
                return "\(prefix)No Midi Entity in System"
            case .entityIndexOutOfRange:
                return "\(prefix)Entity Index Out Of Range"

            case .noDeviceInSystem:
                return "\(prefix)No Midi Device in System"
            case .deviceIndexOutOfRange:
                return "\(prefix)Device Index Out Of Range"

            case .noExternalDeviceInSystem:
                return "\(prefix)No External Midi Device in System"
            case .externalDeviceIndexOutOfRange:
                return "\(prefix)External Device Index Out Of Range"


            case .sourceRefNotSet:
                return "\(prefix)Source Ref not set"
            case .inputPortRefNotSet:
                return "\(prefix)Input Port Ref not set"
            case .cantAllocatePacketList:
                return "\(prefix)Can't allocate packet list"
            }
        }
    }
    
    enum MidiError: Error, CustomStringConvertible {
        /// Not defined in CoreMidi documentation
        case unknown(err: OSStatus)
        
        /// CoreMidi errors
        case unknownMidiError
        case invalidClient
        case invalidPort
        case wrongEndpointType
        case noConnection
        case unknownEndpoint
        case unknownProperty
        case wrongPropertyType
        case noCurrentSetup
        case messageSendError
        case serverStartError
        case setupFormatError
        case wrongThread
        case objectNotFound
        case IDNotUnique
        case notPermitted
                
        init?(_ osStatus: OSStatus) {
            switch osStatus {
            case noErr:
                return nil
            case kMIDIUnknownError:
                self = .unknownMidiError
            case kMIDIInvalidClient:
                self = .invalidClient
            case kMIDIInvalidPort:
                self = .invalidPort
            case kMIDIWrongEndpointType:
                self = .wrongEndpointType
            case kMIDINoConnection:
                self = .noConnection
            case kMIDIUnknownEndpoint:
                self = .unknownEndpoint
            case kMIDIUnknownProperty:
                self = .unknownProperty
            case kMIDIWrongPropertyType:
                self = .wrongPropertyType
            case kMIDINoCurrentSetup:
                self = .noCurrentSetup
            case kMIDIMessageSendErr:
                self = .messageSendError
            case kMIDIServerStartErr:
                self = .serverStartError
            case kMIDISetupFormatErr:
                self = .setupFormatError
            case kMIDIWrongThread:
                self = .wrongThread
            case kMIDIObjectNotFound:
                self = .objectNotFound
            case kMIDIIDNotUnique:
                self = .IDNotUnique
            case kMIDINotPermitted:
                self = .notPermitted
            default:
                self = .unknown(err: osStatus)
            }
        }
        
        var osStatus: OSStatus {
            switch self {
            case .unknown(let err):
                return err
            case .unknownMidiError:
                return kMIDIUnknownError
            case .invalidClient:
                return kMIDIInvalidClient
            case .invalidPort:
                return kMIDIInvalidPort
            case .wrongEndpointType:
                return kMIDIWrongEndpointType
            case .noConnection:
                return kMIDINoConnection
            case .unknownEndpoint:
                return kMIDIUnknownEndpoint
            case .unknownProperty:
                return kMIDIUnknownProperty
            case .wrongPropertyType:
                return kMIDIWrongPropertyType
            case .noCurrentSetup:
                return kMIDINoCurrentSetup
            case .messageSendError:
                return kMIDIMessageSendErr
            case .serverStartError:
                return kMIDIServerStartErr
            case .setupFormatError:
                return kMIDISetupFormatErr
            case .wrongThread:
                return kMIDIWrongThread
            case .objectNotFound:
                return kMIDIObjectNotFound
            case .IDNotUnique:
                return kMIDIIDNotUnique
            case .notPermitted:
                return kMIDINotPermitted
            }
        }
        
        public var description: String {
            let prefix = "CoreMidi Error \(osStatus) - "
            switch self {
            case .unknown:
                return "\(osStatus) - SwiftyMdi Unknown Error"
            case .unknownMidiError:
                return "\(prefix)Unknown Error"
            case .invalidClient:
                return "\(prefix)Invalid Client"
            case .invalidPort:
                return "\(prefix)Invalid Port"
            case .wrongEndpointType:
                return "\(prefix)Wrong Endpoint Type"
            case .noConnection:
                return "\(prefix)No Connection"
            case .unknownEndpoint:
                return "\(prefix)Unknown Endpoint"
            case .unknownProperty:
                return "\(prefix)Unknown Property"
            case .wrongPropertyType:
                return "\(prefix)Wrong Property Type"
            case .noCurrentSetup:
                return "\(prefix)No Current Setup"
            case .messageSendError:
                return "\(prefix)Message Send Err"
            case .serverStartError:
                return "\(prefix)Server Start Err"
            case .setupFormatError:
                return "\(prefix)Setup Format Err"
            case .wrongThread:
                return "\(prefix)Wrong Thread"
            case .objectNotFound:
                return "\(prefix)Object Not Found"
            case .IDNotUnique:
                return "\(prefix)ID Not Unique"
            case .notPermitted:
                return "\(prefix)Not Permitted"
            }
        }
    }
}
