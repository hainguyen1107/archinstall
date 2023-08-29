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

# Configure audio
cp -r /usr/share/pipewire /home/$(whoami)/.config/
sed -i '/resample.quality/s/#//; /resample.quality/s/4/15/' /home/$(whoami)/.config/pipewire/{client.conf,pipewire-pulse.conf}

# Install software
PKGS=(

    # TERMINAL UTILITIES --------------------------------------------------

    'neofetch'                     # Shows system info when you launch terminal
    'ntp'                          # Network Time Protocol to set time via network.
    'p7zip'                        # 7z compression program
    'terminus-font'                # Font package with some bigger fonts for login terminal
    'unrar'                        # RAR compression program
    'unzip'                        # Zip compression program
    'wget'                         # Remote content retrieval
    'zip'                          # Zip compression program
    'syntax-highlighting'          # Terminal Plugin

    # DEVELOPMENT ---------------------------------------------------------

    'neovim'                       # Text editor
    'sequoia-sq'                   # To check PGP key
    'docker'                       # Pack, ship and run any application as a lightweight container

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

    # OTHERS --------------------------------------------------------

    'mpv'                          # MPV player
    'smplayer'                     # Frontend GUI for mpv player
    'goldendict-nggit'	           # Golden dictionary	
    'okular'                       # PDF viewer
    'libreoffice-fresh'            # Office
    'google-chrome'	               # Web browser
    'ferdium-bin'	               # Messenger, discord... manager
    #'ibus-bamboo'	               # Vietnamese IME for Ibus
    'nomacs'                       # Image viewer
    'kimageformats'                # Image format plugins for Qt5
    'fcitx5-bamboo'                # Bamboo (Vietnamese Input Method) engine support for Fcitx
    'fcitx5-gtk'                   # Fcitx5 gtk im module and glib based dbus client library
    'fcitx5-qt'                    # Fcitx5 Qt Library
    'fcitx5-configtool'            # Configuration Tool for Fcitx5
    'konsave'                      # Import, export, extract KDE Plasma configuration profile
    'ttf-ms-fonts'                 # Core TTF Fonts from Microsoft
    'ttf-dejavu'                   # Font family based on the Bitstream Vera Fonts with a wider range of characters
    'noto-fonts'                   # Google Noto TTF fonts
    'ttf-liberation'               # Font family which aims at metric compatibility with Arial, Times New Roman, and Courier New
    'ttf-jetbrains-mono'           # Typeface for developers, by JetBrains
    'papirus-icon-theme'           # Papirus icon theme
    'layan-cursor-theme-git'       # A x-cursor theme inspired by the Layan GTK Theme and based on Capitaine Cursors
    'layan-gtk-theme-git'          # An Flat Gtk+ theme based on Material Design
    'kvantum-theme-layan-git'      # Layan theme for KDE Plasma 5
)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    yay -Syu "$PKG" --noconfirm --needed
done

# Enable QEMU connection for virt-manager
systemctl enable libvirtd.service

# Add user into kvm and libvirt groups
sudo usermod -aG kvm,libvirt $(whoami)
sudo systemctl restart libvirtd.service

# Enable trim for improving SSD performance
systemctl enable fstrim.timer

# Set up alias for updating (less effort, less typo)
echo "'alias up=yay -Syu --noconfirm --needed; yay -Sc --noconfirm'" >> ~/.bashrc

# Enable docker service and add user to docker group
sudo usermod -aG docker $(whoami)
systemctl enable docker.service

# Set up for Fcitx5
echo "GTK_IM_MODULE=fcitx" >> ~/.bashrc
echo "QT_IM_MODULE=fcitx" >> ~/.bashrc
echo "XMODIFIERS=@im=fcitx" >> ~/.bashrc

# Enable pipewire, pipewire-pulse and wireplumber globally
sudo systemctl --global enable pipewire.socket pipewire-pulse.socket
sudo systemctl --global enable pipewire.service pipewire-pulse.service wireplumber.service

echo "                    ========================="
echo "                    Configuring KDE Plasma..."
echo "                    ========================="

