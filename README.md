# Raspberry Pi Proxy & Ad-Blocking Stack

A high-performance, containerized networking stack designed for secure, ad-filtered browsing. This project leverages **Xray (VLESS)** for proxied traffic, **Pi-hole** for network-wide DNS sinkholing, and **Cloudflare Tunnels** to expose the service without opening local firewall ports. 

## Architecture
This stack is built with modular engineering principles, separating secrets from logic and utilizing highly optimized network routing for zero-latency resolution:

* **Xray (VLESS over WS):** Handles encrypted inbound proxy traffic with SNI sniffing enabled to route internal DNS queries efficiently.
* **Pi-hole:** Acts as the primary DNS server for Xray, stripping ads and trackers at the DNS level. 
* **Cloudflare Tunnel:** Creates a secure outbound-only connection to the Cloudflare edge, bypassing the need for Port Forwarding.
* **Zero-Latency Host Networking:** Pi-hole is deployed in `network_mode: "host"`, bypassing the Docker Bridge NAT entirely. This binds Pi-hole directly to the Pi's physical IP, dropping DNS resolution latency to near 0ms.
* **Resource Management:** All containers implement strict JSON log rotation (max 30MB per service) to prevent SD card wear and storage bloat.

## Getting Started

### Prerequisites
* A Raspberry Pi (running Linux) with a configured Static IP.
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
    * **Generate a UUID:** `cat /proc/sys/kernel/random/uuid`
    * Edit `xray/config.json` and replace `YOUR_UUID` and `YOUR_PATH` with your specific values.

4.  **Deploy the Stack:**
    ```bash
    docker-compose up -d --remove-orphans
    ```

## Configuration Details

### DNS Integration
Due to the Host-Mode architecture, Xray and other bridged containers (like Uptime Kuma) are configured via `docker-compose.yml` to use the Raspberry Pi's physical IP address (e.g., `192.168.31.88`) as their primary DNS resolver. This ensures that all traffic tunneled through the proxy is automatically filtered for ads and telemetry before reaching the destination, without the overhead of Docker's internal network.

### Automated Maintenance
To maximize the lifespan of the Raspberry Pi's SD card, this stack includes a host-level cleanup script (`maintenance.sh`). 
* **Capabilities:** Prunes dangling Docker images, truncates container logs without breaking file handles, cleans the `apt` cache, and vacuums system `journalctl` logs.
* **Automation:** Recommended to be run weekly via a root cron job:
  ```bash
  0 0 * * 0 /path/to/maintenance.sh >> /path/to/cleanup.log 2>&1
