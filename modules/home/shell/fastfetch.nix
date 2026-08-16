_: {
  xdg.configFile."fastfetch/fastfetch.txt".source = ./fastfetch.txt;

  xdg.configFile."fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",

      "logo": {
        "source": "~/.config/fastfetch/fastfetch.txt",
        "type": "file",
        "padding": {
          "top": 0,
          "left": 2,
          "right": 2
        },
        "color": {
          "1": "blue",
          "2": "white"
        }
      },

      "display": {
        "separator": " ",
        "color": "bright_blue",
        "key": {
          "width": 15
        },
        "size": {
          "binaryPrefix": "iec",
          "maxPrefix": "TB",
          "ndigits": 2
        }
      },

      "modules": [
        {
          "type": "custom",
          "key": "{#7} [HARDWARE] {#}{#34}\uE0B0",
          "keyColor": "bright_blue"
        },
        {
          "type": "cpu",
          "key": "\u251C\u2500 \uE266 CPU",
          "keyColor": "bright_blue",
          "format": "{name} ({cores-physical}C/{cores-logical}T)"
        },
        {
          "type": "gpu",
          "key": "\u251C\u2500 \uF1FC iGPU",
          "keyColor": "bright_blue",
          "hideType": "discrete",
          "format": "{name}"
        },
        {
          "type": "gpu",
          "key": "\u251C\u2500 \uF1FC dGPU",
          "keyColor": "bright_blue",
          "hideType": "integrated",
          "format": "{name}"
        },
        {
          "type": "memory",
          "key": "\u251C\u2500 \uEFC5 RAM",
          "keyColor": "bright_blue",
          "format": "{used} / {total} ({percentage})"
        },
        {
          "type": "swap",
          "key": "\u251C\u2500 \uF0E4 SWAP",
          "keyColor": "bright_blue",
          "format": "{used} / {total} ({percentage})"
        },
        {
          "type": "disk",
          "key": "\u251C\u2500 \uF0A0 DISK",
          "keyColor": "bright_blue",
          "folders": "/",
          "format": "{size-used} / {size-total} ({size-percentage}) \u00B7 {filesystem}"
        },
        {
          "type": "battery",
          "key": "\u251C\u2500 \uF240 BAT",
          "keyColor": "bright_blue",
          "format": "{capacity} \u00B7 {status} \u00B7 {time-formatted}"
        },
        {
          "type": "poweradapter",
          "key": "\u251C\u2500 \uF0E7 PWR",
          "keyColor": "bright_blue",
          "format": "{watts}W \u00B7 {name}"
        },
        {
          "type": "display",
          "key": "\u2514\u2500 \uF108 DISP",
          "keyColor": "bright_blue",
          "format": "{scaled-width}x{scaled-height} @ {refresh-rate} Hz"
        },

        "break",

        {
          "type": "custom",
          "key": "{#7} [SYSTEM CORE] {#}{#34}\uE0B0",
          "keyColor": "bright_blue"
        },
        {
          "type": "os",
          "key": "\u251C\u2500 \uF313 OS",
          "keyColor": "bright_blue",
          "format": "{pretty-name} ({arch})"
        },
        {
          "type": "host",
          "key": "\u251C\u2500 \uF109 HOST",
          "keyColor": "bright_blue",
          "format": "{vendor} {name}"
        },
        {
          "type": "kernel",
          "key": "\u251C\u2500 \uF17C KERN",
          "keyColor": "bright_blue",
          "format": "{release}"
        },
        {
          "type": "initsystem",
          "key": "\u251C\u2500 \uF013 INIT",
          "keyColor": "bright_blue",
          "format": "{name} {version}"
        },
        {
          "type": "bootmgr",
          "key": "\u2514\u2500 \uF11E BOOT",
          "keyColor": "bright_blue",
          "format": "{name} \u00B7 Secure Boot: {secure-boot}"
        },

        "break",

        {
          "type": "custom",
          "key": "{#7} [WAYLAND STACK] {#}{#34}\uE0B0",
          "keyColor": "bright_blue"
        },
        {
          "type": "wm",
          "key": "\u251C\u2500 \uF2D0 WM",
          "keyColor": "bright_blue",
          "format": "{pretty-name} {version} ({protocol-name})"
        },
        {
          "type": "command",
          "key": "\u251C\u2500 \uF186 SHELL",
          "keyColor": "bright_blue",
          "text": "command -v noctalia >/dev/null 2>&1 && noctalia --version | awk '{print $2}'",
          "format": "Noctalia {result}",
          "condition": {
            "succeeded": true
          }
        },
        {
          "type": "command",
          "key": "\u251C\u2500 \uF2DC NIX",
          "keyColor": "bright_blue",
          "text": "command -v nix >/dev/null 2>&1 && nix --version | awk '{print $3}'",
          "format": "Nix {result}",
          "condition": {
            "succeeded": true
          }
        },
        {
          "type": "command",
          "key": "\u2514\u2500 \uF487 FLATPAK",
          "keyColor": "bright_blue",
          "text": "command -v flatpak >/dev/null 2>&1 && flatpak --version | awk '{print $2}'",
          "format": "Flatpak {result}",
          "condition": {
            "succeeded": true
          }
        },

        "break",

        {
          "type": "custom",
          "key": "{#7} [USER ENVIRONMENT] {#}{#34}\uE0B0",
          "keyColor": "bright_blue"
        },
        {
          "type": "shell",
          "key": "\u251C\u2500 \uE795 SH",
          "keyColor": "bright_blue",
          "format": "{pretty-name} {version}"
        },
        {
          "type": "terminal",
          "key": "\u251C\u2500 \uF120 TERM",
          "keyColor": "bright_blue",
          "format": "{pretty-name} {version}"
        },
        {
          "type": "terminalfont",
          "key": "\u251C\u2500 \uF031 FONT",
          "keyColor": "bright_blue",
          "format": "{name} {size}"
        },
        {
          "type": "packages",
          "key": "\u251C\u2500 \uF187 PKGS",
          "keyColor": "bright_blue",
          "combined": false,
          "format": "{nix-all} Nix \u00B7 {flatpak-all} Flatpak"
        },
        {
          "type": "locale",
          "key": "\u251C\u2500 \uF57D LOCALE",
          "keyColor": "bright_blue"
        },
        {
          "type": "datetime",
          "key": "\u251C\u2500 \uF017 TIME",
          "keyColor": "bright_blue",
          "format": "{year}-{month-pretty}-{day-pretty} {hour-pretty}:{minute-pretty}"
        },
        {
          "type": "uptime",
          "key": "\u2514\u2500 \uF254 UPTIME",
          "keyColor": "bright_blue",
          "format": "{formatted}"
        }
      ]
    }
  '';
}
