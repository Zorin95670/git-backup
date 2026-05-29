# git-backup

A minimal, production-ready Git mirror backup CLI for Linux (designed for Raspberry Pi, Debian, Ubuntu, Fedora, Arch, and homelab servers).

It creates full Git mirror backups of your repositories and performs automated snapshotting, compression, and retention management so you can restore your entire Git state at any time—even if Git becomes unavailable.

---

# Key Features

* Full Git mirror support (`--mirror`)
* All branches, tags, and refs included
* Incremental backup snapshots
* Automatic compression using `zstd`
* Retention policy (keeps last 5 snapshots)
* Skips backups when no changes are detected
* Simple CLI (init / install / exec)
* systemd compatible for automation

---

# Installation

## Quick install (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/Zorin95670/git-backup/main/install.sh | sudo bash
````

---

## Manual install (Debian / Ubuntu)

```bash
sudo apt update
sudo apt install -y git zstd curl

sudo curl -o /usr/local/bin/git-backup \
https://raw.githubusercontent.com/Zorin95670/git-backup/main/git-backup

sudo chmod +x /usr/local/bin/git-backup
```

---

# SSH Authentication (IMPORTANT)

This tool requires Git access to your repositories.

We strongly recommend using a dedicated SSH key for backups.

## 1. Generate a backup SSH key

```bash
ssh-keygen -t ed25519 -f ~/.ssh/git_backup
```

## 2. Add SSH config

```bash
nano ~/.ssh/config
```

```sshconfig
Host github.com
    IdentityFile ~/.ssh/git_backup
    IdentitiesOnly yes
```

## 3. Add the public key to GitHub

```bash
cat ~/.ssh/git_backup.pub
```

Add it here:

[https://github.com/settings/keys](https://github.com/settings/keys)

## 4. Test access

```bash
ssh -T git@github.com
```

---

# Quick Start

## 1. Initialize

```bash
git-backup init
```

Creates:

```text
/opt/git-backup/
├── mirrors/
├── snapshots/
├── logs/
└── repos.txt
```

---

## 2. Configure repositories

```bash
nano /opt/git-backup/repos.txt
```

```text
git@github.com:user/repo1.git
git@github.com:user/repo2.git
```

---

## 3. Install mirrors

```bash
git-backup install
```

Internally:

```bash
git clone --mirror <repo>
```

---

## 4. Run backup manually

```bash
git-backup exec
```

---

# Automation

## Option A — systemd (recommended)

```bash
sudo systemctl enable --now git-backup.timer
```

> Note: systemd service and timer files must be installed separately.

---

## Option B — cron alternative

```bash
crontab -e
```

```bash
0 2 * * * /usr/local/bin/git-backup exec >> /opt/git-backup/logs/cron.log 2>&1
```

---

# Configuration File

```bash
/opt/git-backup/repos.txt
```

Format:

```text
# One repository per line
git@github.com:USER/REPO1.git
git@github.com:USER/REPO2.git
https://github.com/USER/REPO3.git
```

---

# Backup Structure

```text
/opt/git-backup/
├── mirrors/          # live git mirrors
├── snapshots/        # historical backups
│   ├── 2026-05-29_12-00-00/
│   ├── 2026-05-28_12-00-00.tar.zst
│   └── ...
├── repos.txt
└── logs/
```

---

# Restore a repository

## Step 1: Extract snapshot

```bash
tar --zstd -xf 2026-05-28_12-00-00.tar.zst
```

## Step 2: Enter repository

⚠️ The folder name includes a hash:

```bash
cd <repo_name>_<hash>.git
```

## Step 3: Push back to GitHub

```bash
git push --mirror git@github.com:USER/REPO.git
```

---

# Why this tool exists

Git is not a backup system.

This tool ensures:

* Full offline recovery of all repositories
* Disaster recovery in case of account or service loss
* Local redundancy for all Git projects

---

# License

AGPL-3.0

```
