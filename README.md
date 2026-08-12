# nm-user-dispatcher

Per-user NetworkManager event dispatcher for Linux desktops.

`nm-user-dispatcher` runs as a `systemd --user` service, watches `nmcli monitor`, and executes user-defined hook scripts when NetworkManager devices change state. Hooks are stored in the current user's configuration directory, so each user can react to network events without installing scripts into the system-wide NetworkManager dispatcher directory.

## Features

- Runs once per logged-in user through a systemd user unit.
- Watches NetworkManager device state changes via `nmcli monitor`.
- Executes executable `*.sh` hooks from `~/.config/networkmanager/dispatcher.d/`.
- Supports `pre-up`, `up`, and `down` events.
- Passes the interface and event both as script arguments and environment variables.
- Runs hooks sequentially in lexical filename order.

## Requirements

- Linux with systemd user services
- NetworkManager with `nmcli`
- Bash
- `find`, `sort`, and `date` from a standard userland
- `bats-core` only when running the test suite

## Installation

### From Source

Install the dispatcher and systemd user unit:

```sh
sudo make install
```

The default installation paths are:

- `/usr/libexec/nm-user-dispatcher`
- `/usr/lib/systemd/user/nm-user-dispatcher.service`
- `/usr/share/nm-user-dispatcher/VERSION`

After installing from source, reload the systemd user manager and enable the service for your user:

```sh
systemctl --user daemon-reload
systemctl --user enable --now nm-user-dispatcher.service
```

To install into a packaging root, use `DESTDIR`:

```sh
make install DESTDIR=/tmp/package-root
```

To uninstall files installed by the Makefile:

```sh
sudo make uninstall
```

### Debian Package

The Debian packaging installs the dispatcher and enables `nm-user-dispatcher.service` globally for users through `systemctl enable --global`. On purge, the package disables the global user service again.

## Usage

Create the dispatcher hook directory for your user:

```sh
mkdir -p ~/.config/networkmanager/dispatcher.d
```

Add executable shell scripts with a `.sh` suffix. Scripts are executed in lexical order, so numeric prefixes are useful:

```sh
install -m 0755 /path/to/your-hook.sh ~/.config/networkmanager/dispatcher.d/10-your-hook.sh
```

Each hook receives the interface name and event in two ways:

- Argument 1: interface name, for example `wlan0`
- Argument 2: event name, for example `up`
- Environment variable `IFACE`: interface name
- Environment variable `EVENT`: event name

Supported events are:

- `pre-up`: the device entered a connecting state
- `up`: the device entered a connected state
- `down`: the device disconnected, deactivated, or was removed

## Hook Example

Create `~/.config/networkmanager/dispatcher.d/10-log-network-event.sh`:

```sh
#!/usr/bin/env bash
set -euo pipefail

printf '%s %s %s\n' "$(date '+%F %T')" "${IFACE}" "${EVENT}" >>"${HOME}/network-events.log"
```

Make it executable:

```sh
chmod +x ~/.config/networkmanager/dispatcher.d/10-log-network-event.sh
```

The same hook can also use positional arguments:

```sh
#!/usr/bin/env bash
set -euo pipefail

iface="$1"
event="$2"

case "${event}" in
  up)
    notify-send "Network connected" "${iface} is up"
    ;;
  down)
    notify-send "Network disconnected" "${iface} is down"
    ;;
esac
```

## Service Management

Start the dispatcher for the current user:

```sh
systemctl --user start nm-user-dispatcher.service
```

Enable it for future graphical sessions:

```sh
systemctl --user enable nm-user-dispatcher.service
```

Check its status:

```sh
systemctl --user status nm-user-dispatcher.service
```

View logs:

```sh
journalctl --user -u nm-user-dispatcher.service
```

Restart after changing hooks or updating the dispatcher:

```sh
systemctl --user restart nm-user-dispatcher.service
```

## Configuration

By default, hooks are loaded from:

```text
${XDG_CONFIG_HOME:-$HOME/.config}/networkmanager/dispatcher.d
```

For testing or custom setups, override the hook directory with `NMUD_DISPATCH_DIR`:

```sh
NMUD_DISPATCH_DIR=/path/to/hooks /usr/libexec/nm-user-dispatcher
```

The script also supports overriding command paths with these environment variables:

- `NMUD_NMCLI_BIN`
- `NMUD_FIND_BIN`
- `NMUD_SORT_BIN`
- `NMUD_DATE_BIN`

## Development

Run the test suite with:

```sh
make test
```

Tests require `bats-core`.

The Makefile supports these targets:

- `make build`: no-op build target
- `make test`: run Bats tests
- `make install`: install dispatcher, systemd unit, and version file
- `make uninstall`: remove installed files
- `make clean`: no-op clean target

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
