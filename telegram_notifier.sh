#!/bin/bash

# Load Configuration
CONFIG_FILE="/etc/fail2ban/telegram_notifier.conf"
if [ -f "$CONFIG_FILE" ]; then
  source <(grep -v '^#' "$CONFIG_FILE" | sed 's/ *= */=/g')
else
  echo "❌ Error: Configuration file $CONFIG_FILE not found!"
  exit 1
fi

# Handling Parameters
EVENT_TYPE="$1"
IP="$2"
JAIL="$3"
FAILURES="$4"

# Function to Get IP Information
get_ip_info() {
  local ip="$1"
  if [[ "$USE_IPAPI" == "no" ]]; then
    echo "🌍 Location: ❌ Disabled"
    return
  fi

  local response=$(curl -m 5 -s "http://ip-api.com/json/$ip?fields=status,message,country,city,isp,as,proxy,hosting") || response="{}"
  local status=$(echo "$response" | jq -r '.status // "error"')

  if [[ "$status" != "success" ]]; then
    echo "*🌍 Location:* ❌ Error getting IP info"
    return
  fi

  local country=$(echo "$response" | jq -r '.country // "Unknown"')
  local city=$(echo "$response" | jq -r '.city // "Unknown"')
  local isp=$(echo "$response" | jq -r '.isp // "Unknown"')
  local as=$(echo "$response" | jq -r '.as // "Unknown"' | awk '{print $1}')
  local proxy=$(echo "$response" | jq -r '.proxy')
  local hosting=$(echo "$response" | jq -r '.hosting')

  local vpn_status="🚫 No"
  if [[ "$proxy" == "true" || "$hosting" == "true" ]]; then
    vpn_status="⚠️ Yes"
  fi

  echo "*🌍 Location:* \`$city, $country\`
🔗 *ISP:* \`$isp ($as)\`
🛡 *VPN/Proxy:* $vpn_status"
}

case "$EVENT_TYPE" in
"ban")
  if [[ "$IP" =~ \/ ]]; then
    SUBNET="$IP"
    IP_INFO="🌍 *Location:* 🚫 Skipped (Subnet Ban)"
  else
    SUBNET=$(ipcalc -n -b "$IP" | awk '/Network:/ {print $2}')
    IP_INFO=$(get_ip_info "$IP")
  fi

  RDNS=$(host "$IP" | awk '/domain name pointer/ {print $5}' | sed 's/\.$//')
  if [[ -z "$RDNS" ]]; then RDNS="No rDNS"; fi

  MESSAGE="🚫 *BANNED ($JAIL)*
  
📍 *IP:* \`$IP\`
🚩 *Failures:* \`$FAILURES\`
🌐 *Subnet:* \`$SUBNET\`
$IP_INFO
🔄 *Reverse DNS:* $RDNS

🔐 *Host:* \`$(hostname)\`"
  ;;

"unban")
  MESSAGE="✅ *UNBANNED ($JAIL)*

📍 *IP:* \`$IP\`
🚩 *Failures:* \`$FAILURES\`

🔐 *Host:* \`$(hostname)\`"
  ;;

"start")
  MESSAGE="🟢 *Fail2Ban Started*

⚙️ *Jail:* \`$JAIL\`
🔐 *Host:* \`$(hostname)\`"
  ;;

"stop")
  MESSAGE="🔴 *Fail2Ban Stopped*

⚙️ *Jail:* \`$JAIL\`
🔐 *Host:* \`$(hostname)\`"
  ;;

*)
  echo "Unknown event type: $EVENT_TYPE"
  exit 1
  ;;
esac

# Function to Send Messages to Multiple Chat IDs
send_message() {
  local chat_ids=($CHAT_IDS)
  local text="$1"

  for chat_id in "${chat_ids[@]}"; do
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
      -d "chat_id=$chat_id" \
      -d "text=$text" \
      -d "parse_mode=Markdown" >/dev/null
  done
}

send_message "$MESSAGE"
