# Shared setup for the scripts that write to this checkout. Source it, don't
# run it.

# Non-interactive SSH sessions get a bare PATH and skip .profile, so rv is
# never reachable. Source .profile (which already puts rv on PATH via
# ~/.cargo/env) rather than guessing rv's install location, then load its
# Ruby env explicitly since that's only wired into interactive shells via
# .bashrc.
[ -f "$HOME/.profile" ] && . "$HOME/.profile"
eval "$(rv shell env bash)"

# Run from the repo root regardless of where the calling script lives.
REPO="${SAMHURI_REPO:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
cd "$REPO"

# Local clones here name the GitHub remote "github"; a fresh clone on the server
# names it "origin". Prefer github, fall back to origin, unless overridden.
REMOTE="${SAMHURI_REMOTE:-$(git remote | grep -qx github && echo github || echo origin)}"
BRANCH="${SAMHURI_BRANCH:-main}"

# Serialise everything that writes to the checkout. The phone Shortcut over SSH
# and the Pressa web app both end up in these scripts, and two publishes at once
# against one git repo would corrupt something. Exit 75 (EX_TEMPFAIL) says "try
# again shortly" rather than "that failed".
acquire_publish_lock() {
  local lock_file="${SAMHURI_LOCK_FILE:-$REPO/.publish.lock}"

  if ! command -v flock >/dev/null 2>&1; then
    echo "==> flock unavailable, running without the publish lock" >&2
    return 0
  fi

  exec 9>"$lock_file"
  if ! flock -n 9; then
    echo "Error: another publish is already running, try again shortly" >&2
    exit 75
  fi
}

read_payload() {
  local payload
  payload="$(cat)"
  if [ -z "${payload//[[:space:]]/}" ]; then
    echo "Error: empty payload on stdin" >&2
    exit 1
  fi
  printf '%s' "$payload"
}
