## Laravel Docker Setup

Docker setup for Laravel applications with FrankenPHP, Redis queues, and cron support.

---

## How to run git in Laravel project as a laravel user:
```bash
cd /var/www
su laravel
git status
```
---

# **Setup Ubuntu**

## **Add your ssh key**

### Step 1) Copy your public key (on Windows)

```powershell
type $env:USERPROFILE\.ssh\id_ed25519.pub
```

Copy the entire single line (starts with `ssh-ed25519`).

### Step 2) Add it to the server (one command)

Replace `PASTE_YOUR_PUBLIC_KEY_HERE` with that full line:

```powershell
mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo 'PASTE_YOUR_PUBLIC_KEY_HERE' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys
```

Notes:

* Keep the key **inside the single quotes** after `echo`.
* The key must stay **one line**.

### Step 3) Test login
Put your ip here
```powershell
ssh root@77.110.106.5
```
## Set up docker

Here’s the clean, modern way to install **Docker Engine** + the **Docker Compose plugin** on **Ubuntu 24.04** (works the same on 24.x). This uses Docker’s official repo, so you get the current, supported packages.

### 1) Remove old/conflicting packages (safe) (optional)

```bash
sudo apt-get remove -y docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc || true
```

### 2) Add Docker’s official GPG key + repo

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo ${UBUNTU_CODENAME}) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
```

### 3) Install Docker Engine + Compose plugin

```bash
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### 4) Start and enable Docker

```bash
sudo systemctl enable --now docker
```

### 5) (Optional) Run docker without sudo

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### 6) Verify everything

```bash
docker --version
docker compose version
docker run --rm hello-world
```

If `hello-world` runs, your Docker setup is officially alive 🐳✨

---

## Create user 'laravel'
```bash
sudo useradd -m -s /bin/bash laravel
```
---

## Add ssh key for github

Here's how to create an SSH key for the root user and copy it to the laravel user:

**Step 1: Create SSH key for root user**
```bash
sudo ssh-keygen -t ed25519 -C "your-email@example.com"
```

When prompted:
- Press Enter to accept the default location (`/root/.ssh/id_ed25519`)
- Press Enter twice to skip the passphrase (or set one if you prefer)

**Step 2: Add the SSH key to GitHub for root**
```bash
sudo cat /root/.ssh/id_ed25519.pub
```

Copy the output and add it to GitHub:
- Go to GitHub → Settings → SSH and GPG keys → New SSH key
- Paste the key and save

**Step 3: Test the connection (optional)**
```bash
sudo ssh -T git@github.com
```

**Step 4: Copy SSH keys to laravel user**
```bash
# Create .ssh directory for laravel user
sudo mkdir -p /home/laravel/.ssh

# Copy the SSH keys
sudo cp /root/.ssh/id_ed25519 /home/laravel/.ssh/
sudo cp /root/.ssh/id_ed25519.pub /home/laravel/.ssh/

# Set correct ownership
sudo chown -R laravel:laravel /home/laravel/.ssh

# Set correct permissions
sudo chmod 700 /home/laravel/.ssh
sudo chmod 600 /home/laravel/.ssh/id_ed25519
sudo chmod 644 /home/laravel/.ssh/id_ed25519.pub
```

**Step 5: Test as laravel user**
```bash
sudo -u laravel ssh -T git@github.com
```

You should see: "Hi username! You've successfully authenticated..."

Both root and laravel users will now be able to use Git with GitHub using the same SSH key.

---

## Add Laravel Repo
Clone your Laravel repository:
```bash
cd /var
git@github.com:egorshubin/laravel_octane.git
mv laravel www
```
Since now you must do git commands only from laravel user, so make it the owner.
```bash
sudo chown -R laravel:laravel /var/www
```

Since Docker runs under the laravel user, you might also want to ensure the laravel user is in the docker group (if not already):
```bash
sudo usermod -aG docker laravel
```

Add .env file

## Add Docker Repo (this current repo at last!)
```bash
cd /var
git clone git@github.com:egorshubin/laravel_docker.git
mv laravel_docker docker
```

Inside /var/docker git commands must be run under root (so we do nothing)

---
## Docker set up
* add .env file
* edit /var/docker/caddy/Caddyfile, add your domain
* edit /var/docker/supervisor/supervisord.conf
  * Change `--queue=` parameter to your queue name
  * Change `numprocs=` - set the number of processes that you need
* create /var/docker/crontab file with your cron schedule, for example:
```
* * * * * laravel php /var/www/artisan schedule:run >> /dev/null 2>&1
```
Note: The cron job runs as the `laravel` user (specified at the beginning of each line)
## Build docker containers
Now you are ready for:
```bash
cd /var/docker
docker compose up -d
```
## Install Laravel
```bash
docker exec -it laravel_octane bash
composer install
php artisan migrate
```
Now exit the container (ctrl+D) and run:
```bash
docker compose restart app queue
```
Check how the processes work:
```bash
docker exec laravel_octane supervisorctl -c /etc/supervisor/conf.d/octane.conf status
docker exec laravel_queue supervisorctl -c /etc/supervisor/conf.d/supervisord.conf status
```
Supervisor now manages Octane, Redis queues, and cron jobs
