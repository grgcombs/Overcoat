XC_WORKSPACE=Overcoat.xcworkspace
XC_PROJ=Overcoat.xcodeproj
XC_DERIVED_DATA_PATH=./Builds

OSX_TEST_SCHEME_FLAGS:=-workspace $(XC_WORKSPACE) -scheme Overcoat-OSX -derivedDataPath $(XC_DERIVED_DATA_PATH) -sdk macosx
IOS_TEST_SCHEME_FLAGS:=-workspace $(XC_WORKSPACE) -scheme Overcoat-iOS -derivedDataPath $(XC_DERIVED_DATA_PATH) -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 7 Plus,OS=10.0'
TVOS_TEST_SCHEME_FLAGS:=-workspace $(XC_WORKSPACE) -scheme Overcoat-tvOS -derivedDataPath $(XC_DERIVED_DATA_PATH) -sdk appletvsimulator -destination 'platform=tvOS Simulator,name=Apple TV 1080p,OS=10.0'

CARTHAGE_PLATFORMS_NO_TVOS=Mac,iOS
CARTHAGE_PLATFORMS_ALL=Mac,iOS,tvOS
CARTHAGE_PLATFORM_FLAGS:=--platform $(CARTHAGE_PLATFORMS_NO_TVOS)
CARTHAGE_PLATFORM_ALL_FLAGS:=--platform $(CARTHAGE_PLATFORMS_ALL)
CARTHAGE_TOOLCHAIN_FLAGS:=--toolchain com.apple.dt.toolchain.Swift_2_3
CARTHAGE_DERIVED_DATA_FLAGS:=--derived-data $(XC_DERIVED_DATA_PATH)

POD_TRUNK_PUSH_FLAGS=--verbose

test: install-carthage clean run-tests

test-osx: install-carthage clean run-tests-osx

test-ios: install-carthage clean run-tests-ios

test-tvos: install-carthage-tvos clean run-tests-tvos

# Build Tests

clean:
	xcodebuild -project $(XC_PROJ) -alltargets clean

install-pod:
	COCOAPODS_DISABLE_DETERMINISTIC_UUIDS=YES pod install

install-carthage: 
	carthage update $(CARTHAGE_PLATFORM_FLAGS) --no-build
	carthage build --no-skip-current $(CARTHAGE_PLATFORM_FLAGS) $(CARTHAGE_TOOLCHAIN_FLAGS) $(CARTHAGE_DERIVED_DATA_FLAGS)

install-carthage-tvos: 
	carthage update $(CARTHAGE_PLATFORM_ALL_FLAGS) --no-build
	carthage build --no-skip-current $(CARTHAGE_PLATFORM_ALL_FLAGS) $(CARTHAGE_TOOLCHAIN_FLAGS) $(CARTHAGE_DERIVED_DATA_FLAGS)

# Run Tests

run-tests-osx:
	xcrun xcodebuild test $(OSX_TEST_SCHEME_FLAGS)

run-tests-ios:
	xcrun xcodebuild test $(IOS_TEST_SCHEME_FLAGS)

run-tests-tvos:
	xcrun xcodebuild test $(TVOS_TEST_SCHEME_FLAGS)

# Intetfaces

run-tests: run-tests-osx run-tests-ios run-tests-tvos

# Distribution

test-carthage:
	rm -rf Pods/
	carthage update $(CARTHAGE_PLATFORM_FLAGS) --no-build
	carthage build --no-skip-current $(CARTHAGE_PLATFORM_FLAGS) $(CARTHAGE_TOOLCHAIN_FLAGS) $(CARTHAGE_DERIVED_DATA_FLAGS) --verbose 

test-pod:
	pod spec lint ./*.podspec --verbose --allow-warnings --no-clean --fail-fast

distribute-pod: test
	pod trunk push Overcoat.podspec $(POD_TRUNK_PUSH_FLAGS)
	pod trunk push Overcoat+CoreData.podspec --allow-warnings $(POD_TRUNK_PUSH_FLAGS)
	pod trunk push Overcoat+ReactiveCocoa.podspec $(POD_TRUNK_PUSH_FLAGS)
	pod trunk push Overcoat+Social.podspec $(POD_TRUNK_PUSH_FLAGS)

distribute-carthage: test
