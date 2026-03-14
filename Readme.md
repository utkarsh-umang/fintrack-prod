# FinTrack – Full Stack Financial Tracker

FinTrack is a full-stack financial tracking application built with:

* **Frontend:** React + Vite
* **Backend:** FastAPI (Uvicorn)
* **Database:** MongoDB
* **Reverse Proxy:** Nginx
* **Containerization:** Docker + Docker Compose

---

# 🏗 Architecture

```
Client (Browser)
        ↓
Nginx (Reverse Proxy)
        ├── /        → React Frontend
        └── /api     → FastAPI Backend
                          ↓
                       MongoDB
```

All services run inside Docker containers.

---

# 📁 Project Structure

```
.
├── docker-compose.yml
├── docker-compose.dev.yml
├── nginx.conf
├── fintrack-be/              # FastAPI backend
└── internal-dashboard-fe/    # React frontend
```

# 🚀 Production Deployment Guide (GCP VM)

This section describes how to deploy and update FinTrack in production.

---

## 🔐 1️⃣ SSH Into Server

From your local machine:

```bash
ssh <your-user>@<your-server-ip>
```

If you use root:

```bash
ssh root@<your-server-ip>
```

---

## 📂 2️⃣ Navigate To Application Directory

Production app is located at:

```
/srv/fintrack
```

Run:

```bash
cd /srv/fintrack
```

If using root and want to switch user:

```bash
sudo su
cd /srv/fintrack
```

---

# 🚀 One-command deploy from your machine (`deploy.sh`)

From your **local machine** (not the VM), you can run:

```bash
./deploy.sh
```

**Step 1:** The script opens Google auth so you can log in with your **personal** GCP account (and avoid using your work account).

**Step 2:** It SSHs into your VM and runs `git pull`, submodule update, and `docker-compose up -d --build` (with `sudo` on the server).

**Configure once** (edit `deploy.sh` or set env vars):

- **Option A – GCP VM:** set `FINTRACK_GCP_PROJECT`, `FINTRACK_GCP_ZONE`, `FINTRACK_GCP_INSTANCE`.
- **Option B – direct SSH:** set `FINTRACK_VM` (e.g. `utk_umang@your-vm-ip`).

Optional: `FINTRACK_REPO_DIR` (default `/srv/fintrack`), `FINTRACK_BRANCH` (default `main`).

---

# 🔄 Updating Production (After Pushing Code)

Whenever you push changes to GitHub:

---

## 1️⃣ Pull Latest Code

```bash
git pull origin main
```

(Replace `main` with your branch if different.)

---

## 2️⃣ Update Submodules

If the project uses submodules:

```bash
git submodule sync
git submodule update --init --recursive
```

This ensures backend and frontend are updated correctly.

---

## 3️⃣ Rebuild & Restart Containers

```bash
docker-compose down
docker-compose up -d --build
```

This will:

* Rebuild backend image
* Rebuild frontend image
* Restart nginx
* Keep Mongo volume data intact

---

## ✅ Verify Deployment

Check running containers:

```bash
docker ps
```

Check logs if needed:

```bash
docker-compose logs -f
```

---

# 🛑 Stopping The Application

```bash
docker-compose down
```

---

# 🔁 Full Clean Restart (If Something Breaks)

```bash
docker-compose down
docker-compose up -d --build
```

---

# 🔄 Restart Only Nginx (After SSL Renewal)

```bash
docker exec fintrack-nginx nginx -s reload
```

---

# 📦 First-Time Production Setup

On a fresh VM:

```bash
sudo apt update
sudo apt install docker.io docker-compose git -y
```

Clone repository:

```bash
git clone <repo-url> /srv/fintrack
cd /srv/fintrack
git submodule update --init --recursive
docker-compose up -d --build
```

---

# 📁 Production Folder Structure

```
/srv/fintrack
 ├── docker-compose.yml
 ├── nginx.conf
 ├── fintrack-be
 └── internal-dashboard-fe
```

---

# 🔐 SSL Certificates Location

Certificates are stored at:

```
/etc/letsencrypt/live/fintrack.scalebrandslab.com/
```

Mounted into nginx container.

---

# 🧠 Deployment Workflow Summary

```
Push code → SSH into VM → cd /srv/fintrack
git pull
git submodule update --init --recursive
docker-compose up -d --build
```


## Start Production

```bash
docker-compose up -d --build
```

## Stop Production

```bash
docker-compose down
```

---

# 🧪 Local Development (Docker)

Development mode exposes backend and MongoDB for easier debugging.

Uses:

```
docker-compose.yml + docker-compose.dev.yml
```

## Start Local Dev

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build
```

Or if using older Docker:

```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up --build
```

### Access Locally

* Frontend: [http://localhost:3000](http://localhost:3000)
* Backend: [http://localhost:8000](http://localhost:8000)
* MongoDB: mongodb://localhost:27017

---

## Stop Local Dev

```bash
docker compose down
```

---

# 🔐 HTTPS (Production)

SSL certificates are generated using Certbot:

```bash
sudo certbot certonly --standalone -d fintrack.scalebrandslab.com
```

Certificates are mounted into the nginx container from:

```
/etc/letsencrypt
```

Automatic renewal is handled by cron.

---

# 🔄 Updating Production

On the server:

```bash
cd /srv/fintrack
git pull
docker-compose up -d --build
```

---

# 🛠 Common Commands

## View Running Containers

```bash
docker ps
```

## View Logs

```bash
docker-compose logs -f
```

## Restart Everything

```bash
docker-compose down
docker-compose up -d --build
```

---

# ⚠️ Important Notes

* Frontend API calls must use **relative paths**:

  ```
  /api/...
  ```

  Do NOT hardcode `localhost` or `127.0.0.1`.

* MongoDB is internal to Docker network in production (not publicly exposed).

* Nginx handles HTTPS and reverse proxying.

---

# 📦 Tech Stack Versions

* Node 20+
* Python 3.11+
* MongoDB 7
* Docker 24+
* Nginx Alpine

---

# 🧠 Environment Variables

Backend expects:

```
MONGO_URL
DB_NAME
ENVIRONMENT
```

Frontend should use:

```
VITE_API_URL=/api
```

---

# 🧾 License

Internal project – not publicly licensed.