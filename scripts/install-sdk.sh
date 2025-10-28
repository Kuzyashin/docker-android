#!/bin/bash

set -euo pipefail

# If the installation flag of the Android SDK is set
# we download the Android command-line tools,
# install the SDK, platform tools and the emulator.
if [ "${INSTALL_ANDROID_SDK}" == "1" ]; then
  echo "Installing the Android SDK, platform tools and emulator ..."
  CLI_ZIP="/tmp/commandlinetools-linux-${CMD_LINE_VERSION}.zip"
  TEMP_DIR="/tmp/cmdline-tools"

  wget -O "${CLI_ZIP}" "https://dl.google.com/android/repository/commandlinetools-linux-${CMD_LINE_VERSION}.zip"
  mkdir -p "${ANDROID_SDK_ROOT}/cmdline-tools"
  rm -rf "${TEMP_DIR}"
  unzip -q "${CLI_ZIP}" -d "${TEMP_DIR}"
  rm "${CLI_ZIP}"
  rm -rf "${ANDROID_SDK_ROOT}/cmdline-tools/latest"
  mv "${TEMP_DIR}/cmdline-tools" "${ANDROID_SDK_ROOT}/cmdline-tools/latest"
  rm -rf "${TEMP_DIR}"

  SDKMANAGER="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager"

  yes | "${SDKMANAGER}" --sdk_root="${ANDROID_SDK_ROOT}" --licenses
  "${SDKMANAGER}" --sdk_root="${ANDROID_SDK_ROOT}" --install "$PACKAGE_PATH" "$ANDROID_PLATFORM_VERSION" platform-tools emulator
fi
