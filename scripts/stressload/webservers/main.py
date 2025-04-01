#!/usr/bin/env python3

# File: scripts/stressload/webservers/main.py
# Version: 0.1.0

"""
Cloud Function Stress Tester — Fully Config-Driven

- Reads all runtime parameters from config.json.
- No use of environment variables or hardcoded fallbacks.
- Uses only explicitly declared values.
"""

import os
import time
import json
import logging
import threading
import subprocess
import requests


# === GCloud Helpers ===

def gcloud_json(
    cmd: list[str]
) -> dict:
    result = subprocess.run(
        cmd, 
        capture_output=True, 
        text=True
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip())
    return json.loads(result.stdout)


def get_instance_count(
    mig_name: str, 
    region: str, 
    project_id: str
) -> int:
    cmd = [
        "gcloud", "compute", "instance-groups", "managed", "list-instances", mig_name,
        "--region", region,
        "--project", project_id,
        "--format", "json"
    ]
    return len(gcloud_json(cmd))


# === Stress Load Engine ===

def send_request(
    url: str
):
    try:
        response = requests.get(
            url, 
            timeout=10
        )
        logging.info(f"Status {response.status_code} | Time {response.elapsed.total_seconds():.2f}s")
    except Exception as e:
        logging.error(f"Request failed: {e}")


def stress_loop(
    url: str, 
    seconds: int, 
    concurrency: int, 
    sleep_interval: float
):
    logging.info(f"Stress load: {concurrency} threads for {seconds}s")
    stop_time = time.time() + seconds

    def worker():
        while time.time() < stop_time:
            send_request(url)
            time.sleep(sleep_interval)

    threads = [threading.Thread(target=worker) for _ in range(concurrency)]
    [t.start() for t in threads]
    [t.join() for t in threads]


def wait_for_scale_down(
    min_replicas: int, 
    mig_name: str, 
    region: str, 
    project_id: str
):
    logging.info("Monitoring for scale down...")
    while True:
        count = get_instance_count(
            mig_name, 
            region, 
            project_id
        )
        logging.info(f"Current instances: {count}")
        if count <= min_replicas:
            logging.info("Scaled down.")
            break
        time.sleep(10)


# === Entrypoint ===

def main(
    request=None
):
    CONFIG_PATH = os.path.join(
        os.path.dirname(__file__), 
        "config.json"
    )

    if not os.path.exists(CONFIG_PATH):
        return {
            "statusCode": 500,
            "body": "Configuration missing: config.json not found."
        }

    try:
        with open(CONFIG_PATH, "r") as f:
            config = json.load(f)
    except Exception as e:
        return {
            "statusCode": 500,
            "body": f"Failed to load config.json: {e}"
        }

    REQUIRED_KEYS = [
        "target_url",
        "project_id",
        "region",
        "mig_name",
        "autoscaler_name",
        "log_level",
        "stress_duration_seconds",
        "stress_concurrency",
        "request_sleep_interval",
        "autoscaler_min_replicas",
        "autoscaler_max_replicas"
    ]

    missing_keys = [k for k in REQUIRED_KEYS if k not in config]
    if missing_keys:
        return {
            "statusCode": 500,
            "body": f"Missing config keys: {', '.join(missing_keys)}"
        }

    # Extract config values
    target_url = config["target_url"]
    project_id = config["project_id"]
    region = config["region"]
    mig_name = config["mig_name"]
    autoscaler_name = config["autoscaler_name"]
    log_level = config["log_level"].upper()
    duration = config["stress_duration_seconds"]
    concurrency = config["stress_concurrency"]
    sleep_interval = config["request_sleep_interval"]
    min_replicas = config["autoscaler_min_replicas"]
    max_replicas = config["autoscaler_max_replicas"]

    # Setup logging
    logging.basicConfig(
        level=log_level,
        format="%(asctime)s - %(levelname)s - %(message)s"
    )

    try:
        logging.info(f"Autoscaler Range (from config): {min_replicas}-{max_replicas}")

        while get_instance_count(
            mig_name, 
            region, project_id
        ) < max_replicas:
            stress_loop(
                target_url, 
                duration, 
                concurrency, 
                sleep_interval
            )

        wait_for_scale_down(
            min_replicas, 
            mig_name, 
            region, 
            project_id
        )

        return {"statusCode": 200, "body": "Stress test completed"}
    except Exception as e:
        logging.error(
            str(e), 
            exc_info=True
        )
        return {"statusCode": 500, "body": f"Error: {str(e)}"}


if __name__ == "__main__":
    main()
