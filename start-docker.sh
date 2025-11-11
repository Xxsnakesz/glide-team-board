#!/bin/bash

# ProManage Docker Startup Script
# This script helps you get started with Docker deployment

set -e

echo "🐳 ProManage Docker Setup"
echo "========================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "   Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available. Please install Docker Compose."
    echo "   Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  No .env file found. Creating from template..."
    if [ -f .env.docker ]; then
        cp .env.docker .env
        echo "✅ Created .env file from .env.docker"
        echo ""
        echo "⚠️  IMPORTANT: Please edit .env and add your Google OAuth credentials:"
        echo "   - GOOGLE_CLIENT_ID"
        echo "   - GOOGLE_CLIENT_SECRET"
        echo ""
        read -p "Press Enter to continue after updating .env file..."
    else
        echo "❌ .env.docker template not found"
        exit 1
    fi
else
    echo "✅ .env file exists"
fi

echo ""
echo "📦 Building and starting services..."
echo ""

# Start services
docker compose up -d --build

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check service status
echo ""
echo "📊 Service Status:"
docker compose ps

echo ""
echo "✅ Setup Complete!"
echo ""
echo "🌐 Access the application:"
echo "   Frontend: http://localhost"
echo "   Backend:  http://localhost:3000"
echo "   Health:   http://localhost:3000/health"
echo ""
echo "📝 View logs with:"
echo "   docker compose logs -f"
echo ""
echo "🛑 Stop services with:"
echo "   docker compose down"
echo ""
