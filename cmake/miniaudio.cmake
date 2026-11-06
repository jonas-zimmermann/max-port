include(versions)
include(FetchContent)

if(EXISTS ${PROJECT_SOURCE_DIR}/dependencies/${MINIAUDIO_FILE})
	file(${MINIAUDIO_HASH_TYPE} ${PROJECT_SOURCE_DIR}/dependencies/${MINIAUDIO_FILE} MINIAUDIO_FILE_HASH)

	if(${MINIAUDIO_FILE_HASH} STREQUAL ${MINIAUDIO_HASH})
		set(MINIAUDIO_URI file://${PROJECT_SOURCE_DIR}/dependencies/${MINIAUDIO_FILE})
	endif()
endif()

find_package(Patch)

if(NOT Patch_FOUND)
	message(FATAL_ERROR "Patch tool is required.")
endif()

set(MINIAUDIO_PATCH ${Patch_EXECUTABLE} -p0 < ${CMAKE_CURRENT_SOURCE_DIR}/cmake/patches/miniaudio.patch)

FetchContent_Declare(
	MINIAUDIO
	TIMEOUT 60
	URL ${MINIAUDIO_URI}
	URL_HASH ${MINIAUDIO_HASH_TYPE}=${MINIAUDIO_HASH}
	DOWNLOAD_EXTRACT_TIMESTAMP FALSE
	OVERRIDE_FIND_PACKAGE
	PATCH_COMMAND ${MINIAUDIO_PATCH}
	UPDATE_DISCONNECTED TRUE
)

set(MINIAUDIO_NO_LIBVORBIS ON)
set(MINIAUDIO_NO_LIBOPUS ON)
set(MINIAUDIO_NO_ENCODING ON)
set(MINIAUDIO_NO_FLAC ON)
set(MINIAUDIO_NO_MP3 ON)
set(MINIAUDIO_NO_GENERATION ON)
set(MINIAUDIO_INSTALL OFF)

# Force Release build without debug info (treat as system library)
set(CMAKE_BUILD_TYPE_BACKUP ${CMAKE_BUILD_TYPE})
set(CMAKE_BUILD_TYPE Release)

FetchContent_MakeAvailable(MINIAUDIO)

if(MAX_IOS)
    # Only the implementation includes AVFoundation and uses @autoreleasepool /
    # AVAudioSession. Header consumers remain C/C++; do not change them globally.
    # Source properties must be set in the directory that owns this target.
    get_target_property(miniaudio_source_dir miniaudio SOURCE_DIR)
    set_source_files_properties("${miniaudio_source_dir}/miniaudio.c"
        DIRECTORY "${miniaudio_source_dir}"
        PROPERTIES LANGUAGE OBJC)
    target_link_libraries(miniaudio PRIVATE
        "-framework AVFoundation" "-framework AudioToolbox" "-framework CoreFoundation")
endif()

# Restore build configuration
set(CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE_BACKUP})

if(NOT TARGET Miniaudio::Miniaudio)
	add_library(Miniaudio::Miniaudio ALIAS miniaudio)
endif()
