#!/bin/bash
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

echo
echo "Installing Yay"
echo

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm --needed
cd ~

# Set timezone
timedatectl set-timezone Asia/Ho_Chi_Minh
# Enable Network Time Sync
timedatectl set-ntp true

# Configure audio
cp -r /usr/share/pipewire /home/$(whoami)/.config/
sed -i '/resample.quality/s/#//; /resample.quality/s/4/15/' /home/$(whoami)/.config/pipewire/{client.conf,pipewire-pulse.conf}

# Install software
PKGS=(

    # TERMINAL UTILITIES --------------------------------------------------

    'fastfetch'                    # Like Neofetch, but much faster because written in C
    'ntp'                          # Network Time Protocol to set time via network.
    'terminus-font'                # Font package with some bigger fonts for login terminal
    'neovim'                       # Text editor
    'wlogout'                      # Logout menu for wayland
    'pacseek'                      # A terminal user interface for searching and installing Arch Linux packages
    'fzf'                          # Command-line fuzzy finder
    'fd'			   # Simple, fast and user-friendly alternative to find
    'ripgrep'			   # A search tool that combines the usability of ag with the raw speed of grep
    'yazi'                         # Terminal file manager

    # Compression and decompression

    'p7zip'                        # 7z compression program
    'ark'                          # Dolphin default app for compressing and decompressing
    'unrar'                        # RAR compression program
    'unzip'                        # Zip compression program
    'wget'                         # Remote content retrieval
    'zip'                          # Zip compression program
    'zstd'                         # Zstandard - Fast real-time compression algorithm
    
    
    # DEVELOPMENT ---------------------------------------------------------

 #   'apparmor'                     # Mandatory Access Control (MAC) using Linux Security Module (LSM)
 #   'snapd'                        # Service and tools for management of snap packages
    'extra-cmake-modules'          # Extra modules and scripts for CMake
    'sequoia-sq'                   # To check PGP key
    'docker'                       # Pack, ship and run any application as a lightweight container
    'python-pip'                   # The PyPA recommended tool for installing Python packages
    'wget'                         # Network utility to retrieve files from the Web
    'python-gpgme'                 # Python bindings for GPGme
    'downgrade'                    # Bash script for downgrading one or more packages to a version in your cache or the A.L.A
    'auto-cpufreq'                 # Automatic CPU speed & power optimizer
    'clipboard-sync'
    'luarocks'			           # Deployment and management system for Lua modules
    'extension-manager'            # A manager for Gnome extensions
    
    
    # Wine - software to run some windows apps on Linux
    'wine-staging'                 # A compatibility layer for running Windows programs - Staging branch
    'wine-gecko'                   # Wine's built-in replacement for Microsoft's Internet Explorer
    'wine-mono'                    # Wine's built-in replacement for Microsoft's .NET Framework

    # Study
    'anki-bin'                     # Helps you remember facts (like words/phrases in a foreign language) efficiently
    'logseq-desktop-bin'           # Privacy-first, open-source platform for knowledge sharing and management

    # Cloud storage
    'megasync-bin'                 # Easy automated syncing between your computers and your MEGA cloud drive
    'maestral'                     # A light-weight and open-source Dropbox client
    
    # Faster whisper
    'cuda'                         # NVIDIA's GPU programming toolkit
    'cudnn'                        # NVIDIA CUDA Deep Neural Network library

    # Network
    'nm-connection-editor'         # NetworkManager GUI connection editor and widgets
    'networkmanager-openvpn'       # NetworkManager VPN plugin for OpenVPN
    
    
    # KVM/QEMU
    'virt-manager'                 # Desktop user interface for managing virtual machines
    'qemu-full'                    # A full QEMU setup
    'edk2-ovmf'                    # TianoCore project to enable UEFI support for Virtual Machines
    'vde2'                         # Virtual Distributed Ethernet for emulators like qemu
    'dnsmasq'                      # Lightweight, easy to configure DNS forwarder and DHCP server
    'iptables-nft'                 # Linux kernel packet control tool (using nft interface)
    'bridge-utils'                 # Utilities for configuring the Linux ethernet bridge
    'virt-viewer'                  # A lightweight interface for interacting with the graphical display of virtualized guest OS
    'dmidecode'                    # Desktop Management Interface table related utilities
    'swtpm'                        # Libtpms-based TPM emulator with socket, character device, and Linux CUSE interface
    'openbsd-netcat'               # TCP/IP swiss army knife. OpenBSD variant.
    'libguestfs'                   # Access and modify virtual machine disk images

    # Vietnamese input ----------------------------------------------
    'fcitx5-bamboo'                # Bamboo (Vietnamese Input Method) engine support for Fcitx
    'fcitx5-gtk'                   # Fcitx5 gtk im module and glib based dbus client library
    'fcitx5-qt'                    # Fcitx5 Qt Library
    'fcitx5-configtool'            # Configuration Tool for Fcitx5

    # Chinese input -------------------------------------------------
    #'fcitx5-chinese-addons'        # Addons related to Chinese
    #'adobe-source-han-sans-cn-fonts'
    #'adobe-source-han-serif-cn-fonts'
    #'noto-fonts-cjk wqy-microhei'
    #'wqy-microhei-lite' 
    #'wqy-bitmapfont'
    #'wqy-zenhei'
    #'ttf-arphic-ukai'
    #'ttf-arphic-uming'
    #'ttf-kanjistrokeorders'        # Kanji stroke order font

    # Extra fonts
    'ttf-meslo-nerd-font-powerlevel10k'
    'ttf-sourcecodepro-nerd'
    'ttf-jetbrains-mono-nerd'
    'ttf-ms-fonts'                 # Core TTF Fonts from Microsoft
    'noto-fonts'                   # Google Noto TTF fonts
    'ttf-liberation'               # Font family which aims at metric compatibility with Arial, Times New Roman, and Courier New
    'otf-atkinson-hyperlegible'    # A typeface focusing on leterform distinction for legibility for low vision readers
    'nerd-fonts-inter'             # Inter Font, patched with the Nerd Fonts Patcher
    'otf-font-awesome'             # Important to show icons in Waybar
    'ttf-font-awesome'             # Iconic font designed for Bootstrap

    # VPN
    'protonvpn-cli-community'      # A Community Linux CLI for ProtonVPN

    # Theme and customization
    'konsave'                      # Import, export, extract KDE Plasma configuration profile
    'nwg-look'                     # GTK3 settings editor adapted to work on wlroots-based compositors
    'swww'                         # A Solution to your Wayland Wallpaper Woes
    
    # OTHERS --------------------------------------------------------

    'mpv'                          # MPV player
    'smplayer'                     # Frontend GUI for mpv player
    'deluge'                       # Full-featured BitTorrent application
    'deluge-gtk'                   # Deluge GUI
    'okular'                       # PDF viewer
    'libreoffice-fresh'            # Office
    'firefox'	                   # Web browser
    'ferdium-bin'	               # Messenger, discord... manager
    'nomacs'                       # Image viewer
    'libheif'                      # An HEIF and AVIF file format decoder and encoder
    'grimshot'                     # A helper for screenshots within sway
    'ulauncher'                    # Application launcher like rofi
)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    yay -Syu "$PKG" --noconfirm --needed
done

