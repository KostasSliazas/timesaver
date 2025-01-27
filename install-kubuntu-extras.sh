#!/bin/bash

# Exit immediately if a command fails
set -e
# set -x
# Global COLORS VARIABLES
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
RESET="\e[0m"

# Display welcome message
echo -e "\n${CYAN}==============================="
echo " CUTE Kubuntu Extras Installer "
echo -e "===============================${RESET}"

# Define a global list of apps to be installed
declare -a apps=(
  "vlc"
  "gimp"
  "htop"
  "inkscape"
  "firefox"
  "curl"
  "git"
  "ufw"
  "kget"
  "strawberry"
  "gnome-disk-utility"
  "trimage"
  "xdm"
  "krita"
  "darktable"
  "stacer"
  "chromium"
  "transmission-cli"
  "clamav"
  "wget"
)

# Global constant for countdown time
COUNTDOWN_TIME=3

# Define a list of services to disable
services_to_disable=(
  "rsyslog"
  "systemd-journald"
  "bluetooth"
  "mysql"
  "apache2"
  "ssh"
  "nginx"
  "postfix"
  "docker"
  "cups"
)

# List of domains to block
BLOCKED_DOMAINS=(
  "0rbit.com"
  "adclicksrv.com"
  "ads.yieldmanager.com"
  "adservinginternational.com"
  "affiliate-network.com"
  "amazonaws.com" # Often used for hosting phishing pages
  "badb.com"
  "clicksor.com"
  "clickserve.cc"
  "datr.com"        # Facebook's tracker, but can be used by malicious parties
  "doubleclick.net" # Google's ad network often misused in malicious ads
  "g.doubleclick.net"
  "malwaredomainlist.com"
  "phishing.com"
  "static.advertising.com"
  "track.360yield.com"
  "track.adnxs.com"
  "tracking.server.com"
  "unwanted-ads.net"
  "unsafeweb.com"
  "winfixer.com" # Known for redirecting to fake antivirus sites
  "yourdirtywork.com"
  "zeusbot.com"         # Common in botnet infections
  "amarketplace.com"    # Scam and fraudulent sites
  "contentdelivery.com" # Often used in fake update prompts
  "infoproc.net"        # Used in click fraud schemes
  "clickture.com"
  "spamhub.com"      # Used to host spam websites
  "clickrewards.com" # Part of click fraud campaigns
  "trackedlink.com"
  "adservice.com"
  "trackmyads.com"  # Known for tracking and delivering unwanted ads
  "spybot.com"      # Often a rogue program related to adware
  "cool-search.com" # Redirects to malicious or fake websites
  "fakewebsecurity.com"
  "adsrvmedia.com"     # Known to deliver adware
  "smartlink.com"      # Associated with fraudulent redirection
  "trustedsurveys.com" # Often used in phishing schemes
  "phishing-attack.com"
  "ads2go.com"
  "securitycheckup.com" # Fake security warning sites
  "shadyclicks.com"
  "olifeja.lt"
  "loto.lt"
  "fb.com"
  "malwareexpert.com"
  "botattack.com"          # Associated with botnet attacks
  "zeusbot.net"            # Related to the Zeus botnet, often used in financial malware
  "scamtracker.com"        # Used to host scams
  "browser-optimizer.com"  # A malicious site posing as optimization software
  "tools-virus.com"        # Known to distribute virus warnings
  "spamlord.com"           # Hosts spam or fraudulent content
  "admiraltracker.com"     # Tracker used for malicious purposes
  "data-collection.com"    # Data harvesting and fraudulent activities
  "research-adnetwork.com" # Unwanted ad network and trackers
  "rootkit.com"            # Used for malware-related rootkits
  "badads.com"             # Known for ad fraud and malware distribution
  "fraudulentads.com"      # Used in scam advertising
  "advertising-scams.com"
  "clickfraudtracker.com"   # Associated with click fraud campaigns
  "ssl-malware.com"         # Malicious SSL-related site
  "fake-dns.com"            # DNS manipulation and fraud
  "cyberthreat.com"         # Associated with cybersecurity threats
  "malwarehost.com"         # Malware hosting site
  "unsafe-surf.com"         # Risky site hosting malicious content
  "phishing-host.com"       # Common in phishing attacks
  "trojan-distribution.com" # Used for distributing trojans
  "security-error.com"      # A site often used in fake warnings
  "scamlandingpage.com"     # Scam landing page frequently used in phishing
  "unsafe-exe.com"          # Hosts dangerous .exe files
  "clickblocker.com"        # Used for malicious redirecting
  "attack-router.com"       # Associated with network-based attacks
  "clickdisguise.com"       # Fraudulent click and ad campaigns
  "fraudulent-redirect.com" # Redirects to harmful or scam websites
)
# Declare log_enabled globally
log_enabled=false # Default is false, logging is off initially
# Log file
LOGFILE="install-log.txt"

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}🚨 This script must be run as root! 🚨${RESET}\nRun it with:\n${CYAN}sudo ./install_kubuntu_extras.sh${RESET}"
  exit 1
