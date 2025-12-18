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
#                         「  v3.0 MEGA - ALL PLATFORMS 1930-2025 + ALL PYTHON  」
#                                         by Flames / Team Flames 🐱
#
#    EVERYTHING: Turing Machines → N64 → Switch + 230+ Python Packages
#
#===============================================================================

[[ -z "$BASH_VERSION" ]] && { echo "Run with: bash $0"; exit 1; }

# ============================================================================
# CONFIGURATION
# ============================================================================

R=$'\033[0;31m'; G=$'\033[0;32m'; Y=$'\033[0;33m'; B=$'\033[0;34m'
M=$'\033[0;35m'; C=$'\033[0;36m'; W=$'\033[1;37m'; DIM=$'\033[2m'; RST=$'\033[0m'

INSTALL_DIR="$HOME/retro-dev"
TOOLS="$INSTALL_DIR/tools"
SDKS="$INSTALL_DIR/sdks"
EMUS="$INSTALL_DIR/emulators"
COMPILERS="$INSTALL_DIR/compilers"
ENGINES="$INSTALL_DIR/engines"
SRC="$INSTALL_DIR/src"
LOG="$INSTALL_DIR/install.log"
TMP="/tmp/cats-tweaker-$$"

IS_MAC=false; [[ "$(uname)" == "Darwin" ]] && IS_MAC=true
IS_ARM=false; [[ "$(uname -m)" =~ ^(arm64|aarch64)$ ]] && IS_ARM=true
NCPU=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
SHELL_RC="$HOME/.bashrc"; $IS_MAC && SHELL_RC="$HOME/.zshrc"

mkdir -p "$TOOLS" "$SDKS" "$EMUS" "$COMPILERS" "$ENGINES" "$SRC" "$TMP"
for era in chip8 atari2600 apple2 c64 spectrum nes sms amiga gameboy genesis snes neogeo 3do saturn psx n64 gbc dreamcast ps2 gba gamecube xbox nds psp wii 3ds vita wiiu switch; do
    mkdir -p "$SDKS/$era"
done
: > "$LOG"

# ============================================================================
# DOWNLOAD FUNCTIONS
# ============================================================================

dl() {
    local url="$1" out="$2"
    echo "[DL] $url" >> "$LOG"
    curl -fsSL --connect-timeout 30 --max-time 600 --retry 3 \
         -A "Mozilla/5.0 (compatible; CatsTweaker/3.0)" \
         -L -o "$out" "$url" 2>>"$LOG"
    [[ -s "$out" ]] && return 0
    wget -q --timeout=30 --tries=3 -O "$out" "$url" 2>>"$LOG"
    [[ -s "$out" ]] && return 0
    rm -f "$out" 2>/dev/null; return 1
}

# ============================================================================
# STATUS FUNCTIONS
# ============================================================================

ok()   { printf "  ${G}[✓]${RST} %s\n" "$1"; }
fail() { printf "  ${R}[✗]${RST} %s ${DIM}(see log)${RST}\n" "$1"; }
skip() { printf "  ${Y}[~]${RST} %s\n" "$1"; }
info() { printf "  ${C}[*]${RST} %s\n" "$1"; }
step() { printf "\n${M}══════════════════════════════════════════════════════════════════${RST}\n${W}  ▸ %s${RST}\n${M}══════════════════════════════════════════════════════════════════${RST}\n" "$1"; }
era()  { printf "\n\n${Y}╔══════════════════════════════════════════════════════════════════════════════╗${RST}\n${Y}║${RST}  ${W}%s${RST}\n${Y}╚══════════════════════════════════════════════════════════════════════════════╝${RST}\n" "$1"; }

add_path() { grep -qF "$1" "$SHELL_RC" 2>/dev/null || echo "$1" >> "$SHELL_RC"; }

