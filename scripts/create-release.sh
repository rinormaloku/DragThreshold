#!/bin/bash
set -e

# Script to create release package locally
# Usage: ./scripts/create-release.sh [version]
# If version is not provided, it will be extracted from the closest git tag

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

cd "$REPO_ROOT"

# Get version from argument or git tag
if [ -z "$1" ]; then
    # Try to get version from git tag
    if git describe --tags --exact-match &>/dev/null; then
        VERSION=$(git describe --tags --exact-match | sed 's/^v//')
    else
        echo "Error: No version provided and no exact git tag found."
        echo "Usage: $0 [version]"
        echo "Example: $0 0.1.4"
        exit 1
    fi
else
    VERSION="$1"
fi

echo "========================================"
echo "Creating release package for v${VERSION}"
echo "========================================"

# Check if plugin is built
if [ ! -f "DragThreshold/bin/Release/net8.0/DragThreshold.dll" ]; then
    echo "Error: Plugin not built. Please run 'dotnet build -c Release' first."
    exit 1
fi

# Clean up old build output and zip
rm -rf build_output DragThreshold.zip

# Create a clean directory for packaging
mkdir -p build_output/DragThreshold

# Copy only the necessary files
cp DragThreshold/bin/Release/net8.0/DragThreshold.dll build_output/DragThreshold/
cp DragThreshold/bin/Release/net8.0/DragThreshold.deps.json build_output/DragThreshold/

echo "Copied plugin files to build_output/"

# Create zip from inside the DragThreshold directory (files at root of zip)
cd build_output/DragThreshold
zip -r ../../DragThreshold.zip . > /dev/null
cd ../..

echo "Created DragThreshold.zip"

# Calculate SHA256
SHA256=$(sha256sum DragThreshold.zip | awk '{print $1}')

echo "SHA256: ${SHA256}"

# Create metadata file and add it to the zip
cat > build_output/DragThreshold/metadata-${VERSION}.json << EOF
{
    "Name": "DragThreshold",
    "Owner": "rinormaloku",
    "Description": "Prevents Pen clicks to be registered as Pen drags due to tiny movements by setting a threshold that must be exceeded before it counts as a drag",
    "PluginVersion": "${VERSION}",
    "SupportedDriverVersion": "0.6.6.2",
    "RepositoryUrl": "https://github.com/rinormaloku/DragThreshold",
    "DownloadUrl": "https://github.com/rinormaloku/DragThreshold/releases/download/v${VERSION}/DragThreshold.zip",
    "CompressionFormat": "zip",
    "SHA256": "${SHA256}",
    "WikiUrl": "",
    "LicenseIdentifier": "GPL-3.0-only"
}
EOF

# Update zip with metadata
cd build_output/DragThreshold
zip -r ../../DragThreshold.zip metadata-${VERSION}.json > /dev/null
cd ../..

echo "Added metadata to zip"

# Also save metadata.json in the repo root for reference
cp build_output/DragThreshold/metadata-${VERSION}.json metadata.json

echo ""
echo "========================================"
echo "=== Release Metadata ==="
echo "========================================"
cat metadata.json
echo ""
echo "========================================"
echo "Files created:"
echo "  - DragThreshold.zip (contains dll, deps.json, and metadata)"
echo "  - metadata.json (for reference)"
echo "========================================"

# Cleanup temp directory
rm -rf build_output

echo "Done!"
