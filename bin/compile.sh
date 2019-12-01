#!/bin/zsh

# bail on errors
set -e

# export PATH="$HOME/.rbenv/shims:$PATH"

DIR=$(dirname "$0")
# HARP="node_modules/harp/bin/harp"
BLOG_DIR="${1:-${DIR}/..}"
TARGET="${BLOG_DIR%/}/${2:-www}"

function main() {
  echo "* compile rss feed"
  # compile_feeds

  # echo "* harp compile $BLOG_DIR $TARGET"
  # rm -rf "$TARGET/*" "$TARGET/.*"
  # "$HARP" compile "$BLOG_DIR" "$TARGET"

  # clean up temporary feeds
  # rm $BLOG_DIR/public/feed.xml
  # rm $BLOG_DIR/public/feed.json

  echo "* munge html files to make them available without an extension"
  # munge_html

  echo "* inline CSS"
  # ruby -w $DIR/inline-css.rb "$TARGET"

  echo "* minify js"
  # minify_js
}

function compile_feeds() {
  ruby -w $DIR/feeds.rb $BLOG_DIR/public
}

function munge_html() {
  for FILE in "$TARGET"/*.html "$TARGET"/posts/*/*/*.html "$TARGET"/posts/drafts/*.html "$TARGET"/projects/*.html; do
    FILENAME="${FILE##*/}"
    case "$FILENAME" in
    index.html)
      continue
      ;;
    missing.html)
      continue
      ;;
    esac

    # make posts available without an .html extension
    FILE_DIR="${FILE%.html}"
    mkdir -p "$FILE_DIR"
    mv "$FILE" "$FILE_DIR/index.html"
  done
}

# function minify_js() {
#   for FILE in "$TARGET"/js/*.js; do
#     $DIR/minify-js.sh "$FILE" > /tmp/minified.js && mv /tmp/minified.js "$FILE" || echo "* failed to minify $FILE"
#   done
# }

main
