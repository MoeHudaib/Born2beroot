## 🧱 STEP 1: Virtual Machine Setup

### 🔧 Choose your virtualization software:

Most use **VirtualBox**.

1. Download **Debian** ISO from [debian.org](https://www.debian.org/distrib/) (use netinst version).
2. In **VirtualBox**, create a new VM:

   * **Type**: Linux
   * **Version**: Debian (64-bit)
   * Allocate **2+ CPUs**, **4–8 GB RAM**, and **10–20 GB storage**
3. Under “Network” settings:

   * Choose **NAT** (default)
   * In “Advanced” → “Port Forwarding”, forward:

     * Host Port: `2222`
     * Guest Port: `4242`

### 📌 Why:

* NAT lets your VM access the internet through your host.
* Port forwarding makes your host’s port 2222 connect to VM’s SSH (port 4242).

---

## 🗃️ STEP 2: OS Installation & Partitioning

When you boot the ISO:

* Choose **Manual partitioning**
* Create a **LVM encrypted setup** with separate mount points.

### 🗂 Recommended structure:

| Mount Point | Size      | Purpose                            |
| ----------- | --------- | ---------------------------------- |
| `/`         | 5–8 GB    | Base system                        |
| `/home`     | \~2–5 GB  | User data                          |
| `/var`      | 1–3 GB    | System logs, apt cache, mail, etc. |
| `/var/log`  | 500 MB–1G | Required for bonus                 |
| `/srv`      | Optional  | For web or other services (bonus)  |
| `/tmp`      | 500 MB–1G | Temporary files                    |
| `swap`      | 1–2 GB    | Virtual RAM                        |

> 💡 Use **LVM** for flexible partition resizing.

---

## 🔐 STEP 3: SSH Setup

### 1. Install the SSH server:

```bash
sudo apt update
sudo apt install openssh-server
```

### 2. Change SSH port from `22` to `4242`:

Edit config:

```bash
sudo nano /etc/ssh/sshd_config
```

Find and edit (or add):

```ini
Port 4242
PermitRootLogin no
```

Then restart the SSH server:

```bash
sudo systemctl restart ssh
```

### 3. Verify it’s listening:

```bash
sudo ss -tuln | grep 4242
```

Should return something like:

```
LISTEN 0 128 *:4242 *:*
```

### 4. Test from your host:

```bash
ssh your_username@localhost -p 2222
```

If it prompts for a password — it works ✅

---

## 🔥 STEP 4: Firewall (UFW)

Install UFW (Uncomplicated Firewall):

```bash
sudo apt install ufw
```

Set up default policies:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 4242/tcp
```

Enable the firewall:

```bash
sudo ufw enable
```

Check the status:

```bash
sudo ufw status verbose
```

> 💡 Only port `4242` should be open for incoming connections.

---

## 🧠 STEP 5: User & Password Policy

You’ll modify these files:

### 1. Lock out root login via SSH:

Already done via:

```ini
PermitRootLogin no
```

### 2. Set password expiration policy:

```bash
sudo nano /etc/login.defs
```

Edit:

```ini
PASS_MAX_DAYS   30
PASS_MIN_DAYS   2
PASS_WARN_AGE   7
```

Then, apply to your user:

```bash
sudo chage -M 30 -m 2 -W 7 your_username
```

### 3. Strong password rules:

Install `libpam-pwquality`:

```bash
sudo apt install libpam-pwquality
```

Edit PAM config:

```bash
sudo nano /etc/pam.d/common-password
```

Find this line and edit:

```bash
password requisite pam_pwquality.so retry=3 minlen=10 ucredit=-1 lcredit=-1 dcredit=-1
```

Means: minimum 10 characters, at least 1 uppercase, 1 lowercase, and 1 digit.

---

## 📈 STEP 6: Monitoring Script (Bonus)

### 1. Script to log system usage:

```bash
nano ~/monitor.sh
```

Paste:

```bash
#!/bin/bash
echo "Logging system stats..."
date
top -b -n1 | grep "Cpu(s)"
free -m
df -h
```

Make executable:

```bash
chmod +x ~/monitor.sh
```

### 2. Run every 10 minutes with cron:

```bash
crontab -e
```

Add:

```crona night to remember
*/10 * * * * /home/your_username/monitor.sh >> /home/your_username/monitor.log
```

---

## 🌐 STEP 7: Bonus - WordPress Stack (optional)

### 1. Install lighttpd:

```bash
sudo apt install lighttpd
```

Start and enable it:

```bash
sudo systemctl start lighttpd
sudo systemctl enable lighttpd
```

### 2. Install PHP and MariaDB:

```bash
sudo apt install mariadb-server php php-cgi php-mysql
```

Enable FastCGI:

```bash
sudo lighttpd-enable-mod fastcgi
sudo lighttpd-enable-mod fastcgi-php
sudo systemctl reload lighttpd
```

### 3. Setup MariaDB:

```bash
sudo mysql_secure_installation
```

Then:

```sql
CREATE DATABASE wordpress;
CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'yourpassword';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';
FLUSH PRIVILEGES;
```

### 4. Download and extract WordPress:

```bash
wget https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
sudo mv wordpress /var/www/html
sudo chown -R www-data:www-data /var/www/html/wordpress
```

---

## 📸 Finalize: Snapshot + Signature

1. Shutdown VM from inside:

```bash
sudo shutdown now
```

2. In VirtualBox:

   * Go to **Snapshots** tab
   * Take a snapshot (name it e.g., `final`)

3. Generate SHA-1 hash:

```bash
sha1sum debian.vdi > signature.txt
```

Submit `signature.txt` and `.vdi` for evaluation.

---

## 🧭 Useful Commands Summary

| Command                     | Purpose                 |
| --------------------------- | ----------------------- |
| `sudo systemctl status ssh` | Check SSH status        |
| `sudo ufw status`           | Show firewall rules     |
| `passwd -S user`            | Password aging info     |
| `crontab -e`                | Schedule periodic tasks |
| `df -h` / `free -m`         | Disk / Memory info      |
| `ss -tuln`                  | Show open ports         |
| `lighttpd -v`               | Web server version      |
| `mysql -u root -p`          | Enter MariaDB shell     |

---

That’s a full walkthrough! Let me know if you want help writing any configuration files, troubleshooting common errors, or diving deeper into services like LVM, SSH keys, or the WordPress setup.

