# ProManage

A modern, full-stack Trello-style project management application with real-time collaboration.

## Architecture

ProManage is built as a **monorepo** with separate frontend and backend:

- **Frontend**: React + TypeScript + Vite (runs in Lovable)
- **Backend**: Node.js + Express + PostgreSQL (deploy separately to your VPS)

## Features

✅ Google OAuth authentication  
✅ Boards, Lists, and Cards (Trello-style)  
✅ Drag-and-drop reordering  
✅ Real-time collaboration (Socket.IO)  
✅ Comments and file attachments  
✅ Team member management  
✅ Role-based access control  
✅ Beautiful, responsive UI  

## Quick Start

### 🐳 Docker (Recommended)

The easiest way to run the entire application:

```bash
# 1. Copy environment file
cp .env.docker .env

# 2. Update .env with your Google OAuth credentials

# 3. Start all services (frontend, backend, database)
docker-compose up -d

# 4. Access the application at http://localhost
```

See [DOCKER.md](DOCKER.md) for complete Docker deployment guide.

### Frontend (Lovable)

The frontend is already running in Lovable. To connect it to your backend:

1. Create `.env` file:
```bash
VITE_API_URL=http://localhost:3000/api
```

2. Update when you deploy backend to production

### Backend (Your VPS)

See [backend/README.md](backend/README.md) for complete setup instructions.

Quick version:
```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your values
npm run db:migrate
npm run dev
```

## Tech Stack

### Frontend
- React 18 + TypeScript
- Vite
- TailwindCSS + shadcn/ui
- Zustand (state management)
- React Query
- Dnd Kit (drag & drop)
- Framer Motion
- Socket.IO client

### Backend
- Node.js + Express
- PostgreSQL (pure SQL via `pg`)
- Passport.js (Google OAuth)
- Socket.IO
- Zod validation
- TypeScript

## Folder Structure

```
promanage/
├── src/                  # Frontend React app
│   ├── components/
│   ├── pages/
│   ├── store/
│   ├── api/
│   └── types/
│
├── backend/              # Node.js API (deploy to VPS)
│   ├── src/
│   │   ├── db/
│   │   ├── routes/
│   │   ├── controllers/
│   │   ├── socket/
│   │   └── index.ts
│   └── package.json
│
└── README.md
```

## Development Workflow

1. **Frontend Development**: Work in Lovable (live preview)
2. **Backend Development**: Run locally or on VPS
3. **Connect**: Set `VITE_API_URL` to point to your backend
4. **Deploy Backend**: Use PM2 + Nginx on your VPS
5. **Deploy Frontend**: Lovable handles this automatically

## Deployment

### Backend Deployment (VPS)

1. Set up PostgreSQL database
2. Configure environment variables
3. Run migrations: `npm run db:migrate`
4. Build: `npm run build`
5. Start with PM2: `pm2 start dist/index.js`
6. Configure Nginx as reverse proxy

See [backend/README.md](backend/README.md) for detailed instructions.

### Frontend Deployment

Frontend is automatically deployed by Lovable. Update `VITE_API_URL` to point to your production backend.

## Google OAuth Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create OAuth 2.0 credentials
3. Add authorized redirect URIs:
   - Development: `http://localhost:3000/api/auth/google/callback`
   - Production: `https://api.yourdomain.com/api/auth/google/callback`
4. Add credentials to backend `.env` file

## Security

- ✅ Helmet.js security headers
- ✅ CORS configured
- ✅ Rate limiting
- ✅ SQL injection protection (parameterized queries)
- ✅ Input validation (Zod)
- ✅ Role-based access control
- ✅ Secure session management

---

## Original Lovable Project Info

**URL**: https://lovable.dev/projects/a90cac45-9083-45a4-a5ba-0ef67a9cc851

### Technologies
- Vite
- TypeScript
- React
- shadcn-ui
- Tailwind CSS

## License

MIT
