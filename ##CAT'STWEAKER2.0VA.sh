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
#                                        「  v1.8 - retro dev toolkit  」
#                                         by Flames / Team Flames 🐱
#
#===============================================================================

[[ -z "$BASH_VERSION" ]] && { echo "Run with: bash $0"; exit 1; }

# Colors
G=$'\033[0;32m'
Y=$'\033[0;33m'
C=$'\033[0;36m'
M=$'\033[0;35m'
W=$'\033[1;37m'
RST=$'\033[0m'

INSTALL_DIR="$HOME/retro-dev"
TOOLS="$INSTALL_DIR/tools"
SDKS="$INSTALL_DIR/sdks"
EMUS="$INSTALL_DIR/emulators"
COMPILERS="$INSTALL_DIR/compilers"
LOG="$INSTALL_DIR/install.log"

mkdir -p "$TOOLS" "$SDKS" "$EMUS" "$COMPILERS"
: > "$LOG"

IS_MAC=false
[[ "$(uname)" == "Darwin" ]] && IS_MAC=true
IS_ARM=false
[[ "$(uname -m)" == "arm64" ]] && IS_ARM=true

NCPU="$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)"

if $IS_MAC; then
    SHELL_RC="$HOME/.zshrc"
else
    SHELL_RC="$HOME/.bashrc"
fi

# Download with retry
dl() {
    local url="$1"
    local out="$2"
    echo "[DL] $url" >> "$LOG"
    if curl -fsSL --connect-timeout 30 --max-time 600 --retry 3 -L -o "$out" "$url" 2>>"$LOG"; then
        if [[ -s "$out" ]]; then
            echo "[DL] Success: $(ls -lh "$out" 2>/dev/null)" >> "$LOG"
            return 0
        fi
    fi
    echo "[DL] Failed or empty" >> "$LOG"
    rm -f "$out" 2>/dev/null
    return 1
}

# Status indicators
ok()   { printf "  %s[✓]%s %s\n" "$G" "$RST" "$1"; }
fail() { printf "  %s[✗]%s %s %s(see log)%s\n" "$Y" "$RST" "$1" "$Y" "$RST"; }
info() { printf "  %s[*]%s %s\n" "$C" "$RST" "$1"; }
step() { printf "\n%s▸ %s%s\n" "$M" "$1" "$RST"; }

add_path() {
    if ! grep -qF "$1" "$SHELL_RC" 2>/dev/null; then
        echo "$1" >> "$SHELL_RC"
    fi
}