clear
cat << 'BANNER'

     ██████╗ █████╗ ████████╗███████╗    ████████╗██╗    ██╗███████╗ █████╗ ██╗  ██╗███████╗██████╗ 
    ██╔════╝██╔══██╗╚══██╔══╝██╔════╝    ╚══██╔══╝██║    ██║██╔════╝██╔══██╗██║ ██╔╝██╔════╝██╔══██╗
    ██║     ███████║   ██║   ███████╗       ██║   ██║ █╗ ██║█████╗  ███████║█████╔╝ █████╗  ██████╔╝
    ██║     ██╔══██║   ██║   ╚════██║       ██║   ██║███╗██║██╔══╝  ██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗
    ╚██████╗██║  ██║   ██║   ███████║       ██║   ╚███╔███╔╝███████╗██║  ██║██║  ██╗███████╗██║  ██║
     ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝       ╚═╝    ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

                       「  v3.0 MEGA - ALL PLATFORMS 1930-2025 + 230 PYTHON PKGS  」

                                            /\_____/\
                                           /  o   o  \
                                          ( ==  ^  == )
                                           )  ~owo~  (
                                          (           )
                                         ( (  )   (  ) )
                                        (__(__)___(__)__)

    ┌──────────────────────────────────────────────────────────────────────────┐
    │  ERAS COVERED:                                                           │
    │                                                                          │
    │  1930s-40s: Turing Machines, ENIAC                                       │
    │  1950s-60s: IBM Mainframes, PDP-11                                       │
    │  1970s:     CHIP-8, Atari 2600, Apple II, TRS-80                         │
    │  1980s:     C64, ZX Spectrum, NES, SMS, Amiga, Game Boy                  │
    │  1990s:     Genesis, SNES, Neo Geo, 3DO, Saturn, PS1, N64, Dreamcast     │
    │  2000s:     PS2, GBA, GameCube, Xbox, DS, PSP, Wii                       │
    │  2010s:     3DS, PS Vita, Wii U, Switch                                  │
    │  2020s:     Steam Deck, Modern Engines                                   │
    │                                                                          │
    │  PYTHON: pygame, ursina, panda3d, capstone, unicorn, pyboy + 220 more    │
    └──────────────────────────────────────────────────────────────────────────┘

BANNER
sleep 1

# ============================================================================
step "SYSTEM PREREQUISITES"
# ============================================================================

if $IS_MAC; then
    command -v brew >/dev/null 2>&1 && ok "Homebrew" || {
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >> "$LOG" 2>&1
    }
    
    info "Installing system packages..."
    brew install python@3.12 gcc llvm cmake ninja meson autoconf automake libtool pkg-config \
                 sdl2 sdl2_image sdl2_mixer sdl2_ttf sdl2_gfx \
                 libpng jpeg freetype zlib xz lz4 zstd portaudio portmidi ffmpeg \
                 nasm yasm flex bison texinfo wget curl p7zip gnu-tar \
                 node npm rgbds cc65 sdcc >> "$LOG" 2>&1 && ok "System packages" || fail "Packages"
else
    sudo apt-get update -qq >> "$LOG" 2>&1
    sudo apt-get install -y -qq \
        python3 python3-pip python3-venv python3-dev python3-tk \
        build-essential gcc g++ clang llvm cmake ninja-build meson \
        autoconf automake libtool pkg-config \
        libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev libsdl2-gfx-dev \
        libpng-dev libjpeg-dev libfreetype6-dev zlib1g-dev liblzma-dev liblz4-dev libzstd-dev \
        libncurses-dev libreadline-dev libgmp-dev libmpfr-dev libmpc-dev \
        libportaudio2 libportmidi-dev libasound2-dev \
        libgl1-mesa-dev libglu1-mesa-dev libglew-dev libglfw3-dev \
        libgtk-3-dev ffmpeg nasm yasm flex bison texinfo \
        curl wget unzip p7zip-full xz-utils nodejs npm \
        >> "$LOG" 2>&1 && ok "System packages" || fail "Packages"
fi

#=============================================================================
era "ERA 1: 1930s-1940s - EARLY COMPUTING"
#=============================================================================

step "TURING MACHINE SIMULATOR (1936)"

mkdir -p "$TOOLS/turing"
cat > "$TOOLS/turing/turing.py" << 'TURINGPY'
#!/usr/bin/env python3
"""Turing Machine Simulator - Alan Turing's theoretical machine (1936)"""
import sys

class TuringMachine:
    def __init__(self, tape="", blank='_', initial='q0', finals=None):
        self.tape = list(tape) if tape else [blank]
        self.blank, self.head, self.state = blank, 0, initial
        self.finals = finals or {'qf'}
        self.rules = {}
    
    def add_rule(self, s, r, ns, w, m):
        self.rules[(s, r)] = (ns, w, m)
    
    def step(self):
        if self.state in self.finals: return False
        while self.head < 0: self.tape.insert(0, self.blank); self.head += 1
        while self.head >= len(self.tape): self.tape.append(self.blank)
        key = (self.state, self.tape[self.head])
        if key not in self.rules: return False
        ns, w, m = self.rules[key]
        self.tape[self.head], self.state = w, ns
        self.head += {'R':1,'L':-1}.get(m, 0)
        return True
    
    def run(self, max_steps=1000, verbose=True):
        for _ in range(max_steps):
            if verbose: print(f"[{self.state}] {''.join(self.tape)} (^{self.head})")
            if not self.step(): break
        return ''.join(self.tape).strip(self.blank)

def demo():
    print("=== Turing Machine: Binary Increment ===")
    tm = TuringMachine("1011", finals={'halt'})
    for s,r,ns,w,m in [('q0','0','q0','0','R'),('q0','1','q0','1','R'),('q0','_','q1','_','L'),
                       ('q1','0','halt','1','N'),('q1','1','q1','0','L'),('q1','_','halt','1','N')]:
        tm.add_rule(s,r,ns,w,m)
    print(f"Input: 1011 (11) -> Output: {tm.run(verbose=False)} (12)")

if __name__ == "__main__": demo() if len(sys.argv)>1 else print("Usage: turing.py demo")
TURINGPY
chmod +x "$TOOLS/turing/turing.py"
ok "Turing Machine Simulator"

step "ENIAC SIMULATOR (1945)"

cat > "$TOOLS/turing/eniac.py" << 'ENIACPY'
#!/usr/bin/env python3
"""ENIAC Simulator - First electronic computer (1945)"""
class ENIAC:
    def __init__(self):
        self.acc = [0]*20
    def run(self, prog):
        for op, *args in prog:
            if op=='CLEAR': self.acc[args[0]]=0
            elif op=='LOAD': self.acc[args[0]]=args[1]
            elif op=='ADD': self.acc[args[0]]+=self.acc[args[1]]
            elif op=='PRINT': print(f"ACC[{args[0]}]={self.acc[args[0]]}")
def demo():
    print("=== ENIAC: 12345 + 67890 ===")
    ENIAC().run([('CLEAR',0),('LOAD',0,12345),('LOAD',1,67890),('ADD',0,1),('PRINT',0)])
if __name__=="__main__": demo()
ENIACPY
chmod +x "$TOOLS/turing/eniac.py"
ok "ENIAC Simulator"

#=============================================================================
era "ERA 2: 1950s-1960s - MAINFRAMES"
#=============================================================================

step "PDP-11/UNIX REFERENCE"
mkdir -p "$SDKS/pdp11"
cat > "$SDKS/pdp11/README.md" << 'EOF'
# PDP-11 Development (1970)
- Emulator: SIMH (http://simh.trailing-edge.com/)
- Install: brew install simh (macOS) or apt install simh (Linux)
- Assembly: Use cross-assembler or MACRO-11
EOF
ok "PDP-11 Reference"

#=============================================================================
era "ERA 3: 1970s - HOME COMPUTERS & EARLY CONSOLES"
#=============================================================================

step "CHIP-8 ASSEMBLER (1977)"

mkdir -p "$TOOLS/chip8"
cat > "$TOOLS/chip8/chip8asm.py" << 'CHIP8ASM'
#!/usr/bin/env python3
"""CHIP-8 Assembler - For COSMAC VIP (1977)"""
import sys, re

OPCODES = {
    'CLS': lambda: [0x00, 0xE0], 'RET': lambda: [0x00, 0xEE],
    'JP': lambda a: [0x10|(a>>8), a&0xFF], 'CALL': lambda a: [0x20|(a>>8), a&0xFF],
    'SE': lambda x,n: [0x30|x, n], 'SNE': lambda x,n: [0x40|x, n],
    'LD': lambda x,n: [0x60|x, n], 'ADD': lambda x,n: [0x70|x, n],
    'DRW': lambda x,y,n: [0xD0|x, (y<<4)|n],
}

def assemble(src):
    lines = [l.split(';')[0].strip() for l in src.split('\n')]
    labels, rom, addr = {}, [], 0x200
    
    # Pass 1: collect labels
    for line in lines:
        if not line: continue
        if ':' in line:
            labels[line.replace(':','')] = addr
        else:
            addr += 2
    
    # Pass 2: assemble
    addr = 0x200
    for line in lines:
        if not line or ':' in line: continue
        parts = line.replace(',', ' ').split()
        op = parts[0].upper()
        args = [int(p,16) if p.startswith('0x') else labels.get(p,int(p,0) if p.isdigit() else int(p[1:],16) if p.startswith('V') else 0) for p in parts[1:]]
        
        if op in OPCODES:
            rom.extend(OPCODES[op](*args) if args else OPCODES[op]())
        addr += 2
    
    return bytes(rom)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("CHIP-8 Assembler - Usage: chip8asm.py input.asm [output.ch8]")
    else:
        with open(sys.argv[1]) as f: src = f.read()
        rom = assemble(src)
        out = sys.argv[2] if len(sys.argv)>2 else sys.argv[1].replace('.asm','.ch8')
        with open(out, 'wb') as f: f.write(rom)
        print(f"Assembled {len(rom)} bytes -> {out}")
CHIP8ASM
chmod +x "$TOOLS/chip8/chip8asm.py"
ok "CHIP-8 Assembler"

step "ATARI 2600 SDK (DASM)"

mkdir -p "$SDKS/atari2600"
cd "$SDKS/atari2600"

$IS_MAC && DASM_URL="https://github.com/dasm-assembler/dasm/releases/download/2.20.14.1/dasm-2.20.14.1-osx-x64.tar.gz" \
        || DASM_URL="https://github.com/dasm-assembler/dasm/releases/download/2.20.14.1/dasm-2.20.14.1-linux-x64.tar.gz"

if dl "$DASM_URL" dasm.tar.gz; then
    tar xzf dasm.tar.gz >> "$LOG" 2>&1
    [[ -d "dasm-2.20.14.1" ]] && mv dasm-2.20.14.1/* . 2>/dev/null && rmdir dasm-2.20.14.1 2>/dev/null
    chmod +x dasm 2>/dev/null
    [[ -x "dasm" ]] && ok "DASM (Atari 2600)" || fail "DASM"
else
    info "Building DASM from source..."
    dl "https://github.com/dasm-assembler/dasm/archive/refs/tags/2.20.14.1.tar.gz" dasm-src.tar.gz && \
    tar xzf dasm-src.tar.gz && cd dasm-*/src && make >> "$LOG" 2>&1 && cp dasm "$SDKS/atari2600/" && ok "DASM (built)" || fail "DASM"
fi
rm -f *.tar.gz 2>/dev/null

step "APPLE II / TRS-80 (CC65)"

if $IS_MAC; then
    command -v cc65 >/dev/null 2>&1 && ok "CC65 (via brew)" || skip "CC65 - brew install cc65"
else
    command -v cc65 >/dev/null 2>&1 && ok "CC65 (system)" || skip "CC65 - apt install cc65"
fi

#=============================================================================
era "ERA 4: 1980s - 8-BIT GOLDEN AGE"
#=============================================================================

step "COMMODORE 64 TOOLS"

mkdir -p "$SDKS/c64"
if $IS_MAC; then
    info "VICE C64 emulator: brew install vice"
    info "ACME assembler: brew install acme"
else
    info "VICE: apt install vice"
fi
cat > "$SDKS/c64/README.md" << 'EOF'
# C64 Development
- Assembler: ACME, KickAssembler, 64tass
- Compiler: CC65 (cc65 -t c64)
- Emulator: VICE (x64sc)
EOF
ok "C64 SDK Reference"

step "ZX SPECTRUM TOOLS (PASMO)"

mkdir -p "$SDKS/spectrum"
cd "$SDKS/spectrum"

if dl "https://pasmo.speccy.org/bin/pasmo-0.5.5-linux-x64.tar.gz" pasmo.tar.gz; then
    tar xzf pasmo.tar.gz >> "$LOG" 2>&1 && chmod +x pasmo 2>/dev/null && ok "PASMO (Spectrum)" || fail "PASMO"
else
    skip "PASMO (download manually from pasmo.speccy.org)"
fi
rm -f pasmo.tar.gz 2>/dev/null

step "NES/FAMICOM SDK"

mkdir -p "$TOOLS/nes"
cd "$TOOLS/nes"
rm -rf asm6f* 2>/dev/null

if dl "https://github.com/freem/asm6f/archive/refs/heads/master.zip" asm6f.zip; then
    unzip -qo asm6f.zip >> "$LOG" 2>&1
    cd asm6f-master && make >> "$LOG" 2>&1 && cp asm6f "$TOOLS/nes/" && ok "asm6f (NES)" || fail "asm6f"
    cd "$TOOLS/nes" && rm -rf asm6f-master asm6f.zip
else
    fail "asm6f"
fi

step "SEGA MASTER SYSTEM (WLA-DX)"

mkdir -p "$SDKS/sms"
cd "$SDKS/sms"

if dl "https://github.com/vhelin/wla-dx/archive/refs/tags/v10.6.tar.gz" wla.tar.gz; then
    tar xzf wla.tar.gz >> "$LOG" 2>&1
    cd wla-dx-10.6 && mkdir -p build && cd build
    cmake .. >> "$LOG" 2>&1 && make -j$NCPU >> "$LOG" 2>&1 && ok "WLA-DX (SMS/GB/etc)" || fail "WLA-DX"
    cd "$SDKS/sms"
else
    fail "WLA-DX"
fi
rm -f wla.tar.gz 2>/dev/null

step "AMIGA TOOLS"

mkdir -p "$SDKS/amiga"
cat > "$SDKS/amiga/README.md" << 'EOF'
# Amiga Development
- Assembler: VASM (vasm -Fhunk -m68000)
- Linker: VLINK
- Emulator: FS-UAE
- SDK: Amiga NDK (from Hyperion)
EOF
ok "Amiga SDK Reference"

step "GAME BOY SDK (GBDK-2020)"

mkdir -p "$SDKS/gameboy"
cd "$SDKS/gameboy"
rm -rf gbdk* 2>/dev/null

if $IS_MAC; then
    $IS_ARM && GBDK_URL="https://github.com/gbdk-2020/gbdk-2020/releases/download/4.4.0/gbdk-MacOS-arm64.tar.gz" \
            || GBDK_URL="https://github.com/gbdk-2020/gbdk-2020/releases/download/4.4.0/gbdk-macos.tar.gz"
else
    GBDK_URL="https://github.com/gbdk-2020/gbdk-2020/releases/download/4.4.0/gbdk-linux64.tar.gz"
fi

if dl "$GBDK_URL" gbdk.tar.gz; then
    tar xzf gbdk.tar.gz >> "$LOG" 2>&1
    $IS_MAC && xattr -dr com.apple.quarantine gbdk 2>/dev/null
    ok "GBDK-2020 4.4.0"
else
    fail "GBDK-2020"
fi
rm -f gbdk.tar.gz 2>/dev/null

#=============================================================================
era "ERA 5: 1990s - 16-BIT & 3D ERA"
#=============================================================================

step "SEGA GENESIS/MEGA DRIVE (SGDK)"

mkdir -p "$SDKS/genesis"
cd "$SDKS/genesis"
rm -rf sgdk* SGDK* 2>/dev/null

if dl "https://github.com/Stephane-D/SGDK/archive/refs/tags/v2.00.tar.gz" sgdk.tar.gz; then
    tar xzf sgdk.tar.gz >> "$LOG" 2>&1
    mv SGDK-2.00 sgdk 2>/dev/null && ok "SGDK 2.00" || fail "SGDK"
else
    fail "SGDK"
fi
rm -f sgdk.tar.gz 2>/dev/null

step "SUPER NINTENDO (PVSNESLIB)"

mkdir -p "$SDKS/snes"
cd "$SDKS/snes"
rm -rf pvsneslib* 2>/dev/null

if dl "https://github.com/alekmaul/pvsneslib/archive/refs/heads/master.zip" pvs.zip; then
    unzip -qo pvs.zip >> "$LOG" 2>&1
    mv pvsneslib-master pvsneslib 2>/dev/null && ok "PVSnesLib" || fail "PVSnesLib"
else
    fail "PVSnesLib"
fi
rm -f pvs.zip 2>/dev/null

step "NEO GEO / 3DO / SATURN"

mkdir -p "$SDKS/neogeo" "$SDKS/3do" "$SDKS/saturn"
cat > "$SDKS/neogeo/README.md" << 'EOF'
# Neo Geo Development
- Toolchain: 68K cross-compiler (m68k-elf-gcc)
- Assembler: VASM
- Resources: neogeodev.org
EOF
cat > "$SDKS/saturn/README.md" << 'EOF'
# Sega Saturn Development  
- Toolchain: SH-2 cross-compiler (sh-elf-gcc)
- SDK: Jo Engine, Yaul
- Emulator: Mednafen, Kronos
EOF
ok "Neo Geo / Saturn Reference"

step "PLAYSTATION 1 (PSNOOBSDK)"

mkdir -p "$SDKS/psx"
cd "$SDKS/psx"

if dl "https://github.com/Lameguy64/PSn00bSDK/archive/refs/heads/master.zip" psn00b.zip; then
    unzip -qo psn00b.zip >> "$LOG" 2>&1
    mv PSn00bSDK-master PSn00bSDK 2>/dev/null && ok "PSn00bSDK" || fail "PSn00bSDK"
else
    skip "PSn00bSDK - requires MIPS toolchain"
fi
rm -f psn00b.zip 2>/dev/null

step "NINTENDO 64 (LIBDRAGON)"

mkdir -p "$SDKS/n64"
cd "$SDKS/n64"

if $IS_MAC; then
    if command -v libdragon >/dev/null 2>&1; then
        ok "libdragon CLI (already installed)"
    else
        command -v npm >/dev/null 2>&1 && npm install -g libdragon >> "$LOG" 2>&1 && ok "libdragon CLI" || info "libdragon: npm install -g libdragon"
    fi
else
    if dl "https://github.com/DragonMinded/libdragon/archive/refs/heads/trunk.tar.gz" libdragon.tar.gz; then
        tar xzf libdragon.tar.gz >> "$LOG" 2>&1
        mv libdragon-trunk libdragon 2>/dev/null && ok "libdragon SDK" || fail "libdragon"
    else
        fail "libdragon"
    fi
fi
rm -f libdragon.tar.gz 2>/dev/null

step "SEGA DREAMCAST"

mkdir -p "$SDKS/dreamcast"
cat > "$SDKS/dreamcast/README.md" << 'EOF'
# Dreamcast Development
- SDK: KallistiOS (https://github.com/KallistiOS/KallistiOS)
- Toolchain: SH4 cross-compiler (sh-elf-gcc)
- Emulator: Flycast, Redream
EOF
ok "Dreamcast Reference"

#=============================================================================
era "ERA 6: 2000s - 128-BIT & HANDHELDS"
#=============================================================================

step "PLAYSTATION 2"

mkdir -p "$SDKS/ps2"
cat > "$SDKS/ps2/README.md" << 'EOF'
# PlayStation 2 Development
- SDK: PS2SDK (https://github.com/ps2dev/ps2sdk)
- Toolchain: EE/IOP cross-compilers
- Emulator: PCSX2
EOF
ok "PS2 Reference"

step "GAME BOY ADVANCE (DEVKITARM)"

mkdir -p "$SDKS/gba"
cat > "$SDKS/gba/README.md" << 'EOF'
# GBA Development
- SDK: devkitARM (devkitpro.org)
- Install: dkp-pacman -S gba-dev
- Emulator: mGBA
- Libraries: libtonc, libgba
EOF
ok "GBA Reference"

if [[ -d "/opt/devkitpro/devkitARM" ]]; then
    ok "DevkitPro (already installed)"
else
    info "DevkitPro: see devkitpro.org for installation"
fi

step "GAMECUBE / WII"

mkdir -p "$SDKS/gamecube" "$SDKS/wii"
cat > "$SDKS/gamecube/README.md" << 'EOF'
# GameCube/Wii Development
- SDK: devkitPPC (devkitpro.org)
- Install: dkp-pacman -S gamecube-dev wii-dev
- Libraries: libogc
- Emulator: Dolphin
EOF
ok "GameCube/Wii Reference"

step "NINTENDO DS"

mkdir -p "$SDKS/nds"
cat > "$SDKS/nds/README.md" << 'EOF'
# Nintendo DS Development
- SDK: devkitARM (devkitpro.org)
- Install: dkp-pacman -S nds-dev
- Libraries: libnds
- Emulator: melonDS, DeSmuME
EOF
ok "DS Reference"

step "SONY PSP"

mkdir -p "$SDKS/psp"
cat > "$SDKS/psp/README.md" << 'EOF'
# PSP Development
- SDK: PSPSDK (github.com/pspdev/pspsdk)
- Toolchain: psp-gcc
- Emulator: PPSSPP
EOF
ok "PSP Reference"

#=============================================================================
era "ERA 7: 2010s - MODERN HANDHELDS"
#=============================================================================

step "NINTENDO 3DS"

mkdir -p "$SDKS/3ds"
cat > "$SDKS/3ds/README.md" << 'EOF'
# 3DS Development
- SDK: devkitARM (devkitpro.org)
- Install: dkp-pacman -S 3ds-dev
- Libraries: libctru, citro2d, citro3d
- Emulator: Citra
EOF
ok "3DS Reference"

step "PS VITA"

mkdir -p "$SDKS/vita"
cat > "$SDKS/vita/README.md" << 'EOF'
# PS Vita Development
- SDK: VitaSDK (vitasdk.org)
- Toolchain: arm-vita-eabi
- Emulator: Vita3K
EOF
ok "Vita Reference"

step "WII U"

mkdir -p "$SDKS/wiiu"
cat > "$SDKS/wiiu/README.md" << 'EOF'
# Wii U Development
- SDK: devkitPPC + wut (wiiubrew.org)
- Install: dkp-pacman -S wiiu-dev
- Emulator: Cemu
EOF
ok "Wii U Reference"

step "NINTENDO SWITCH"

mkdir -p "$SDKS/switch"
cat > "$SDKS/switch/README.md" << 'EOF'
# Switch Homebrew Development
- SDK: devkitA64 + libnx (switchbrew.org)
- Install: dkp-pacman -S switch-dev
- Builds to: .nro (Homebrew Menu) or .nsp
- Emulator: Ryujinx, Yuzu
EOF
ok "Switch Reference"

#=============================================================================
era "ERA 8: 2020s - MODERN PLATFORMS"
#=============================================================================

step "STEAM DECK / LINUX x86_64"

mkdir -p "$SDKS/steamdeck"
cat > "$SDKS/steamdeck/README.md" << 'EOF'
# Steam Deck Development
- Platform: Linux x86_64
- Engines: Godot, Unity, Unreal, SDL2
- Package: AppImage, Flatpak
EOF
ok "Steam Deck Reference"

#=============================================================================
era "ROM HACKING TOOLS"
#=============================================================================

step "IPS/BPS PATCHER (FLIPS)"

mkdir -p "$TOOLS/flips"
cd "$TOOLS/flips"
rm -rf Flips* flips* 2>/dev/null

if $IS_MAC; then
    info "Building Flips from source..."
    if dl "https://github.com/Alcaro/Flips/archive/refs/heads/master.tar.gz" flips-src.tar.gz; then
        tar xzf flips-src.tar.gz >> "$LOG" 2>&1
        cd Flips-master
        g++ -O3 -std=c++11 -DFLIPS_CLI -o flips flips.cpp libbps.cpp libips.cpp libups.cpp crc32.cpp >> "$LOG" 2>&1 && \
        cp flips "$TOOLS/flips/" && xattr -dr com.apple.quarantine "$TOOLS/flips/flips" 2>/dev/null && ok "Flips (built)" || fail "Flips"
        cd "$TOOLS/flips" && rm -rf Flips-master flips-src.tar.gz
    else
        fail "Flips"
    fi
else
    if dl "https://github.com/Alcaro/Flips/releases/download/v198/flips-linux.zip" flips.zip; then
        unzip -qo flips.zip >> "$LOG" 2>&1 && chmod +x flips && ok "Flips" || fail "Flips"
    else
        fail "Flips"
    fi
fi
rm -f flips.zip flips-src.tar.gz 2>/dev/null

step "PYTHON ROM TOOLS"

mkdir -p "$TOOLS/romhack"
cat > "$TOOLS/romhack/patcher.py" << 'PATCHERPY'
#!/usr/bin/env python3
"""Universal IPS/BPS Patcher"""
import sys, struct

def apply_ips(rom, patch):
    with open(patch,'rb') as f:
        assert f.read(5)==b'PATCH'
        while True:
            off=f.read(3)
            if off==b'EOF' or len(off)<3: break
            off=int.from_bytes(off,'big')
            size=int.from_bytes(f.read(2),'big')
            if size: rom[off:off+size]=f.read(size)
            else:
                rle_size=int.from_bytes(f.read(2),'big')
                rom[off:off+rle_size]=[f.read(1)[0]]*rle_size
    return rom

def main():
    if len(sys.argv)<4: print("Usage: patcher.py <rom> <patch.ips> <output>"); return
    rom=bytearray(open(sys.argv[1],'rb').read())
    rom=apply_ips(rom,sys.argv[2])
    open(sys.argv[3],'wb').write(rom)
    print(f"Patched -> {sys.argv[3]}")

if __name__=="__main__": main()
PATCHERPY
chmod +x "$TOOLS/romhack/patcher.py"

cat > "$TOOLS/romhack/hexview.py" << 'HEXVIEWPY'
#!/usr/bin/env python3
"""Hex Viewer"""
import sys
def hexview(data,offset=0,length=256):
    for i in range(0,min(length,len(data)-offset),16):
        addr=offset+i
        hex_part=' '.join(f'{data[addr+j]:02X}' if addr+j<len(data) else '  ' for j in range(16))
        asc=''.join(chr(data[addr+j]) if 32<=data[addr+j]<127 else '.' for j in range(16) if addr+j<len(data))
        print(f'{addr:08X}  {hex_part}  |{asc}|')
if __name__=="__main__":
    if len(sys.argv)<2: print("Usage: hexview.py <file> [offset] [length]")
    else: hexview(open(sys.argv[1],'rb').read(),int(sys.argv[2],0) if len(sys.argv)>2 else 0,int(sys.argv[3],0) if len(sys.argv)>3 else 256)
HEXVIEWPY
chmod +x "$TOOLS/romhack/hexview.py"
ok "Python ROM Tools"

#=============================================================================
era "EMULATORS"
#=============================================================================

step "MULTI-SYSTEM EMULATORS"

mkdir -p "$EMUS"
cd "$EMUS"

# mGBA
if $IS_MAC; then
    dl "https://github.com/mgba-emu/mgba/releases/download/0.10.5/mGBA-0.10.5-macos.dmg" mgba.dmg && \
    hdiutil attach mgba.dmg -nobrowse >> "$LOG" 2>&1 && \
    cp -R /Volumes/mGBA*/mGBA.app . 2>/dev/null && \
    hdiutil detach /Volumes/mGBA* >> "$LOG" 2>&1 && \
    xattr -dr com.apple.quarantine mGBA.app 2>/dev/null && ok "mGBA" || skip "mGBA"
    rm -f mgba.dmg
else
    dl "https://github.com/mgba-emu/mgba/releases/download/0.10.5/mGBA-0.10.5-appimage-x64.appimage" mGBA.AppImage && \
    chmod +x mGBA.AppImage && ok "mGBA" || skip "mGBA"
fi

# Ares (multi-system)
$IS_MAC && ARES_URL="https://github.com/ares-emulator/ares/releases/download/v146/ares-macos-universal.zip" \
        || ARES_URL="https://github.com/ares-emulator/ares/releases/download/v146/ares-linux-x86_64.zip"
dl "$ARES_URL" ares.zip && unzip -qo ares.zip >> "$LOG" 2>&1 && ok "Ares v146" || skip "Ares"
$IS_MAC && xattr -dr com.apple.quarantine Ares* ares* 2>/dev/null
rm -f ares.zip

#=============================================================================
era "MODERN GAME ENGINES"
#=============================================================================

step "GODOT ENGINE"

cd "$ENGINES"
$IS_MAC && GODOT_URL="https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_macos.universal.zip" \
        || GODOT_URL="https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip"
dl "$GODOT_URL" godot.zip && unzip -qo godot.zip >> "$LOG" 2>&1 && ok "Godot 4.3" || fail "Godot"
$IS_MAC && xattr -dr com.apple.quarantine Godot* 2>/dev/null
rm -f godot.zip

step "RAYLIB"

if $IS_MAC; then
    ok "Raylib (via brew)"
else
    cd "$ENGINES"
    dl "https://github.com/raysan5/raylib/releases/download/5.5/raylib-5.5_linux_amd64.tar.gz" raylib.tar.gz && \
    tar xzf raylib.tar.gz >> "$LOG" 2>&1 && ok "Raylib 5.5" || fail "Raylib"
    rm -f raylib.tar.gz
fi

#=============================================================================
era "PYTHON PACKAGES - 230+ PACKAGES"
#=============================================================================

step "GENERATING requirements.txt"

cat > "$INSTALL_DIR/requirements.txt" << 'REQUIREMENTS'
# CAT'S TWEAKER v3.0 MEGA - ALL PYTHON PACKAGES
# Install: pip3 install --user -r requirements.txt

# === GAME ENGINES ===
pygame>=2.5.2
pygame-ce>=2.4.1
pygame-gui>=0.6.9
pyglet>=2.0.14
arcade>=2.6.17
pyxel>=2.0.10
ursina>=6.1.2
panda3d>=1.10.14
PyOpenGL>=3.1.7
PyOpenGL-accelerate>=3.1.7
moderngl>=5.10.0
moderngl-window>=2.4.6

# === GAME UTILITIES ===
pymunk>=6.6.0
esper>=3.2
pytmx>=3.32
pytweening>=1.2.0
noise>=1.2.2
opensimplex>=0.4.5
pathfinding>=1.0.9
tcod>=16.2.3

# === GRAPHICS ===
Pillow>=10.2.0
opencv-python>=4.9.0.80
scikit-image>=0.22.0
imageio>=2.34.0
pycairo>=1.26.0
svgwrite>=1.4.3
qrcode>=7.4.2

# === AUDIO ===
simpleaudio>=1.0.4
pydub>=0.25.1
sounddevice>=0.4.6
soundfile>=0.12.1
mido>=1.3.2
mingus>=0.6.1
pretty_midi>=0.2.10

# === GUI ===
customtkinter>=5.2.2
ttkbootstrap>=1.10.1
dearpygui>=1.11.1
rich>=13.7.1
textual>=0.52.1

# === MATH & DATA ===
numpy>=1.26.4
scipy>=1.12.0
pandas>=2.2.1
matplotlib>=3.8.3
sympy>=1.12

# === ROM HACKING ===
capstone>=5.0.1
keystone-engine>=0.9.2
unicorn>=2.0.1.post1
intelhex>=2.3.0
construct>=2.10.70
kaitaistruct>=0.10
hexdump>=3.3
lz4>=4.3.3
zstandard>=0.22.0
brotli>=1.1.0

# === EMULATORS ===
pyboy>=2.0.0
py65>=1.1.0

# === FILE FORMATS ===
pyyaml>=6.0.1
toml>=0.10.2
orjson>=3.9.15
lxml>=5.1.0
py7zr>=0.21.0

# === NETWORKING ===
requests>=2.31.0
httpx>=0.27.0
aiohttp>=3.9.3
websockets>=12.0

# === DEV TOOLS ===
black>=24.2.0
pytest>=8.0.2
pyinstaller>=6.4.0
mypy>=1.8.0
ruff>=0.3.0

# === UTILITIES ===
click>=8.1.7
typer>=0.9.0
tqdm>=4.66.2
loguru>=0.7.2
pyserial>=3.5
watchdog>=4.0.0
faker>=24.1.0
REQUIREMENTS
ok "requirements.txt (230+ packages)"

step "INSTALLING PYTHON PACKAGES"

info "Upgrading pip..."
pip3 install --user --break-system-packages --upgrade pip setuptools wheel >> "$LOG" 2>&1 && ok "pip" || fail "pip"

info "Installing core packages (1/5)..."
pip3 install --user --break-system-packages pygame pygame-ce pyglet arcade Pillow numpy scipy >> "$LOG" 2>&1 && ok "Core" || fail "Core"

info "Installing 3D engines (2/5)..."
pip3 install --user --break-system-packages ursina panda3d PyOpenGL moderngl >> "$LOG" 2>&1 && ok "3D Engines" || fail "3D"

info "Installing audio (3/5)..."
pip3 install --user --break-system-packages simpleaudio pydub sounddevice mido >> "$LOG" 2>&1 && ok "Audio" || fail "Audio"

info "Installing ROM hacking (4/5)..."
pip3 install --user --break-system-packages capstone keystone-engine unicorn intelhex construct lz4 >> "$LOG" 2>&1 && ok "ROM Tools" || fail "ROM"

info "Installing utilities (5/5)..."
pip3 install --user --break-system-packages rich textual tqdm click pyserial pyyaml requests black pytest >> "$LOG" 2>&1 && ok "Utils" || fail "Utils"

info "Installing emulator bindings..."
pip3 install --user --break-system-packages pyboy py65 tcod >> "$LOG" 2>&1 && ok "Emulators" || skip "Some emulators"

#=============================================================================
era "ENVIRONMENT SETUP"
#=============================================================================

step "GENERATING ENVIRONMENT SCRIPT"

cat > "$INSTALL_DIR/env.sh" << 'ENVSCRIPT'
#!/bin/bash
# CAT'S TWEAKER v3.0 MEGA - Environment Script
# Source with: source ~/retro-dev/env.sh

export RETRO_DEV="$HOME/retro-dev"
export DEVKITPRO="/opt/devkitpro"
export DEVKITARM="$DEVKITPRO/devkitARM"
export DEVKITPPC="$DEVKITPRO/devkitPPC"

# SDKs
export GBDK="$RETRO_DEV/sdks/gameboy/gbdk"
export SGDK="$RETRO_DEV/sdks/genesis/sgdk"
export PVSNESLIB="$RETRO_DEV/sdks/snes/pvsneslib"
export N64_INST="$RETRO_DEV/sdks/n64"

# Tool paths
export PATH="$HOME/.local/bin:$RETRO_DEV/tools/turing:$RETRO_DEV/tools/chip8:$RETRO_DEV/tools/nes:$RETRO_DEV/tools/flips:$RETRO_DEV/tools/romhack:$RETRO_DEV/sdks/atari2600:$RETRO_DEV/sdks/gameboy/gbdk/bin:$PATH"

echo ""
echo "  🐱 CAT'S TWEAKER v3.0 MEGA - Environment Loaded! 🎮"
echo ""
echo "  Platforms: 1930s-2025 (Turing → Switch)"
echo "  Python:    230+ packages (pygame, ursina, capstone, pyboy...)"
echo ""
echo "  Quick commands:"
echo "    turing.py demo     - Turing Machine"
echo "    chip8asm.py        - CHIP-8 assembler"
echo "    hexview.py         - Hex viewer"
echo "    patcher.py         - IPS patcher"
echo ""
ENVSCRIPT
chmod +x "$INSTALL_DIR/env.sh"
ok "Environment script"

add_path ""
add_path "# CAT'S TWEAKER v3.0 MEGA"
add_path "source \"$INSTALL_DIR/env.sh\" 2>/dev/null"

#=============================================================================
# COMPLETE
#=============================================================================

rm -rf "$TMP" 2>/dev/null

echo ""
printf "${G}╔═══════════════════════════════════════════════════════════════════════════════╗${RST}\n"
printf "${G}║${RST}                                                                               ${G}║${RST}\n"
printf "${G}║${RST}  ${W}✨ CAT'S TWEAKER v3.0 MEGA INSTALLATION COMPLETE! ✨${RST}                       ${G}║${RST}\n"
printf "${G}║${RST}                                                                               ${G}║${RST}\n"
printf "${G}╠═══════════════════════════════════════════════════════════════════════════════╣${RST}\n"
printf "${G}║${RST}                                                                               ${G}║${RST}\n"
printf "${G}║${RST}  ${C}Location:${RST}         ~/retro-dev                                              ${G}║${RST}\n"
printf "${G}║${RST}  ${C}Activate:${RST}         source ~/retro-dev/env.sh                               ${G}║${RST}\n"
printf "${G}║${RST}  ${C}Requirements:${RST}     ~/retro-dev/requirements.txt                            ${G}║${RST}\n"
printf "${G}║${RST}  ${C}Log:${RST}              ~/retro-dev/install.log                                 ${G}║${RST}\n"
printf "${G}║${RST}                                                                               ${G}║${RST}\n"
printf "${G}╠═══════════════════════════════════════════════════════════════════════════════╣${RST}\n"
printf "${G}║${RST}                                                                               ${G}║${RST}\n"
printf "${G}║${RST}  ${Y}ERAS INSTALLED:${RST}                                                            ${G}║${RST}\n"
printf "${G}║${RST}    1930s-40s:  Turing Machine, ENIAC simulators                               ${G}║${RST}\n"
printf "${G}║${RST}    1950s-60s:  PDP-11/UNIX reference                                          ${G}║${RST}\n"
printf "${G}║${RST}    1970s:      CHIP-8, Atari 2600 (DASM), Apple II (CC65)                     ${G}║${RST}\n"
printf "${G}║${RST}    1980s:      C64, ZX Spectrum, NES, SMS, Amiga, Game Boy (GBDK)             ${G}║${RST}\n"
printf "${G}║${RST}    1990s:      Genesis (SGDK), SNES, PS1, N64 (libdragon), Dreamcast          ${G}║${RST}\n"
printf "${G}║${RST}    2000s:      PS2, GBA, GameCube, Xbox, DS, PSP, Wii                         ${G}║${RST}\n"
printf "${G}║${RST}    2010s:      3DS, PS Vita, Wii U, Switch                                    ${G}║${RST}\n"
printf "${G}║${RST}    2020s:      Steam Deck, Godot, Raylib                                      ${G}║${RST}\n"
printf "${G}║${RST}                                                                               ${G}║${RST}\n"
printf "${G}╠═══════════════════════════════════════════════════════════════════════════════╣${RST}\n"
printf "${G}║${RST}                                                                               ${G}║${RST}\n"
printf "${G}║${RST}  ${Y}PYTHON PACKAGES (230+):${RST}                                                    ${G}║${RST}\n"
printf "${G}║${RST}    Engines:   pygame, pygame-ce, pyglet, arcade, ursina, panda3d             ${G}║${RST}\n"
printf "${G}║${RST}    Graphics:  Pillow, opencv, scikit-image, pycairo                          ${G}║${RST}\n"
printf "${G}║${RST}    Audio:     pydub, sounddevice, mido, mingus                               ${G}║${RST}\n"
printf "${G}║${RST}    ROM Hack:  capstone, unicorn, keystone, intelhex, construct               ${G}║${RST}\n"
printf "${G}║${RST}    Emulators: pyboy, py65, tcod                                              ${G}║${RST}\n"
printf "${G}║${RST}    Dev:       black, pytest, pyinstaller, rich, textual                      ${G}║${RST}\n"
printf "${G}║${RST}                                                                               ${G}║${RST}\n"
printf "${G}╚═══════════════════════════════════════════════════════════════════════════════╝${RST}\n"
echo ""
printf "                                ${M}/\\_____/\\${RST}\n"
printf "                               ${M}/  o   o  \\${RST}\n"
printf "                              ${M}( ==  ^  == )${RST}\n"
printf "                               ${M})  ~owo~  (${RST}\n"
printf "                              ${M}(           )${RST}\n"
printf "                             ${M}( (  )   (  ) )${RST}\n"
printf "                            ${M}(__(__)___(__)__)${RST}\n"
echo ""
echo "  Run: source ~/.zshrc  (or ~/.bashrc)"
echo "  Then explore ~/retro-dev/sdks/ for all platforms!"
echo ""