fi

# Prompt for confirmation to procced
echo -e "${BLUE}Do you want to proceed with the installation? (y/n): ${RESET}"
read -r choice

if [[ "$choice" != "y" ]]; then
  echo -e "${YELLOW}Installation aborted by the user.${RESET}"
  exit 0
fi

# Prompt user for logging preference
echo -e "${BLUE}Do you want to enable logging? (y/n) ${RESET}"
read -r loging

# Set global variable for logging
if [[ "$loging" == "y" ]]; then
  log_enabled=true
  echo -e "${GREEN}Logging enabled. All output will be saved to "$LOGFILE".${RESET}"
else
  log_enabled=false
  echo -e "${CYAN}Logging disabled. No log file will be saved.${RESET}"
fi

# Function to log messages with timestamp and colored output
log() {
  if [[ "$log_enabled" == false ]]; then
    echo -e "\n${GREEN}$(date '+%Y-%m-%d %H:%M:%S') $1${RESET}" # Echo the message to user if logging is disabled
  else
    echo -e "\n${GREEN}$(date '+%Y-%m-%d %H:%M:%S') $1${RESET}" | tee -a "$LOGFILE"
  fi
}

# Function to clear screen with countdown
clear_screen() {
  local COUNTDOWN_TIME=3 # Set the countdown time, for example, 5 seconds
  for ((i = COUNTDOWN_TIME; i > 0; i--)); do
    echo -ne "${YELLOW}Clearing screen in $i...${RESET}\r" # Countdown with carriage return to overwrite
    tput el                                                # Clears to the end of the line
    sleep 1
  done

  clear                                     # Clear the terminal screen
  echo -e "${GREEN}Screen cleared!${RESET}" # Final message in green
}
# Check if dialog is installed
if ! command -v dialog &>/dev/null; then
  log "Installing dialog for the interactive menu..."
  sudo apt install -y dialog
fi
# Function to disable a service with error checking
disable_service() {
  local service_name="$1"

  # Check if the service is active or exists
  echo "${CYAN}Checking if $service_name is active...${RESET}"
  if systemctl list-units --full --all | grep -q "$service_name"; then
    echo -e "${CYAN}Disabling $service_name...${RESET}"

    # Stop the service and disable it, with error checking
    sudo systemctl stop "$service_name" || {
      echo -e "${RED}Failed to stop $service_name${RESET}"
      return 1
    }
    sudo systemctl disable "$service_name" || {
      echo -e "${RED}Failed to disable $service_name${RESET}"
      return 1
    }

    echo -e "${GREEN}$service_name has been disabled.${RESET}"
  else
    echo -e "${YELLOW}$service_name is not found or not running.${RESET}"
  fi
}

