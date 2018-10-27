#/usr/bin/env bash

# Synchronize package databases
sudo pacman -Sy

sudo pacman -S --noconfirm \
	arc-gtk-theme filemanager-actions uget imagemagick lshw \
	libreoffice-fresh jre10-openjdk jdk10-openjdk openjdk10-doc \
	deepin-screenshot gcolor2 tmux tcpdump htop iftop gimp mpv \
	dosfstools tree bind-tools pavucontrol smartmontools traceroute \
	xdotool ttf-dejavu ttf-liberation adobe-source-han-sans-otc-fonts \
	ttf-hanazono go go-tools terminator zenity p7zip unrar rsync a52dec \
	libmad x264 gst-libav gst-plugins-ugly totem dconf-editor ntfs-3g \
	jq tcpdump asciinema dnscrypt-proxy unbound expat restic

# Setup golang
mkdir -p ~/src/go/{src,bin}

# Remove gnome-terminal version of 'Open in Terminal' in nautilus
sudo mv -vi /usr/lib/nautilus/extensions-3.0/libterminal-nautilus.so{,.bak}

yay -S --noconfirm \
	dropbox nautilus-dropbox transmission-gtk peek vokoscreen \
	adobe-source-han-sans-otc-fonts nvm spotify visual-studio-code-bin

# Prevent dropbox automatic updates
rm -rf ~/.dropbox-dist
install -dm0 ~/.dropbox-dist

# DNS request -> unbound :53 -> dnscrypt-proxy :53000 -> enabled dnscrypt resolver
# Change DNSCrypt-proxy port to 53000
sed -i -E -e "/^listen_addresses/s/:53'/:53000'/g" /etc/dnscrypt-proxy/dnscrypt-proxy.toml

# Get root servers list for unbound
curl -o /etc/unbound/root.hints https://www.internic.net/domain/named.cache

# Unbound configuration
cat <<-EOF > /etc/unbound/unbound.conf
server:
  use-syslog: yes
  do-daemonize: no
  username: "unbound"
  directory: "/etc/unbound"
  trust-anchor-file: trusted-key.key
  private-domain: "intranet"
  private-domain: "internal"
  private-domain: "private"
  private-domain: "corp"
  private-domain: "home"
  private-domain: "lan"
  unblock-lan-zones: yes
  insecure-lan-zones: yes
  domain-insecure: "intranet"
  domain-insecure: "internal"
  domain-insecure: "private"
  domain-insecure: "corp"
  domain-insecure: "home"
  domain-insecure: "lan"
  root-hints: root.hints
  do-not-query-localhost: no
forward-zone:
  name: "."
  forward-addr: ::1@53000
  forward-addr: 127.0.0.1@53000
EOF

# DNSSEC test
echo "DNSSEC Test, you should see the ip address with '(secure)' next to"
unbound-host -C /etc/unbound/unbound.conf -v sigok.verteiltesysteme.net

# Post-install messages
echo "Notes:"
echo "=== Gnome Exts ==="
echo "Alternatetab"
echo "Application Menu"
echo "Dash to dock"
echo "Places status indicator"
echo "Removable drive menu"
echo "Sound input & output device chooser"
echo "Uptime indicator"
echo "User themes"
echo "System-monitor"
echo ""
echo "Apply extensions setting in dconf dir"
echo ""
