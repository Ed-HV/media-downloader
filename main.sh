#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/lib/config.sh"
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/downloader.sh"

settings_menu() {
    while true; do
        local option
        option=$(
            whiptail \
            --title "Configuración" \
            --menu "Opciones" \
            18 70 8 \
            "1" "Cambiar carpeta de Video" \
            "2" "Cambiar carpeta de Audio" \
            "3" "Actualizar yt-dlp" \
            "4" "Ver configuración actual" \
            "5" "Volver" \
            3>&1 1>&2 2>&3
        ) || return

        case "$option" in
            1)
                VIDEO_DIR=$(whiptail --inputbox "Nueva carpeta para videos" 10 70 "$VIDEO_DIR" 3>&1 1>&2 2>&3) || continue
                mkdir -p "$VIDEO_DIR"
                ;;
            2)
                AUDIO_DIR=$(whiptail --inputbox "Nueva carpeta para audio" 10 70 "$AUDIO_DIR" 3>&1 1>&2 2>&3) || continue
                mkdir -p "$AUDIO_DIR"
                save_config
                ;;
            3)
                clear
                if yt-dlp -U; then
                    whiptail --msgbox "Actualización finalizada con éxito." 10 50
                else
                    whiptail --title "Error" --msgbox "No se pudo actualizar yt-dlp." 10 50
                fi
                ;;
            4)
                whiptail --title "Configuración actual" --msgbox "Video:\n$VIDEO_DIR\n\nAudio:\n$AUDIO_DIR" 15 70
                ;;
            5) return ;;
        esac
    done
}

main_menu() {
    while true; do
        local option
        option=$(
            whiptail \
            --title "Media Downloader" \
            --menu "Seleccione una opción" \
            18 70 8 \
            "1" "Descargar Video" \
            "2" "Descargar Audio" \
            "3" "Configuración" \
            "4" "Salir" \
            3>&1 1>&2 2>&3
        ) || exit 0

        case "$option" in
            1) download_video ;;
            2) download_audio ;;
            3) settings_menu ;;
            4) clear; exit 0 ;;
        esac
    done
}

init_config
load_config
check_dependencies
main_menu