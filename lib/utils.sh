check_dependencies() {
    local missing=()
    command -v yt-dlp >/dev/null || missing+=("yt-dlp")
    command -v ffmpeg >/dev/null || missing+=("ffmpeg")
    command -v whiptail >/dev/null || missing+=("whiptail")

    if [[ ${#missing[@]} -gt 0 ]]; then
        whiptail \
            --title "Dependencias faltantes" \
            --msgbox "Instala:\n\n${missing[*]}" \
            12 60
        exit 1
    fi
}

get_target_inputs() {
    local default_dir="$1"
    
    TARGET_URL=$(whiptail --inputbox "Ingrese la URL" 10 70 3>&1 1>&2 2>&3) || return 1
    TARGET_DIR=$(whiptail --inputbox "Directorio destino" 10 70 "$default_dir" 3>&1 1>&2 2>&3) || return 1

    mkdir -p "$TARGET_DIR"
    return 0
}

execute_download() {
    clear
    if "$@"; then
        whiptail --title "Éxito" --msgbox "Descarga completada correctamente." 10 50
    else
        whiptail --title "Error" --msgbox "Ocurrió un problema durante la descarga. Verifica la URL o tu conexión." 10 60
    fi
}