#!/bin/bash

echo "=== MediaMTX RTSP Streaming Test ==="

# Check if MediaMTX container is running
echo "1. Checking MediaMTX container status..."
if docker ps | grep -q mediamtx-rtsp; then
    echo "✅ MediaMTX container is running"
else
    echo "❌ MediaMTX container is not running"
    echo "Starting MediaMTX..."
    cd mediaMTX && docker-compose up -d
    sleep 5
fi

# Test RTSP stream accessibility
echo ""
echo "2. Testing RTSP stream accessibility..."

# Test from host machine
echo "Testing from host machine..."
if command -v ffprobe &> /dev/null; then
    echo "Testing rtsp://localhost:8554/stream1"
    timeout 10s ffprobe -v quiet -print_format json -show_format -show_streams rtsp://localhost:8554/stream1 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ RTSP stream is accessible from host machine"
    else
        echo "❌ RTSP stream is not accessible from host machine"
    fi
else
    echo "⚠️  ffprobe not found, skipping stream test"
fi

# Test from video pipeline container
echo ""
echo "3. Testing from video pipeline container..."
if docker ps | grep -q video_pipeline; then
    echo "Testing rtsp://localhost:8554/stream1 from video pipeline container"
    docker exec video_pipeline timeout 10s ffprobe -v quiet -print_format json -show_format -show_streams rtsp://localhost:8554/stream1 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ RTSP stream is accessible from video pipeline container"
    else
        echo "❌ RTSP stream is not accessible from video pipeline container"
        echo "Testing with host-gateway..."
        docker exec video_pipeline timeout 10s ffprobe -v quiet -print_format json -show_format -show_streams rtsp://host-gateway:8554/stream1 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "✅ RTSP stream is accessible via host-gateway"
        else
            echo "❌ RTSP stream is not accessible via host-gateway"
        fi
    fi
else
    echo "⚠️  Video pipeline container not running"
fi

# Test MediaMTX web interface
echo ""
echo "4. Testing MediaMTX web interface..."
if curl -s http://localhost:8888 > /dev/null; then
    echo "✅ MediaMTX web interface is accessible at http://localhost:8888"
else
    echo "❌ MediaMTX web interface is not accessible"
fi

# Check MediaMTX logs
echo ""
echo "5. Recent MediaMTX logs:"
docker logs --tail 10 mediamtx-rtsp

echo ""
echo "=== Test Complete ==="
echo ""
echo "To access the RTSP stream:"
echo "  - From host: rtsp://localhost:8554/stream1"
echo "  - From containers: rtsp://host-gateway:8554/stream1"
echo "  - Web interface: http://localhost:8888"
echo ""
echo "To test with VLC:"
echo "  vlc rtsp://localhost:8554/stream1" 