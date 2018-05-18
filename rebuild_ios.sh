#!/bin/bash

########################################################
LIB_NAME="iconv"
#LIB_VERSION="1.14"
LIB_DEBUG=true
LIB_SUFIX="LibX64D"

# 编译架构，请只选择一个，将另一个注释
#ARCHS=("i386" "armv7" "armv7s") # 32-bit
#ARCHS=("arm64" "x86_64") # 64-bit
ARCHS=("x86_64")

SDK_VERSION="11.3"
########################################################

function log_info() {
    echo "\033[32m[INFO]\033[0m $1"
}

if [ "$LIB_DEBUG" = true ] ; then
    LIB_ENABLE_DEBUG="--enable-debug"
else
    LIB_ENABLE_DEBUG=""
fi

ROOT_DIR=$(pwd)
BUILD_DIR="build"
#LIPO_CMD="lipo -create -output ${BUILD_DIR}/install/lib${LIB_NAME}${LIB_SUFIX}.a "

for ARCH in "${ARCHS[@]}"; do
    cd "${ROOT_DIR}" || exit

    if [ -d "${BUILD_DIR}/install/${ARCH}" ]; then
        rm -rf "${BUILD_DIR}/install/${ARCH}"
    fi
    mkdir -p "${BUILD_DIR}/install/${ARCH}"

    if [ "$ARCH" == "i386" ] || [ "$ARCH" == "x86_64" ]; then
        PLATFORM="iPhoneSimulator"
    else
        PLATFORM="iPhoneOS"
    fi
    BUILD_SDKROOT="/Applications/Xcode.app/Contents/Developer/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDK_VERSION}.sdk"
    export LDFLAGS="-arch ${ARCH} -pipe -isysroot ${BUILD_SDKROOT} -miphoneos-version-min=8.0 -Os"
    export CFLAGS="-arch ${ARCH} -pipe -isysroot ${BUILD_SDKROOT} -miphoneos-version-min=8.0 -Os"
    export CPPFLAGS="${CFLAGS}"
    export CXXFLAGS="${CFLAGS}"
    export CC=clang
    export CXX=clang++

    if [ "$ARCH" == "arm64" ]; then
        HOST="aarch64"
    else
        HOST="${ARCH}"
    fi

    log_info "Configuring: ${LIB_NAME} ${ARCH}"
    ./configure --host="${HOST}-apple-darwin" \
        --prefix="${ROOT_DIR}/${BUILD_DIR}/install/${ARCH}" \
        --enable-fill --enable-static  ${LIB_ENABLE_DEBUG}

    if [ $? -eq 0 ]; then
        log_info "Configured: ${LIB_NAME} ${ARCH}"
        log_info "Compiling: ${LIB_NAME} ${ARCH}"
        make 1>/dev/null
        if [ $? -eq 0 ]; then
            log_info "Compiled: ${LIB_NAME} ${ARCH}"
            log_info "Installing: ${LIB_NAME} ${ARCH}"
            make install 1>/dev/null
            if [ $? -eq 0 ]; then
                log_info "Installed: ${LIB_NAME} ${ARCH}"

                #LIPO_CMD="${LIPO_CMD} ${ROOT_DIR}/${BUILD_DIR}/install/${ARCH}/lib/lib${LIB_NAME}.a "
            else
                log_info "Error installation ${LIB_NAME} ${ARCH}"
            fi
        else
            log_info "Error compilation ${LIB_NAME} ${ARCH}"
        fi
    else
        log_info "Error configuration ${LIB_NAME} ${ARCH}"
    fi
done

