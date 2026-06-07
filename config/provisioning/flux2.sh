#!/bin/bash
set -e

COMFYUI_DIR="${COMFYUI_DIR:-/workspace/ComfyUI}"
HF_TOKEN="${HF_TOKEN:-}"

echo "=========================================="
echo "FLUX.2 Provisioning Script"
echo "=========================================="
echo "ComfyUI Dir: $COMFYUI_DIR"
echo "HF Token: ${HF_TOKEN:+set (hidden)}"
echo ""

mkdir -p "$COMFYUI_DIR/models/unet"
mkdir -p "$COMFYUI_DIR/models/clip"
mkdir -p "$COMFYUI_DIR/models/vae"

AUTH_HEADER=""
if [ -n "$HF_TOKEN" ]; then
    AUTH_HEADER="Authorization: Bearer $HF_TOKEN"
fi

# FLUX.2 [dev] UNet model (~24GB)
if [ ! -f "$COMFYUI_DIR/models/unet/flux2-dev.safetensors" ]; then
    echo "Downloading FLUX.2 [dev] UNet model (~24GB)..."
    if [ -n "$AUTH_HEADER" ]; then
        wget --header="$AUTH_HEADER" -q --show-progress \
            -O "$COMFYUI_DIR/models/unet/flux2-dev.safetensors" \
            "https://huggingface.co/black-forest-labs/FLUX.2-dev/resolve/main/flux2-dev.safetensors"
    else
        echo "WARNING: HF_TOKEN not set. FLUX.2 [dev] requires authentication."
        exit 1
    fi
    echo "✓ UNet model downloaded"
else
    echo "✓ UNet model already exists, skipping"
fi

# VAE model (~0.3GB)
if [ ! -f "$COMFYUI_DIR/models/vae/ae.safetensors" ]; then
    echo "Downloading VAE model..."
    if [ -n "$AUTH_HEADER" ]; then
        wget --header="$AUTH_HEADER" -q --show-progress \
            -O "$COMFYUI_DIR/models/vae/ae.safetensors" \
            "https://huggingface.co/black-forest-labs/FLUX.2-dev/resolve/main/ae.safetensors"
    else
        wget -q --show-progress \
            -O "$COMFYUI_DIR/models/vae/ae.safetensors" \
            "https://huggingface.co/black-forest-labs/FLUX.2-dev/resolve/main/ae.safetensors"
    fi
    echo "✓ VAE model downloaded"
else
    echo "✓ VAE model already exists, skipping"
fi

# CLIP-L encoder (~0.25GB, public)
if [ ! -f "$COMFYUI_DIR/models/clip/clip_l.safetensors" ]; then
    echo "Downloading CLIP-L encoder..."
    wget -q --show-progress \
        -O "$COMFYUI_DIR/models/clip/clip_l.safetensors" \
        "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors"
    echo "✓ CLIP-L downloaded"
else
    echo "✓ CLIP-L already exists, skipping"
fi

# T5-XXL encoder (~9.7GB, public)
if [ ! -f "$COMFYUI_DIR/models/clip/t5xxl_fp16.safetensors" ]; then
    echo "Downloading T5-XXL encoder (~9.7GB)..."
    wget -q --show-progress \
        -O "$COMFYUI_DIR/models/clip/t5xxl_fp16.safetensors" \
        "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors"
    echo "✓ T5-XXL downloaded"
else
    echo "✓ T5-XXL already exists, skipping"
fi

echo ""
echo "=========================================="
echo "FLUX.2 Provisioning Complete!"
echo "=========================================="
echo "Models installed in:"
echo "  - $COMFYUI_DIR/models/unet/flux2-dev.safetensors"
echo "  - $COMFYUI_DIR/models/vae/ae.safetensors"
echo "  - $COMFYUI_DIR/models/clip/clip_l.safetensors"
echo "  - $COMFYUI_DIR/models/clip/t5xxl_fp16.safetensors"
