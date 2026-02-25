#!/usr/bin/env python3
"""
Edit Verification Hook

Verifies that Edit/Write calls actually modify files on disk by comparing
mtime and size before and after. Catches silent edit failures immediately
instead of discovering them hours later.

Also tracks edit counts for files in project/ subdirectories that may be
gitignored (e.g., project/overleaf/, project/paper/) and nudges about
backup at thresholds.

Hook Event: PostToolUse (matcher: "Write|Edit")
Returns: Exit code 0 (non-blocking)
"""

import json
import os
import sys
from pathlib import Path

# Colors for terminal output
RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[0;33m"
NC = "\033[0m"  # No color

# Directories inside project/ where files may be gitignored and only
# Dropbox-protected. Edits here deserve extra caution.
WATCHED_PROJECT_DIRS = [
    "/project/overleaf/",
    "/project/paper/",
    "/project/output/",
]

# Thresholds for backup nudges (only for watched dirs)
NUDGE_THRESHOLD = 3
WARN_THRESHOLD = 6


def get_cache_path() -> Path:
    """Get the session cache file for edit fingerprints."""
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", "")
    if not project_dir:
        cache_dir = Path.home() / ".claude" / "sessions" / "default"
    else:
        import hashlib
        project_hash = hashlib.md5(project_dir.encode()).hexdigest()[:8]
        cache_dir = Path.home() / ".claude" / "sessions" / project_hash

    cache_dir.mkdir(parents=True, exist_ok=True)
    return cache_dir / "edit-verify-cache.json"


def load_cache() -> dict:
    """Load the fingerprint cache."""
    cache_path = get_cache_path()
    try:
        if cache_path.exists():
            return json.loads(cache_path.read_text())
    except (json.JSONDecodeError, IOError):
        pass
    return {"fingerprints": {}, "edit_counts": {}}


def save_cache(cache: dict) -> None:
    """Save the fingerprint cache."""
    try:
        get_cache_path().write_text(json.dumps(cache))
    except IOError:
        pass


def get_fingerprint(file_path: str) -> tuple:
    """Get mtime and size for a file. Returns (mtime, size) or (0, 0)."""
    try:
        stat = os.stat(file_path)
        return (stat.st_mtime, stat.st_size)
    except OSError:
        return (0, 0)


def is_in_watched_dir(file_path: str) -> bool:
    """Check if file is in a watched project subdirectory."""
    normalized = file_path.replace("\\", "/")
    return any(d in normalized for d in WATCHED_PROJECT_DIRS)


def main() -> int:
    # Read hook input
    try:
        hook_input = json.load(sys.stdin)
    except (json.JSONDecodeError, IOError):
        return 0

    tool_input = hook_input.get("tool_input", {})
    file_path = tool_input.get("file_path", "")

    if not file_path:
        return 0

    # Normalize for comparison
    file_key = file_path.replace("\\", "/")
    filename = Path(file_path).name

    cache = load_cache()
    fingerprints = cache.get("fingerprints", {})
    edit_counts = cache.get("edit_counts", {})

    # Get current fingerprint (after the edit was applied)
    current_fp = get_fingerprint(file_path)

    # Compare with previous fingerprint
    previous_fp = fingerprints.get(file_key)

    if previous_fp is not None:
        prev_mtime, prev_size = previous_fp
        curr_mtime, curr_size = current_fp

        if curr_mtime == prev_mtime and curr_size == prev_size:
            # File was NOT modified on disk despite the edit
            print(
                f"\n{RED}EDIT VERIFICATION FAILED:{NC} "
                f"{filename} was not modified on disk after edit!\n"
                f"   mtime: {curr_mtime}  size: {curr_size}\n"
                f"   The Edit/Write tool may have reported success "
                f"without writing to disk.\n"
            )

    # Update fingerprint and count
    fingerprints[file_key] = current_fp
    count = edit_counts.get(file_key, 0) + 1
    edit_counts[file_key] = count

    cache["fingerprints"] = fingerprints
    cache["edit_counts"] = edit_counts
    save_cache(cache)

    # Verification confirmation
    if previous_fp is not None:
        curr_mtime, curr_size = current_fp
        prev_mtime, prev_size = previous_fp
        if curr_mtime != prev_mtime or curr_size != prev_size:
            print(
                f"{GREEN}+ {filename} verified on disk"
                f" ({count} edit{'s' if count != 1 else ''}"
                f" this session){NC}"
            )

    # Backup nudges for watched directories
    if is_in_watched_dir(file_path):
        if count == WARN_THRESHOLD:
            print(
                f"\n{RED}Backup reminder:{NC} {count} edits to "
                f"{filename} this session.\n"
                f"   This file may be gitignored and only "
                f"Dropbox-protected.\n"
                f"   Verify changes are on disk and consider a "
                f"manual backup.\n"
            )
        elif count == NUDGE_THRESHOLD:
            print(
                f"\n{YELLOW}Reminder:{NC} {count} edits to "
                f"{filename} this session.\n"
                f"   Files in project/ may be gitignored and only "
                f"Dropbox-protected.\n"
            )

    return 0


if __name__ == "__main__":
    sys.exit(main())
