#!/bin/bash

# Set the desired image name
IMAGE_NAME="ros:viw-fusion-melodic"

# Build the Docker image
docker build --tag $IMAGE_NAME -f ./Dockerfile ..

# Check if the image was built successfully
if [ $? -eq 0 ]; then
    echo "Docker image '$IMAGE_NAME' built successfully."
else
    echo "Failed to build Docker image."
fi

