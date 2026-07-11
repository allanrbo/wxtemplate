Development
-----------

### Prerequisites

You only need GTK 3 on Linux, the Xcode SDK on macOS, or MinGW on Windows. The project automatically builds wxWidgets for you.

Linux (Debian/Ubuntu):

    sudo apt install build-essential libgtk-3-dev cmake

macOS:

    xcode-select --install
    # Download and install CMake dmg from https://cmake.org/

Windows (MSYS2 MINGW64 shell, blue icon):

    pacman -Syy
    pacman -Syuu
    pacman -S base-devel
    pacman -S mingw-w64-x86_64-toolchain
    pacman -S mingw-w64-x86_64-cmake
    # Restart shell at this point.

    # Optional useful extras for msys2
    pacman -S git


### Configure and build

Each platform should keep its own build directory so CMake caches don't clash when the tree lives on a shared drive. Example per OS:

    # Linux
    cmake -S . -B build-linux -DCMAKE_BUILD_TYPE=Release
    cmake --build build-linux --parallel 8
    cpack --config build-linux/project-build/CPackConfig.cmake -D CPACK_GENERATOR=DEB
    cpack --config build-linux/project-build/CPackConfig.cmake -D CPACK_GENERATOR=TGZ
    # Optional AppImage packaging (requires curl unless its tools are already cached)
    ./make-appimage.sh

    # Check which dynamic libraries this binary depends on.
    ldd ./build-linux/project-build/mywxapp1
    # Run it
    ./build-linux/project-build/mywxapp1

    # Windows (MSYS2 MINGW64 shell, blue icon)
    cmake -S . -B build-windows -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release
    cmake --build build-windows --parallel 8
    cpack --config build-windows/project-build/CPackConfig.cmake -D CPACK_GENERATOR=ZIP

    # macOS
    cmake -S . -B build-macos -DCMAKE_BUILD_TYPE=Release
    cmake --build build-macos --parallel 8
    cpack --config build-macos/project-build/CPackConfig.cmake -D CPACK_GENERATOR=DragNDrop


The first build downloads and builds wxWidgets 3.2.8, installing it under the platform build directory, for example `build-windows/wx-install`. Subsequent builds reuse it.

Set `-DCMAKE_BUILD_TYPE=Debug` during the initial configure (with your per-OS build directory) if you prefer a debug wxWidgets build; the cached libraries match whatever configuration you build first.

### Cleaning build directories

    rm -rf build-linux build-windows build-macos

Removing the build directory deletes the cached wxWidgets build as well. The next configure run recreates it.


### Icon assets

Artwork and platform-specific icons live under `graphics/appicon/`. Follow the README in that directory to regenerate `.ico`, `.icns`, and the XPM used at runtime.
