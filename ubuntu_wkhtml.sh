#!/usr/bin/env bash

# Ubuntu 24.04 wkhtmltopdf installer
# Updated 2026-05-19

set -euo pipefail

TEST_URL="${TEST_URL:-https://google.hr}"
TEST_PDF="${TEST_PDF:-/tmp/wkhtmltopdf-test.pdf}"

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    exec sudo -E bash "$0" "$@"
fi

if [[ -r /etc/os-release ]]; then
    . /etc/os-release
else
    echo "Cannot determine the operating system."
    exit 1
fi

if [[ "${ID:-}" != "ubuntu" || "${VERSION_ID:-}" != "24.04" ]]; then
    echo "This script is intended for Ubuntu 24.04. Detected: ${PRETTY_NAME:-unknown}."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "Updating package lists..."
apt-get update

if ! apt-cache policy wkhtmltopdf | awk '
    /Candidate:/ {
        found = 1
        exit ($2 == "(none)")
    }
    END {
        if (!found) {
            exit 1
        }
    }
'; then
    echo "wkhtmltopdf is not available yet; enabling the universe repository..."
    apt-get install -y software-properties-common
    add-apt-repository -y universe
    apt-get update
fi

echo "Installing wkhtmltopdf and required fonts/libraries..."
apt-get install -y --no-install-recommends \
    ca-certificates \
    fontconfig \
    fonts-dejavu-core \
    libxrender1 \
    wkhtmltopdf \
    xauth \
    xvfb \
    xfonts-75dpi \
    xfonts-base

echo
echo "Installation done."
wkhtmltopdf --version

echo
echo "Testing PDF generation: ${TEST_URL} -> ${TEST_PDF}"
if [[ -n "${DISPLAY:-}" ]]; then
    wkhtmltopdf "$TEST_URL" "$TEST_PDF"
else
    xvfb-run -a wkhtmltopdf "$TEST_URL" "$TEST_PDF"
fi

echo
echo "All done."
echo "Test PDF created at: ${TEST_PDF}"
