#!/bin/bash
set -eu
#set -x

########################################################
LIB_NAME="zstd"
LIB_SOURCE_DIR="zstd-1.0.0"
LIB_DEBUG=true

# 编译架构，请只选择一个，将另一个注释
#ARCHS=("i386" "armv7" "armv7s") # 32-bit
ARCHS=("arm64" "x86_64") # 64-bit

SDK_VERSION="11.3"
CMAKE_TOOLCHAIN_FILE="${HOME}/svn/b_xx_dev_mobile_2018-02-22/DevEnv/devtools/cmake/ios.toolchain.cmake"
CMAKELISTS_DIR="zstd-1.0.0/projects/cmake"
OTHER_CMAKE_BUILD_OPTION="--target libzstd_static"
########################################################

function log_info() {
    echo "\033[32m[INFO]\033[0m $1"
}

if [ "$LIB_DEBUG" = true ] ; then
    LIB_BUILD_TYPE_FLAG="-DCMAKE_BUILD_TYPE=Debug"
    BUILD_DIR="Debug"
else
    LIB_BUILD_TYPE_FLAG="-DCMAKE_BUILD_TYPE=Release"
    BUILD_DIR="Release"
fi

ROOT_DIR=$(pwd)
CMAKELISTS_ABS_DIR=${ROOT_DIR}/${CMAKELISTS_DIR}

for ARCH in "${ARCHS[@]}"; do
    cd "${ROOT_DIR}" || exit

    arrOS_ARCH=("armv7" "armv7s" "arm64")
    arrSIMULATOR_ARCH=("i386")
    arrSIMULATOR64_ARCH=("x86_64")
    if [[ " ${arrOS_ARCH[*]} " == *" ${ARCH} "* ]]; then
        IOS_PLATFORM="OS"
    elif [[ " ${arrSIMULATOR_ARCH[*]} " == *" ${ARCH} "* ]]; then
        IOS_PLATFORM="SIMULATOR"
    elif [[ " ${arrSIMULATOR64_ARCH[*]} " == *" ${ARCH} "* ]]; then
        IOS_PLATFORM="SIMULATOR64"
    else
        echo "Unspported arch: ${IOS_ARCH}"
        exit 0
    fi

    OUTPUT_DIR=${ROOT_DIR}/${BUILD_DIR}/${ARCH}
    if [ -d "${OUTPUT_DIR}" ]; then
        rm -rf ${OUTPUT_DIR}
    fi
    mkdir -p "${OUTPUT_DIR}"
    cd ${OUTPUT_DIR}

    log_info "Configuring: ${LIB_NAME} ${ARCH}"
    cmake ${CMAKELISTS_ABS_DIR} -GXcode \
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} ${LIB_BUILD_TYPE_FLAG} \
        -DIOS_PLATFORM=${IOS_PLATFORM} \
        -DIOS_ARCH=${ARCH}

    if [ $? -eq 0 ]; then
        log_info "Configured: ${LIB_NAME} ${ARCH}"
        log_info "Compiling: ${LIB_NAME} ${ARCH}"
        cmake --build ${OUTPUT_DIR} --config ${BUILD_DIR} ${OTHER_CMAKE_BUILD_OPTION}
        if [ $? -eq 0 ]; then
            log_info "Compiled: ${LIB_NAME} ${ARCH}"
        else
            log_info "Error compilation ${LIB_NAME} ${ARCH}"
        fi
    else
        log_info "Error configuration ${LIB_NAME} ${ARCH}"
    fi
done

