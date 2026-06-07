FROM nvidia/cuda:12.9.0-base-ubuntu22.04

ARG HF_TOKEN
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_ROOT_USER_ACTION=ignore

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    python3.11 \
    python3-pip \
    python3.11-venv \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

WORKDIR /workspace

RUN git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI && \
    cd /workspace/ComfyUI && \
    pip3 install --no-cache-dir -r requirements.txt

RUN mkdir -p /workspace/ComfyUI/models/unet \
    /workspace/ComfyUI/models/clip \
    /workspace/ComfyUI/models/vae

# Download FLUX.2 [dev] weights
RUN wget --header="Authorization: Bearer ${HF_TOKEN}" \
    -O /workspace/ComfyUI/models/unet/flux2-dev.safetensors \
    "https://huggingface.co/black-forest-labs/FLUX.2-dev/resolve/main/flux2-dev.safetensors" && \
    wget --header="Authorization: Bearer ${HF_TOKEN}" \
    -O /workspace/ComfyUI/models/vae/ae.safetensors \
    "https://huggingface.co/black-forest-labs/FLUX.2-dev/resolve/main/ae.safetensors"

# Download CLIP text encoders (public, no token needed)
RUN wget -O /workspace/ComfyUI/models/clip/clip_l.safetensors \
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors" && \
    wget -O /workspace/ComfyUI/models/clip/t5xxl_fp16.safetensors \
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors"

WORKDIR /workspace/ComfyUI

EXPOSE 18188

CMD ["python3", "main.py", "--listen", "0.0.0.0", "--port", "18188", "--enable-cors-header"]