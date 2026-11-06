# Native iPhone foundation (phase 1)

Work takes place on `ios-port`. The existing C/C++ engine and AI sources are
compiled into the native target; there is no DOSBox, emulator or streaming.
The iOS entry point currently displays a small SDL3 status screen. It does
**not** start a playable game. No gameplay or AI rules are changed.

## Build on a Mac

Requirements: Xcode with its iPhone SDK, its command-line tools selected, and
CMake 3.28 or newer. The target is a real iPhone ARM64 binary, minimum iOS 15.
From the checkout on `ios-port`:

```sh
cmake --preset ios-arm64
cmake --build --preset ios-arm64 --parallel 3
```

The output is `build/ios-arm64/Debug-iphoneos/max-port.app`. It is deliberately
unsigned. This verifies compilation/linking without a certificate or paid
Apple developer membership. It cannot be installed directly on an iPhone.
For a device run, open the generated Xcode project on a Mac and select your own
unique bundle identifier and signing team, enabling signing locally. A personal
Apple ID can be used for limited local device testing under Apple's current
rules. Store submission and distribution are outside this phase.

The toolchain uses Apple's SDK/Clang and static third-party libraries, not
GNU's full static executable link flags. SDL3 supplies the native UIKit entry
point. The desktop libbacktrace crash handler is replaced by a small adapter
which leaves Apple's native crash reporting active. UPnP is off by default on
iOS. Unit tests remain host tests and are not run as unsigned device programs.
Linux defaults are preserved.

## GitHub Actions: instructions for the repository owner

Nothing has been pushed and no GitHub workflow has been started by the assistant.
The workflow file is `.github/workflows/ios.yml`, using the standard `macos-15-intel` runner and Xcode 16.4 (iOS 18.5 SDK).
The Intel host cross-compiles for `iphoneos` ARM64; the app is not an Intel
binary or a simulator build. This label uses a different runner pool from
`macos-15`, but runner availability and shorter queue times are not guaranteed.
No paid service, signing secret or deployment is configured.

When you explicitly decide to upload the changes:

1. Upload **only the `ios-port` branch**, not changes directly to `master`.
   If you want the assistant to do this, explicitly authorize a commit/push
   and creation of a draft pull request.
2. On GitHub create a **draft pull request** with base `master` and compare
   `ios-port`. Do not merge it. This starts the workflow while keeping master
   unchanged. The title can be “iOS phase 1: native ARM64 foundation”.
3. Open its **Checks** tab, then “iOS ARM64 foundation”. A green check means
   the Mac runner compiled the app and checked its plist and ARM64 executable.
   It does not establish that gameplay works on a physical device.
4. The run's **Artifacts** section contains the unsigned development bundle.
   This is a test build, not an App Store release or an installable signed IPA.

The workflow also declares manual dispatch. GitHub normally only exposes
“Run workflow” once the workflow exists on the repository's default branch;
the draft-PR route above avoids requiring a merge just to test this branch.
Use only the included Actions allowance; check the account's current quota
before running, and do not enable paid usage to complete this phase.

## Original game data and future import

No original MAX.RES, maps, music or videos are added to this branch or workflow.
Only the existing port-owned configuration/patch assets enter the app bundle.
The bundle is read-only. A future native document-picker importer must copy
user-selected licensed game data into the app's writable sandbox, validate it
using the existing game-data validation, and store a sandbox-relative location.
Settings, saves and imported data must stay outside the bundle; no desktop
file paths or external folders may be assumed to remain accessible on iOS.

This phase deliberately does not enable file sharing, request broad file access,
implement import, or call the desktop folder-picker/game startup. Files are not
downloaded from an unofficial game-data source. The status screen works without
game data. The desktop resource-manager paths need iOS-specific integration
before the engine can be launched on the phone.

## Validation and remaining work

The first Xcode 16.4 / iPhoneOS 18.5 attempt reached compilation but exited
with code 65 and Objective-C declarations (`@class` / `@protocol`) being parsed
as C. The miniaudio implementation includes AVFoundation on iOS, so its
`miniaudio.c` is now explicitly compiled as Objective-C in the dependency's own
CMake directory. Objective-C is enabled before dependency configuration; normal
header consumers and Linux keep their original languages. The dependency also
declares its required Apple frameworks explicitly. Xcode validation of this
correction is pending; the earlier host checks do not prove an iOS build.

Validation in the Linux cloud task after these changes: native Debug configure
and build succeeded; all 48 existing unit tests passed (0 failed). The two iOS
C++ files passed host syntax checks against SDL3 headers. Preset JSON, landscape
plist and workflow YAML parsed successfully, and `git diff --check` passed.
No Xcode/iOS SDK is available here, so no real iOS build or device run has been
performed. The Actions workflow has not been uploaded or executed.

Linux configure/build and the existing 48 unit tests are the regression check.
The bootstrap and crash adapter can additionally be syntax-checked against the
existing SDL3 headers on Linux. These checks cannot verify Apple's UIKit,
framework linking, code signing, device lifecycle or the actual iOS bundle.
Only a successful Xcode build can establish the ARM64 build foundation.

After the first Mac build: address any SDK-specific compiler/linker failures,
verify the shell on a device, add sandbox resource paths and explicit user data
import, then integrate game startup and touch controls. Existing computer AI is
preserved but is not yet demonstrated running on an iPhone. App icons, store
privacy review and distribution packaging are later work.
