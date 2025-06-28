# Shared Volume Setup for Video Pipeline and AI Inference

## Overview

This document describes the shared volume configuration that allows the AI Inference service to access decoded frames from the Video Pipeline service.

## Architecture

```
┌─────────────────┐    ┌──────────────────┐
│  Video Pipeline │    │   AI Inference   │
│                 │    │                  │
│ /app/frames     │◄──►│ /app/frames      │
│ (shared volume) │    │ (shared volume)  │
└─────────────────┘    └──────────────────┘
```

## Docker Compose Configuration

The `docker-compose.dev.yml` file has been updated to include:

### Shared Volumes
- `shared-frames-data`: Stores decoded video frames
- `shared-temp-data`: Stores temporary data

### Service Configuration

#### Video Pipeline Service
```yaml
video_pipeline:
  volumes:
    - shared-temp-data:/app/shared
    - shared-frames-data:/app/frames  # Decoded frames storage
```

#### AI Inference Service
```yaml
ai_inference:
  volumes:
    - shared-temp-data:/app/shared
    - shared-frames-data:/app/frames  # Access to decoded frames
```

## Environment Variables

### Video Pipeline (.env)
```
TEMP_SHARED_PATH=/app/shared
```

### AI Inference (.env)
```
SHARED_TEMP_PATH=/app/shared
SHARED_FRAMES_PATH=/app/frames
```

## API Endpoints

### AI Inference Service - Shared Frame Access

#### List Available Cameras
```http
GET /shared/cameras
```
Returns list of camera IDs that have decoded frames available.

#### Get Camera Frame Information
```http
GET /shared/cameras/{camera_id}/frames
```
Returns information about decoded frames for a specific camera.

#### Get Latest Frame
```http
GET /shared/cameras/{camera_id}/frames/latest
```
Returns the latest decoded frame for a camera as an image file.

#### Run Inference on Latest Frame
```http
POST /shared/cameras/{camera_id}/inference?object_name=person
```
Runs object detection on the latest frame from a camera.

#### Get Frame by Index
```http
GET /shared/cameras/{camera_id}/frames/{frame_index}
```
Returns a specific frame by index for a camera.

#### Health Check
```http
GET /health
```
Returns health status including shared volume information.

## Usage Example

1. **Start the services:**
   ```bash
   docker-compose -f docker-compose.dev.yml up
   ```

2. **Upload and decode a video:**
   ```bash
   curl -X POST "http://localhost:8002/api/v1/video-pipeline/decode/" \
     -F "camera_id=camera_001" \
     -F "file=@video.mp4" \
     -F "fps=5"
   ```

3. **Check available cameras:**
   ```bash
   curl "http://localhost:8001/shared/cameras"
   ```

4. **Run inference on latest frame:**
   ```bash
   curl -X POST "http://localhost:8001/shared/cameras/camera_001/inference?object_name=person"
   ```

## File Structure

The shared frames volume follows this structure:
```
/app/frames/
├── camera_001/
│   ├── frame_0001.jpg
│   ├── frame_0002.jpg
│   └── ...
├── camera_002/
│   ├── frame_0001.jpg
│   └── ...
└── ...
```

## Benefits

1. **Real-time Processing**: AI Inference can access frames as soon as they're decoded
2. **Efficient Storage**: Single storage location for decoded frames
3. **Scalability**: Multiple services can access the same data
4. **Separation of Concerns**: Video Pipeline handles decoding, AI Inference handles analysis

## Troubleshooting

### Check Shared Volume Status
```bash
curl "http://localhost:8001/health"
```

### Verify Frame Directory
```bash
docker exec -it <ai-inference-container> ls -la /app/frames
```

### Check Video Pipeline Output
```bash
docker exec -it <video-pipeline-container> ls -la /app/frames
```

## Development Notes

- The video-pipeline service automatically creates camera-specific directories in `/app/frames`
- Frame files are named `frame_XXXX.jpg` where XXXX is a sequential number
- The ai-inference service can access frames immediately after they're written
- Both services use the same volume mount points for consistency 