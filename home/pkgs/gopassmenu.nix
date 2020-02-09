{ pkgs, ... }:
let
  alacritty = "${pkgs.alacritty}/bin/alacritty";
  fzf = "${pkgs.fzf}/bin/fzf";
  gopass = "${pkgs.gopass}/bin/gopass";
  notify-send = "${pkgs.libnotify}/bin/notify-send";
  rg = "${pkgs.ripgrep}/bin/rg";
  wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
in
''
  gopassmenu_path="$(readlink -f "$0")"
  gopassmenu_fifo="/tmp/gopassmenu_fifo"
  gopassmenu_lock="/tmp/gopassmenu_lock"

  function gopassmenu_lock() {
      if [[ -f "$gopassmenu_lock" ]]; then
          ${notify-send} "✖️ gopassmenu already running"
          exit 1
      else
          touch "$gopassmenu_lock"
      fi
  }

  function gopassmenu_unlock() {
      if [[ -f "$gopassmenu_lock" ]]; then
          rm -f "$gopassmenu_lock"
      fi
  }

  function gopassmenu_window() {
      name="$(${gopass} ls -f | ${rg} "$GOPASS_FILTER" | ${fzf})"
      echo "$name" > "$gopassmenu_fifo"
  }

  function gopassmenu_backend() {
      gopassmenu_lock
      export GOPASSMENU_BEHAVE_AS_WINDOW=1
      ${alacritty} -d 80 20 -t gopassmenu -e "$gopassmenu_path"

      name="$(cat "$gopassmenu_fifo")"
      rm -f "$gopassmenu_fifo"
      if [ "$name" == "" ]; then
          gopassmenu_unlock
          exit 1
      fi

      local password="$(gopass_get "$name")"
      ${wl-copy} -o "$password"
      gopassmenu_unlock
  }

  if [[ -v GOPASSMENU_BEHAVE_AS_WINDOW ]]; then
      gopassmenu_window
  else
      gopassmenu_backend
  fi
''
