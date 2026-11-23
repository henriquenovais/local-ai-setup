# Machine & Hardware Specifications

**System Model:** Lenovo LOQ 15IRH8 (83EU)  
**Date Documented:** November 23, 2026  
**Operating System:** Pop!_OS 24.04 LTS (x86_64)  
**Intended Workload:** Local AI Model Serving, Quantized LLM Inference, and Development

---
## Power & Charging Specifications

---
### USB-C Charging (Power Delivery)

- **Port:** 1× USB-C 3.2 Gen 2 located on the left side (supports Data Transfer, DisplayPort 1.4, and Power Delivery).
- **Maximum Power (Lenovo GaN):** Up to 140W (20V / 7A) using Lenovo's proprietary USB-C protocol and adapter.
- **Maximum Power (Standard USB-PD):** Up to 100W (20V / 5A) using standard USB-PD 3.0 chargers and 100W (5A) e-marked cables.
- **Minimum Required Power:** 65W (20V / 3.25A). Standard phone chargers (15W–45W) or chargers lacking a 20V profile will not power or charge the laptop while running.
- **Operational Advisory:** USB-C charging is suitable for general productivity, coding, travel, and battery replenishment. Under heavy GPU/CPU workloads (such as LLM inference or gaming), system power demand can exceed 100W, leading to battery percentage drop even while plugged into USB-C.

---
### Main AC Power Adapter (Rear DC-In)

- **Connector Type:** Lenovo Slim Tip (proprietary rectangular yellow-tipped 3-pin connector) connected to the rear DC-in port.
- **Operating Voltage:** 20V DC.
- **Required Adapter Wattage:** 135W (20V / 6.75A) or 170W (20V / 8.5A) Slim Tip AC adapter.
- **Compatibility:** Fully compatible with higher-wattage Lenovo Slim Tip chargers (such as 230W, 20V / 11.5A).
- **Operational Advisory:** The dedicated Slim Tip adapter is required to sustain full thermal and clock performance across the CPU and discrete GPU during local AI training, batch inference, or gaming without battery discharge.

---
## Compute & Memory Architecture

---
### CPU & System RAM

- **Processor:** 12th Gen Intel® Core™ i5-12450H (Alder Lake).
- **Core Configuration:** 8 Physical Cores (4 Performance Cores + 4 Efficient Cores), 12 Execution Threads.
- **Architecture:** `x86_64`.
- **System RAM:** 16 GB DDR5 (approx. 15 GiB usable).
- **Swap Space:** Total ~19.3 GiB:
  - 15.3 GiB dynamic `zram` compressed in-RAM swap.
  - 4.0 GiB encrypted disk swap partition (`cryptswap`).

---
### GPU Acceleration

- **Dedicated GPU (dGPU):** NVIDIA GeForce RTX 3050 6GB Laptop GPU.
  - **VRAM:** 6144 MiB (6 GB) GDDR6.
  - **Installed Driver Version:** 580.178.04.
  - **Role:** GPU offload layers for local LLM inference (e.g. `llama.cpp` CUDA backend, Ollama).
- **Integrated GPU (iGPU):** Intel Corporation Alder Lake-P GT1 [UHD Graphics].

---
## Storage & Connectivity

---
### Storage & Drives

- **Primary Drive (`nvme0n1` — ~512 GB / 465.8 GiB NVMe):**
  - `/` (Root Partition): ext4 filesystem, 449 GB allocated (~177 GB used, ~249 GB available).
  - `/boot/efi`: 1020 MB vfat partition.
  - `/recovery`: 4.0 GB vfat recovery image.
  - Swap: 4.0 GB encrypted swap partition.
- **Secondary Drive (`nvme1n1` — ~512 GB / 476.9 GiB NVMe):**
  - Secondary partition: ~476 GB NTFS (`nvme1n1p3`).

---
### Networking & Ports

- **Wireless:** Realtek Semiconductor RTL8852BE PCIe 802.11ax Wireless Network Controller (Wi-Fi 6).
- **Wired Ethernet:** Realtek Semiconductor RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller.
- **Audio:** Intel Alder Lake PCH-P HD Audio and NVIDIA High Definition Audio.
- **Available Ports:**
  - 1× USB-C 3.2 Gen 2 (Data 10Gbps, DisplayPort 1.4, Power Delivery up to 140W).
  - 3× USB-A (1× USB 3.2 Gen 1 on right side, 2× USB 3.2 Gen 2 on rear).
  - 1× HDMI 2.1 (supports up to 8K @ 60Hz).
  - 1× RJ-45 Gigabit Ethernet port.
  - 1× 3.5mm Headphone/Microphone combo audio jack.
  - 1× Lenovo Slim Tip DC-in power port.

---
## Operating System & Toolchains

---
### System Software

- **Operating System:** Pop!_OS 24.04 LTS (`noble`).
- **Linux Kernel:** 7.2.15-76070215-generic (`x86_64`).
- **Desktop Environment:** COSMIC Desktop.
- **Display Server:** Wayland.
- **Default Shell:** `/bin/bash` (with `zsh 5.9` also installed).

---
### Installed Developer Runtimes

- **Node.js:** v26.13.1 (npm 11.20.0).
- **Python:** 3.14.6 (pip 26.1.2).
- **Go:** go1.22.2 (`linux/amd64`).
- **Git:** 2.43.0.
