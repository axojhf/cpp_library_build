include("${CMAKE_CURRENT_LIST_DIR}/skia-functions.cmake")

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://github.com/google/skia
    REF 661b4d60fcaa3ebbd6c2b00ce4bbe93b112f5211
    PATCHES
        disable-msvc-env-setup.patch
        uwp.patch
        core-opengl32.patch
#        0001-fix-win_sak-path.patch
)

# these following aren't available in vcpkg
# to update, visit the DEPS file in Skia's root directory
declare_external_from_git(abseil-cpp
    URL "https://skia.googlesource.com/external/github.com/abseil/abseil-cpp.git"
    REF "2a3fe1b580a19ec04ed892a96f4dfdb30a4479f6"
    LICENSE_FILE LICENSE
)
declare_external_from_git(d3d12allocator
    URL "https://skia.googlesource.com/external/github.com/GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator.git"
    REF "3d2f1b223ae9a31491b1cad111c0681cd6acd9f8"
    LICENSE_FILE LICENSE.txt
)
declare_external_from_git(dawn
    URL "https://dawn.googlesource.com/dawn.git"
    REF "d0797b07a5a6522ea38c4ffd896f51afb75fcd20"
    LICENSE_FILE LICENSE
)
declare_external_from_git(dng_sdk
    URL "https://android.googlesource.com/platform/external/dng_sdk.git"
    REF "121ebb9b8ea23c8e1770d0f46064d58d0d268ad4"
    LICENSE_FILE LICENSE
)
declare_external_from_git(jinja2
    URL "https://chromium.googlesource.com/chromium/src/third_party/jinja2"
    REF "264c07d7e64f2874434a3b8039e101ddf1b01e7e"
    LICENSE_FILE LICENSE.rst
)
declare_external_from_git(libgifcodec
    URL "https://skia.googlesource.com/libgifcodec"
    REF "f34bdbe66f0589af466b38e8b6f65acc5e30b3a1"
    LICENSE_FILE LICENSE.md
)
declare_external_from_git(markupsafe
    URL "https://chromium.googlesource.com/chromium/src/third_party/markupsafe"
    REF "13f4e8c9e206567eeb13bf585406ddc574005748"
    LICENSE_FILE LICENSE
)
declare_external_from_git(piex
    URL "https://android.googlesource.com/platform/external/piex.git"
    REF "98ecd898ea61034d9f88adf50c7d82fd3ade1b2b"
    LICENSE_FILE LICENSE
)
declare_external_from_git(sfntly
    URL "https://github.com/googlefonts/sfntly.git"
    REF "a56f5782f209771aa226063757d57e6b5c948478"
    LICENSE_FILE README.md
)
declare_external_from_git(spirv-cross
    URL "https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Cross"
    REF "89d4c2b205e28f94cb17e23ee032f799b8564f22"
    LICENSE_FILE LICENSE
)
declare_external_from_git(spirv-headers
    URL "https://skia.googlesource.com/external/github.com/KhronosGroup/SPIRV-Headers.git"
    REF "5cf26fb1a89c0eb3627db3a0c5b01426937830df"
    LICENSE_FILE LICENSE
)
declare_external_from_git(spirv-tools
    URL "https://skia.googlesource.com/external/github.com/KhronosGroup/SPIRV-Tools.git"
    REF "f62e121b0df5374d1f043d1fbda98467406af0b1"
    LICENSE_FILE LICENSE
)
declare_external_from_git(tint
    URL "https://dawn.googlesource.com/tint"
    REF "f29007b756894d77eb35c87eb4475f4d897bb8ac"
    LICENSE_FILE LICENSE
)
declare_external_from_git(vulkan-headers
    URL "https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Headers"
    REF "53d493208369b4d5a75c32f8a9232b245ef21da8"
    LICENSE_FILE LICENSE.txt
)
declare_external_from_git(vulkan-tools
    URL "https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Tools"
    REF "b1d824efe72605141ecc8ceb992f6d720997adb1"
    LICENSE_FILE LICENSE.txt
)

declare_external_from_pkgconfig(expat)
declare_external_from_pkgconfig(fontconfig PATH "third_party")
declare_external_from_pkgconfig(freetype2)
declare_external_from_pkgconfig(harfbuzz MODULES harfbuzz harfbuzz-subset)
declare_external_from_pkgconfig(icu MODULES icu-uc DEFINES "U_USING_ICU_NAMESPACE=0")
declare_external_from_pkgconfig(libjpeg PATH "third_party/libjpeg-turbo" MODULES libturbojpeg libjpeg)
declare_external_from_pkgconfig(libpng)
declare_external_from_pkgconfig(libwebp MODULES libwebpdecoder libwebpdemux libwebpmux libwebp)
declare_external_from_pkgconfig(zlib)

set(known_cpus x86 x64 arm arm64 wasm)
if(NOT VCPKG_TARGET_ARCHITECTURE IN_LIST known_cpus)
    message(WARNING "Unknown target cpu '${VCPKG_TARGET_ARCHITECTURE}'.")
