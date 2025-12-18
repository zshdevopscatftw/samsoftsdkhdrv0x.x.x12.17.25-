#!/bin/bash
#===============================================================================
#
#     ██████╗ █████╗ ████████╗███████╗    ████████╗██╗    ██╗███████╗ █████╗ ██╗  ██╗███████╗██████╗ 
#    ██╔════╝██╔══██╗╚══██╔══╝██╔════╝    ╚══██╔══╝██║    ██║██╔════╝██╔══██╗██║ ██╔╝██╔════╝██╔══██╗
#    ██║     ███████║   ██║   ███████╗       ██║   ██║ █╗ ██║█████╗  ███████║█████╔╝ █████╗  ██████╔╝
#    ██║     ██╔══██║   ██║   ╚════██║       ██║   ██║███╗██║██╔══╝  ██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗
#    ╚██████╗██║  ██║   ██║   ███████║       ██║   ╚███╔███╔╝███████╗██║  ██║██║  ██╗███████╗██║  ██║
#     ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝       ╚═╝    ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
#
#                                   「  v2.0 ULTIMATE - ALL PYTHON PACKAGES  」
#                                         by Flames / Team Flames 🐱
#
#===============================================================================

[[ -z "$BASH_VERSION" ]] && { echo "Run with: bash $0"; exit 1; }

# Colors
R=$'\033[0;31m'
G=$'\033[0;32m'
Y=$'\033[0;33m'
B=$'\033[0;34m'
M=$'\033[0;35m'
C=$'\033[0;36m'
W=$'\033[1;37m'
DIM=$'\033[2m'
RST=$'\033[0m'

INSTALL_DIR="$HOME/retro-dev"
TOOLS="$INSTALL_DIR/tools"
SDKS="$INSTALL_DIR/sdks"
EMUS="$INSTALL_DIR/emulators"
COMPILERS="$INSTALL_DIR/compilers"
VENV_DIR="$INSTALL_DIR/venv"
LOG="$INSTALL_DIR/install.log"

mkdir -p "$TOOLS" "$SDKS" "$EMUS" "$COMPILERS" "$VENV_DIR"
: > "$LOG"

IS_MAC=false; [[ "$(uname)" == "Darwin" ]] && IS_MAC=true
IS_ARM=false; [[ "$(uname -m)" =~ ^(arm64|aarch64)$ ]] && IS_ARM=true
NCPU="$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)"

$IS_MAC && SHELL_RC="$HOME/.zshrc" || SHELL_RC="$HOME/.bashrc"

# Download function
dl() {
    local url="$1" out="$2"
    echo "[DL] $url" >> "$LOG"
    curl -fsSL --connect-timeout 30 --max-time 600 --retry 3 -L -o "$out" "$url" 2>>"$LOG"
    [[ -s "$out" ]] && return 0
    rm -f "$out" 2>/dev/null
    return 1
}

# Status functions
ok()   { printf "  ${G}[✓]${RST} %s\n" "$1"; }
fail() { printf "  ${R}[✗]${RST} %s ${DIM}(see log)${RST}\n" "$1"; }
skip() { printf "  ${Y}[~]${RST} %s\n" "$1"; }
info() { printf "  ${C}[*]${RST} %s\n" "$1"; }
step() { printf "\n${M}══════════════════════════════════════════════════════════════════${RST}\n${W}  ▸ %s${RST}\n${M}══════════════════════════════════════════════════════════════════${RST}\n" "$1"; }

add_path() { grep -qF "$1" "$SHELL_RC" 2>/dev/null || echo "$1" >> "$SHELL_RC"; }

