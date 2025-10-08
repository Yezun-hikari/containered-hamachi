# Fully Automated Hamachi Docker Container for ARM (Raspberry Pi)

This repository contains everything needed to build and run a LogMeIn Hamachi client in a Docker container on an ARM-based system like a Raspberry Pi. The process is designed to be as automated as possible.

## Features

- **Fully Automated Build:** The `Dockerfile` handles downloading the correct Hamachi version, extracting, and installing it. No manual file transfers are needed.
- **Portainer Stack Ready:** A `docker-compose.yml` file is provided for easy deployment as a stack in Portainer.
- **Persistent Configuration:** A Docker volume is used to store your Hamachi identity and network configurations, so they survive container restarts and updates.
- **Designed for ARM:** Uses a `balenalib/armv7hf-debian` base image, perfect for Raspberry Pi and similar devices.

## How to Use

There are two main steps:

1.  **Build the Docker Image (One-Time Step)**
2.  **Deploy the Stack in Portainer**

### Step 1: Build the Docker Image

Because Portainer cannot build an image from a `Dockerfile` during a stack deployment, you must build the image once on your Docker host (your Raspberry Pi).

1.  **Connect to your Pi:**
    ```bash
    ssh pi@your_pi_ip_address
    ```

2.  **Clone this repository:**
    ```bash
    git clone <URL_of_this_repository>
    cd <repository_name>
    ```

3.  **Build the Docker image:**
    This command uses the `Dockerfile` in the repository to create a local Docker image named `hamachi-arm:custom`. It will automatically download and set up everything.
    ```bash
    docker build -t hamachi-arm:custom .
    ```

That's it! The image is now stored locally on your Pi, ready for Portainer. You don't need the cloned repository files anymore, but it's good to keep them for future rebuilds.

### Step 2: Deploy the Stack in Portainer

1.  Log in to your Portainer instance.
2.  Go to **Stacks** > **Add stack**.
3.  Give the stack a name (e.g., `hamachi`).
4.  In the **Web editor**, paste the contents of the `docker-compose.yml` file from this repository:

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
          - hamachi-config:/var/lib/logmein-hamachi
        restart: unless-stopped

    volumes:
      hamachi-config:
        name: hamachi-config
    ```

5.  Click **Deploy the stack**.

Portainer will now create and start the container using the `hamachi-arm:custom` image you built earlier.

### Step 3: Using Hamachi

After the stack is running, you need to interact with the Hamachi client inside the container.

1.  In Portainer, go to **Containers**.
2.  Find and click on your `hamachi` container.
3.  Click the **>_ Console** button to open a shell.
4.  Run your Hamachi commands:
    ```bash
    # Log in and bring the client online
    hamachi login

    # Join a network
    hamachi join YOUR_NETWORK_ID

    # List your networks and peers
    hamachi list
    ```

Your Hamachi client is now running and will automatically start whenever you restart your Pi.