# Move dotfiles folder to home
mv -r dotfiles ${HOME}

# Move .zshrc to its location
ln ${HOME}/dotfiles/.zshrc ${HOME}/.zshrc

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install powerlevel10k theme for zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install plugins for zsh
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete


# Enable QEMU connection for virt-manager
sudo systemctl enable libvirtd.service

# Enable Apparmor and Snap.Apparmor
#sudo systemctl enable apparmor.service
#sudo systemctl enable snapd.apparmor.service

# Enable Snapd socket
#sudo systemctl enable snapd.socket

# Add user into kvm and libvirt groups
sudo usermod -aG kvm,libvirt $(whoami)
sudo systemctl restart libvirtd.service

# Enable virtual network and set it to autostart
sudo virsh net-start default
sudo virsh net-autostart default

# Configure and enable DNS
sudo ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
sudo mkdir -p /etc/systemd/resolved.conf.d
sudo cat > /etc/systemd/resolved.conf.d/dns_servers.conf << EOF
[Resolve]
DNS=8.8.8.8 2001:4860:4860::8888
DNS=8.8.4.4 2001:4860:4860::8844
Domains=~.
FallbackDNS=127.0.0.1 ::1
EOF
sudo systemctl enable --now systemd-resolved.service

# Enable trim for improving SSD performance
sudo systemctl enable fstrim.timer

# Enable docker service and add user to docker group
sudo usermod -aG docker $(whoami)
sudo systemctl enable docker.service

# Enable pipewire, pipewire-pulse and wireplumber globally
sudo systemctl --global enable pipewire.socket pipewire-pulse.socket
sudo systemctl --global enable pipewire.service pipewire-pulse.service wireplumber.service

# Disable any kind of suspension
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# Set dolphin to show hidden files
#sed -i '/Hidden/d' ~/.local/share/dolphin/view_properties/global/.directory
#echo "HiddenFilesShown=true" >> ~/.local/share/dolphin/view_properties/global/.directory

# Set up Virtual Environment for external python packages (for using PIP):
mkdir -p $HOME/.venvs  # create a folder for all virtual environments 
python3 -m venv $HOME/.venvs/MyEnv  # create MyEnv


# Add SSH private key to the ssh-agent
mkdir -p $HOME/.ssh
ssh-add $HOME/.ssh/id_ed25519

# Git configuration
git config --global user.name "hainguyen1107"
git config --global user.email "tamtunhubui@gmail.com"
git config --global  pull.ff true

# Remove archived journal files until the disk space they use falls below 100M
sudo journalctl --vacuum-size=100M

mkdir $HOME/.config/systemd/user
cp -r ${HOME}/dotfiles/systemd/user/* ${HOME}/.config/systemd/user

# Enable auto-cpufreq
sudo systemctl enable --now auto-cpufreq.service

# Change default shell to zsh
sudo chsh -s /usr/bin/zsh
source $HOME/.zshrc

# Activate ulauncher service
systemctl --user enable --now ulauncher.service

echo 'Install the extension "Super key"'
echo "Open Ulauncher Preferences and set hotkey to something you'll never use"
echo 'Open Settings > Keyboard (may be named "Keyboard Shortcuts"), then scroll down to Customize Shortcuts > Custom Shortcuts > +'
echo 'In Command enter ulauncher-toggle, set name and shortcut, then click Add'

echo
echo "Done!"
rm -r ${HOME}/arch
