#!/usr/bin/env sh
# Capture unresolved file comments as exact source-and-feedback examples.
#
# Crit exposes the review context as env vars (CRIT_*) and a JSON payload on
# stdin. The hook runs with $PWD set to the repository root.

set -eu

: "${HOME:?missing HOME}"
: "${CRIT_REVIEW_PATH:?missing CRIT_REVIEW_PATH}"
: "${CRIT_SESSION_KEY:?missing CRIT_SESSION_KEY}"
: "${CRIT_UNRESOLVED_COUNT:=0}"

case "$CRIT_UNRESOLVED_COUNT" in
  ""|*[!0-9]*)
    printf 'crit: invalid CRIT_UNRESOLVED_COUNT: %s\n' "$CRIT_UNRESOLVED_COUNT" >&2
    exit 1
    ;;
esac

if [ "$CRIT_UNRESOLVED_COUNT" -eq 0 ]; then
  exit 0
fi

case "$CRIT_SESSION_KEY" in
  ""|"."|".."|*[!A-Za-z0-9._-]*)
    printf 'crit: invalid CRIT_SESSION_KEY: %s\n' "$CRIT_SESSION_KEY" >&2
    exit 1
    ;;
esac

review_json="$CRIT_REVIEW_PATH/review.json"
if [ ! -f "$review_json" ]; then
  printf 'crit: review JSON not found at %s\n' "$review_json" >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  printf 'crit: jq is required to capture review examples\n' >&2
  exit 1
fi
if ! command -v shasum >/dev/null 2>&1; then
  printf 'crit: shasum is required to verify review examples\n' >&2
  exit 1
fi

examples_dir="$HOME/.crit/examples"
mkdir -p "$examples_dir"

temp_dir="$examples_dir/.hook-$CRIT_SESSION_KEY-$$"
mkdir "$temp_dir"
records_file="$temp_dir/records.jsonl"
record_file="$temp_dir/record.json"
source_temp="$temp_dir/source"
metadata_temp="$temp_dir/metadata.json"

