# Networking Configuration

## Overview

This document explains the networking setup for the retail dashboard application and how to resolve common networking issues, particularly with RTSP streams.

## Architecture

The application uses Docker Compose with the following services:

- **Frontend** (Next.js): Port 3000
- **Backend** (FastAPI): Port 8000
- **Video Pipeline**: Port 8002
- **AI Inference**: Port 8001
- **Database** (PostgreSQL): Port 5432
- **Nginx Reverse Proxy**: Port 80/443

## Network Configuration

### Docker Network
All services run on a custom bridge network called `retail-net` for secure inter-service communication.

### Reverse Proxy (Nginx)
Nginx acts as a reverse proxy providing:
- Unified entry point at `http://localhost`
- Load balancing and routing
- Increased timeouts for video processing
- SSL termination (when configured)

### RTSP Access Configuration

The video pipeline and AI inference services have `extra_hosts` configuration to access RTSP streams on the host machine:

```yaml
extra_hosts:
  - "localhost:host-gateway"
```

This allows containers to access `localhost:8554` by mapping it to the host machine's gateway.

## Common Issues and Solutions

### 1. RTSP Stream Access Issues

**Problem**: Video pipeline service cannot access RTSP streams at `rtsp://localhost:8554/stream1`

**Solution**: The `extra_hosts` configuration maps `localhost` to the host gateway, allowing containers to access host services.

**Alternative Solutions**:
- Use `host-gateway:8554` instead of `localhost:8554` in RTSP URLs
- Use the host machine's actual IP address
- Use `host.docker.internal` (Docker Desktop) or `host-gateway` (Linux)

### 2. Service Communication Issues

**Problem**: Services cannot communicate with each other

**Solution**: All services are on the same `retail-net` network and can reach each other by service name.

### 3. Frontend-Backend Communication

**Problem**: Frontend cannot reach backend API

**Solution**: Nginx reverse proxy routes `/api/*` requests to the backend service.

## Testing Network Connectivity

### Test RTSP Access
```bash
# Test from within video pipeline container
docker exec video_pipeline curl -I http://localhost:8554/stream1

# Test host gateway access
docker exec video_pipeline ping -c 1 host-gateway
```

### Test Service Communication
```bash
# Test backend to video pipeline
docker exec backend curl -f http://video_pipeline:8002/api/v1/video-pipeline/health/

# Test nginx to backend
docker exec nginx curl -f http://backend:8000/api/v1/cameras/
```

## Environment Variables

### Frontend
- `NEXT_PUBLIC_API_URL`: Public API URL (http://localhost/api)
- `INTERNAL_API_URL`: Internal API URL (http://nginx/api)

### Backend
- `VIDEO_PIPELINE_URL`: Video pipeline service URL (http://video_pipeline:8002)

## Production Considerations

### 1. SSL/TLS
Add SSL certificates and configure HTTPS in nginx:
```nginx
server {
    listen 443 ssl;
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    # ... rest of configuration
}
```

### 2. Security
- Remove direct port exposure where possible
- Use internal networks for sensitive services
- Implement proper authentication and authorization

### 3. Load Balancing
For production, consider using external load balancers or Kubernetes.

## Troubleshooting

### Check Service Status
```bash
docker-compose ps
docker-compose logs video_pipeline
docker-compose logs backend
```

### Test Network Connectivity
```bash
# Test from host
curl http://localhost/api/v1/cameras/

# Test from within container
docker exec backend curl http://video_pipeline:8002/api/v1/video-pipeline/health/
```

### Debug RTSP Issues
```bash
# Check if RTSP server is running on host
netstat -an | grep 8554

# Test RTSP access from host
ffprobe rtsp://localhost:8554/stream1
```

## Alternative RTSP URL Formats

If `localhost:8554` doesn't work, try these alternatives:

1. **Host Gateway**: `rtsp://host-gateway:8554/stream1`
2. **Host IP**: `rtsp://192.168.1.100:8554/stream1` (replace with actual IP)
3. **Docker Desktop**: `rtsp://host.docker.internal:8554/stream1`
4. **Bridge Network**: If RTSP server is also containerized, use service name

## Monitoring

Monitor network connectivity and service health:
- Nginx access logs: `/var/log/nginx/access.log`
- Service logs: `docker-compose logs [service-name]`
- Health checks: `curl http://localhost/health` 