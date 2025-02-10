#!/bin/bash

# Step 1: Create a Docker bridge network (if it doesn't exist already)
DOCKER_BRIDGE_NAME="echo_lab_bridge"
docker network ls | grep -q "$DOCKER_BRIDGE_NAME"
if [ $? -ne 0 ]; then
    echo "Creating Docker bridge network: $DOCKER_BRIDGE_NAME"
    docker network create --driver bridge "$DOCKER_BRIDGE_NAME"
else
    echo "Docker bridge network '$DOCKER_BRIDGE_NAME' already exists"
fi

# Step 2: Pull the Kali Linux Docker image if not already pulled
echo "Pulling Kali Linux Docker image..."
docker pull kalilinux/kali-rolling

# Step 3: Run a Kali Linux container with SSH enabled and attached to the Docker bridge network
echo "Starting Kali Linux container with SSH..."
docker run -d \
    --name kali-ssh \
    --network "$DOCKER_BRIDGE_NAME" \
    -p 2222:22 \
    kalilinux/kali-rolling \
    /usr/sbin/sshd -D

# Step 4: Display the status and IP of the container
echo "Kali Linux container is running. You can SSH to it using the following command:"
echo "ssh root@localhost -p 2222"

# Show the container IP address within the bridge network (optional)
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kali-ssh
