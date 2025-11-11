# Docker Deployment Guide

This guide explains how to run ProManage using Docker and Docker Compose.

## Prerequisites

- Docker (version 20.10 or later)
- Docker Compose (version 2.0 or later)

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Xxsnakesz/glide-team-board.git
cd glide-team-board
```

### 2. Configure Environment Variables

Copy the example environment file and update it with your values:

```bash
cp .env.docker .env
```

Edit `.env` and update the following:

- `GOOGLE_CLIENT_ID` - Your Google OAuth Client ID
- `GOOGLE_CLIENT_SECRET` - Your Google OAuth Client Secret
- `SESSION_SECRET` - A secure random string (generate with `openssl rand -hex 32`)
- `DB_PASSWORD` - A secure database password

### 3. Start the Application

**Option A: Using the startup script (recommended for first-time setup)**

```bash
./start-docker.sh
```

The script will:
- Check if Docker is installed
- Create .env from template if needed
- Build and start all services
- Display access URLs

**Option B: Manual start**

```bash
docker compose up -d
```

This will start three services:
- **PostgreSQL** database on port 5432
- **Backend** API on port 3000
- **Frontend** web app on port 80

### 4. Access the Application

Open your browser and navigate to:
- Frontend: http://localhost
- Backend API: http://localhost:3000
- Health Check: http://localhost:3000/health

## Service Architecture

```
┌─────────────────────────────────────────────────┐
│                   Frontend                      │
│          (React + Vite + Nginx)                 │
│              Port: 80                           │
└─────────────────┬───────────────────────────────┘
                  │
                  │ HTTP/WebSocket
                  │
┌─────────────────▼───────────────────────────────┐
│                  Backend                        │
│     (Node.js + Express + Socket.IO)             │
│              Port: 3000                         │
└─────────────────┬───────────────────────────────┘
                  │
                  │ PostgreSQL
                  │
┌─────────────────▼───────────────────────────────┐
│                PostgreSQL                       │
│            (Database Server)                    │
│              Port: 5432                         │
└─────────────────────────────────────────────────┘
```

## Docker Commands

### Start Services

```bash
# Start all services
docker compose up -d

# Start specific service
docker compose up -d backend

# Start with logs
docker compose up
```

> **Note:** If you have an older version of Docker Compose, you may need to use `docker-compose` (with hyphen) instead of `docker compose`.

### Stop Services

```bash
# Stop all services
docker compose down

# Stop and remove volumes (WARNING: This deletes all data)
docker compose down -v
```

### View Logs

```bash
# View all logs
docker compose logs

# View specific service logs
docker compose logs backend
docker compose logs frontend
docker compose logs postgres

# Follow logs
docker compose logs -f backend
```

### Restart Services

```bash
# Restart all services
docker compose restart

# Restart specific service
docker compose restart backend
```

### Rebuild Services

```bash
# Rebuild and restart all services
docker compose up -d --build

# Rebuild specific service
docker compose up -d --build backend
```

## Database Management

### Access PostgreSQL

```bash
# Connect to database
docker compose exec postgres psql -U postgres -d promanage
```

### Run Migrations

The database schema is automatically initialized when the PostgreSQL container starts for the first time. If you need to manually run migrations:

```bash
# Run schema migration
docker compose exec postgres psql -U postgres -d promanage -f /docker-entrypoint-initdb.d/01-schema.sql

# Run seed data
docker compose exec postgres psql -U postgres -d promanage -f /docker-entrypoint-initdb.d/02-seed.sql
```

### Backup Database

```bash
# Backup to file
docker compose exec postgres pg_dump -U postgres promanage > backup.sql

