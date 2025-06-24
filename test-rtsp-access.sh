#!/bin/bash

echo "Testing RTSP access from video pipeline container..."

# Test if we can access localhost:8554 from within the container
docker exec video_pipeline curl -I http://localhost:8554/stream1 2>/dev/null || echo "Cannot access localhost:8554 from video pipeline container"

# Test if we can access the host gateway
docker exec video_pipeline ping -c 1 host-gateway 2>/dev/null && echo "Host gateway is accessible" || echo "Host gateway is not accessible"

# Test if we can access the RTSP stream via host-gateway
docker exec video_pipeline curl -I http://host-gateway:8554/stream1 2>/dev/null || echo "Cannot access host-gateway:8554 from video pipeline container"

echo "Testing complete." 