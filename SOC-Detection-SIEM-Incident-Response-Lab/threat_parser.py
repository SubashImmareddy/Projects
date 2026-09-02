#!/usr/bin/env python3
"""
SOC Automation Tool: Wazuh Alert & IOC Parser
Author: socadmin
Description: Ingests Wazuh alert logs (JSON/text), filters high-severity 
             threats (Level >= 10), extracts attacker IPs, and generates a 
             triage summary report.
"""

import json
import sys
from collections import Counter
from datetime import datetime

# Simulated sample log data matching our lab's alerts
SAMPLE_ALERTS = [
    {
        "timestamp": "2026-09-01T21:19:29.684+0530",
        "rule": {"id": "92213", "level": 15, "description": "Executable file dropped in folder commonly used by malware", "mitre": {"id": ["T1105"]}},
        "agent": {"name": "DESKTOP-E2522QF", "ip": "192.168.56.20"},
        "data": {"win": {"eventdata": {"image": "powershell.exe", "user": "socadmin"}}}
    },
    {
        "timestamp": "2026-09-01T21:34:59.622+0530",
        "rule": {"id": "60204", "level": 10, "description": "Multiple Windows Logon Failures", "mitre": {"id": ["T1110"]}},
        "agent": {"name": "DESKTOP-E2522QF", "ip": "192.168.56.20"},
        "data": {"win": {"eventdata": {"ipAddress": "192.168.56.30", "targetUserName": "socadmin"}}}
    },
    {
        "timestamp": "2026-09-01T21:35:07.819+0530",
        "rule": {"id": "60115", "level": 9, "description": "User account locked out (multiple login errors)", "mitre": {"id": ["T1531"]}},
        "agent": {"name": "DESKTOP-E2522QF", "ip": "192.168.56.20"},
        "data": {"win": {"eventdata": {"targetUserName": "socadmin"}}}
    }
]

def analyze_alerts(alerts):
    print("=" * 60)
    print(f"[*] SOC AUTOMATION: WAZUH THREAT & IOC REPORT")
    print(f"[*] Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)

    high_sev_count = 0
    attacker_ips = []
    affected_hosts = Counter()
    mitre_techniques = Counter()

    for alert in alerts:
        rule = alert.get("rule", {})
        level = rule.get("level", 0)
        agent = alert.get("agent", {}).get("name", "Unknown")
        event_data = alert.get("data", {}).get("win", {}).get("eventdata", {})

        affected_hosts[agent] += 1

        for tech in rule.get("mitre", {}).get("id", []):
            mitre_techniques[tech] += 1

        if "ipAddress" in event_data:
            attacker_ips.append(event_data["ipAddress"])

        if level >= 10:
            high_sev_count += 1
            print(f"\n[!] HIGH SEVERITY ALERT (Level {level})")
            print(f"    Timestamp  : {alert.get('timestamp')}")
            print(f"    Host       : {agent}")
            print(f"    Rule ID    : {rule.get('id')} - {rule.get('description')}")
            print(f"    User       : {event_data.get('user') or event_data.get('targetUserName', 'N/A')}")

    print("\n" + "-" * 60)
    print("[*] SUMMARY STATISTICS")
    print(f"    Total Alerts Parsed : {len(alerts)}")
    print(f"    Critical/High Alerts: {high_sev_count}")
    print(f"    Top Attacking IPs   : {list(set(attacker_ips)) if attacker_ips else 'N/A'}")
    print(f"    MITRE Tactics Seen  : {dict(mitre_techniques)}")
    print("=" * 60)

if __name__ == "__main__":
    analyze_alerts(SAMPLE_ALERTS)