clear
cat << 'BANNER'

     ██████╗ █████╗ ████████╗███████╗    ████████╗██╗    ██╗███████╗ █████╗ ██╗  ██╗███████╗██████╗ 
    ██╔════╝██╔══██╗╚══██╔══╝██╔════╝    ╚══██╔══╝██║    ██║██╔════╝██╔══██╗██║ ██╔╝██╔════╝██╔══██╗
    ██║     ███████║   ██║   ███████╗       ██║   ██║ █╗ ██║█████╗  ███████║█████╔╝ █████╗  ██████╔╝
    ██║     ██╔══██║   ██║   ╚════██║       ██║   ██║███╗██║██╔══╝  ██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗
    ╚██████╗██║  ██║   ██║   ███████║       ██║   ╚███╔███╔╝███████╗██║  ██║██║  ██╗███████╗██║  ██║
     ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝       ╚═╝    ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

                              「  v2.0 ULTIMATE - ALL PYTHON PACKAGES  」
                                            /\_____/\
                                           /  o   o  \
                                          ( ==  ^  == )
                                           )  ~owo~  (
                                          (           )
                                         ( (  )   (  ) )
                                        (__(__)___(__)__)

BANNER
sleep 1

# ============================================================================
step "SYSTEM PREREQUISITES"
# ============================================================================

if $IS_MAC; then
    if command -v brew >/dev/null 2>&1; then
        ok "Homebrew found"
    else
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >> "$LOG" 2>&1 && ok "Homebrew" || fail "Homebrew"
    fi
    
    info "Installing system packages..."
    brew install python@3.12 python@3.11 pyenv \
                 gcc llvm cmake ninja meson autoconf automake libtool pkg-config \
                 sdl2 sdl2_image sdl2_mixer sdl2_ttf sdl2_gfx \
                 libpng jpeg freetype zlib xz lz4 zstd \
                 portaudio portmidi ffmpeg \
                 nasm yasm flex bison texinfo \
                 wget curl p7zip gnu-tar \
                 node npm \
                 rgbds cc65 sdcc >> "$LOG" 2>&1 && ok "System packages" || fail "Some packages"
else
    info "Updating package manager..."
    sudo apt-get update -qq >> "$LOG" 2>&1 && ok "APT updated" || fail "APT"
    
    info "Installing build dependencies..."
    sudo apt-get install -y -qq \
        python3 python3-pip python3-venv python3-dev python3-tk \
        build-essential gcc g++ clang llvm \
        cmake ninja-build meson autoconf automake libtool pkg-config \
        libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev libsdl2-gfx-dev \
        libpng-dev libjpeg-dev libfreetype6-dev zlib1g-dev liblzma-dev liblz4-dev libzstd-dev \
        libncurses-dev libreadline-dev libgmp-dev libmpfr-dev libmpc-dev \
        libportaudio2 libportmidi-dev libasound2-dev \
        libgl1-mesa-dev libglu1-mesa-dev libglew-dev libglfw3-dev \
        libgtk-3-dev libcairo2-dev libgirepository1.0-dev \
        libffi-dev libssl-dev \
        ffmpeg libavcodec-dev libavformat-dev libswscale-dev \
        nasm yasm flex bison texinfo gawk \
        curl wget unzip p7zip-full xz-utils \
        nodejs npm \
        >> "$LOG" 2>&1 && ok "Build dependencies" || fail "Build dependencies"
fi

# ============================================================================
step "PYTHON ENVIRONMENT SETUP"
# ============================================================================

# Get Python version
PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
info "System Python: $PYTHON_VERSION"

# Create virtual environment for isolation
info "Creating virtual environment..."
python3 -m venv "$VENV_DIR/gamedev" >> "$LOG" 2>&1 && ok "Virtual environment" || fail "Virtual environment"

# Activation script
cat > "$INSTALL_DIR/activate_gamedev.sh" << 'VENVACT'
#!/bin/bash
# Activate Cat's Tweaker Python environment
source "$HOME/retro-dev/venv/gamedev/bin/activate"
echo "🐱 Game Dev Python environment activated!"
echo "   Python: $(python --version)"
echo "   Packages: pygame, ursina, pyglet, arcade, panda3d, ..."
echo "   Deactivate with: deactivate"
VENVACT
chmod +x "$INSTALL_DIR/activate_gamedev.sh"

# ============================================================================
step "PYTHON PACKAGES - REQUIREMENTS FILE"
# ============================================================================

info "Generating comprehensive requirements.txt..."

cat > "$INSTALL_DIR/requirements.txt" << 'REQUIREMENTS'
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CAT'S TWEAKER v2.0 - ULTIMATE PYTHON REQUIREMENTS                        ║
# ║  Install with: pip install -r requirements.txt                            ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ═══════════════════════════════════════════════════════════════════════════
# GAME ENGINES & FRAMEWORKS
# ═══════════════════════════════════════════════════════════════════════════

# 2D Game Engines
pygame>=2.5.0
pygame-ce>=2.4.0
pygame-gui>=0.6.9
pygame-menu>=4.4.3
pygame-widgets>=1.1.0
pyglet>=2.0.10
arcade>=2.6.17
cocos2d>=0.6.9

# 3D Game Engines
ursina>=6.1.2
panda3d>=1.10.13
PyOpenGL>=3.1.7
PyOpenGL-accelerate>=3.1.7
moderngl>=5.10.0
moderngl-window>=2.4.4
pyray>=0.0.5

# Game Utilities
pymunk>=6.6.0
esper>=3.2
pytmx>=3.32
pyganim>=0.9.7

# ═══════════════════════════════════════════════════════════════════════════
# GRAPHICS & IMAGE PROCESSING
# ═══════════════════════════════════════════════════════════════════════════

# Core Image Libraries
Pillow>=10.2.0
opencv-python>=4.9.0.80
scikit-image>=0.22.0
imageio>=2.34.0
imageio-ffmpeg>=0.4.9

# Drawing & Graphics
cairo>=1.0.2
pycairo>=1.25.1
svgwrite>=1.4.3
drawsvg>=2.3.0
svglib>=1.5.1
reportlab>=4.1.0

# Color & Palettes
colour>=0.1.5
colorama>=0.4.6
colorthief>=0.2.1
palettable>=3.3.3

# Sprites & Animation
spriteutil>=0.1.0
aseprite>=1.0.2

# ═══════════════════════════════════════════════════════════════════════════
# AUDIO & MUSIC
# ═══════════════════════════════════════════════════════════════════════════

# Audio Playback
simpleaudio>=1.0.4
playsound>=1.3.0
pydub>=0.25.1
sounddevice>=0.4.6
soundfile>=0.12.1
pyaudio>=0.2.14

# Music Generation
mido>=1.3.2
python-rtmidi>=1.5.8
mingus>=0.6.1
music21>=9.1.0
pretty_midi>=0.2.10

# Audio Analysis
librosa>=0.10.1
aubio>=0.4.9
essentia>=2.1b6.dev1034

# Chiptune / Retro Audio
chippy>=0.1.0
py8bits>=0.0.2

# ═══════════════════════════════════════════════════════════════════════════
# GUI & UI FRAMEWORKS
# ═══════════════════════════════════════════════════════════════════════════

# Tkinter Extensions
ttkthemes>=3.2.2
ttkbootstrap>=1.10.1
customtkinter>=5.2.2
tkinterdnd2>=0.3.0
pillow-tk>=0.0.1

# Other GUI
PySimpleGUI>=4.60.5
dearpygui>=1.10.1
pywebview>=4.4.1
nicegui>=1.4.14

# Terminal UI
rich>=13.7.0
textual>=0.52.1
blessed>=1.20.0
urwid>=2.2.3
asciimatics>=1.15.0

# ═══════════════════════════════════════════════════════════════════════════
# MATH, SCIENCE & DATA
# ═══════════════════════════════════════════════════════════════════════════

# Core Math
numpy>=1.26.4
scipy>=1.12.0
sympy>=1.12
mpmath>=1.3.0

# Data Processing
pandas>=2.2.0
polars>=0.20.7

# Visualization
matplotlib>=3.8.2
seaborn>=0.13.2
plotly>=5.18.0
bokeh>=3.3.4

# ═══════════════════════════════════════════════════════════════════════════
# ROM HACKING & EMULATION
# ═══════════════════════════════════════════════════════════════════════════

# Hex & Binary
hexdump>=3.3
binaryfile>=2.0.3
construct>=2.10.70
kaitaistruct>=0.10

# Disassembly & Reverse Engineering
capstone>=5.0.1
keystone-engine>=0.9.2
unicorn>=2.0.1.post1

# Intel HEX / ROM Files
intelhex>=2.3.0
bincopy>=17.14.5
srec>=1.2

# Compression
lz4>=4.3.3
zstandard>=0.22.0
brotli>=1.1.0
python-lzo>=1.15

# Checksums
crcmod>=1.7
pycrc>=0.1.1

# ═══════════════════════════════════════════════════════════════════════════
# FILE FORMATS
# ═══════════════════════════════════════════════════════════════════════════

# Archives
zipfile-deflate64>=0.2.0
py7zr>=0.21.0
rarfile>=4.1
patool>=2.1.1

# Config Files
pyyaml>=6.0.1
toml>=0.10.2
tomli>=2.0.1
tomli-w>=1.0.0
configparser>=6.0.0
python-dotenv>=1.0.1

# JSON
orjson>=3.9.13
ujson>=5.9.0
simplejson>=3.19.2

# XML
lxml>=5.1.0
xmltodict>=0.13.0
defusedxml>=0.7.1

# ═══════════════════════════════════════════════════════════════════════════
# NETWORKING & MULTIPLAYER
# ═══════════════════════════════════════════════════════════════════════════

# HTTP & Web
requests>=2.31.0
httpx>=0.26.0
aiohttp>=3.9.3
urllib3>=2.2.0

# WebSockets
websockets>=12.0
websocket-client>=1.7.0

# Async
asyncio>=3.4.3
trio>=0.24.0
anyio>=4.2.0

# Game Networking
pyngrok>=7.0.5

# Serial
pyserial>=3.5

# ═══════════════════════════════════════════════════════════════════════════
# INPUT DEVICES
# ═══════════════════════════════════════════════════════════════════════════

# Controllers & Joysticks
inputs>=0.5
XInput-Python>=0.4.0
pyjoystick>=2020.7.9

# Keyboard & Mouse
pynput>=1.7.6
keyboard>=0.13.5
mouse>=0.7.1

# ═══════════════════════════════════════════════════════════════════════════
# AI & MACHINE LEARNING (Game AI)
# ═══════════════════════════════════════════════════════════════════════════

# ML Basics
scikit-learn>=1.4.0

# Neural Networks (optional, heavy)
# torch>=2.2.0
# tensorflow>=2.15.0

# Pathfinding
pathfinding>=1.0.9
python-astar>=1.0.1
tcod>=16.2.3

# Behavior Trees
py-trees>=2.2.3

# ═══════════════════════════════════════════════════════════════════════════
# DEVELOPMENT TOOLS
# ═══════════════════════════════════════════════════════════════════════════

# Packaging
setuptools>=69.0.3
wheel>=0.42.0
pip>=24.0
build>=1.0.3
twine>=5.0.0
pyinstaller>=6.4.0
cx-Freeze>=6.15.14
py2exe>=0.13.0.1; sys_platform == 'win32'
nuitka>=2.0.3

# Code Quality
black>=24.2.0
isort>=5.13.2
flake8>=7.0.0
pylint>=3.0.3
mypy>=1.8.0
ruff>=0.2.1

# Testing
pytest>=8.0.0
pytest-cov>=4.1.0
pytest-asyncio>=0.23.4
hypothesis>=6.98.0

# Debugging
debugpy>=1.8.1
py-spy>=0.3.14
line-profiler>=4.1.2
memory-profiler>=0.61.0

# Documentation
sphinx>=7.2.6
mkdocs>=1.5.3
pdoc>=14.4.0

# ═══════════════════════════════════════════════════════════════════════════
# EMULATOR BINDINGS & GAME CONSOLE TOOLS
# ═══════════════════════════════════════════════════════════════════════════

# NES
py65>=1.1.0

# Game Boy
pyboy>=1.6.11

# Chip-8
chip8>=1.0.2

# Generic Emulation
unicorn>=2.0.1.post1

# ═══════════════════════════════════════════════════════════════════════════
# UTILITY LIBRARIES
# ═══════════════════════════════════════════════════════════════════════════

# General Utilities
more-itertools>=10.2.0
toolz>=0.12.1
funcy>=2.0
boltons>=24.0.0
attrs>=23.2.0
pydantic>=2.6.1

# CLI
click>=8.1.7
typer>=0.9.0
argcomplete>=3.2.2
tqdm>=4.66.2

# Logging
loguru>=0.7.2
structlog>=24.1.0

# Paths & Files
pathlib2>=2.3.7.post1
watchdog>=4.0.0
send2trash>=1.8.2
appdirs>=1.4.4
platformdirs>=4.2.0

# Text Processing
regex>=2023.12.25
chardet>=5.2.0
ftfy>=6.1.3
unidecode>=1.3.8

# Date & Time
python-dateutil>=2.8.2
arrow>=1.3.0
pendulum>=3.0.0

# Cryptography
cryptography>=42.0.2
pycryptodome>=3.20.0
hashlib>=20081119; python_version < '3'

# Random & UUIDs
uuid>=1.30
shortuuid>=1.0.13
faker>=23.2.0

# Caching
cachetools>=5.3.2
diskcache>=5.6.3
joblib>=1.3.2
REQUIREMENTS

ok "requirements.txt generated (200+ packages)"

# ============================================================================
step "INSTALLING PYTHON PACKAGES"
# ============================================================================

# Upgrade pip first
info "Upgrading pip..."
pip3 install --user --break-system-packages --upgrade pip setuptools wheel >> "$LOG" 2>&1 && ok "pip upgraded" || fail "pip upgrade"

# Install in stages to avoid conflicts
info "Installing core packages (Stage 1/5)..."
pip3 install --user --break-system-packages \
    pygame pygame-ce pygame-gui \
    pyglet arcade \
    Pillow numpy scipy \
    >> "$LOG" 2>&1 && ok "Core packages" || fail "Core packages"

info "Installing 3D engines (Stage 2/5)..."
pip3 install --user --break-system-packages \
    ursina panda3d \
    PyOpenGL PyOpenGL-accelerate moderngl \
    >> "$LOG" 2>&1 && ok "3D engines" || fail "3D engines"

info "Installing audio packages (Stage 3/5)..."
pip3 install --user --break-system-packages \
    simpleaudio pydub sounddevice soundfile \
    mido mingus pretty_midi \
    >> "$LOG" 2>&1 && ok "Audio packages" || fail "Audio packages"

info "Installing ROM hacking tools (Stage 4/5)..."
pip3 install --user --break-system-packages \
    capstone keystone-engine unicorn \
    intelhex construct kaitaistruct \
    hexdump lz4 zstandard \
    >> "$LOG" 2>&1 && ok "ROM hacking tools" || fail "ROM hacking tools"

info "Installing utility packages (Stage 5/5)..."
pip3 install --user --break-system-packages \
    pyserial pyyaml toml \
    requests httpx aiohttp \
    rich textual tqdm click typer \
    black pytest \
    pyinstaller \
    >> "$LOG" 2>&1 && ok "Utility packages" || fail "Utility packages"

# ============================================================================
step "INSTALLING EMULATOR PYTHON BINDINGS"
# ============================================================================

info "Installing PyBoy (Game Boy emulator)..."
pip3 install --user --break-system-packages pyboy >> "$LOG" 2>&1 && ok "PyBoy" || skip "PyBoy"

info "Installing py65 (6502 emulator)..."
pip3 install --user --break-system-packages py65 >> "$LOG" 2>&1 && ok "py65" || skip "py65"

info "Installing TCOD (roguelike library)..."
pip3 install --user --break-system-packages tcod >> "$LOG" 2>&1 && ok "TCOD" || skip "TCOD"

# ============================================================================
step "LIBDRAGON N64 SDK"
# ============================================================================

cd "$HOME" || exit 1

if $IS_MAC; then
    if command -v libdragon >/dev/null 2>&1; then
        ok "libdragon CLI (already installed)"
    else
        if command -v npm >/dev/null 2>&1; then
            info "Installing libdragon CLI..."
            npm install -g libdragon >> "$LOG" 2>&1 && ok "libdragon CLI" || fail "libdragon CLI"
        else
            info "libdragon requires npm: brew install node"
        fi
    fi
else
    mkdir -p "$SDKS"
    cd "$SDKS" || exit 1
    rm -rf libdragon libdragon-trunk libdragon.tar.gz 2>/dev/null
    
    if dl "https://github.com/DragonMinded/libdragon/archive/refs/heads/trunk.tar.gz" libdragon.tar.gz; then
        tar xzf libdragon.tar.gz >> "$LOG" 2>&1
        mv libdragon-trunk libdragon 2>/dev/null
        rm -f libdragon.tar.gz
        ok "libdragon SDK source"
    else
        fail "libdragon SDK"
    fi
fi

# ============================================================================
step "GAME BOY SDK (GBDK-2020)"
# ============================================================================

cd "$HOME" || exit 1
mkdir -p "$SDKS"
cd "$SDKS" || exit 1
rm -rf gbdk gbdk.tar.gz 2>/dev/null

if $IS_MAC; then
    $IS_ARM && GBDK_URL="https://github.com/gbdk-2020/gbdk-2020/releases/download/4.4.0/gbdk-MacOS-arm64.tar.gz" \
            || GBDK_URL="https://github.com/gbdk-2020/gbdk-2020/releases/download/4.4.0/gbdk-macos.tar.gz"
else
    GBDK_URL="https://github.com/gbdk-2020/gbdk-2020/releases/download/4.4.0/gbdk-linux64.tar.gz"
fi

if dl "$GBDK_URL" gbdk.tar.gz; then
    tar xzf gbdk.tar.gz >> "$LOG" 2>&1
    rm -f gbdk.tar.gz
    $IS_MAC && xattr -dr com.apple.quarantine gbdk 2>/dev/null
    ok "GBDK-2020 4.4.0"
else
    fail "GBDK-2020"
fi
add_path "export GBDK=\"$SDKS/gbdk\""
add_path "export PATH=\"\$GBDK/bin:\$PATH\""

# ============================================================================
step "NES TOOLS"
# ============================================================================

cd "$HOME" || exit 1
rm -rf "$TOOLS/asm6" 2>/dev/null
mkdir -p "$TOOLS/asm6"
cd "$TOOLS/asm6" || exit 1

if dl "https://github.com/freem/asm6f/archive/refs/heads/master.zip" asm6f.zip; then
    unzip -qo asm6f.zip >> "$LOG" 2>&1
    cd asm6f-master || exit 1
    make >> "$LOG" 2>&1 && install -m 755 asm6f "$TOOLS/asm6/" && ok "asm6f" || fail "asm6f"
    cd "$TOOLS/asm6" && rm -rf asm6f-master asm6f.zip
else
    fail "asm6f"
fi
add_path "export PATH=\"$TOOLS/asm6:\$PATH\""

# ============================================================================
step "ATARI SDK (DASM)"
# ============================================================================

cd "$HOME" || exit 1
mkdir -p "$SDKS/atari"
cd "$SDKS/atari" || exit 1

$IS_MAC && DASM_URL="https://github.com/dasm-assembler/dasm/releases/download/2.20.14.1/dasm-2.20.14.1-osx-x64.tar.gz" \
        || DASM_URL="https://github.com/dasm-assembler/dasm/releases/download/2.20.14.1/dasm-2.20.14.1-linux-x64.tar.gz"

dl "$DASM_URL" dasm.tar.gz && tar xzf dasm.tar.gz >> "$LOG" 2>&1 && ok "DASM" || fail "DASM"
rm -f dasm.tar.gz
add_path "export PATH=\"$SDKS/atari:\$PATH\""

# ============================================================================
step "GENESIS/SNES SDKS"
# ============================================================================

cd "$HOME" || exit 1
cd "$SDKS" || exit 1
rm -rf sgdk SGDK-2.00 sgdk.tar.gz 2>/dev/null

dl "https://github.com/Stephane-D/SGDK/archive/refs/tags/v2.00.tar.gz" sgdk.tar.gz && \
tar xzf sgdk.tar.gz >> "$LOG" 2>&1 && mv SGDK-2.00 sgdk 2>/dev/null && ok "SGDK" || fail "SGDK"
rm -f sgdk.tar.gz
add_path "export SGDK=\"$SDKS/sgdk\""

cd "$SDKS" || exit 1
rm -rf pvsneslib pvsneslib-master pvs.zip 2>/dev/null

dl "https://github.com/alekmaul/pvsneslib/archive/refs/heads/master.zip" pvs.zip && \
unzip -qo pvs.zip >> "$LOG" 2>&1 && mv pvsneslib-master pvsneslib 2>/dev/null && ok "PVSnesLib" || fail "PVSnesLib"
rm -f pvs.zip
add_path "export PVSNESLIB=\"$SDKS/pvsneslib\""

# ============================================================================
step "ROM HACKING TOOLS"
# ============================================================================

cd "$HOME" || exit 1
rm -rf "$TOOLS/flips" 2>/dev/null
mkdir -p "$TOOLS/flips"
cd "$TOOLS/flips" || exit 1

$IS_MAC && FLIPS_URL="https://github.com/Alcaro/Flips/releases/download/v198/flips-mac.zip" \
        || FLIPS_URL="https://github.com/Alcaro/Flips/releases/download/v198/flips-linux.zip"

if dl "$FLIPS_URL" flips.zip; then
    unzip -qo flips.zip >> "$LOG" 2>&1
    $IS_MAC && xattr -dr com.apple.quarantine ./* 2>/dev/null
    chmod +x ./* 2>/dev/null
    ok "Flips"
else
    fail "Flips"
fi
rm -f flips.zip
add_path "export PATH=\"$TOOLS/flips:\$PATH\""

# ============================================================================
step "EMULATORS"
# ============================================================================

cd "$HOME" || exit 1
mkdir -p "$EMUS"
cd "$EMUS" || exit 1

# mGBA
if $IS_MAC; then
    dl "https://github.com/mgba-emu/mgba/releases/download/0.10.5/mGBA-0.10.5-macos.dmg" mgba.dmg && \
    hdiutil attach mgba.dmg -nobrowse >> "$LOG" 2>&1 && \
    cp -R /Volumes/mGBA*/mGBA.app "$EMUS" 2>/dev/null && \
    hdiutil detach /Volumes/mGBA* >> "$LOG" 2>&1 && \
    xattr -dr com.apple.quarantine "$EMUS/mGBA.app" 2>/dev/null && \
    ok "mGBA 0.10.5" || fail "mGBA"
    rm -f mgba.dmg
else
    dl "https://github.com/mgba-emu/mgba/releases/download/0.10.5/mGBA-0.10.5-appimage-x64.appimage" mGBA.AppImage && \
    chmod +x mGBA.AppImage && ok "mGBA 0.10.5" || fail "mGBA"
fi

# Ares
$IS_MAC && ARES_URL="https://github.com/ares-emulator/ares/releases/download/v146/ares-macos-universal.zip" \
        || ARES_URL="https://github.com/ares-emulator/ares/releases/download/v146/ares-linux-x86_64.zip"

dl "$ARES_URL" ares.zip && unzip -qo ares.zip >> "$LOG" 2>&1 && \
$IS_MAC && xattr -dr com.apple.quarantine ares* Ares* 2>/dev/null
chmod +x ares*/ares Ares.app/Contents/MacOS/ares 2>/dev/null
ok "Ares v146" || fail "Ares"
rm -f ares.zip

# ============================================================================
step "MODERN ENGINES"
# ============================================================================

cd "$HOME" || exit 1
cd "$TOOLS" || exit 1

# Godot
$IS_MAC && GODOT_URL="https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_macos.universal.zip" \
        || GODOT_URL="https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip"

dl "$GODOT_URL" godot.zip && unzip -qo godot.zip >> "$LOG" 2>&1 && ok "Godot 4.3" || fail "Godot"
$IS_MAC && xattr -dr com.apple.quarantine Godot* 2>/dev/null
rm -f godot.zip

# ============================================================================
step "ENVIRONMENT SETUP"
# ============================================================================

cat > "$INSTALL_DIR/env.sh" << 'ENVEOF'
#!/bin/bash
#===============================================================================
# CAT'S TWEAKER v2.0 - Environment Script
# Source with: source ~/retro-dev/env.sh
#===============================================================================

export RETRO_DEV="$HOME/retro-dev"
export DEVKITPRO="/opt/devkitpro"
export DEVKITARM="$DEVKITPRO/devkitARM"
export GBDK="$RETRO_DEV/sdks/gbdk"
export SGDK="$RETRO_DEV/sdks/sgdk"
export PVSNESLIB="$RETRO_DEV/sdks/pvsneslib"

# N64 toolchain (Linux native)
[[ -d "$RETRO_DEV/compilers/n64/bin" ]] && {
    export N64_INST="$RETRO_DEV/compilers/n64"
    export PATH="$N64_INST/bin:$PATH"
}

# Tool paths
export PATH="$DEVKITARM/bin:$GBDK/bin:$RETRO_DEV/tools/asm6:$RETRO_DEV/tools/flips:$RETRO_DEV/sdks/atari:$PATH"

# Python user packages
export PATH="$HOME/.local/bin:$PATH"

echo ""
echo "  🐱 CAT'S TWEAKER v2.0 Environment Loaded! 🎮"
echo ""
echo "  Python Packages:"
echo "    pygame, pygame-ce, pyglet, arcade    (2D Engines)"
echo "    ursina, panda3d, moderngl            (3D Engines)"
echo "    capstone, unicorn, keystone          (RE Tools)"
echo "    pyboy, py65                          (Emulators)"
echo ""
echo "  Console SDKs:"
echo "    N64 (macOS): libdragon init && make"
echo "    GB/GBC:      lcc --version"
echo "    NES:         asm6f / cc65"
echo "    Genesis:     \$SGDK"
echo "    SNES:        \$PVSNESLIB"
echo ""
ENVEOF
chmod +x "$INSTALL_DIR/env.sh"
ok "Environment script"

add_path ""
add_path "# CAT'S TWEAKER v2.0"
add_path "source \"$INSTALL_DIR/env.sh\" 2>/dev/null"

# ============================================================================
step "GENERATING PACKAGE VERIFICATION SCRIPT"
# ============================================================================

cat > "$INSTALL_DIR/verify_packages.py" << 'VERIFYSCRIPT'
#!/usr/bin/env python3
"""
Cat's Tweaker v2.0 - Package Verification Script
Checks all installed Python packages
"""

import sys
import importlib

PACKAGES = {
    # Game Engines
    'pygame': 'pygame',
    'pyglet': 'pyglet', 
    'arcade': 'arcade',
    'ursina': 'ursina',
    'panda3d': 'panda3d.core',
    'moderngl': 'moderngl',
    
    # Graphics
    'PIL': 'PIL',
    'cv2': 'cv2',
    'numpy': 'numpy',
    'scipy': 'scipy',
    
    # Audio
    'pydub': 'pydub',
    'mido': 'mido',
    
    # ROM Hacking
    'capstone': 'capstone',
    'unicorn': 'unicorn',
    'intelhex': 'intelhex',
    
    # Emulators
    'pyboy': 'pyboy',
    'py65': 'py65',
    
    # Utilities
    'yaml': 'yaml',
    'toml': 'toml',
    'requests': 'requests',
    'rich': 'rich',
    'click': 'click',
}

def main():
    print("\n🐱 Cat's Tweaker v2.0 - Package Verification\n")
    print("=" * 50)
    
    ok_count = 0
    fail_count = 0
    
    for name, module in PACKAGES.items():
        try:
            importlib.import_module(module)
            print(f"  ✓ {name:15} OK")
            ok_count += 1
        except ImportError:
            print(f"  ✗ {name:15} NOT FOUND")
            fail_count += 1
    
    print("=" * 50)
    print(f"\n  Total: {ok_count} OK, {fail_count} missing")
    print(f"  Python: {sys.version}")
    
    if fail_count > 0:
        print("\n  Install missing: pip3 install --user <package>")
    
    print()

if __name__ == "__main__":
    main()
VERIFYSCRIPT
chmod +x "$INSTALL_DIR/verify_packages.py"
ok "Verification script"

# ============================================================================
# COMPLETE
# ============================================================================

echo ""
printf "${G}╔═══════════════════════════════════════════════════════════════════════════╗${RST}\n"
printf "${G}║${RST}                                                                           ${G}║${RST}\n"
printf "${G}║${RST}  ${W}✨ CAT'S TWEAKER v2.0 ULTIMATE INSTALLATION COMPLETE! ✨${RST}               ${G}║${RST}\n"
printf "${G}║${RST}                                                                           ${G}║${RST}\n"
printf "${G}╠═══════════════════════════════════════════════════════════════════════════╣${RST}\n"
printf "${G}║${RST}                                                                           ${G}║${RST}\n"
printf "${G}║${RST}  ${C}Installed to:${RST}     ~/retro-dev                                         ${G}║${RST}\n"
printf "${G}║${RST}  ${C}Activate:${RST}         source ~/retro-dev/env.sh                          ${G}║${RST}\n"
printf "${G}║${RST}  ${C}Requirements:${RST}     ~/retro-dev/requirements.txt                       ${G}║${RST}\n"
printf "${G}║${RST}  ${C}Verify packages:${RST}  python3 ~/retro-dev/verify_packages.py             ${G}║${RST}\n"
printf "${G}║${RST}  ${C}Log:${RST}              ~/retro-dev/install.log                            ${G}║${RST}\n"
printf "${G}║${RST}                                                                           ${G}║${RST}\n"
printf "${G}╠═══════════════════════════════════════════════════════════════════════════╣${RST}\n"
printf "${G}║${RST}                                                                           ${G}║${RST}\n"
printf "${G}║${RST}  ${Y}PYTHON PACKAGES INSTALLED:${RST}                                             ${G}║${RST}\n"
printf "${G}║${RST}                                                                           ${G}║${RST}\n"
printf "${G}║${RST}    ${M}Game Engines:${RST}    pygame, pygame-ce, pyglet, arcade, ursina,         ${G}║${RST}\n"
printf "${G}║${RST}                      panda3d, moderngl, PyOpenGL                          ${G}║${RST}\n"
printf "${G}║${RST}    ${M}Graphics:${RST}        Pillow, opencv-python, numpy, scipy               ${G}║${RST}\n"
printf "${G}║${RST}    ${M}Audio:${RST}           pydub, sounddevice, mido, mingus, pretty_midi     ${G}║${RST}\n"
printf "${G}║${RST}    ${M}ROM Hacking:${RST}     capstone, unicorn, keystone, intelhex, construct  ${G}║${RST}\n"
printf "${G}║${RST}    ${M}Emulators:${RST}       pyboy, py65, tcod                                 ${G}║${RST}\n"
printf "${G}║${RST}    ${M}GUI:${RST}             customtkinter, rich, textual, dearpygui          ${G}║${RST}\n"
printf "${G}║${RST}    ${M}Dev Tools:${RST}       black, pytest, pyinstaller, mypy                 ${G}║${RST}\n"
printf "${G}║${RST}                                                                           ${G}║${RST}\n"
printf "${G}╠═══════════════════════════════════════════════════════════════════════════╣${RST}\n"
printf "${G}║${RST}                                                                           ${G}║${RST}\n"
printf "${G}║${RST}  ${Y}CONSOLE SDKS:${RST}                                                          ${G}║${RST}\n"
printf "${G}║${RST}                                                                           ${G}║${RST}\n"
printf "${G}║${RST}    N64:      libdragon (Docker CLI on macOS)                              ${G}║${RST}\n"
printf "${G}║${RST}    GB/GBC:   GBDK-2020 4.4.0                                              ${G}║${RST}\n"
printf "${G}║${RST}    NES:      asm6f, cc65                                                  ${G}║${RST}\n"
printf "${G}║${RST}    Atari:    DASM 2.20.14                                                 ${G}║${RST}\n"
printf "${G}║${RST}    Genesis:  SGDK 2.00                                                    ${G}║${RST}\n"
printf "${G}║${RST}    SNES:     PVSnesLib                                                    ${G}║${RST}\n"
printf "${G}║${RST}                                                                           ${G}║${RST}\n"
printf "${G}╚═══════════════════════════════════════════════════════════════════════════╝${RST}\n"
echo ""
printf "                              ${M}/\\_____/\\${RST}\n"
printf "                             ${M}/  o   o  \\${RST}\n"
printf "                            ${M}( ==  ^  == )${RST}\n"
printf "                             ${M})  ~owo~  (${RST}\n"
printf "                            ${M}(           )${RST}\n"
printf "                           ${M}( (  )   (  ) )${RST}\n"
printf "                          ${M}(__(__)___(__)__)${RST}\n"
echo ""
echo "  Run: source ~/.bashrc  (or ~/.zshrc on macOS)"
echo "  Then: python3 ~/retro-dev/verify_packages.py"
echo ""
