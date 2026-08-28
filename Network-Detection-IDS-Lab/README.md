# Network Detection and Response (NDR) Home Lab

## Objective
The goal of this project was to engineer an isolated virtual network to simulate, detect, and analyze cyber threats. By deploying an Intrusion Detection System (IDS) and executing targeted attacks, I gained hands-on experience with detection engineering, protocol analysis, and incident reporting.

## Infrastructure & Tools
*   **Hypervisor:** VMware Workstation Pro (Host-only NAT configuration)
*   **Target/Sensor:** Ubuntu Server 24.04
*   **Attacker:** Debian 12
*   **Security Tools:** Suricata (IDS), Nmap (Reconnaissance), tcpdump (Packet Capture)

## Methodology & Execution
1.  **Network Architecture:** Configured a secure, isolated subnet (`192.168.56.0/24`) and managed headless Linux servers via SSH.
2.  **Detection Engineering:** Deployed Suricata on the Ubuntu Sensor and authored custom threat signatures to detect specific malicious behaviors, including ICMP floods and targeted SSH port scans.
3.  **Attack Simulation:** Acted as a Red Team operator utilizing Debian to execute network mapping (`nmap`) to trigger the custom IDS rules.
4.  **Forensic Packet Analysis:** Captured live wire data utilizing `tcpdump`. Analyzed the `.pcap` files to identify cleartext HTTP `GET` requests, DNS routing queries, and the TCP 3-way handshake.

## Project Artifacts
*   **[suricata.rules](./suricata.rules):** The custom threat signatures written for the IDS.
*   **[fast.log](./fast.log):** Suricata alert outputs proving the successful detection of the Nmap scan.
*   **[project_capture.pcap](./project_capture.pcap):** The raw network traffic capture.

## Visual Evidence

### 1. Network Architecture (SSH Access)
![Architecture](./1_Architecture.png)

### 2. Reconnaissance (Nmap Port Scan)
![Nmap Scan](./2_Nmap_Scan.png)

### 3. Threat Detection (Suricata IDS Alerts)
![Suricata Alerts](./3_Suricata_Alerts.png)

### 4. Protocol Analysis (TCP 3-Way Handshake)
![Packet Analysis](./4_Packet_Analysis.png)
