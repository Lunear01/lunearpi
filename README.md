# Raspberry Pi Proxy & Ad-Blocking Stack

A high-performance, containerized networking stack designed for secure, ad-filtered browsing. This project leverages **Xray (VLESS)** for proxied traffic, **Pi-hole** for network-wide DNS sinkholing, and **Cloudflare Tunnels** to expose the service without opening local firewall ports.

## 🏗 Architecture
This stack is built with modular engineering principles, separating secrets from logic and utilizing a dedicated Docker network for internal DNS routing:

* [cite_start]**Xray (VLESS over WS):** Handles encrypted inbound proxy traffic[cite: 1, 2].
* [cite_start]**Pi-hole:** Acts as the primary DNS server for Xray, stripping ads and trackers at the DNS level[cite: 1].
* [cite_start]**Cloudflare Tunnel:** Creates a secure outbound-only connection to the Cloudflare edge, bypassing the need for Port Forwarding[cite: 1].
* [cite_start]**Docker Networking:** Uses a static subnet (`172.18.0.0/16`) to ensure predictable communication between the Xray and Pi-hole containers[cite: 1].

## 🚀 Getting Started

### Prerequisites
* A Raspberry Pi (running Linux).
* **Docker** and **Docker Compose** installed.
* A domain managed by **Cloudflare**.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone git@github.com:Lunear01/lunearpi.git
    cd lunearpi
    ```

2.  **Configure Environment Variables:**
    Create a `.env` file in the root directory (this file is ignored by Git):
    ```bash
    PIHOLE_PWD=your_strong_password
    TUNNEL_TOKEN=your_cloudflare_tunnel_token
    ```

3.  **Prepare Xray Configuration:**
    Copy the example configuration and add your unique identifiers:
    ```bash
    cp xray/config.json.example xray/config.json
    ```
    * **Generate a UUID:** `cat /proc/sys/kernel/random/uuid`[cite: 2].
    * Edit `xray/config.json` and replace `YOUR_UUID` and `YOUR_PATH` with your specific values[cite: 2, 3].

4.  **Deploy the Stack:**
    ```bash
    docker-compose up -d
    ```

## 🛠 Configuration Details

### DNS Integration
[cite_start]The Xray configuration is set to use the Pi-hole container at `172.18.0.3` as its primary DNS resolver[cite: 1, 2]. [cite_start]This ensures that all traffic tunneled through the proxy is automatically filtered for ads and telemetry before reaching the destination[cite: 1, 2].

### Performance Optimizations
For reduced latency and faster handshakes, ensure the following are enabled in your Cloudflare dashboard:
* **HTTP/3 (QUIC)**
* **0-RTT Connection Resumption**
* **TLS 1.3** (Minimum version)

## 🔒 Security
* [cite_start]**Zero Open Ports:** The Cloudflare tunnel handles all ingress traffic; no port forwarding is required on your router[cite: 1].
* [cite_start]**Inbound Protection:** Sniffing is enabled in Xray to correctly identify and route HTTP and TLS traffic[cite: 3].
* **Secret Management:** All sensitive tokens, UUIDs, and passwords are kept in local configuration files or `.env` files and are excluded from source control via `.gitignore`.

---

**Developed by Iker Huang**
*Software Developer & Computer Science Specialist*