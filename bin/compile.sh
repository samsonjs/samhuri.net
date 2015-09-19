#!/bin/zsh

# bail on errors
set -e

export PATH="$HOME/.rbenv/shims:$PATH"

DIR=$(dirname "$0")
HARP="node_modules/harp/bin/harp"
BLOG_DIR="${1:-${DIR}/..}"
TARGET="${BLOG_DIR%/}/${2:-www}"
LOCK_FILE="$BLOG_DIR/compile.lock"

if [[ -e "$LOCK_FILE" ]]; then
  echo "Bailing, another compilation is running"
  exit 1
fi

function lock {
  echo $$ >| "$LOCK_FILE"
}
function delete_lock_file {
	rm -f "$LOCK_FILE"
}
trap delete_lock_file SIGHUP SIGINT SIGTERM SIGEXIT
lock

function main() {
  echo "* compile rss feed"
  compile_rss

  echo "* harp compile $BLOG_DIR $TARGET"
  rm -rf "$TARGET/*" "$TARGET/.*"
  "$HARP" compile "$BLOG_DIR" "$TARGET"

  # clean up temporary feed
  rm $BLOG_DIR/public/feed.xml

  echo "* munge html files to make them available without an extension"
  munge_html

  echo "* inline CSS"
  ruby -w $DIR/inline-css.rb "$TARGET"

  echo "* minify js"
  minify_js

  delete_lock_file
}

function compile_rss() {
  ruby -w $DIR/rss.rb $BLOG_DIR/public
}

function munge_html() {
  for FILE in "$TARGET"/*.html "$TARGET"/posts/*/*/*.html "$TARGET"/posts/drafts/*.html "$TARGET"/projects/*.html; do
    [[ "${FILE##*/}" = "index.html" ]] && continue

    # make posts available without an .html extension
    FILE_DIR="${FILE%.html}"
    mkdir -p "$FILE_DIR"
    mv "$FILE" "$FILE_DIR/index.html"
  done
}

function minify_js() {
  for FILE in "$TARGET"/js/*.js; do
    $DIR/minify-js.sh "$FILE" > /tmp/minified.js && mv /tmp/minified.js "$FILE" || echo "* failed to minify $FILE"
  done
}

main
