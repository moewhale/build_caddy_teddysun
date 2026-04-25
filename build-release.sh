#!/bin/bash

# Example: v2.10.2 Default: Latest version
VERSION=${1:-$(curl -s https://api.github.com/repos/caddyserver/caddy/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')}
LDFLAGS="-s -w -buildid="
[ -z "${VERSION}" ] && echo "[$(date)] Argument 1 is missing, Example: v2.10.2" && exit 1

rm -fv go.*
go mod init caddy
echo "require github.com/caddyserver/caddy/v2 ${VERSION}" >> go.mod
go mod tidy

# Parse version for versioninfo (format: x.x.x.x or x.x.x)
# Remove 'v' prefix and extract version components
VERSION_CLEAN=${VERSION#v}
# Extract base version (remove -X-gXXXXXXX suffix if exists), e.g., v5.44.1-1-g00092ea -> 5.44.1
VERSION_BASE=$(echo "${VERSION_CLEAN}" | sed -E 's/-[0-9]+-g[0-9a-f]+$//')
IFS='.-' read -r MAJOR MINOR PATCH BUILD <<< "${VERSION_BASE}"
# Set defaults if empty
MAJOR=${MAJOR:-0}
MINOR=${MINOR:-0}
PATCH=${PATCH:-0}
BUILD=${BUILD:-0}
# Ensure all version components are pure numbers (remove any non-digit characters)
MAJOR=$(echo "${MAJOR}" | tr -cd '0-9')
MINOR=$(echo "${MINOR}" | tr -cd '0-9')
PATCH=$(echo "${PATCH}" | tr -cd '0-9')
BUILD=$(echo "${BUILD}" | tr -cd '0-9')
# Re-validate defaults
MAJOR=${MAJOR:-0}
MINOR=${MINOR:-0}
PATCH=${PATCH:-0}
BUILD=${BUILD:-0}

# Generate versioninfo.json with actual version
if hash goversioninfo 2>/dev/null; then
    sed -e "s/%MAJOR%/$MAJOR/g" \
        -e "s/%MINOR%/$MINOR/g" \
        -e "s/%PATCH%/$PATCH/g" \
        -e "s/%BUILD%/$BUILD/g" \
        -e "s/%VERSION%/$VERSION_CLEAN/g" \
        versioninfo.json > versioninfo_generated.json
    # Generate platform-specific .syso files for all Windows architectures
    # This creates resource_windows_386.syso, resource_windows_amd64.syso, resource_windows_arm.syso, resource_windows_arm64.syso
    goversioninfo -platform-specific versioninfo_generated.json
fi

OSES=(windows)
ARCHS=(amd64 386 arm64)
suffix=".exe"
for os in "${OSES[@]}"; do
    for arch in "${ARCHS[@]}"; do
        env CGO_ENABLED=0 GOOS=${os} GOARCH=${arch} go build -a -v -x -buildmode pie -compiler gc -trimpath -ldflags "-s -w -buildid=" -o caddy_${VERSION}_${os}_${arch}${suffix}
    done
done

# Clean up generated files
if [ -f "versioninfo_generated.json" ]; then
    rm -f versioninfo_generated.json
fi
# Clean up generated .syso files
rm -f resource_*.syso 2>/dev/null
