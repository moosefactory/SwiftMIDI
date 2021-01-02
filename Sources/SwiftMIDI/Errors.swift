//
//  SwiftMIDI+Errors.swift
//  MidiCenter
//
//  Created by Tristan Leblanc on 30/12/2020.
//

import Foundation
import CoreMIDI

public extension SwiftMIDI {
    
    enum Errors: Error, CustomStringConvertible {
        
        /// SwiftMIDIErrors
        case sourceIndexOutOfRange
        case destinationIndexOutOfRange

        /// To use when checking MIDIObjectRef before use it in core midi
        case sourceRefNotSet
        case inputPortRefNotSet

        public var description: String {
            let prefix = "CoreMidi Error - "

            switch self {
            case .sourceIndexOutOfRange:
                return "\(prefix)Source Index Out Of Range"
            case .destinationIndexOutOfRange:
                return "\(prefix)Destination Index Out Of Range"
            case .sourceRefNotSet:
                return "\(prefix)Source Ref not set"
            case .inputPortRefNotSet:
                return "\(prefix)Input Port Ref not set"
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
