cmake_minimum_required(VERSION 3.20)

project(mywxapp1 VERSION 1.0 LANGUAGES CXX)

option(SUPERBUILD "Build dependencies first, then this project" ON)

set(WX_VERSION 3.2.8)
set(WX_PREFIX "${CMAKE_BINARY_DIR}/wx-install")

if(SUPERBUILD)
    include(ExternalProject)

    set(WX_TOOLKIT gtk3)
    if(APPLE)
        set(WX_TOOLKIT osx_cocoa)
    elseif(WIN32)
        set(WX_TOOLKIT msw)
    endif()

    set(WX_BUILD_TYPE Release)
    if(NOT CMAKE_CONFIGURATION_TYPES AND CMAKE_BUILD_TYPE)
        set(WX_BUILD_TYPE "${CMAKE_BUILD_TYPE}")
    endif()

    ExternalProject_Add(wx
        URL https://github.com/wxWidgets/wxWidgets/releases/download/v${WX_VERSION}/wxWidgets-${WX_VERSION}.tar.bz2
        URL_HASH SHA256=c74784904109d7229e6894c85cfa068f1106a4a07c144afd78af41f373ee0fe6
        DOWNLOAD_EXTRACT_TIMESTAMP TRUE
        CMAKE_ARGS
            -DwxBUILD_SHARED=OFF
            -DwxBUILD_MONOLITHIC=OFF
            -DwxBUILD_SAMPLES=OFF
            -DwxBUILD_DEMOS=OFF
            -DwxBUILD_TESTS=OFF
            -DwxUSE_LIBJPEG=OFF
            -DwxUSE_LIBTIFF=OFF
            -DwxUSE_ADV=OFF
            -DwxUSE_AUI=OFF
            -DwxUSE_HELP=OFF
            -DwxUSE_HTML=OFF
            -DwxUSE_MEDIACTRL=OFF
            -DwxUSE_PROPGRID=OFF
            -DwxUSE_RIBBON=OFF
            -DwxUSE_RICHTEXT=OFF
            -DwxUSE_STC=OFF
            -DwxUSE_WEBVIEW=OFF
            -DwxUSE_WXHTML_HELP=OFF
            -DwxUSE_XRC=OFF
            -DwxUSE_LIBSDL=OFF
            -DwxUSE_LIBNOTIFY=OFF
            -DwxUSE_LIBMSPACK=OFF
            -DwxUSE_LIBGNOMEVFS=OFF
            -DwxUSE_WEBREQUEST=OFF
            -DwxUSE_OPENGL=OFF
            -DwxUSE_SVG=OFF
            -DwxUSE_XML=OFF
            -DwxUSE_SOCKETS=OFF
            -DwxUSE_URL=OFF
            -DwxUSE_PROTOCOL=OFF
            -DwxUSE_FS_INET=OFF
            -DwxBUILD_TOOLKIT=${WX_TOOLKIT}
            -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
            -DCMAKE_BUILD_TYPE=${WX_BUILD_TYPE}
        INSTALL_DIR ${WX_PREFIX}
    )

    set(PROJECT_SELF_BINARY_DIR "${CMAKE_BINARY_DIR}/project-build")
    set(PROJECT_SELF_ARGS
        -DSUPERBUILD=OFF
        -DCMAKE_PREFIX_PATH=${WX_PREFIX}
    )
    if(NOT CMAKE_CONFIGURATION_TYPES AND CMAKE_BUILD_TYPE)
        list(APPEND PROJECT_SELF_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE})
    endif()

    ExternalProject_Add(project_self
        SOURCE_DIR ${CMAKE_SOURCE_DIR}
        BINARY_DIR ${PROJECT_SELF_BINARY_DIR}
        CMAKE_ARGS ${PROJECT_SELF_ARGS}
        BUILD_ALWAYS 1
        INSTALL_COMMAND ""
        DEPENDS wx
    )

    return()
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(wxWidgets CONFIG REQUIRED COMPONENTS core base)

add_executable(mywxapp1
    src/main.cpp
    src/licenses.cpp
)

target_link_libraries(mywxapp1 PRIVATE wx::core wx::base)

if(APPLE)
    target_sources(mywxapp1 PRIVATE graphics/appicon/icon.icns)
    set_source_files_properties(graphics/appicon/icon.icns PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
    set_target_properties(mywxapp1 PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/Info.plist"
        MACOSX_BUNDLE_ICON_FILE icon.icns
    )
    set(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${PROJECT_VERSION}-macOS-${CMAKE_SYSTEM_PROCESSOR}")
    install(TARGETS mywxapp1 BUNDLE DESTINATION .)
endif()

if(WIN32)
    target_sources(mywxapp1 PRIVATE graphics/appicon/app.rc)
    target_include_directories(mywxapp1 PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/graphics/appicon
    )

    target_link_options(mywxapp1 PRIVATE -static -static-libgcc -static-libstdc++)

    set_target_properties(mywxapp1 PROPERTIES
        WIN32_EXECUTABLE TRUE
    )
    set(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${PROJECT_VERSION}-Windows-${CMAKE_SYSTEM_PROCESSOR}")
endif()

if(NOT APPLE)
    install(TARGETS mywxapp1 RUNTIME DESTINATION bin)
endif()

if(UNIX AND NOT APPLE)
    set(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${PROJECT_VERSION}-Linux-${CMAKE_SYSTEM_PROCESSOR}")
    set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
    set(CPACK_DEBIAN_ARCHITECTURE ${CMAKE_SYSTEM_PROCESSOR})
    install(FILES mywxapp1.desktop DESTINATION share/applications)
    install(FILES graphics/appicon/icon_256x256.png
        DESTINATION share/icons/hicolor/256x256/apps
        RENAME mywxapp1.png
    )
endif()

set(CPACK_PACKAGE_VENDOR "Example Vendor")
set(CPACK_PACKAGE_CONTACT "Example Contact <example@example.com>")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Application")
set(CPACK_PACKAGE_DIRECTORY "${CMAKE_BINARY_DIR}")
set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
    set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
endif()

include(CPack)