# Disable recent file tracking
kwriteconfig5 --file kdeglobals --group RecentDocuments --key UseRecent false
# Use Google chrome browser for http and https URLs.
kwriteconfig5 --file kdeglobals --group 'General' --key 'BrowserApplication' 'google-chrome.desktop'
# Use fastest animation speed.
kwriteconfig5 --file kwinrc --group Compositing --key 'AnimationSpeed' '0'
# Turn off alert noise when AC adapter is unplugged.
kwriteconfig5 --file powerdevil.notifyrc --group 'Event/unplugged' --key 'Action' ''
# Turn off alert noise when trash is emptied.
kwriteconfig5 --file  plasma_workspace.notifyrc --group 'Event/Trash: emptied' --key 'Action' ''
# Turn off alert noises for warnings and errors (popup instead).
kwriteconfig5 --file  plasma_workspace.notifyrc --group 'Event/catastrophe' --key 'Action' 'Popup'
kwriteconfig5 --file  plasma_workspace.notifyrc --group 'Event/fatalerror' --key 'Action' 'Popup'
kwriteconfig5 --file  plasma_workspace.notifyrc --group 'Event/messageCritical' --key 'Action' 'Popup'
kwriteconfig5 --file  plasma_workspace.notifyrc --group 'Event/messageInformation' --key 'Action' 'Popup'
kwriteconfig5 --file  plasma_workspace.notifyrc --group 'Event/messageWarning' --key 'Action' 'Popup'
kwriteconfig5 --file  plasma_workspace.notifyrc --group 'Event/messageboxQuestion' --key 'Action' 'Popup'
kwriteconfig5 --file  plasma_workspace.notifyrc --group 'Event/notification' --key 'Action' 'Popup'
kwriteconfig5 --file  plasma_workspace.notifyrc --group 'Event/printerror' --key 'Action' 'Popup'
kwriteconfig5 --file  plasma_workspace.notifyrc --group 'Event/warning' --key 'Action' 'Popup'
# Turn off alerts for console bells.
kwriteconfig5 --file  konsole.notifyrc --group 'Event/BellInvisible' --key 'Action' ''
kwriteconfig5 --file  konsole.notifyrc --group 'Event/BellVisible' --key 'Action' ''
# Automatically lock screen after .... 99999 minutes (=_=)
kwriteconfig5 --file  kscreenlockerrc --group 'Daemon' --key 'Timeout' '99999'
# Narrower window drop shadows.
kwriteconfig5 --file breezerc --group 'Common' --key 'ShadowSize' 'ShadowSmall'
# Turn off kwallet.
kwriteconfig5 --file kwalletrc --group 'Wallet' --key 'Enabled' 'false'
kwriteconfig5 --file kwalletrc --group 'Wallet' --key 'First Use' 'false'
# Disable file indexing by baloofile.
kwriteconfig5 --file kcmshell5rc --group 'Basic Settings' --key 'Indexing-Enabled' 'false'
kwriteconfig5 --file baloofilerc --group 'Basic Settings' --key 'Indexing-Enabled' 'false'
# Don't show media controls on the lock screen.
kwriteconfig5 --file kscreenlockerrc --group 'Greeter' --group 'LnF' --group 'General' --key 'showMediaControls' --type 'bool' 'false'
# Make sure desktop session starts empty
kwriteconfig5 --file ksmserverrc --group 'General' --key 'loginMode' 'default'
# Open new documents in tabs.
kwriteconfig5 --file okularpartrc --group 'General' --key 'ShellOpenFileInTabs' --type 'bool' 'true'
# Make yakuake full-width.
kwriteconfig5 --file yakuakerc --group 'Window' --key 'Width' '100'
# Make yakuake animation instant.
kwriteconfig5 --file yakuakerc --group 'Animation' --key 'Frames' '0'
# Allow empty clipboard.
kwriteconfig5 --file klipperrc --group 'General' --key 'PreventEmptyClipboard' --type bool 'false'
# Set language to "American English"
kwriteconfig5 --file kdeglobals --group 'Translations' --key 'LANGUAGE' 'en_US'
# Make kde faster, effects are for people who have leisure time.
kwriteconfig5 --file kdeglobals --group "KDE-Global GUI Settings" --key "GraphicEffectsLevel" 0
# Power management
kwriteconfig5 --file powermanagementprofilesrc --group AC --group SuspendSession  --key idleTime 1200000
kwriteconfig5 --file powermanagementprofilesrc --group AC --group SuspendSession  --key suspendThenHibernate false
kwriteconfig5 --file powermanagementprofilesrc --group AC --group SuspendSession  --key suspendType 1
kwriteconfig5 --file powermanagementprofilesrc --group AC --group HandleButtonEvents --key lidAction 32
kwriteconfig5 --file powermanagementprofilesrc --group AC --group HandleButtonEvents --key powerButtonAction 1
kwriteconfig5 --file powermanagementprofilesrc --group AC --group HandleButtonEvents --key triggerLidActionWhenExternalMonitorPresent false
kwriteconfig5 --file powermanagementprofilesrc --group Battery --group HandleButtonEvents --key lidAction 32
kwriteconfig5 --file powermanagementprofilesrc --group Battery --group HandleButtonEvents --key powerButtonAction 1
kwriteconfig5 --file powermanagementprofilesrc --group Battery --group HandleButtonEvents --key triggerLidActionWhenExternalMonitorPresent false
kwriteconfig5 --file powermanagementprofilesrc --group LowBattery --group HandleButtonEvents --key lidAction 32
kwriteconfig5 --file powermanagementprofilesrc --group LowBattery --group HandleButtonEvents --key powerButtonAction 1
kwriteconfig5 --file powermanagementprofilesrc --group LowBattery --group HandleButtonEvents --key triggerLidActionWhenExternalMonitorPresent false
# Change panel height
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "panels()[0].height = 50"
# Set the Meta key as a shortcut to open KRunner
kwriteconfig5 --file kwinrc --group ModifierOnlyShortcuts --key Meta "org.kde.krunner,/App,,toggleDisplay"
qdbus org.kde.KWin /KWin reconfigure
# Disable stupid touch screen edges and weird corners and thir animations
kwriteconfig5 --file kwinrc --group Effect-Cube --key BorderActivate "9"
kwriteconfig5 --file kwinrc --group Effect-Cube --key BorderActivateCylinder "9"
kwriteconfig5 --file kwinrc --group Effect-Cube --key BorderActivateSphere "9"
kwriteconfig5 --file kwinrc --group Effect-Cube --key TouchBorderActivate "9"
kwriteconfig5 --file kwinrc --group Effect-Cube --key TouchBorderActivateCylinder "9"
kwriteconfig5 --file kwinrc --group Effect-Cube --key TouchBorderActivateSphere "9"
kwriteconfig5 --file kwinrc --group Effect-DesktopGrid --key BorderActivate "9"
kwriteconfig5 --file kwinrc --group Effect-DesktopGrid --key TouchBorderActivate "9"
kwriteconfig5 --file kwinrc --group Effect-PresentWindows --key BorderActivate "9"
kwriteconfig5 --file kwinrc --group Effect-PresentWindows --key BorderActivateAll "9"
kwriteconfig5 --file kwinrc --group Effect-PresentWindows --key BorderActivateClass "9"
kwriteconfig5 --file kwinrc --group Effect-PresentWindows --key TouchBorderActivate "9"
kwriteconfig5 --file kwinrc --group Effect-PresentWindows --key TouchBorderActivateAll "9"
kwriteconfig5 --file kwinrc --group Effect-PresentWindows --key TouchBorderActivateClass "9"
kwriteconfig5 --file kwinrc --group TabBox --key BorderActivate "9"
kwriteconfig5 --file kwinrc --group TabBox --key BorderAlternativeActivate "9"
kwriteconfig5 --file kwinrc --group TabBox --key TouchBorderActivate "9"
kwriteconfig5 --file kwinrc --group TabBox --key TouchBorderAlternativeActivate "9"
kwriteconfig5 --file kwinrc --group ElectricBorders --key Bottom "None"
kwriteconfig5 --file kwinrc --group ElectricBorders --key BottomLeft "None"
kwriteconfig5 --file kwinrc --group ElectricBorders --key BottomRight "None"
kwriteconfig5 --file kwinrc --group ElectricBorders --key Left "None"
kwriteconfig5 --file kwinrc --group ElectricBorders --key Right "None"
kwriteconfig5 --file kwinrc --group ElectricBorders --key Top "None"
kwriteconfig5 --file kwinrc --group ElectricBorders --key TopLeft "None"
kwriteconfig5 --file kwinrc --group ElectricBorders --key TopRight "None"
kwriteconfig5 --file kwinrc --group TouchEdges --key Bottom "None"
kwriteconfig5 --file kwinrc --group TouchEdges --key Left "None"
kwriteconfig5 --file kwinrc --group TouchEdges --key Right "None"
kwriteconfig5 --file kwinrc --group TouchEdges --key Top "None"
# Set titlebar buttons
kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key BorderSize "Normal"
kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft "MF"
kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight "IAX"
kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key CloseOnDoubleClickOnMenu "false"
kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key ShowToolTips "false"
# Set night color instant = 5500K
kwriteconfig5 --file kwinrc --group NightColor --key Active "true"
kwriteconfig5 --file kwinrc --group NightColor --key Mode "Constant"
kwriteconfig5 --file kwinrc --group NightColor --key NightTemperature "5500"
# Set icon theme to ePapirus-dark
kwriteconfig5 --file kdeglobals --group Icons --key Theme "ePapirus-Dark"
# Set mouse cursor to Layan-cursor
kwriteconfig5 --file kcminputrc --group Mouse --key cursorTheme "Layan-cursors"
# Set KDE Look and Feel package and widgetStyle to Layan
kwriteconfig5 --file kdeglobals --group KDE --key LookAndFeelPackage "com.github.vinceliuice.Layan"
kwriteconfig5 --file kdeglobals --group KDE --key widgetStyle "Breeze"
# Set timezone
kwriteconfig5 --file ktimezonedrc --group TimeZones --key LocalZone "Asia/Ho_Chi_Minh"
# Set SDDM theme
kwriteconfig5 --file sddmthemeinstallerrc --group DownloadedThemes --key /tmp/Layan.tar.xz "/usr/share/sddm/themes/Layan"




echo
echo "Done!"
echo