endif()

set(OPTIONS "target_cpu=\"${VCPKG_TARGET_ARCHITECTURE}\"")
set(OPTIONS_DBG "is_debug=true")
set(OPTIONS_REL "is_official_build=true")
vcpkg_list(SET SKIA_TARGETS ":skia")

if(VCPKG_TARGET_IS_ANDROID)
    string(APPEND OPTIONS " target_os=\"android\"")
elseif(VCPKG_TARGET_IS_IOS)
    string(APPEND OPTIONS " target_os=\"ios\"")
elseif(VCPKG_TARGET_IS_EMSCRIPTEN)
    string(APPEND OPTIONS " target_os=\"wasm\"")
elseif(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    string(APPEND OPTIONS " target_os=\"win\"")
    if(VCPKG_TARGET_IS_UWP)
        string(APPEND OPTIONS " skia_enable_winuwp=true skia_enable_fontmgr_win=false skia_use_xps=false")
    endif()
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    string(APPEND OPTIONS " is_component_build=true")
else()
    string(APPEND OPTIONS " is_component_build=false")
endif()

set(required_externals
    dng_sdk
    expat
    libgifcodec
    libjpeg
    libpng
    libwebp
    piex
    sfntly
    zlib
)

if("fontconfig" IN_LIST FEATURES)
    list(APPEND required_externals fontconfig)
    string(APPEND OPTIONS " skia_use_fontconfig=true")
else()
    string(APPEND OPTIONS " skia_use_fontconfig=false")
endif()

if("freetype" IN_LIST FEATURES)
    list(APPEND required_externals freetype2)
    string(APPEND OPTIONS " skia_use_freetype=true")
else()
    string(APPEND OPTIONS " skia_use_freetype=false")
endif()

if("harfbuzz" IN_LIST FEATURES)
    list(APPEND required_externals harfbuzz)
    string(APPEND OPTIONS " skia_use_harfbuzz=true")
else()
    string(APPEND OPTIONS " skia_use_harfbuzz=false")
endif()

if("icu" IN_LIST FEATURES)
    list(APPEND required_externals icu)
    string(APPEND OPTIONS " skia_use_icu=true")
else()
    string(APPEND OPTIONS " skia_use_icu=false")
endif()

if("gl" IN_LIST FEATURES)
    string(APPEND OPTIONS " skia_use_gl=true")
else()
    string(APPEND OPTIONS " skia_use_gl=false")
endif()

if("metal" IN_LIST FEATURES)
    string(APPEND OPTIONS " skia_use_metal=true")
endif()

if("vulkan" IN_LIST FEATURES)
    string(APPEND OPTIONS " skia_use_vulkan=true")
    file(COPY "${CURRENT_INSTALLED_DIR}/include/vk_mem_alloc.h" DESTINATION "${SOURCE_PATH}/third_party/vulkanmemoryallocator")
endif()

if("direct3d" IN_LIST FEATURES)
    list(APPEND required_externals
        spirv-cross
        spirv-headers
        spirv-tools
        d3d12allocator
    )
    string(APPEND OPTIONS " skia_use_direct3d=true")
endif()

if("dawn" IN_LIST FEATURES)
    if (VCPKG_TARGET_IS_LINUX)
        message(WARNING
[[
dawn support requires the following libraries from the system package manager:

    libx11-xcb-dev mesa-common-dev

They can be installed on Debian based systems via

    apt-get install libx11-xcb-dev mesa-common-dev
]]
        )
    endif()

    list(APPEND required_externals
        spirv-cross
        spirv-headers
        spirv-tools
        tint
        jinja2
        markupsafe
## Remove
        vulkan-headers
        vulkan-tools
        abseil-cpp
## REMOVE ^
        dawn
    )
    string(APPEND OPTIONS " skia_use_dawn=true")
    string(REPLACE "dynamic" "shared" DAWN_LINKAGE "${VCPKG_LIBRARY_LINKAGE}")
    vcpkg_list(APPEND SKIA_TARGETS
        "third_party/externals/dawn/src/dawn:proc_${DAWN_LINKAGE}"
        "third_party/externals/dawn/src/dawn/native:${DAWN_LINKAGE}"
        "third_party/externals/dawn/src/dawn/platform:${DAWN_LINKAGE}"
    )
endif()

get_externals(${required_externals})
if(EXISTS "${SOURCE_PATH}/third_party/externals/dawn/generator/dawn_version_generator.py")
    vcpkg_find_acquire_program(GIT)
    vcpkg_replace_string("${SOURCE_PATH}/third_party/externals/dawn/generator/dawn_version_generator.py"
        "get_git()," 
        "\"${GIT}\","
    )
endif()

vcpkg_find_acquire_program(PYTHON3)
vcpkg_replace_string("${SOURCE_PATH}/.gn" "script_executable = \"python3\"" "script_executable = \"${PYTHON3}\"")
vcpkg_replace_string("${SOURCE_PATH}/gn/toolchain/BUILD.gn" "python3 " "\\\"${PYTHON3}\\\" ")

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    string(REGEX REPLACE "[\\]\$" "" WIN_VC "$ENV{VCINSTALLDIR}")
    string(APPEND OPTIONS " win_vc=\"${WIN_VC}\"")
else()
    string(APPEND OPTIONS " \
        cc=\"${VCPKG_DETECTED_CMAKE_C_COMPILER}\" \
        cxx=\"${VCPKG_DETECTED_CMAKE_CXX_COMPILER}\"")
endif()

string_to_gn_list(SKIA_C_FLAGS_DBG "${VCPKG_COMBINED_C_FLAGS_DEBUG}")
string_to_gn_list(SKIA_CXX_FLAGS_DBG "${VCPKG_COMBINED_CXX_FLAGS_DEBUG}")
string(APPEND OPTIONS_DBG " \
    extra_cflags_c=${SKIA_C_FLAGS_DBG} \
    extra_cflags_cc=${SKIA_CXX_FLAGS_DBG}")
string_to_gn_list(SKIA_C_FLAGS_REL "${VCPKG_COMBINED_C_FLAGS_RELEASE}")
string_to_gn_list(SKIA_CXX_FLAGS_REL "${VCPKG_COMBINED_CXX_FLAGS_RELEASE}")
string(APPEND OPTIONS_REL " \
    extra_cflags_c=${SKIA_C_FLAGS_REL} \
    extra_cflags_cc=${SKIA_CXX_FLAGS_REL}")
if(VCPKG_TARGET_IS_UWP)
    string_to_gn_list(SKIA_LD_FLAGS "-APPCONTAINER WindowsApp.lib")
    string(APPEND OPTIONS " extra_ldflags=${SKIA_LD_FLAGS}")
endif()

vcpkg_gn_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "${OPTIONS} skia_use_lua=false skia_enable_tools=false skia_enable_spirv_validation=false"
    OPTIONS_DEBUG "${OPTIONS_DBG}"
    OPTIONS_RELEASE "${OPTIONS_REL}"
)

