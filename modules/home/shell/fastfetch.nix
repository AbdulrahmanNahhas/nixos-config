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
          "left": 2
        },
        "color": {
          "1": "blue",
          "2": "white"
        }
      },
      "display": {
        "separator": " ",
        "color": "bright_blue"
      },
      "modules": [
        {
          "type": "custom",
          "key": "{#7} [HARDWARE DEEP DIVE] {#}{#34}\uE0B0",
          "keyColor": "bright_blue"
        },
        {
          "type": "cpu",
          "key": "\u251C\u2500 \uE266 CPU  ",
          "keyColor": "bright_blue"
        },
        {
          "type": "gpu",
          "key": "\u251C\u2500 \uF1FC GPU  ",
          "keyColor": "bright_blue",
          "hideType": "integrated"
        },
        {
          "type": "memory",
          "key": "\u251C\u2500 \uEFC5 RAM  ",
          "keyColor": "bright_blue"
        },
        {
          "type": "swap",
          "key": "\u251C\u2500 \uF0E4 SWAP ",
          "keyColor": "bright_blue"
        },
        {
          "type": "disk",
          "key": "\u251C\u2500 \uF0A0 DSK  ",
          "keyColor": "bright_blue",
          "format": "{size-used} / {size-total} ({size-percentage}) - {mountpoint} ({filesystem})"
        },
        {
          "type": "battery",
          "key": "\u251C\u2500 \uF240 BAT  ",
          "keyColor": "bright_blue"
        },
        {
          "type": "poweradapter",
          "key": "\u251C\u2500 \uF0E7 PWR  ",
          "keyColor": "bright_blue"
        },
        {
          "type": "display",
          "key": "\u2514\u2500 \uF108 RES  ",
          "keyColor": "bright_blue"
        },
        "break",
        {
          "type": "custom",
          "key": "{#7} [SYSTEM CORE] {#}{#34}\uE0B0",
          "keyColor": "bright_blue"
        },
        {
          "type": "kernel",
          "key": "\u251C\u2500 \uF17C KER  ",
          "keyColor": "bright_blue"
        },
        {
          "type": "gpu",
          "key": "\u251C\u2500 \uF0AD DRV  ",
          "keyColor": "bright_blue",
          "driverSpecific": true,
          "format": "{driver}"
        },
        {
          "type": "wm",
          "key": "\u251C\u2500 \uF2D0 WM   ",
          "keyColor": "bright_blue"
        },
        {
          "type": "de",
          "key": "\u2514\u2500 \uF26C DE   ",
          "keyColor": "bright_blue"
        },
        "break",
        {
          "type": "custom",
          "key": "{#7} [SYSTEM & UI] {#}{#34}\uE0B0",
          "keyColor": "bright_blue"
        },
        {
          "type": "os",
          "key": "\u251C\u2500 \uF179 OS   ",
          "keyColor": "bright_blue"
        },
        {
          "type": "host",
          "key": "\u251C\u2500 \uF109 HOST ",
          "keyColor": "bright_blue"
        },
        {
          "type": "bootloader",
          "key": "\u251C\u2500 \uF013 BOOT ",
          "keyColor": "bright_blue"
        },
        {
          "type": "shell",
          "key": "\u251C\u2500 \uE795 SH   ",
          "keyColor": "bright_blue"
        },
        {
          "type": "font",
          "key": "\u251C\u2500 \uF031 FONT ",
          "keyColor": "bright_blue"
        },
        {
          "type": "terminal",
          "key": "\u251C\u2500 \uF120 TERM ",
          "keyColor": "bright_blue"
        },
        {
          "type": "packages",
          "key": "\u251C\u2500 \uF187 PKG  ",
          "keyColor": "bright_blue"
        },
        {
          "type": "users",
          "key": "\u251C\u2500 \uF007 USER ",
          "keyColor": "bright_blue",
          "format": "{1}"
        },
        {
          "type": "datetime",
          "key": "\u251C\u2500 \uF017 TIME ",
          "keyColor": "bright_blue"
        },
        {
          "type": "uptime",
          "key": "\u2514\u2500 \uF254 UPT  ",
          "keyColor": "bright_blue"
        }
      ]
    }
  '';
}
