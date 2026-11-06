# SDL3 supplies the UIKit entry point through SDL_main.h.
set_target_properties(max PROPERTIES
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_INFO_PLIST "${PROJECT_SOURCE_DIR}/platform/ios/Info.plist.in"
    MACOSX_BUNDLE_GUI_IDENTIFIER "org.maxport.ios"
    MACOSX_BUNDLE_BUNDLE_NAME "M.A.X. Port"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "${GAME_VERSION_MAJOR}.${GAME_VERSION_MINOR}.${GAME_VERSION_PATCH}"
    MACOSX_BUNDLE_BUNDLE_VERSION "1"
    XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1"
    XCODE_ATTRIBUTE_SUPPORTS_MACCATALYST NO
    XCODE_ATTRIBUTE_ENABLE_BITCODE NO
)
# Only port-owned configuration assets. Never add MAX.RES or original game data.
set(ios_resources LICENSE PATCHES.RES settings.json language.json maxint.json help.json)
foreach(resource IN LISTS ios_resources)
    set(path "${PROJECT_SOURCE_DIR}/assets/${resource}")
    target_sources(max PRIVATE "${path}")
    set_source_files_properties("${path}" PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
endforeach()
target_link_libraries(max PRIVATE "-framework AudioToolbox" "-framework AVFoundation" "-framework CoreAudio")

# Xcode/CMake may use Debug/ rather than Debug-iphoneos/. Export the actual
# generator-resolved product paths instead of guessing them in CI.
file(GENERATE OUTPUT "${CMAKE_BINARY_DIR}/ios-bundle-$<CONFIG>.txt"
    CONTENT "$<TARGET_BUNDLE_DIR:max>\n")
file(GENERATE OUTPUT "${CMAKE_BINARY_DIR}/ios-executable-$<CONFIG>.txt"
    CONTENT "$<TARGET_FILE:max>\n")