# Function to display interactive checklist using dialog
select_domains() {
  log "Displaying domain selection menu..."

  # Prepare options for dialog checklist
  options=()
  for domain in "${BLOCKED_DOMAINS[@]}"; do
    options+=("$domain" "" "on") # "on" means pre-selected
  done

  # Run dialog checklist and capture selected domains
  selected=$(dialog --separate-output --checklist "Select domains to block:" 22 76 16 "${options[@]}" 2>&1 >/dev/tty)

  clear
  if [[ -z "$selected" ]]; then
    log "No domains selected. Exiting."
    exit 0
  fi

  # Convert selected items into an array
  SELECTED_DOMAINS=($selected)
}

# Flush DNS cache based on available services
flush_dns_cache() {
  if command -v systemctl &>/dev/null; then
    if systemctl list-units --full -all | grep -q "nscd.service"; then
      sudo systemctl restart nscd
    elif systemctl list-units --full -all | grep -q "systemd-resolved.service"; then
      sudo systemctl restart systemd-resolved
    elif systemctl list-units --full -all | grep -q "dnsmasq.service"; then
      sudo systemctl restart dnsmasq
    else
      log "No DNS caching service found to restart."
      return
    fi
    log "DNS cache flushed successfully."
  else
    log "Systemctl command not found. Unable to flush DNS cache."
  fi
}

# Function to block selected domains
block_domains() {
  log "Blocking selected domains..."

  for domain in "${SELECTED_DOMAINS[@]}"; do
    if ! grep -q "$domain" /etc/hosts; then
      echo "127.0.0.1 $domain" | sudo tee -a /etc/hosts >/dev/null
      echo "127.0.0.1 www.$domain" | sudo tee -a /etc/hosts >/dev/null
      log "Blocked: $domain"
    else
      log "Already blocked: $domain"
    fi
  done

  # Flush DNS cache
  flush_dns_cache
}

# Check if dialog is installed
if ! command -v dialog &>/dev/null; then
  log "Installing dialog for the interactive menu..."
  sudo apt install -y dialog
fi

# Function to safely disable systemd-journald and its related services
disable_persistent_logging() {
  # Define the services and sockets involved
  local services=("systemd-journald.service" "systemd-journald.socket" "systemd-journald-dev-log.socket" "systemd-journal-flush.service")

  # Loop through the services and try to stop and disable them
  for service in "${services[@]}"; do
    echo -e "${CYAN}Stopping $service...${RESET}"
    sudo systemctl stop "$service" 2>/dev/null

    # Check if the stop command succeeded
    if [[ $? -ne 0 ]]; then
      echo -e "${CYAN}Failed to stop $service. Continuing...${RESET}"
    else
      echo -e "${GREEN}$service stopped successfully.${RESET}"
    fi

    echo -e "${CYAN}Disabling $service...${RESET}"
    sudo systemctl disable "$service" 2>/dev/null

    # Check if the disable command succeeded
    if [[ $? -ne 0 ]]; then
      echo -e "${CYAN}Failed to disable $service. Continuing...${RESET}"
    else
      echo -e "${GREEN}$service disabled successfully.${RESET}"
    fi

    # Mask the services to prevent automatic activation
    echo -e "${CYAN}Masking $service...${RESET}"
    sudo systemctl mask "$service" 2>/dev/null

    # Check if the mask command succeeded
    if [[ $? -ne 0 ]]; then
      echo -e "${CYAN}Failed to mask $service. Continuing...${RESET}"
    else
      echo -e "${GREEN}$service masked successfully.${RESET}"
    fi

    # Check if the service is still active
    if systemctl is-active --quiet "$service"; then
      echo -e "${CYAN}$service is still active. Investigating further.${RESET}"
    else
      echo -e "${GREEN}$service has been successfully stopped, disabled, and masked.${RESET}"
    fi
  done

  # Reload systemd configuration to apply the changes
  echo -e "${CYAN}Reloading systemd configuration...${RESET}"
  sudo systemctl daemon-reload

  # Check if systemd reload was successful
  if [[ $? -ne 0 ]]; then
    echo -e "${RED}Failed to reload systemd configuration. Please check manually.${RESET}"
  else
    echo -e "${GREEN}systemd configuration reloaded successfully.${RESET}"
  fi
  log "Process complete"
}

