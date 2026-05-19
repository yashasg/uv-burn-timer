#!/usr/bin/env bash
set -euo pipefail

squad loop --execute --self-pull --two-pass --wave-dispatch --decision-hygiene --board https://gitlab.com/yashasg/uv-burn-timer/-/work_items --health --copilot-flags "--yolo" --state-backend git-notes
