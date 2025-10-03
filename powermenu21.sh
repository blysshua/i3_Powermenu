#!/bin/bash

options=("󰍃 Logout" "󰤄 Suspend" " Reboot" "⏻ Shutdown")
selected=0

# Draw confirmation box
confirm_box() {
    clear
    echo "  ૮ ◞ ﻌ ◟ა u sure?"
    echo " ╭────────────────"
    echo -n " │ [Y/n]: "
    echo -e "\n ╭────────────────\n │  $(date +"%T")"
    echo -e " ╭────────────────\n │  $(uptime -p | sed 's/^up //; s/hours/hrs/; s/hour/hr/; s/minutes/mins/; s/minute/min/')"
    echo -e " ╭────────────────\n │ 󰁽 $(cat /sys/class/power_supply/BAT0/capacity)%"
    read -rsn1 choice
    case "$choice" in
        n|N|h|H ) return 1 ;;
        q|Q|$'\e') echo; exit 0 ;;
        * ) return 0 ;;
    esac
}


draw_menu() {
    clear
    echo "  ૮ ◞ ﻌ ◟ა u goin?"
    echo " ╭────────────────"
    for i in "${!options[@]}"; do
        if [ "$i" -eq "$selected" ]; then
            printf " │ \e[7m%s\e[0m\n" "${options[$i]}"
        else
            printf " │ %s\n" "${options[$i]}"
        fi

        if [ "$i" -lt $((${#options[@]} - 1)) ]; then
            echo " ╭────────────────"
        fi
    done
}

while true; do
    draw_menu
    read -rsn1 key
    if [[ $key == $'\x1b' ]]; then
        read -rsn2 -t 0.001 key
        case $key in
            "[A") ((selected--)) ;;
            "[B") ((selected++)) ;;
            "[D") continue ;;
            "[C") continue ;;
        esac
    else
        case $key in
            k) ((selected--)) ;; # Vim up
            j) ((selected++)) ;; # Vim down
            l|"") # Enter / Vim enter
                case $selected in
                    0)
                        if confirm_box; then
                            echo "Logging out..."
                            pkill -KILL -u "$USER"
                        fi ;;
                    1)
                        if confirm_box; then
                            echo "Suspending..."
                            systemctl suspend
                        fi ;;
                    2)
                        if confirm_box; then
                            echo "Rebooting..."
                            systemctl reboot
                        fi ;;
                    3)
                        if confirm_box; then
                            echo "Shutting down..."
                            systemctl poweroff
                        fi ;;
                esac ;;
            q|$'\e') echo; exit 0 ;;
        esac
    fi

    # Wrap selection
    if [ "$selected" -lt 0 ]; then
        selected=$((${#options[@]} - 1))
    elif [ "$selected" -ge "${#options[@]}" ]; then
        selected=0
    fi
done
