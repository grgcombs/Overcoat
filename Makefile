XC_WORKSPACE=Overcoat.xcworkspace
XCODE_PROJ=Overcoat.xcodeproj

OSX_TEST_SCHEME_FLAGS:=-workspace $(XC_WORKSPACE) -scheme Overcoat-OSX -sdk macosx
IOS_TEST_SCHEME_FLAGS:=-workspace $(XC_WORKSPACE) -scheme Overcoat-iOS -sdk iphonesimulator
TVOS_TEST_SCHEME_FLAGS:=-workspace $(XC_WORKSPACE) -scheme Overcoat-tvOS -sdk appletvsimulator

CARTHAGE_PLATFORMS=Mac,iOS
CARTHAGE_PLATFORM_FLAGS:=--platform $(CARTHAGE_PLATFORMS)
CARTHAGE_TOOLCHAIN_FLAGS=--toolchain com.apple.dt.toolchain.Swift_2_3
CARTHAGE_DERIVED_DATA_FLAGS=--derived-data ./Builds

POD_TRUNK_PUSH_FLAGS=--verbose

test: install-carthage clean build-tests run-tests

test-osx: install-carthage clean build-tests-osx run-tests-osx

test-ios: install-carthage clean build-tests-ios run-tests-ios

test-tvos: install-carthage clean build-tests-tvos run-tests-tvos

# Build Tests

clean:
	xcodebuild -project $(XCODE_PROJ) -alltargets clean

install-pod:
	COCOAPODS_DISABLE_DETERMINISTIC_UUIDS=YES pod install

install-carthage: 
	carthage update $(CARTHAGE_PLATFORM_FLAGS) --no-build
	carthage build --no-skip-current $(CARTHAGE_PLATFORM_FLAGS) --verbose $(CARTHAGE_TOOLCHAIN_FLAGS) $(CARTHAGE_DERIVED_DATA_FLAGS)

build-tests-osx:
	xcodebuild $(OSX_TEST_SCHEME_FLAGS) build

build-tests-ios:
	xcodebuild $(IOS_TEST_SCHEME_FLAGS) build

build-tests-tvos:
	xcodebuild $(TVOS_TEST_SCHEME_FLAGS) build

# Run Tests

run-tests-osx:
	xcodebuild $(OSX_TEST_SCHEME_FLAGS) test

run-tests-ios:
	xcodebuild $(IOS_TEST_SCHEME_FLAGS) test

run-tests-tvos:
	xcodebuild $(TVOS_TEST_SCHEME_FLAGS) test

# Intetfaces

build-tests: build-tests-osx build-tests-ios build-tests-tvos

run-tests: run-tests-osx run-tests-ios run-tests-tvos

# Distribution

test-carthage:
	rm -rf Pods/
	carthage update $(CARTHAGE_PLATFORM_FLAGS) --no-build
	carthage build --no-skip-current $(CARTHAGE_PLATFORM_FLAGS) --verbose $(CARTHAGE_TOOLCHAIN_FLAGS) $(CARTHAGE_DERIVED_DATA_FLAGS)

test-pod:
	pod spec lint ./*.podspec --verbose --allow-warnings --no-clean --fail-fast

distribute-pod: test
	pod trunk push Overcoat.podspec $(POD_TRUNK_PUSH_FLAGS)
	pod trunk push Overcoat+CoreData.podspec --allow-warnings $(POD_TRUNK_PUSH_FLAGS)
	pod trunk push Overcoat+ReactiveCocoa.podspec $(POD_TRUNK_PUSH_FLAGS)
	pod trunk push Overcoat+Social.podspec $(POD_TRUNK_PUSH_FLAGS)

distribute-carthage: test
