#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"

build_dir="build-linux/project-build"
if [ ! -d "${build_dir}" ]; then
    echo "Build directory not found: ${build_dir}" >&2
    echo "Run the Linux build first:" >&2
    echo "  cmake -S . -B build-linux -DCMAKE_BUILD_TYPE=Release" >&2
    echo "  cmake --build build-linux --parallel 8" >&2
    exit 1
fi

build_dir="$(cd "${build_dir}" && pwd)"
cpack_config="${build_dir}/CPackConfig.cmake"
if [ ! -f "${cpack_config}" ]; then
    echo "Missing CPack config: ${cpack_config}" >&2
    exit 1
fi

cpack_name="$(awk -F '\"' 'index($0, "set(CPACK_PACKAGE_FILE_NAME ") == 1 {print $2; exit}' "${cpack_config}")"
if [ -z "${cpack_name}" ]; then
    echo "Failed to read CPACK_PACKAGE_FILE_NAME from ${cpack_config}" >&2
    exit 1
fi

appimage_name="${cpack_name}.AppImage"

linuxdeploy_cmd="linuxdeploy"
tool_dir="${script_dir}/build-linux/tools"

arch="$(uname -m)"
case "${arch}" in
    x86_64|amd64)
        arch="x86_64"
        ;;
    aarch64|arm64)
        arch="aarch64"
        ;;
    i386|i686)
        arch="i686"
        ;;
    *)
        echo "Unsupported architecture: ${arch}" >&2
        exit 1
        ;;
esac

tool_path="${tool_dir}/linuxdeploy-${arch}.AppImage"
runtime_file="${tool_dir}/runtime-${arch}"

need_curl=0
if ! command -v linuxdeploy >/dev/null 2>&1 && [ ! -f "${tool_path}" ]; then
    need_curl=1
fi
if [ ! -f "${runtime_file}" ]; then
    need_curl=1
fi
if [ "${need_curl}" -eq 1 ] && ! command -v curl >/dev/null 2>&1; then
    echo "curl not found in PATH." >&2
    exit 1
fi

if ! command -v linuxdeploy >/dev/null 2>&1; then
    mkdir -p "${tool_dir}"
    if [ ! -f "${tool_path}" ]; then
        echo "Downloading linuxdeploy to ${tool_path}..."
        curl -fL -o "${tool_path}" \
            "https://github.com/linuxdeploy/linuxdeploy/releases/download/1-alpha-20251107-1/linuxdeploy-${arch}.AppImage"
        chmod +x "${tool_path}"
    else
        chmod +x "${tool_path}"
    fi
    extract_dir="${tool_dir}/squashfs-root"
    if [ ! -d "${extract_dir}" ]; then
        (cd "${tool_dir}" && "${tool_path}" --appimage-extract >/dev/null)
    fi
    linuxdeploy_cmd="${extract_dir}/AppRun"
fi

if [ ! -f "${runtime_file}" ]; then
    mkdir -p "${tool_dir}"
    echo "Downloading AppImage runtime to ${runtime_file}..."
    curl -fL -o "${runtime_file}" \
        "https://github.com/AppImage/type2-runtime/releases/download/20251108/runtime-${arch}"
fi

appdir="${build_dir}/appdir"
rm -rf "${appdir}"
DESTDIR="${appdir}" cmake --install "${build_dir}" --prefix /usr

desktop_path="${appdir}/usr/share/applications/mywxapp1.desktop"
icon_path="${appdir}/usr/share/icons/hicolor/256x256/apps/mywxapp1.png"

if [ ! -f "${desktop_path}" ]; then
    echo "Missing desktop file: ${desktop_path}" >&2
    exit 1
fi

if [ ! -f "${icon_path}" ]; then
    echo "Missing icon file: ${icon_path}" >&2
    exit 1
fi

(
    cd "${script_dir}"
    LDAI_RUNTIME_FILE="${runtime_file}" \
        "${linuxdeploy_cmd}" \
        --appdir "${appdir}" \
        --executable "${appdir}/usr/bin/mywxapp1" \
        --desktop-file "${desktop_path}" \
        --icon-file "${icon_path}" \
        --output appimage
)

appimage_src="${script_dir}/mywxapp1-${arch}.AppImage"
if [ ! -f "${appimage_src}" ]; then
    echo "Expected AppImage not found: ${appimage_src}" >&2
    exit 1
fi

mv -f "${appimage_src}" "${script_dir}/${appimage_name}"
echo "AppImage created: ${script_dir}/${appimage_name}"
