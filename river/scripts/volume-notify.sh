#!/bin/bash

case "$1" in
    up)   wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1 ;;
    down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- -l 1 ;;
    toggle) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    mic) wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle ;;
esac

if command -v makoctl &> /dev/null; then
    NOTIFY="mako"
elif command -v dunstify &> /dev/null; then
    NOTIFY="dunst"
fi

percent=0

if [ "$1" = "mic" ]; then
    vol=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
    muted=$(echo "$vol" | grep -o "MUTED" || true)
    if [ "$muted" ]; then
        text="MIC MUTED"
    else
        percent=$(echo "$vol" | awk '{print int($2 * 100)}')
        text="MIC ${percent}%"
    fi
else
    vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
    muted=$(echo "$vol" | grep -o "MUTED" || true)
    if [ "$muted" ]; then
        text="VOL MUTED"
    else
        percent=$(echo "$vol" | awk '{print int($2 * 100)}')
        text="VOL ${percent}%"
    fi
fi

case "$NOTIFY" in
    mako)
        if [ "$percent" -eq 0 ]; then
            notify-send -a "wp-vol" -t 1500 -h string:x-canonical-private-synchronous:volume "$text"
        else
            notify-send -a "wp-vol" -t 1500 -h string:x-canonical-private-synchronous:volume -h "int:value:$percent" "$text"
        fi
        ;;
    dunst)
        if [ "$percent" -eq 0 ]; then
            dunstify -a "wp-vol" -r 12345 "$text" -t 1500
        else
            dunstify -a "wp-vol" -r 12345 -h "int:value:$percent" "$text" -t 1500
        fi
        ;;
esac
