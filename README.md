# Fail2Ban Telegram Notifier 🚀

![Fail2Ban + Telegram](https://img.shields.io/badge/Fail2Ban-Telegram-blue.svg?logo=telegram)

**Fail2Ban Telegram Notifier** is a powerful extension for Fail2Ban that sends notifications to Telegram when an IP is blocked.  
The script supports **CIDR range blocking (`bancidr`)** and **IP-API integration**

## 📌 Features

✅ **Sends Telegram alerts when Fail2Ban blocks an IP**  
✅ **Can notify about blocking entire CIDR ranges when multiple IPs from the same network attack**   
✅ **Retrieves IP information using ip-api.com**  
✅ **Detects VPN/proxy usage**  
✅ **Supports multiple Telegram chats**  
✅ **Easy installation and configuration**

## 🚀 Installation

### 1️⃣ **Download and Install the Script**

```bash
git clone https://github.com/tonytkachenko/fail2ban-telegram-notifier.git
cd fail2ban-telegram-notifier
sudo cp telegram_notifier.conf /etc/fail2ban/
sudo cp telegram.conf /etc/fail2ban/action.d/
sudo cp telegram_notifier.sh /etc/fail2ban/action.d/
```

### 2️⃣ **Configure the settings:**

Open `/etc/fail2ban/telegram_notifier.conf` and set the following parameters:

```bash
sudo nano /etc/fail2ban/telegram_notifier.conf
```

Sample configuration:

```bash
# Telegram Bot Token
TOKEN="your-telegram-bot-token"

# Telegram Chat IDs (space-separated)
CHAT_IDS="-1001234567890"

# Use ip-api.com to get IP information?
USE_IPAPI="yes"
```

### 3️⃣ **Grant execution permissions to the script:**

```bash
sudo chmod +x /etc/fail2ban/action.d/telegram_notifier.sh
```

### 4️⃣ **Enable it in the Jail configuration:**

```bash
[DEFAULT]
banaction = iptables-multiport
action = %(action_)s
         telegram # <- Set action
```

### 5️⃣ **Restart Fail2Ban**

```bash
sudo systemctl restart fail2ban
```

## 🔒 Security

- Ensure that your Telegram bot is protected and not accessible to unauthorized users.
- Set proper permissions on `/etc/fail2ban/telegram_notifier.conf` to prevent others from viewing the bot token.

## 🔥 **Upcoming Features**

- [ ] **Anti-Spam mechenism**
- [ ] **Autoinstall script**

---

## 📄 License

This project is licensed under the MIT License.

## 🤝 **Support & Contributions**

Feel free to open an **Issue or Pull Request** if you have suggestions or improvements! 🚀
