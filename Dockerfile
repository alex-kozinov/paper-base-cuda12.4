FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TORCH_CUDA_ARCH_LIST="8.6+PTX" \
    HF_HUB_ENABLE_HF_TRANSFER=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONUNBUFFERED=1
# --------------------------------------------------------
# 1. Base system packages
# --------------------------------------------------------
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    git tmux wget curl ca-certificates openssh-server nginx \
    libgl1-mesa-glx libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Make python/pip the default commands
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# --------------------------------------------------------
# 2. Prepare host (SSH, NGINX)
# --------------------------------------------------------
RUN rm -f /etc/ssh/ssh_host_*

# NGINX Proxy
COPY proxy/nginx.conf /etc/nginx/nginx.conf
COPY proxy/readme.html /usr/share/nginx/html/readme.html

# --------------------------------------------------------
# 3. Install PyTorch with CUDA 12.1 support
# --------------------------------------------------------
RUN pip install --upgrade pip setuptools wheel
RUN pip install "torch>=2.3" torchvision --index-url https://download.pytorch.org/whl/cu121

# --------------------------------------------------------
# 4. Install JupyterLab
# --------------------------------------------------------
RUN pip install jupyterlab

# --------------------------------------------------------
# 5. Clone some project repository
# --------------------------------------------------------
WORKDIR /workspace

# --------------------------------------------------------
# 6. Install project dependencies
# --------------------------------------------------------


# --------------------------------------------------------
# 7. Default working directory and entrypoint
# --------------------------------------------------------
# Start Script
COPY scripts/start.sh /start.sh
RUN chmod 755 /start.sh
WORKDIR /workspace
CMD ["/start.sh"]