# desc json output is dual-use: logging and further processing
vcpkg_find_acquire_program(GN)
vcpkg_execute_required_process(
    COMMAND "${GN}" desc --format=json --all --testonly=false "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel" "*"
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME "desc-${TARGET_TRIPLET}-rel"
    OUTPUT_VARIABLE desc_release
)
file(READ "${CURRENT_BUILDTREES_DIR}/desc-${TARGET_TRIPLET}-rel-out.log" desc_release)
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_execute_required_process(
        COMMAND "${GN}" desc --format=json --all --testonly=false "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg" "*"
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "desc-${TARGET_TRIPLET}-dbg"
        OUTPUT_VARIABLE desc_debug
    )
    file(READ "${CURRENT_BUILDTREES_DIR}/desc-${TARGET_TRIPLET}-dbg-out.log" desc_debug)
endif()

vcpkg_gn_install(
    SOURCE_PATH "${SOURCE_PATH}"
    TARGETS ${SKIA_TARGETS}
)

# Use skia repository layout in ${CURRENT_PACKAGES_DIR}/include/skia
file(COPY "${SOURCE_PATH}/include"
          "${SOURCE_PATH}/modules"
          "${SOURCE_PATH}/src"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/skia"
    FILES_MATCHING PATTERN "*.h"
)
auto_clean("${CURRENT_PACKAGES_DIR}/include/skia")
set(skia_dll_static "0")
set(skia_dll_dynamic "1")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/skia/include/core/SkTypes.h" "defined(SKIA_DLL)" "${skia_dll_${VCPKG_LIBRARY_LINKAGE}}")

# vcpkg legacy layout omits "include/" component. Just duplicate.
file(COPY "${CURRENT_PACKAGES_DIR}/include/skia/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/skia")

get_definitions(SKIA_DEFINITIONS_REL "${desc_release}" "//:skia")
get_link_libs(SKIA_DEP_REL "${desc_release}" "//:skia")
if(NOT VCPKG_BUILD_TYPE)
    get_definitions(SKIA_DEFINITIONS_DBG "${desc_debug}" "//:skia")
    get_link_libs(SKIA_DEP_DBG "${desc_debug}" "//:skia")
endif()
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/unofficial-skia")
configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-skia-config.cmake" "${CURRENT_PACKAGES_DIR}/share/unofficial-skia/unofficial-skia-config.cmake" @ONLY)
# vcpkg legacy
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/skiaConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/skia")

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/example/CMakeLists.txt"
    "${SOURCE_PATH}/tools/convert-to-nia.cpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/example"
)
file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/example/convert-to-nia.cpp" [[
// Test for https://github.com/microsoft/vcpkg/issues/27219
#include "include/core/SkColorSpace.h"
]])

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(GLOB third_party_licenses "${SOURCE_PATH}/third_party_licenses/*")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" ${third_party_licenses})
