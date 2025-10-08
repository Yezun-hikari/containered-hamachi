# Fully Automated Hamachi Docker Container for ARM (Raspberry Pi)

This repository contains everything needed to build and run a LogMeIn Hamachi client in a Docker container on an ARM-based system like a Raspberry Pi. The process is designed to be as automated as possible.

## Features

- **Fully Automated Build:** The `Dockerfile` handles downloading the correct Hamachi version, extracting, and installing it. No manual file transfers are needed.
- **Portainer Stack Ready:** A `docker-compose.yml` file is provided for easy deployment as a stack in Portainer.
- **Persistent Configuration:** A Docker volume is used to store your Hamachi identity and network configurations, so they survive container restarts and updates.
- **Designed for ARM:** Uses `debian:bullseye-slim` as the base image, which is lightweight and compatible with Raspberry Pi and similar ARM devices.

## How to Use

There are two main steps:

1. **Build the Docker Image (One-Time Step)**
2. **Deploy the Stack in Portainer**

### Step 1: Build the Docker Image

Because Portainer cannot build an image from a `Dockerfile` during a stack deployment, you must build the image once on your Docker host (your Raspberry Pi).

1. **Connect to your Pi:**

   ```bash
   ssh pi@your_pi_ip_address
   ```

2. **Clone this repository:**

   ```bash
   git clone <url_of_this_repository>
   cd <repository_name>
   ```

3. **Build the Docker image:**

   This command uses the `Dockerfile` in the repository to create a local Docker image named `hamachi-arm:custom`. The Dockerfile is based on `debian:bullseye-slim` and will automatically download and install the ARM-compatible Hamachi binary.

   ```bash
   docker build -t hamachi-arm:custom .
   ```

The build process will:
- Start from the `debian:bullseye-slim` base image
- Install necessary dependencies
- Download the Hamachi ARM binary
- Set up all required components automatically

That's it! The image is now stored locally on your Pi, ready for Portainer. You don't need the cloned repository files anymore, but it's good to keep them for future rebuilds.

### Step 2: Deploy the Stack in Portainer

1. Log in to your Portainer instance.
2. Go to **Stacks** > **Add stack**.
3. Give the stack a name (e.g., `hamachi`).
4. In the **Web editor**, paste the contents of the `docker-compose.yml` file from this repository:

   ```yaml
   version: '3.8'

   services:
     hamachi:
       image: hamachi-arm:custom
       container_name: hamachi
       cap_add:
         - NET_ADMIN
       devices:
         - /dev/net/tun:/dev/net/tun
       volumes:
         - hamachi-data:/var/lib/logmein-hamachi
       restart: unless-stopped

   volumes:
     hamachi-data:
   ```

5. Click **Deploy the stack**.

### Step 3: Configure Hamachi

Once the container is running, you need to configure your Hamachi client:

1. **Access the container:**

   ```bash
   docker exec -it hamachi bash
   ```

2. **Log in to Hamachi:**

   ```bash
   hamachi login
   ```

3. **Join a network:**

   ```bash
   hamachi join <network_name> <password>
   ```

4. **Check status:**

   ```bash
   hamachi
   ```

Your configuration is persisted in the `hamachi-data` volume, so it will survive container restarts.

## Troubleshooting

- **TUN/TAP device errors:** Ensure your Docker host supports TUN/TAP devices and that the device is available at `/dev/net/tun`.
- **Permission issues:** The container needs `NET_ADMIN` capability, which is specified in the docker-compose file.
- **Build failures:** Ensure you have a stable internet connection during the build process, as the Dockerfile downloads the Hamachi binary from the internet.

## Technical Details

- **Base Image:** `debian:bullseye-slim` - A minimal Debian 11 image that provides good compatibility with ARM architectures while keeping the container size small.
- **Architecture:** Designed for ARM devices (armv7/armv8), tested on Raspberry Pi.
- **Hamachi Version:** The Dockerfile downloads version 2.1.0.203 for ARM architecture.

## Repository Structure

```
.
├── Dockerfile          # Automated build configuration
├── docker-compose.yml  # Stack deployment template
├── start.sh           # Container startup script
└── README.md          # This file
```

## License

This project is provided as-is for educational and personal use. LogMeIn Hamachi is a product of LogMeIn, Inc.
