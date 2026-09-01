#!/bin/sh

dnf install binutils-devel -y
dnf install numactl -y
curl -LsSf https://astral.sh/uv/install.sh | sh
