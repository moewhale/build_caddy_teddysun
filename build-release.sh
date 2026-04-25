#!/bin/bash

# Example: v2.10.2 Default: Latest version
VERSION=${1:-$(curl -s https://api.github.com/repos/caddyserver/caddy/releases/latest | grep -oE '"tag_name":\s*"v[0-9.]+"' | grep -oE 'v[0-9.]+' | head -n 1)}
LDFLAGS="-s -w -buildid="
[ -z "${VERSION}" ] && echo "[$(date)] Argument 1 is missing, Example: v2.10.2" && exit 1

echo "Select Target Operating System (OSES):"
echo "1) Linux (Default)"
echo "2) Windows"
read -p "Enter [1 or 2]: " os_choice

case $os_choice in
    2)
        SELECTED_OS="windows"
        suffix=".exe"
        ;;
    *)
        SELECTED_OS="linux"
        suffix=""
        ;;
esac

echo "--------------------------"
echo "Select Target Architecture(ARCHS):"
echo "1) Amd64 (Default)"
echo "2) Arm64"
read -p "Enter [1 or 2]: " arch_choice

case $arch_choice in
    2)
        SELECTED_ARCHS=("arm64")
        ;;
    *)
        SELECTED_ARCHS=("amd64")
        ;;
esac

echo "--------------------------"
echo "Preparing to build: OSES=$SELECTED_OS, ARCHS=${SELECTED_ARCHS[*]}"
echo "--------------------------"

rm -fv go.*
go mod init caddy
echo "require github.com/caddyserver/caddy/v2 ${VERSION}" >> go.mod
go mod tidy

if [ "$SELECTED_OS" == "windows" ]; then
    VERSION_CLEAN=${VERSION#v}
    VERSION_BASE=$(echo "${VERSION_CLEAN}" | sed -E 's/-[0-9]+-g[0-9a-f]+$//')
    IFS='.-' read -r MAJOR MINOR PATCH BUILD <<< "${VERSION_BASE}"
    
    MAJOR=${MAJOR:-0}; MINOR=${MINOR:-0}; PATCH=${PATCH:-0}; BUILD=${BUILD:-0}
    MAJOR=$(echo "${MAJOR}" | tr -cd '0-9')
    MINOR=$(echo "${MINOR}" | tr -cd '0-9')
    PATCH=$(echo "${PATCH}" | tr -cd '0-9')
    BUILD=$(echo "${BUILD}" | tr -cd '0-9')

    if hash goversioninfo 2>/dev/null; then
        sed -e "s/%MAJOR%/$MAJOR/g" \
            -e "s/%MINOR%/$MINOR/g" \
            -e "s/%PATCH%/$PATCH/g" \
            -e "s/%BUILD%/$BUILD/g" \
            -e "s/%VERSION%/$VERSION_CLEAN/g" \
            versioninfo.json > versioninfo_generated.json
        goversioninfo -platform-specific versioninfo_generated.json
    fi
fi

for arch in "${SELECTED_ARCHS[@]}"; do
    echo "Under construction ${SELECTED_OS}_${arch}..."
    env CGO_ENABLED=0 GOOS=${SELECTED_OS} GOARCH=${arch} go build -a -v -x -buildmode pie -compiler gc -trimpath -ldflags "${LDFLAGS}" -o caddy_${VERSION}_${SELECTED_OS}_${arch}${suffix}
done

[ -f "versioninfo_generated.json" ] && rm -f versioninfo_generated.json
rm -f resource_*.syso 2>/dev/null
