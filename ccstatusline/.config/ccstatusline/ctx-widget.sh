#!/usr/bin/env bash
# Renders: Ctx: 88.9k (7.7%)
#
# The percentage is measured against the real auto-compact threshold
# (window - RESERVE), not ccstatusline's hardcoded 80% of the window.
# RESERVE mirrors Claude Code's max-output (20k) + buffer (13k).
# See sirmalloc/ccstatusline#389.
export RESERVE=${CCSTATUSLINE_COMPACT_RESERVE:-33000}

exec /usr/bin/python3 -c '
import json, os, re, sys

try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)

cw = d.get("context_window") or {}
usage = cw.get("current_usage")

# match native context-length: input + cache, excluding output
if isinstance(usage, dict):
    ctxlen = ((usage.get("input_tokens") or 0)
              + (usage.get("cache_creation_input_tokens") or 0)
              + (usage.get("cache_read_input_tokens") or 0))
elif isinstance(usage, (int, float)):
    ctxlen = int(usage)
else:
    sys.exit(0)

win = cw.get("context_window_size")
if not (isinstance(win, (int, float)) and win > 0):
    model = d.get("model") or {}
    mid = model.get("id") if isinstance(model, dict) else model
    m = re.search(r"[\[(]\s*(\d+(?:\.\d+)?)\s*([km])\s*[\])]", str(mid or ""), re.I)
    win = round(float(m.group(1)) * (1e6 if m.group(2).lower() == "m" else 1e3)) if m else 200000

usable = max(1, int(win) - int(os.environ["RESERVE"]))
pct = min(100.0, ctxlen / usable * 100)

if ctxlen >= 1e6:
    size = "%.1fM" % (ctxlen / 1e6)
elif ctxlen >= 1000:
    size = "%.1fk" % (ctxlen / 1000)
else:
    size = str(ctxlen)

print("Ctx: %s (%.1f%%)" % (size, pct))
'
