# 🛍️ Retail Dashboard App

Monorepo for the Retail Dashboard system — combining **dashboard UI**, **backend APIs**, and **supporting microservices** like AI inference, video pipeline, and analytics engine.

Built with **Docker Compose** for easy development and deployment.  
Submodules are used to cleanly separate each component.

---

## 📦 Project Structure

```
retail-dashboard-app/
├── retail-dashboard/        # Frontend (Next.js or similar)
├── retail-backend/          # Backend API (FastAPI, Node.js, etc.)
├── services/
│   ├── ai_inference/        # AI Inference service
│   ├── video_pipeline/      # Video stream processing
│   └── analytics_engine/    # Analytics and metrics aggregation
├── docker-compose.yml      # Docker Compose configuration
└── README.md
```

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone --recurse-submodules https://github.com/your-org/retail-dashboard-app.git
cd retail-dashboard-app
```

If you forgot `--recurse-submodules`:

```bash
git submodule update --init --recursive
```

---

### 2. Build and Start All Services

```bash
docker-compose up --build
```

Or to start without rebuilding:

```bash
docker-compose up
```

Visit:

- Frontend (Dashboard UI): [http://localhost:3000](http://localhost:3000)
- Backend API: [http://localhost:8000](http://localhost:8000)

---

### 3. Stopping the Services

```bash
docker-compose down
```

---

## 🔥 Development Tips

- Frontend and backend can be run separately for faster dev.
- You can edit code locally with **hot reload** using a `docker-compose.override.yml` (optional).
- Use named Docker volumes to persist data where needed.
- Update submodules if upstream repositories change:

```bash
git submodule update --remote --merge
```

---

## ⚙️ Environment Variables

Each subproject may require its own `.env` file:

| Project             | Env File                 | Example Variable            |
|---------------------|---------------------------|------------------------------|
| retail-dashboard    | `.env.local`               | `NEXT_PUBLIC_API_URL=http://localhost:8000` |
| retail_backend      | `.env`                     | `DATABASE_URL=postgresql://user:pass@db:5432/retail` |
| ai_inference        | `.env`                     | `MODEL_PATH=/models/latest` |
| video_pipeline      | `.env`                     | `VIDEO_INPUT_STREAM=rtsp://camera` |
| analytics_engine    | `.env`                     | `ANALYTICS_DB_URL=postgresql://user:pass@db:5432/analytics` |

> Example `.env` files are provided inside each submodule when available.

---

## 🛠️ Managing Git Submodules

| Command | Purpose |
|:---|:---|
| `git submodule add <repo> <path>` | Add a new submodule |
| `git submodule update --init --recursive` | Initialize and pull submodules |
| `git submodule update --remote --merge` | Update submodules to latest |

---

## 🧠 Useful Docker Commands

| Command | Purpose |
|:---|:---|
| `docker-compose build` | Build containers |
| `docker-compose up` | Start containers |
| `docker-compose down` | Stop and remove containers |
| `docker-compose logs -f <service>` | Tail logs for a service |

---

## 📜 License

This project is licensed under [MIT License](LICENSE).

---

# ✨ Notes

- Ensure you have **Docker** and **Docker Compose v2** installed.
- This monorepo is designed to be scalable — easily add more services under `/services`.
- Optional: add a `Makefile` for quicker commands like `make start`, `make stop`.

---

# 🚀 Happy Building!