# Install VS Code and required dependencies
install_vscode() {
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor >/usr/share/keyrings/microsoft-archive-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
  sudo apt update 2>/dev/null
  sudo apt install -y code 2>/dev/null
}

# Install VS Code extensions
install_vscode_extensions() {
  local extension_id="ms-python.python" # Replace with actual extension ID
  log "Installing VS Code Extensions..."
  code --no-sandbox --user-data-dir="$HOME/.vscode-data" --install-extension "$extension_id" --force
}

# Function to show an interactive checklist and install selected packages
install_packages() {
  log "Displaying package selection menu..."

  # Generate dialog options
  options=()
  for app in "${apps[@]}"; do
    options+=("$app" "" off) # Each item: "<package>" "<description>" <on/off>
  done

  # Run checklist with dialog/whiptail
  selected=$(dialog --separate-output --checklist "Select applications to install:" 22 76 16 "${options[@]}" 2>&1 >/dev/tty)

  clear
  if [[ -z "$selected" ]]; then
    log "No packages selected. Exiting."
    exit 0
  fi

  # Convert selected items into an array
  selected_apps=($selected)

  # Install selected packages
  log "Installing selected packages..."
  sudo apt install -y "${selected_apps[@]}" 2>/dev/null | tee -a "$LOGFILE"
}

# Update package lists and Upgrade the system
update_upgrade() {
  log "Updating package lists..."
  sudo apt update 2>/dev/null | tee -a "$LOGFILE"
  log "Upgrading system packages..."
  sudo apt upgrade -y 2>/dev/null | tee -a "$LOGFILE"
}

# Install Kubuntu restricted extras
install_kubuntu_extras() {
  log "Installing Kubuntu restricted extras..."
  sudo apt install -y kubuntu-restricted-extras 2>/dev/null | tee -a "$LOGFILE"
}

# Clean up unnecessary packages
clean_packages() {
  log "Cleaning up unnecessary packages..."
  sudo apt autoremove -y 2>/dev/null | tee -a "$LOGFILE"
  sudo apt autoclean 2>/dev/null | tee -a "$LOGFILE"
}

# Function to allow HTTP traffic on port 80
allow_http() {
  echo -e "${GREEN}Allowing HTTP (Port 80)...${RESET}"
  sudo ufw allow 80/tcp
}

# Function to allow HTTPS traffic on port 443
allow_https() {
  echo -e "${GREEN}Allowing HTTPS (Port 443)...${RESET}"
  sudo ufw allow 443/tcp
}

# Function to enable the firewall
enable_firewall() {
  echo -e "${GREEN}Enabling the firewall...${RESET}"
  sudo ufw enable
}

# Function to set default firewall policies
set_default_policies() {
  echo -e "${GREEN}Setting default firewall policies...${RESET}"
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
}

# Function to check the firewall status
check_firewall_status() {
  echo -e "${GREEN}Checking firewall status...${RESET}"
  sudo ufw status
}

# Main function to apply all firewall settings
configure_firewall() {
  # Ask user if they want to activate the firewall
  dialog --title "Firewall Configuration" --yesno "Do you want to activate the firewall?" 7 60
  response=$?

  if [ $response -eq 0 ]; then
    log "Activating firewall..."
    allow_http
    allow_https
    enable_firewall
    set_default_policies
    check_firewall_status
  else
    log "Firewall activation skipped."
  fi

}

# Loop through and disable each service
disable_all_services() {
  for service in "${services_to_disable[@]}"; do
    disable_service "$service"
  done
}

# clear_screen
update_upgrade
install_kubuntu_extras
install_packages
clean_packages
configure_firewall
select_domains
block_domains
# disable_persistent_logging
# disable_all_services
install_vscode
install_vscode_extensions

log "============ Setup complete ============"

exit 0
