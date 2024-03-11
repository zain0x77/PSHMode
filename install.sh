# PSHMode logs
LOG_FILE=".PSHMode-install.log"
echo "" >$LOG_FILE

# Get the platform.
PLATFORM=$(python3.9 -c "import sys, os, platform;print('win' if sys.platform in ('win32', 'cygwin') else 'macosx' if sys.platform == 'darwin' else 'termux' if os.environ.get('PREFIX') != None else 'ish shell' if platform.release().endswith('ish') else 'linux' if sys.platform.startswith('linux') or sys.platform.startswith('freebsd') else 'unknown')")

# Remove old version from the tool.
python3.9 -c 'import subprocess;subprocess.run(["bash", "-i", "-c", "HackerMode delete"], stdout=subprocess.PIPE, text=True, input="y")' &>/dev/null
rm -rif HackerMode ~/.HackerMode ~/../usr/bin/HackerMode &>/dev/null
rm -f HackerModeInstall &>/dev/null
rm -rif PSHMode ~/.PSHMode ~/../usr/bin/PSHMode &>/dev/null
rm -f PSHMode.install &>/dev/null

# To install before setup the tool.
PSHMODE_PACKAGES=(
  wget
  git
  unzip
  zip
)

# Download PSHMode and move it to home.
function download_PSHMode() {
  cd "$HOME"
  rm -f main.zip
  wget https://github.com/Arab-developers/PSHMode/archive/refs/heads/main.zip &>>$LOG_FILE
  unzip main.zip &>>$LOG_FILE
  rm -f main.zip
  mv -f PSHMode-main .PSHMode
}

if [[ $PLATFORM != "unknown" ]]; then
  echo -e "Start installing for ( \033[1;32m$PLATFORM\033[0m )"
fi

# Linux installation...
if [[ "$PLATFORM" == "linux" ]]; then
  # Install packages...
  sudo apt --fix-broken install
  sudo apt update -y
  sudo apt install python3.9 -y  # Install Python 3.9 instead of python3
  sudo apt install python3.9-pip -y  # Install pip for Python 3.9 instead of python3-pip
  for PKG in ${PSHMODE_PACKAGES[*]}; do
    sudo apt install "$PKG" -y
  done

  # Download the tool.
  download_PSHMode
  sudo python3.9 -B .PSHMode add_shortcut  # Use python3.9 instead of python3
  python3.9 -B .PSHMode install  # Use python3.9 instead of python3

# Termux installation...
elif [[ "$PLATFORM" == "termux" ]]; then
  # Install packages...
  pkg update -y
  pkg install python -y
  for PKG in ${PSHMODE_PACKAGES[*]}; do
    pkg install "$PKG" -y
  done
  pkg install zsh -y

  # Get sdcard permission.
  ls /sdcard &>>$LOG_FILE || termux-setup-storage

  # Download the tool.
  download_PSHMode
  python3.9 -B .PSHMode add_shortcut  # Use python3.9 instead of python3
  mkdir /sdcard/PSHMode &>>$LOG_FILE

  # Add the font
  if ! cmp --silent -- ".PSHMode/share/fonts/DejaVu.ttf" "~/.termux/font.ttf"; then
    cp .PSHMode/share/fonts/DejaVu.ttf ~/.termux/font.ttf
    termux-reload-settings
  fi

  # Start the installation
  python3.9 -B .PSHMode install  # Use python3.9 instead of python3

elif [[ "$PLATFORM" == "ish shell" ]]; then
  # Install packages...
  apk fix
  apk update
  apk add python3.9  # Install Python 3.9 instead of python3
  apk add musl-dev
  apk add py3-pip  # Install pip for Python 3.9 instead of python3-pip
  for PKG in ${PSHMODE_PACKAGES[*]}; do
    apk add "$PKG"
  done

  # Add zshrc file.
  if ! [[ -f ~/.zshrc ]]; then
    touch ~/.zshrc
    echo "PS1='%m:%~# '" >>~/.zshrc
  fi

  # Add include files to the system.
  PY_VERSION_3_ITEMS=$(python3.9 -c 'import sys;print(sys.version.split(" ")[0])')
  PY_VERSION=$(python3.9 -c 'import sys;print(sys.version.split(" ")[0].rsplit(".", 1)[0])')
  if ! [[ -f /usr/include/python$PY_VERSION/Python.h ]]; then
    wget https://www.python.org/ftp/python/$PY_VERSION_3_ITEMS/Python-$PY_VERSION_3_ITEMS.tar.xz
    tar -xvf Python-$PY_VERSION_3_ITEMS.tar.xz Python-$PY_VERSION_3_ITEMS/Include
    rm -f Python-$PY_VERSION_3_ITEMS.tar.xz
    mv Python-$PY_VERSION_3_ITEMS/Include/* /usr/include/python$PY_VERSION/
    rm -rif Python-$PY_VERSION_3_ITEMS
  fi

  # Download the tool.
  download_PSHMode
  python3.9 -B .PSHMode add_shortcut  # Use python3.9 instead of python3
  python3.9 -B .PSHMode install  # Use python3.9 instead of python3

else
  echo "# No support for '$PLATFORM'!"
fi

# Remove variables from the global namespace.
unset PLATFORM PSHMODE_PACKAGES LOG_FILE
unset -f download_PSHMode

# Add PSHMode command line.
source "$HOME"/.PSHMode/PSHMode.shortcut
