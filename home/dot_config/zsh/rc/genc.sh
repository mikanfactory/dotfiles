# genc - generate CLI command from natural language
# Usage: genc "~/code配下でREADME.mdを検索"
#        genc "find large files" -model sonnet
#        genc "find large files" -v
function genc() {
  local prompt=""
  local model="haiku"
  local verbose=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -model|--model)
        model="$2"
        shift 2
        ;;
      -v|--verbose)
        verbose=true
        shift
        ;;
      -p)
        prompt="$2"
        shift 2
        ;;
      *)
        if [[ -z "$prompt" ]]; then
          prompt="$1"
        else
          prompt="$prompt $1"
        fi
        shift
        ;;
    esac
  done

  if [[ -z "$prompt" ]]; then
    echo "Usage: genc \"<説明>\" [-model haiku|sonnet|opus] [-v]"
    echo "       genc -p \"<説明>\" -model haiku --verbose"
    return 1
  fi

  local model_id
  case "$model" in
    haiku)  model_id="claude-haiku-4-5-20251001" ;;
    sonnet) model_id="claude-sonnet-4-6" ;;
    opus)   model_id="claude-opus-4-6" ;;
    *)      model_id="$model" ;;
  esac

  if [[ "$verbose" == true ]]; then
    claude -p "/gen-cmd $prompt" --model "$model_id" \
      --output-format stream-json --verbose --include-partial-messages 2>/dev/null \
      | jq -rj '
        # tool call start - show tool name
        if .type == "stream_event" and .event.content_block.type? == "tool_use" then
          "\u001b[36m⚡ \(.event.content_block.name)\u001b[0m"

        # completed tool call - show input summary
        elif .type == "assistant" then
          (.message.content // [] | .[] |
            select(.type == "tool_use") |
            if .name == "Bash" then
              "\u001b[2m → \(.input.command)\u001b[0m\n"
            elif .name == "Read" then
              "\u001b[2m → \(.input.file_path)\u001b[0m\n"
            elif .name == "Grep" then
              "\u001b[2m → /\(.input.pattern)/\u001b[0m\n"
            else
              "\u001b[2m → \(.input | tostring | .[0:80])\u001b[0m\n"
            end
          ) // empty

        # background task started
        elif .type == "system" and .subtype == "task_started" then
          "\u001b[33m⏳ \(.description)\u001b[0m\n"

        # background task completed
        elif .type == "system" and .subtype == "task_updated" and .patch.status? == "completed" then
          "\u001b[32m✓ done\u001b[0m\n"

        # thinking
        elif .type == "stream_event" and .event.delta.type? == "thinking_delta" and (.event.delta.thinking | length) > 0 then
          "\u001b[2m\(.event.delta.thinking)\u001b[0m"

        # thinking block end - newline separator
        elif .type == "stream_event" and .event.content_block.type? == "thinking" then
          "\u001b[2m💭 \u001b[0m"

        # final text output
        elif .type == "stream_event" and .event.delta.type? == "text_delta" then
          .event.delta.text

        else empty end
      '
    echo  # trailing newline
  else
    claude -p "/gen-cmd $prompt" --model "$model_id"
  fi
}
