#
# Be sure to run `pod lib lint MoofFoundation.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
	s.name             = "SwiftMIDI"
	s.version          = "1.0.2"
	s.summary          = "SwiftMIDI is a cross-platform (iOS/MacOS) Utility Library that adds Swift layer over CoreMidi."
	s.description      = <<-DESC
					    SwiftMIDI is a cross-platform (iOS/MacOS) Utility Library that adds Swift layer over CoreMidi.
					It adds convenient functions to CoreMidi c-style functions, and few utilities.
					   DESC
	s.homepage         = "https://github.com/MooseFactory/SwiftMIDI"
	s.license          = 'MIT'
	s.author           = { "Tristan Leblanc" => "tristan@moosefactory.eu" }
	s.source           = { :git => "https://github.com/moosefactory/SwiftMIDI.git", :tag => s.version.to_s }
	s.social_media_url = 'https://twitter.com/moosefactory_eu'

	s.ios.deployment_target = '13.3'
    s.osx.deployment_target = '10.15'
    s.tvos.deployment_target = '14.0'
    s.watchos.deployment_target = '7.0'
                                                        
	s.requires_arc = true

	s.source_files = 'SwiftMIDI/SwiftMIDI.h', 'Sources/**/*.*'
end
