# Real Camera Access Guide

## Overview

This guide explains how to configure the video pipeline service to access real cameras on the same network as the host machine.

## Current Configuration

The video pipeline service is configured with:
```yaml
extra_hosts:
  - "localhost:host-gateway"
```

This allows the container to access:
- Localhost services on the host machine
- Services that the host can reach on its network

## Accessing Real Cameras

### Method 1: Use Host's Network Interface (Recommended)

For cameras on the same network as the host, use the host's IP address:

```bash
# Find your host's IP address on the camera network
ip addr show | grep "inet " | grep -v 127.0.0.1

# Example: If host IP is 192.168.1.100, use:
rtsp://192.168.1.100:8554/stream1
```

### Method 2: Use Host Gateway (Current Setup)

The current `extra_hosts` configuration allows access to:
- `rtsp://localhost:8554/stream1` (local RTSP server)
- `rtsp://host-gateway:8554/stream1` (same as localhost)

### Method 3: Direct Camera IP Access

For cameras with direct IP addresses, use the camera's IP directly:

```bash
# Example camera configurations:
rtsp://192.168.1.50:554/stream1
rtsp://192.168.1.51:554/h264
rtsp://192.168.1.52:8554/live
```

## Testing Camera Access

### 1. Test from Host Machine
```bash
# Test if camera is reachable from host
ping 192.168.1.50

# Test RTSP stream from host
ffprobe rtsp://192.168.1.50:554/stream1
```

### 2. Test from Video Pipeline Container
```bash
# Test network connectivity
docker exec video_pipeline ping 192.168.1.50

# Test RTSP access
docker exec video_pipeline ffprobe rtsp://192.168.1.50:554/stream1
```

### 3. Test via API
```bash
# Test video info endpoint
curl -X POST "http://localhost/api/v1/video-pipeline/camera/1/video-info-url/" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "url=rtsp://192.168.1.50:554/stream1"
```

## Common Camera Configurations

### IP Cameras
```bash
# Hikvision
rtsp://username:password@192.168.1.50:554/Streaming/Channels/101

# Dahua
rtsp://username:password@192.168.1.51:554/cam/realmonitor?channel=1&subtype=0

# Generic ONVIF
rtsp://192.168.1.52:554/stream1
```

### USB Cameras (via RTSP Server)
```bash
# If using v4l2loopback + ffmpeg
rtsp://localhost:8554/stream1

# If using GStreamer RTSP server
rtsp://localhost:8554/test
```

## Network Troubleshooting

### 1. Check Network Connectivity
```bash
# From host
ping 192.168.1.50
telnet 192.168.1.50 554

# From container
docker exec video_pipeline ping 192.168.1.50
docker exec video_pipeline telnet 192.168.1.50 554
```

### 2. Check RTSP Port
```bash
# Test RTSP port
nmap -p 554 192.168.1.50

# Test from container
docker exec video_pipeline nmap -p 554 192.168.1.50
```

### 3. Check Firewall
```bash
# Check if port 554 is open
sudo ufw status
sudo iptables -L
```

## Advanced Configuration

### 1. Custom Network Bridge
If you need more control, create a custom network:

```yaml
networks:
  camera_net:
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.1.0/24
          gateway: 192.168.1.1
```

### 2. Host Network Mode (Alternative)
For maximum compatibility, use host networking:

```yaml
video_pipeline:
  network_mode: host
  # Note: This breaks communication with other services
```

### 3. Macvlan Network (Production)
For production with dedicated network access:

```yaml
networks:
  camera_net:
    driver: macvlan
    driver_opts:
      parent: eth0
    ipam:
      config:
        - subnet: 192.168.1.0/24
          gateway: 192.168.1.1
```

## Security Considerations

### 1. Network Isolation
- Use separate VLANs for camera networks
- Implement proper firewall rules
- Use VPN for remote camera access

### 2. Authentication
- Use strong passwords for camera access
- Implement certificate-based authentication
- Use ONVIF security features

### 3. Access Control
- Limit camera access to specific IP ranges
- Use network segmentation
- Monitor camera access logs

## Example Camera Setup

### 1. Add Camera to Database
```bash
curl -X POST "http://localhost/api/v1/cameras/" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Entrance Camera",
    "rtsp_url": "rtsp://192.168.1.50:554/stream1",
    "location": "Main Entrance",
    "is_active": true
  }'
```

### 2. Test Camera Validation
```bash
curl -X POST "http://localhost/api/v1/cameras/1/validate-video/"
```

### 3. Monitor Logs
```bash
docker-compose logs video_pipeline
docker-compose logs backend
```

## Troubleshooting Common Issues

### Issue: "Connection refused"
- Check if camera is powered on
- Verify IP address and port
- Check network connectivity
- Verify RTSP URL format

### Issue: "Authentication failed"
- Check username/password
- Verify camera credentials
- Test with camera's web interface

### Issue: "Stream not found"
- Check RTSP path/stream name
- Verify camera supports the requested stream
- Check camera configuration

### Issue: "Network unreachable"
- Check network configuration
- Verify subnet and gateway
- Check firewall rules
- Test from host machine first

## Best Practices

1. **Test from host first**: Always verify camera access from the host machine
2. **Use static IPs**: Configure cameras with static IP addresses
3. **Document configurations**: Keep a record of camera IPs and RTSP URLs
4. **Monitor performance**: Watch for network latency and bandwidth issues
5. **Plan for scale**: Consider network capacity for multiple cameras
6. **Backup configurations**: Keep backup of camera and network settings 