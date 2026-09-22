CONFIG_DIR="$HOME/.config/media-downloader"
CONFIG_FILE="$CONFIG_DIR/config"

mkdir -p "$CONFIG_DIR"

init_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        cat > "$CONFIG_FILE" <<EOF
VIDEO_DIR=$HOME/Videos
AUDIO_DIR=$HOME/Music
EOF
    fi
}

load_config() {
    source "$CONFIG_FILE"
}

save_config() {
    cat > "$CONFIG_FILE" <<EOF
VIDEO_DIR=$VIDEO_DIR
AUDIO_DIR=$AUDIO_DIR
EOF
}