clear
cat << 'EOF'

     ██████╗ █████╗ ████████╗███████╗    ████████╗██╗    ██╗███████╗ █████╗ ██╗  ██╗███████╗██████╗ 
    ██╔════╝██╔══██╗╚══██╔══╝██╔════╝    ╚══██╔══╝██║    ██║██╔════╝██╔══██╗██║ ██╔╝██╔════╝██╔══██╗
    ██║     ███████║   ██║   ███████╗       ██║   ██║ █╗ ██║█████╗  ███████║█████╔╝ █████╗  ██████╔╝
    ██║     ██╔══██║   ██║   ╚════██║       ██║   ██║███╗██║██╔══╝  ██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗
    ╚██████╗██║  ██║   ██║   ███████║       ██║   ╚███╔███╔╝███████╗██║  ██║██║  ██╗███████╗██║  ██║
     ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝       ╚═╝    ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

                                       「  v1.8 - retro dev toolkit  」
                                            /\_____/\
                                           /  o   o  \
                                          ( ==  ^  == )
                                           )         (
                                          (           )
                                         ( (  )   (  ) )
                                        (__(__)___(__)__)

EOF

# ============================================================================
step "SYSTEM SETUP"
# ============================================================================

if $IS_MAC; then
    if command -v brew >/dev/null 2>&1; then
        ok "Homebrew found"
    else
        info "Installing Homebrew..."
        if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >> "$LOG" 2>&1; then
            ok "Homebrew installed"
        else
            fail "Homebrew"
        fi
    fi
    
    info "Installing brew packages..."
    if brew install gcc llvm cmake ninja meson sdl2 sdl2_image sdl2_mixer sdl2_ttf \
                 libpng jpeg freetype zlib python nasm yasm wget curl p7zip \
                 glew glfw boost raylib rgbds cc65 sdcc wla-dx >> "$LOG" 2>&1; then
        ok "Brew packages"
    else
        fail "Some brew packages"
    fi
else
    if sudo apt-get update -qq >> "$LOG" 2>&1; then
        ok "APT update"
    else
        fail "APT update"
    fi
    if sudo apt-get install -y -qq build-essential gcc g++ clang llvm cmake ninja-build meson \
        autoconf automake libtool libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev \
        libpng-dev libjpeg-dev libfreetype6-dev zlib1g-dev python3 python3-pip nasm yasm flex bison \
        texinfo libncurses-dev libreadline-dev curl wget unzip p7zip-full >> "$LOG" 2>&1; then
        ok "Build tools"
    else
        fail "Build tools"
    fi
fi

# ============================================================================
step "PYTHON PACKAGES"
# ============================================================================

if pip3 install --user --break-system-packages pygame ursina pillow numpy pysdl2 pyyaml toml intelhex pyserial capstone >> "$LOG" 2>&1; then
    ok "Python packages"
else
    fail "Python packages"
fi

# ============================================================================
step "LIBDRAGON N64 SDK"
# ============================================================================

cd "$HOME" || exit 1

if $IS_MAC; then
    if command -v libdragon >/dev/null 2>&1; then
        ok "libdragon SDK (via Docker CLI)"
    else
        info "libdragon SDK managed by Docker CLI"
        info "Run: npm install -g libdragon"
    fi
else
    mkdir -p "$SDKS"
    cd "$SDKS" || exit 1
    rm -rf libdragon libdragon-trunk libdragon.tar.gz 2>/dev/null
    
    if dl "https://github.com/DragonMinded/libdragon/archive/refs/heads/trunk.tar.gz" libdragon.tar.gz; then
        tar xzf libdragon.tar.gz >> "$LOG" 2>&1
        mv libdragon-trunk libdragon 2>/dev/null
        rm -f libdragon.tar.gz
        ok "libdragon SDK"
    else
        fail "libdragon SDK"
    fi
fi

# ============================================================================
step "N64 TOOLCHAIN (mips64-elf-gcc)"
# ============================================================================

cd "$HOME" || exit 1

if $IS_MAC; then
    info "N64 toolchain for macOS requires Docker"
    
    if ! command -v docker >/dev/null 2>&1; then
        fail "Docker not installed"
        info "Install Docker Desktop from: https://docker.com/products/docker-desktop"
        info "Then re-run this script"
    else
        ok "Docker found"
        
        if ! command -v npm >/dev/null 2>&1; then
            info "Installing Node.js..."
            brew install node >> "$LOG" 2>&1 || true
        fi
        
        if command -v npm >/dev/null 2>&1; then
            info "Installing libdragon CLI..."
            if npm install -g libdragon >> "$LOG" 2>&1; then
                ok "libdragon CLI installed"
                info "Usage: cd your-project && libdragon init && libdragon make"
                
                mkdir -p "$COMPILERS/n64"
                cd "$COMPILERS/n64" || exit 1
                
                info "Initializing libdragon (downloads ~500MB Docker image)..."
                if libdragon init >> "$LOG" 2>&1; then
                    ok "N64 toolchain ready (via Docker)"
                    info "Test: cd ~/retro-dev/compilers/n64 && libdragon make"
                else
                    fail "libdragon init"
                    info "Try manually: cd ~/retro-dev/compilers/n64 && libdragon init"
                fi
            else
                fail "libdragon CLI install"
                info "Try manually: npm install -g libdragon"
            fi
        else
            fail "Node.js not found"
            info "Install: brew install node"
        fi
    fi
fi

# ============================================================================
step "ATARI 2600/7800 SDK"
# ============================================================================

cd "$HOME" || exit 1
mkdir -p "$SDKS/atari"
cd "$SDKS/atari" || exit 1
rm -f dasm.tar.gz 2>/dev/null

DASM_URL="https://github.com/dasm-assembler/dasm/releases/download/2.20.14.1/dasm-2.20.14.1-linux-x64.tar.gz"
$IS_MAC && DASM_URL="https://github.com/dasm-assembler/dasm/releases/download/2.20.14.1/dasm-2.20.14.1-osx-x64.tar.gz"

if dl "$DASM_URL" dasm.tar.gz; then
    tar xzf dasm.tar.gz >> "$LOG" 2>&1
    ok "DASM"
else
    fail "DASM"
fi
rm -f dasm.tar.gz
add_path "export PATH=\"$SDKS/atari:\$PATH\""

# ============================================================================
step "GENESIS/SNES SDKS"
# ============================================================================

cd "$HOME" || exit 1
mkdir -p "$SDKS"
cd "$SDKS" || exit 1
rm -rf sgdk SGDK-2.00 sgdk.tar.gz 2>/dev/null

if dl "https://github.com/Stephane-D/SGDK/archive/refs/tags/v2.00.tar.gz" sgdk.tar.gz; then
    tar xzf sgdk.tar.gz >> "$LOG" 2>&1
    mv SGDK-2.00 sgdk 2>/dev/null
    ok "SGDK"
else
    fail "SGDK"
fi
rm -f sgdk.tar.gz
add_path "export SGDK=\"$SDKS/sgdk\""

cd "$HOME" || exit 1
cd "$SDKS" || exit 1
rm -rf pvsneslib pvsneslib-master pvs.zip 2>/dev/null

if dl "https://github.com/alekmaul/pvsneslib/archive/refs/heads/master.zip" pvs.zip; then
    unzip -qo pvs.zip >> "$LOG" 2>&1
    mv pvsneslib-master pvsneslib 2>/dev/null
    ok "PVSnesLib"
else
    fail "PVSnesLib"
fi
rm -f pvs.zip
add_path "export PVSNESLIB=\"$SDKS/pvsneslib\""

# ============================================================================
step "ROM HACKING TOOLS"
# ============================================================================

cd "$HOME" || exit 1
rm -rf "$TOOLS/flips" 2>/dev/null
mkdir -p "$TOOLS/flips"
cd "$TOOLS/flips" || exit 1

FLIPS_URL="https://github.com/Alcaro/Flips/releases/download/v198/flips-linux.zip"
$IS_MAC && FLIPS_URL="https://github.com/Alcaro/Flips/releases/download/v198/flips-mac.zip"

if dl "$FLIPS_URL" flips.zip; then
    unzip -qo flips.zip >> "$LOG" 2>&1
    $IS_MAC && xattr -dr com.apple.quarantine . 2>/dev/null
    chmod +x ./* 2>/dev/null
    ok "Flips"
else
    info "Building Flips from source..."
    cd "$HOME" || exit 1
    rm -rf "$TOOLS/flips-src" "$TOOLS/Flips-master" 2>/dev/null
    cd "$TOOLS" || exit 1
    if dl "https://github.com/Alcaro/Flips/archive/refs/heads/master.tar.gz" flips-src.tar.gz; then
        tar xzf flips-src.tar.gz >> "$LOG" 2>&1
        cd Flips-master || exit 1
        if $IS_MAC; then
            if make CFLAGS="-O3" >> "$LOG" 2>&1; then
                cp flips "$TOOLS/flips/"
                ok "Flips (built)"
            else
                fail "Flips"
            fi
        else
            if ./make-linux.sh >> "$LOG" 2>&1; then
                cp flips "$TOOLS/flips/"
                ok "Flips (built)"
            else
                fail "Flips"
            fi
        fi
        cd "$HOME" || exit 1
        rm -rf "$TOOLS/Flips-master" "$TOOLS/flips-src.tar.gz"
    else
        fail "Flips"
    fi
fi
rm -f "$TOOLS/flips/flips.zip"
add_path "export PATH=\"$TOOLS/flips:\$PATH\""

# ============================================================================
step "EMULATORS"
# ============================================================================

cd "$HOME" || exit 1
mkdir -p "$EMUS"
cd "$EMUS" || exit 1

if $IS_MAC; then
    rm -f mgba.dmg 2>/dev/null
    if dl "https://github.com/mgba-emu/mgba/releases/download/0.10.5/mGBA-0.10.5-macos.dmg" mgba.dmg; then
        hdiutil attach mgba.dmg -nobrowse >> "$LOG" 2>&1
        cp -R /Volumes/mGBA*/mGBA.app "$EMUS" 2>/dev/null
        hdiutil detach /Volumes/mGBA* >> "$LOG" 2>&1
        xattr -dr com.apple.quarantine "$EMUS/mGBA.app" 2>/dev/null
        ok "mGBA 0.10.5"
    else
        fail "mGBA"
    fi
    rm -f mgba.dmg
else
    if dl "https://github.com/mgba-emu/mgba/releases/download/0.10.5/mGBA-0.10.5-appimage-x64.appimage" mGBA.AppImage; then
        chmod +x mGBA.AppImage
        ok "mGBA 0.10.5"
    else
        fail "mGBA"
    fi
fi

cd "$HOME" || exit 1
cd "$EMUS" || exit 1
rm -f ares.zip 2>/dev/null

if $IS_MAC; then
    ARES_URL="https://github.com/ares-emulator/ares/releases/download/v146/ares-macos-universal.zip"
else
    ARES_URL="https://github.com/ares-emulator/ares/releases/download/v146/ares-linux-x86_64.zip"
fi

if dl "$ARES_URL" ares.zip; then
    unzip -qo ares.zip >> "$LOG" 2>&1
    if $IS_MAC; then
        xattr -dr com.apple.quarantine ares* Ares* 2>/dev/null
        chmod +x Ares.app/Contents/MacOS/ares 2>/dev/null
    else
        chmod +x ares*/ares 2>/dev/null
    fi
    ok "Ares v146"
else
    fail "Ares"
fi
rm -f ares.zip

# ============================================================================
step "MODERN ENGINES"
# ============================================================================

cd "$HOME" || exit 1
mkdir -p "$TOOLS"
cd "$TOOLS" || exit 1

if $IS_MAC; then
    ok "Raylib (via brew)"
else
    rm -f raylib.tar.gz 2>/dev/null
    if dl "https://github.com/raysan5/raylib/archive/refs/tags/5.5.tar.gz" raylib.tar.gz; then
        tar xzf raylib.tar.gz >> "$LOG" 2>&1
        ok "Raylib"
    else
        fail "Raylib"
    fi
    rm -f raylib.tar.gz
fi

cd "$HOME" || exit 1
cd "$TOOLS" || exit 1
rm -f godot.zip 2>/dev/null

if $IS_MAC; then
    GODOT_URL="https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_macos.universal.zip"
else
    GODOT_URL="https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip"
fi

if dl "$GODOT_URL" godot.zip; then
    unzip -qo godot.zip >> "$LOG" 2>&1
    ok "Godot 4.3"
else
    fail "Godot"
fi
$IS_MAC && xattr -dr com.apple.quarantine Godot* 2>/dev/null
rm -f godot.zip

# ============================================================================
step "ENVIRONMENT SETUP"
# ============================================================================

cd "$HOME" || exit 1

cat > "$INSTALL_DIR/env.sh" << 'ENVEOF'
#!/bin/bash
export RETRO_DEV="$HOME/retro-dev"
export DEVKITPRO="/opt/devkitpro"
export DEVKITARM="$DEVKITPRO/devkitARM"
export GBDK="$RETRO_DEV/sdks/gbdk"
export SGDK="$RETRO_DEV/sdks/sgdk"
export PVSNESLIB="$RETRO_DEV/sdks/pvsneslib"

if [[ -d "$RETRO_DEV/compilers/n64/bin" ]]; then
    export N64_INST="$RETRO_DEV/compilers/n64"
    export PATH="$N64_INST/bin:$PATH"
fi

export PATH="$DEVKITARM/bin:$GBDK/bin:$RETRO_DEV/tools/asm6:$RETRO_DEV/tools/flips:$RETRO_DEV/tools/rgbds:$RETRO_DEV/tools/wla-dx-10.6/build/binaries:$RETRO_DEV/sdks/atari:$PATH"

echo "🐱 CAT'S TWEAKER environment loaded! 🎮"
echo ""
echo "   N64 (macOS): cd project && libdragon init && libdragon make"
echo "   N64 (Linux): mips64-elf-gcc --version"
echo "   GB/GBC:      lcc --version"
echo "   GBA/NDS:     arm-none-eabi-gcc --version (after DevkitPro install)"
ENVEOF
chmod +x "$INSTALL_DIR/env.sh"
ok "Environment script"

# ============================================================================
# COMPLETE
# ============================================================================

echo ""
printf "%s  ╔═══════════════════════════════════════════════════════════════╗%s\n" "$G" "$RST"
printf "%s  ║%s  %s✨ CAT'S TWEAKER 1.8 INSTALLATION COMPLETE! ✨%s                %s║%s\n" "$G" "$RST" "$W" "$RST" "$G" "$RST"
printf "%s  ╠═══════════════════════════════════════════════════════════════╣%s\n" "$G" "$RST"
printf "%s  ║%s  %sInstalled to:%s %-44s %s║%s\n" "$G" "$RST" "$C" "$RST" "$INSTALL_DIR" "$G" "$RST"
printf "%s  ║%s  %sActivate:%s     source ~/retro-dev/env.sh                      %s║%s\n" "$G" "$RST" "$C" "$RST" "$G" "$RST"
printf "%s  ║%s  %sLog:%s          ~/retro-dev/install.log                       %s║%s\n" "$G" "$RST" "$C" "$RST" "$G" "$RST"
printf "%s  ╚═══════════════════════════════════════════════════════════════╝%s\n" "$G" "$RST"
echo ""
printf "                           %s/\\_____/\\%s\n" "$M" "$RST"
printf "                          %s/  o   o  \\%s\n" "$M" "$RST"
printf "                         %s( ==  ^  == )%s\n" "$M" "$RST"
printf "                          %s)  ~nya~  (%s\n" "$M" "$RST"
printf "                         %s(           )%s\n" "$M" "$RST"
printf "                        %s( (  )   (  ) )%s\n" "$M" "$RST"
printf "                       %s(__(__)___(__)__)%s\n" "$M" "$RST"
echo ""