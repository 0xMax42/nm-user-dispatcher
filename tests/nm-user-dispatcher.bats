#!/usr/bin/env bats
# shellcheck source-path=SCRIPTDIR/..

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${BATS_TEST_DIRNAME:=${TEST_DIR}}"

setup() {
  # shellcheck disable=SC2154
  export NMUD_DISPATCH_DIR="${BATS_TEST_TMPDIR}/hooks"
  mkdir -p "${NMUD_DISPATCH_DIR}"
  # shellcheck disable=SC1091
  source "${BATS_TEST_DIRNAME}/../scripts/nm-user-dispatcher"
  last_state=()
}

@test "seeds initial snapshot into connection map" {
  nmud_seed_initial_state $'eth0:connected\nwlan0:disconnected\ntun0:connecting (1%)'
  [[ "${last_state["eth0"]}" == "connected" ]]
  [[ "${last_state["wlan0"]}" == "disconnected" ]]
  [[ "${last_state["tun0"]}" == "connected" ]]
}

@test "state_from_message maps nmcli output" {
  run nmud_state_from_message 'connecting (configuring)'
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "connecting" ]]

  run nmud_state_from_message 'connected'
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "connected" ]]

  run nmud_state_from_message 'device removed'
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "disconnected" ]]

  run nmud_state_from_message 'unknown state'
  [[ "${status}" -ne 0 ]]
}

@test "state_to_event translates states" {
  run nmud_state_to_event 'connecting'
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "pre-up" ]]

  run nmud_state_to_event 'connected'
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "up" ]]

  run nmud_state_to_event 'disconnected'
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "down" ]]

  run nmud_state_to_event 'weird'
  [[ "${status}" -ne 0 ]]
}

@test "apply_state_change notifies only on transitions" {
  declare -a nmud_notify_log=()
  # shellcheck disable=SC2329,SC2317
  nmud_notify_hooks() {
    nmud_notify_log+=("$1:$2")
  }

  nmud_apply_state_change "eth0" "connected"
  nmud_apply_state_change "eth0" "connected"
  nmud_apply_state_change "eth0" "disconnected"
  nmud_apply_state_change "eth0" "unknown"

  [[ "${#nmud_notify_log[@]}" -eq 2 ]]
  [[ "${nmud_notify_log[0]}" == "eth0:up" ]]
  [[ "${nmud_notify_log[1]}" == "eth0:down" ]]
}

@test "handles monitor lines and emits events" {
  declare -a nmud_notify_log=()
  # shellcheck disable=SC2329,SC2317
  nmud_notify_hooks() {
    nmud_notify_log+=("$1:$2")
  }

  # shellcheck disable=SC2218
  nmud_handle_monitor_line 'wlan0: connecting (configuring)'
  # shellcheck disable=SC2218
  nmud_handle_monitor_line 'wlan0: connected'
  # shellcheck disable=SC2218
  nmud_handle_monitor_line 'wlan0: device removed'

  [[ "${#nmud_notify_log[@]}" -eq 3 ]]
  [[ "${nmud_notify_log[0]}" == "wlan0:pre-up" ]]
  [[ "${nmud_notify_log[1]}" == "wlan0:up" ]]
  [[ "${nmud_notify_log[2]}" == "wlan0:down" ]]
}

@test "trigger_hooks runs executable scripts in lexical order" {
  export HOOK_LOG="${BATS_TEST_TMPDIR}/hook.log"

  cat <<'EOF' >"${NMUD_DISPATCH_DIR}/10-first.sh"
#!/usr/bin/env bash
printf 'first:%s:%s\n' "${IFACE}" "${EVENT}" >>"${HOOK_LOG}"
EOF
  chmod +x "${NMUD_DISPATCH_DIR}/10-first.sh"

  cat <<'EOF' >"${NMUD_DISPATCH_DIR}/20-second.sh"
#!/usr/bin/env bash
printf 'second:%s:%s\n' "${IFACE}" "${EVENT}" >>"${HOOK_LOG}"
EOF
  chmod +x "${NMUD_DISPATCH_DIR}/20-second.sh"

  cat <<'EOF' >"${NMUD_DISPATCH_DIR}/30-not-exec.sh"
#!/usr/bin/env bash
echo "should not run" >>"${HOOK_LOG}"
EOF

  touch "${NMUD_DISPATCH_DIR}/90-ignore.txt"

  trigger_hooks "eth0" "up"

  mapfile -t hook_lines <"${HOOK_LOG}"
  [[ "${#hook_lines[@]}" -eq 2 ]]
  [[ "${hook_lines[0]}" == "first:eth0:up" ]]
  [[ "${hook_lines[1]}" == "second:eth0:up" ]]
}

@test "monitor loop consumes provided fd" {
  declare -a handled_lines=()
  nmud_handle_monitor_line() {
    handled_lines+=("$1")
  }

  exec {loop_fd}< <(printf 'wlan0: connecting (configuring)\nwlan0: connected\n')
  nmud_monitor_loop "${loop_fd}"
  exec {loop_fd}>&-

  [[ "${#handled_lines[@]}" -eq 2 ]]
  [[ "${handled_lines[0]}" == "wlan0: connecting (configuring)" ]]
  [[ "${handled_lines[1]}" == "wlan0: connected" ]]
}