cleanup() {
  rm -f "$records_file" "$record_file" "$source_temp" "$metadata_temp" "$temp_dir"/*.seen
  rmdir "$temp_dir" 2>/dev/null || :
}
trap cleanup 0
trap 'exit 1' 1 2 15

repository_remote_url=""
if command -v git >/dev/null 2>&1; then
  repository_remote_url=$(git remote get-url origin 2>/dev/null || :)
fi

# Flatten unresolved file comments into one record per example.
jq -c '
  . as $review
  | (.files // {} | to_entries[]) as $entry
  | ($entry.value.comments // []) as $comments
  | select(($comments | type) == "array")
  | $comments[]
  | select(.resolved != true)
  | {
      review: {
        branch: ($review.branch // null),
        base_ref: ($review.base_ref // null),
        review_round: ($review.review_round // null),
        updated_at: ($review.updated_at // null)
      },
      file_path: $entry.key,
      file: $entry.value,
      comment: .
    }
' "$review_json" > "$records_file"

generated_count=0
skipped_count=0

skip_example() {
  skipped_count=$((skipped_count + 1))
  printf 'crit: skipped %s: %s\n' "$1" "$2" >&2
}

# Capture only complete comments whose current source matches the reviewed hash.
while IFS= read -r record; do
  printf '%s\n' "$record" > "$record_file"

  file_path=$(jq -r '.file_path' "$record_file")
  comment_id=$(jq -r 'if (.comment.id | type) == "string" then .comment.id else "" end' "$record_file")
  label=${comment_id:-$file_path}

  case "$comment_id" in
    ""|"."|".."|*[!A-Za-z0-9._-]*)
      skip_example "$label" "missing_or_invalid_comment_id"
      continue
      ;;
  esac

  if ! jq -e '(.comment.body | type) == "string"' "$record_file" >/dev/null; then
    skip_example "$label" "missing_comment_body"
    continue
  fi

  case "$file_path" in
    ""|/*|".."|../*|*/../*|*/..)
      skip_example "$label" "invalid_source_path"
      continue
      ;;
  esac

  basename=${file_path##*/}
  case "$basename" in
    ""|"."|".."|"metadata.json")
      skip_example "$label" "invalid_source_basename"
      continue
      ;;
  esac

  source_path="$PWD/$file_path"
  if [ ! -f "$source_path" ]; then
    skip_example "$label" "missing_source_file"
    continue
  fi

  stored_hash=$(jq -r 'if (.file.file_hash | type) == "string" then .file.file_hash else "" end' "$record_file")
  hash=${stored_hash#sha256:}
  case "$hash" in
    ""|*[!0-9a-f]*)
      skip_example "$label" "missing_or_invalid_file_hash"
      continue
      ;;
  esac
  if [ "${#hash}" -ne 64 ]; then
    skip_example "$label" "missing_or_invalid_file_hash"
    continue
  fi

  hash_output=$(shasum -a 256 "$source_path")
  actual_hash=${hash_output%% *}
  if [ "$actual_hash" != "$hash" ]; then
    skip_example "$label" "source_hash_mismatch"
    continue
  fi

  example_id="$CRIT_SESSION_KEY-$comment_id"
  if [ -e "$temp_dir/$example_id.seen" ]; then
    skip_example "$label" "duplicate_comment_id"
    continue
  fi
  : > "$temp_dir/$example_id.seen"

  # Prepare source and metadata before updating the example directory.
  cp "$source_path" "$source_temp"
  jq \
    --arg review_id "$CRIT_SESSION_KEY" \
    --arg repository_remote_url "$repository_remote_url" \
    --arg basename "$basename" '
      {
        schema_version: 1,
        review: {
          id: $review_id,
          repository_remote_url: (
            if $repository_remote_url == "" then null else $repository_remote_url end
          ),
          branch: .review.branch,
          base_ref: .review.base_ref,
          review_round: .review.review_round,
          updated_at: .review.updated_at
        },
        file: {
          path: .file_path,
          basename: $basename,
          status: (.file.status // null),
          hash: .file.file_hash
        },
        comment: {
          id: .comment.id,
          body: .comment.body,
          author: (.comment.author // null),
          scope: (.comment.scope // null),
          lines: {
            start: (.comment.start_line // null),
            end: (.comment.end_line // null)
          },
          quote: (.comment.quote // null),
          anchor: (.comment.anchor // null),
          drifted: (.comment.drifted == true),
          review_round: (.comment.review_round // null),
          created_at: (.comment.created_at // null),
          updated_at: (.comment.updated_at // null),
          resolved: (.comment.resolved == true),
          resolved_round: (.comment.resolved_round // null),
          replies: (
            if (.comment.replies | type) == "array" then .comment.replies else [] end
          )
        }
      }
    ' "$record_file" > "$metadata_temp"

  example_dir="$examples_dir/$example_id"
  old_basename=""
  if [ -f "$example_dir/metadata.json" ]; then
    old_basename=$(jq -r 'if (.file.basename | type) == "string" then .file.basename else "" end' "$example_dir/metadata.json" 2>/dev/null || :)
  fi

  mkdir -p "$example_dir"
  mv "$source_temp" "$example_dir/$basename"
  mv "$metadata_temp" "$example_dir/metadata.json"

  if [ -n "$old_basename" ] && [ "$old_basename" != "$basename" ]; then
    case "$old_basename" in
      "."|".."|*/*) ;;
      *) rm -f "$example_dir/$old_basename" ;;
    esac
  fi

  generated_count=$((generated_count + 1))
done < "$records_file"

# The unresolved total can include comments without a source file.
accounted_count=$((generated_count + skipped_count))
if [ "$CRIT_UNRESOLVED_COUNT" -gt "$accounted_count" ]; then
  no_source_count=$((CRIT_UNRESOLVED_COUNT - accounted_count))
  skipped_count=$((skipped_count + no_source_count))
  printf 'crit: skipped %s unresolved comment(s): no_source_file\n' "$no_source_count" >&2
fi

printf 'crit: captured %s example(s) in %s (%s skipped)\n' "$generated_count" "$examples_dir" "$skipped_count" >&2