# Restore from backup
docker compose exec -T postgres psql -U postgres -d promanage < backup.sql
```

## Environment Variables

### Database Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `DB_NAME` | Database name | `promanage` |
| `DB_USER` | Database user | `postgres` |
| `DB_PASSWORD` | Database password | `postgres` |
| `DB_PORT` | Database port | `5432` |

### Backend Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `BACKEND_PORT` | Backend API port | `3000` |
| `NODE_ENV` | Node environment | `production` |
| `SESSION_SECRET` | Session encryption key | (see .env.docker) |
| `GOOGLE_CLIENT_ID` | Google OAuth Client ID | (required) |
| `GOOGLE_CLIENT_SECRET` | Google OAuth Secret | (required) |
| `MAX_FILE_SIZE` | Max upload size in bytes | `5242880` (5MB) |

### Frontend Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `FRONTEND_PORT` | Frontend port | `80` |
| `FRONTEND_URL` | Frontend URL for CORS | `http://localhost` |

## Production Deployment

### Using Custom Domain

1. Update `.env`:
```bash
FRONTEND_URL=https://yourdomain.com
```

2. Set up SSL with Let's Encrypt:
```bash
# Install certbot
sudo apt-get install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d yourdomain.com
```

3. Update nginx configuration to use SSL

### Environment-Specific Configuration

For production, update the following:

1. Generate a secure `SESSION_SECRET`:
```bash
openssl rand -hex 32
```

2. Use a strong `DB_PASSWORD`

3. Configure Google OAuth redirect URIs in Google Cloud Console:
   - Add: `https://yourdomain.com/api/auth/google/callback`

4. Set `NODE_ENV=production`

## Troubleshooting

### Port Conflicts

If ports are already in use, update them in `.env`:

```bash
FRONTEND_PORT=8080
BACKEND_PORT=3001
DB_PORT=5433
```

### Database Connection Issues

Check if PostgreSQL is healthy:

```bash
docker compose ps postgres
docker compose logs postgres
```

### Backend Not Starting

Check backend logs:

```bash
docker compose logs backend
```

Common issues:
- Database not ready: Wait for PostgreSQL health check to pass
- Missing environment variables: Check `.env` file
- Port conflicts: Change `BACKEND_PORT` in `.env`

### Frontend Build Errors

Rebuild the frontend with verbose logs:

```bash
docker compose build --no-cache frontend
docker compose logs frontend
```

### Reset Everything

To completely reset (WARNING: deletes all data):

```bash
docker compose down -v
docker compose up -d --build
```

## Development Mode

For development with hot reload:

1. Use the native setup instead of Docker:
   - Frontend: `npm run dev`
   - Backend: `cd backend && npm run dev`

2. Or use Docker Compose override:

Create `docker-compose.override.yml`:

```yaml
version: '3.8'

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    volumes:
      - ./backend/src:/app/src
    environment:
      NODE_ENV: development
```

## Health Checks

All services include health checks:

```bash
# Check service health
docker compose ps

# Manual health check
curl http://localhost:3000/health
curl http://localhost/
```

## Scaling

To run multiple instances of the backend:

```bash
docker compose up -d --scale backend=3
```

Note: You'll need a load balancer (like nginx) to distribute traffic.

## Security Considerations

1. **Never commit `.env` file** - It contains sensitive credentials
2. **Use strong passwords** - For database and session secrets
3. **Keep secrets out of docker-compose.yml** - Use `.env` file instead
4. **Update dependencies regularly** - Run `docker compose build --no-cache`
5. **Use HTTPS in production** - Set up SSL certificates
6. **Restrict database access** - Don't expose port 5432 publicly
7. **Enable firewall** - Only allow necessary ports

## Performance Tuning

### PostgreSQL

Add to `docker-compose.yml` under postgres service:

```yaml
command:
  - "postgres"
  - "-c"
  - "shared_buffers=256MB"
  - "-c"
  - "max_connections=200"
```

### Nginx

The nginx.conf includes:
- Gzip compression
- Static asset caching
- Security headers

### Backend

Scale horizontally:
```bash
docker-compose up -d --scale backend=3
```

## Monitoring

### View Resource Usage

```bash
docker stats
```

### Container Logs

```bash
# All logs
docker compose logs -f

# Last 100 lines
docker compose logs --tail=100 backend
```

## Support

For issues and questions:
- GitHub Issues: https://github.com/Xxsnakesz/glide-team-board/issues
- Documentation: README.md
