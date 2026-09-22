show_media_info() {
    local url="$1"
    local title
    local extractor

    title=$(yt-dlp --print title "$url" 2>/dev/null | head -n1 || true)
    extractor=$(yt-dlp --print extractor "$url" 2>/dev/null | head -n1 || true)

    whiptail \
        --title "Información detectada" \
        --msgbox "Plataforma: ${extractor:-Desconocida}\n\nTítulo/Lista:\n${title:-No disponible}" \
        15 70
}

get_download_mode() {
    local mode
    mode=$(
        whiptail \
        --title "Modo de Descarga" \
        --menu "Seleccione el tipo de enlace" \
        15 60 2 \
        "1" "Archivo Individual" \
        "2" "Lista de Reproducción / Álbum" \
        3>&1 1>&2 2>&3
    ) || return 1

    if [[ "$mode" == "2" ]]; then
        DL_MODE_FLAGS=("--yes-playlist" "-o" "%(playlist_title)s/%(playlist_index)02d - %(title)s.%(ext)s")
    else
        DL_MODE_FLAGS=("--no-playlist" "-o" "%(title)s.%(ext)s")
    fi
    return 0
}

download_video() {
    local quality
    local format

    get_download_mode || return

    quality=$(
        whiptail --title "Video" --menu "Seleccione calidad" 15 60 5 \
        "720" "720p" "1080" "1080p" "MAX" "Máxima calidad" 3>&1 1>&2 2>&3
    ) || return

    get_target_inputs "$VIDEO_DIR" || return
    show_media_info "$TARGET_URL"

    case "$quality" in
        720)  format="bestvideo[height<=720]+bestaudio/best[height<=720]" ;;
        1080) format="bestvideo[height<=1080]+bestaudio/best[height<=1080]" ;;
        MAX)  format="bestvideo+bestaudio/best" ;;
    esac

    execute_download yt-dlp -f "$format" --merge-output-format mp4 "${DL_MODE_FLAGS[@]}" -P "$TARGET_DIR" "$TARGET_URL"
}

download_audio() {
    local quality

    get_download_mode || return

    quality=$(
        whiptail --title "Audio" --menu "Seleccione calidad" 15 60 5 \
        "MP3" "320 kbps" "BEST" "Mejor calidad disponible" 3>&1 1>&2 2>&3
    ) || return

    get_target_inputs "$AUDIO_DIR" || return
    show_media_info "$TARGET_URL"

    case "$quality" in
        MP3) execute_download yt-dlp -x --audio-format mp3 --audio-quality 0 "${DL_MODE_FLAGS[@]}" -P "$TARGET_DIR" "$TARGET_URL" ;;
        BEST) execute_download yt-dlp -x "${DL_MODE_FLAGS[@]}" -P "$TARGET_DIR" "$TARGET_URL" ;;
    esac
}