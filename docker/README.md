# R3LIVE on ARM64 Architecture

This version of **R3LIVE** has been modified to run on ARM64 architecture.

---

## Prerequisites

Before running R3LIVE, ensure the following:

- Docker is installed on your system.
- ROS is properly set up on the host (e.g., `roscore` can run).
- You have a `.bag` file for testing (e.g., `hku_campus_seq_00.bag`).
- X11 forwarding is enabled for GUI applications like RViz.
- Your user has permission to access the X11 server (run `xhost +local:docker` if needed).

---

## Step 1: Build the Docker Image

Use the provided Dockerfile to build the Docker image:

```bash
docker build -t r3live:latest -f Dockerfile .
```

---

## Step 2: Start `roscore` on the Host

In a terminal on the host (Orin), start `roscore`:

```bash
roscore
```

Keep this terminal open.

---

## Step 3: Run the R3LIVE Docker Container

Open a new terminal and run the following command to start the Docker container:

```bash
sudo docker run -it --rm \
  --env="DISPLAY=$DISPLAY" \
  --env="XAUTHORITY=/root/.Xauthority" \
  --env="QT_X11_NO_MITSHM=1" \
  --env="ROS_MASTER_URI=http://localhost:11311" \
  --env="ROS_IP=localhost" \
  --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
  --volume="$HOME/.Xauthority:/root/.Xauthority:ro" \
  -v /home/scanR_SLAM/src/r3live_docker/r3live_output:/root/r3live_output:rw \
  --network host \
  ehsz/r3live_bash:latest
  bash
```

This will start the container with R3LIVE initialized.

---

## Step 4: Replay the ROS Bag

In another terminal (still on the host), play your `.bag` file for testing:

```bash
rosbag play hku_campus_seq_00.bag
```

This will feed data into R3LIVE running inside the container.

---

## Output

The generated 3D map will be saved in:

```
/home/scanR_SLAM/src/r3live_docker/r3live_output
```

This folder is shared between the host and the container.

---




