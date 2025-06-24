#!/bin/bash

echo "=== API Access Test ==="

# Test nginx health
echo "1. Testing nginx health..."
if curl -s http://localhost/health > /dev/null; then
    echo "✅ Nginx is running and accessible"
else
    echo "❌ Nginx is not accessible"
    exit 1
fi

# Test backend API through nginx
echo ""
echo "2. Testing backend API through nginx..."
echo "Testing GET /api/v1/cameras/"

response=$(curl -s -w "%{http_code}" http://localhost/api/v1/cameras/)
http_code="${response: -3}"
body="${response%???}"

if [ "$http_code" = "200" ]; then
    echo "✅ API call successful (HTTP $http_code)"
    echo "Response: $body"
else
    echo "❌ API call failed (HTTP $http_code)"
    echo "Response: $body"
fi

# Test CORS preflight
echo ""
echo "3. Testing CORS preflight..."
echo "Testing OPTIONS /api/v1/cameras/"

cors_response=$(curl -s -w "%{http_code}" -X OPTIONS \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  http://localhost/api/v1/cameras/)

cors_http_code="${cors_response: -3}"
cors_body="${cors_response%???}"

if [ "$cors_http_code" = "204" ]; then
    echo "✅ CORS preflight successful (HTTP $cors_http_code)"
else
    echo "❌ CORS preflight failed (HTTP $cors_http_code)"
    echo "Response: $cors_body"
fi

# Test frontend accessibility
echo ""
echo "4. Testing frontend accessibility..."
if curl -s http://localhost:3000 > /dev/null; then
    echo "✅ Frontend is accessible at http://localhost:3000"
else
    echo "❌ Frontend is not accessible at http://localhost:3000"
fi

# Test direct backend (should still work)
echo ""
echo "5. Testing direct backend access..."
if curl -s http://localhost:8000/api/v1/cameras/ > /dev/null; then
    echo "✅ Direct backend access works (http://localhost:8000)"
else
    echo "❌ Direct backend access failed"
fi

echo ""
echo "=== Test Complete ==="
echo ""
echo "Expected URLs:"
echo "  - Frontend: http://localhost:3000"
echo "  - API via nginx: http://localhost/api/v1/*"
echo "  - Direct backend: http://localhost:8000/api/v1/*"
echo "  - MediaMTX: http://localhost:8888"
echo "  - RTSP stream: rtsp://localhost:8554/stream1" 