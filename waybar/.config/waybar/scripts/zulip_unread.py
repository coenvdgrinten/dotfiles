#!/usr/bin/env python3
"""
Zulip unread counter for waybar.
Shows unread messages per stream/topic in tooltip, click opens Zulip.

Config: ~/.config/unread_waybar.conf
    [zulip]
    server = https://thetavision.zulipchat.com
    email = your.email@thetavision.com
    api_key = your-zulip-api-key
"""

import json
import base64
import urllib.request
import urllib.parse
import configparser
from pathlib import Path

CONFIG_PATH = Path.home() / ".config" / "unread_waybar.conf"


def main():
    if not CONFIG_PATH.exists():
        print(json.dumps({
            "text": "💬",
            "tooltip": "Not configured. Create ~/.config/unread_waybar.conf",
            "class": "zulip-unconfigured"
        }))
        return

    config = configparser.ConfigParser()
    config.read(CONFIG_PATH)

    if not config.has_section("zulip"):
        print(json.dumps({
            "text": "💬",
            "tooltip": "Zulip section not found in ~/.config/unread_waybar.conf",
            "class": "zulip-unconfigured"
        }))
        return

    server = config.get("zulip", "server", fallback="").rstrip("/")
    email_addr = config.get("zulip", "email", fallback="")
    api_key = config.get("zulip", "api_key", fallback="")

    if not server or not email_addr or not api_key:
        print(json.dumps({
            "text": "💬",
            "tooltip": "Zulip credentials not set in ~/.config/unread_waybar.conf",
            "class": "zulip-unconfigured"
        }))
        return

    try:
        # Use /api/v1/register with fetch_unread_msgs=true to get unread counts
        url = f"{server}/api/v1/register"
        credentials = base64.b64encode(f"{email_addr}:{api_key}".encode()).decode()
        payload = urllib.parse.urlencode({
            "client": "waybar",
            "client_type": "server",
            "fetch_unread_msgs": "true",
            "event_queue_id": "0",
            "last_event_id": "-1",
            "client_grants": "null"
        }).encode()

        req = urllib.request.Request(url, data=payload, method="POST")
        req.add_header("Authorization", f"Basic {credentials}")
        req.add_header("Content-Type", "application/x-www-form-urlencoded")

        with urllib.request.urlopen(req, timeout=10) as response:
            data = json.loads(response.read().decode())

        # Extract unread counts from the response
        unread = data.get("unread_msgs", {})
        total = unread.get("count", 0)

        # Build stream_id → name mapping from the streams list
        stream_names = {}
        for s in data.get("streams", []):
            stream_names[s["stream_id"]] = s.get("name", f"stream:{s['stream_id']}")

        # Build topic list from streams and PMs
        topics = []
        for stream in unread.get("streams", []):
            stream_id = stream.get("stream_id", 0)
            topic_name = stream.get("topic", "")
            msg_ids = stream.get("unread_message_ids", [])
            if msg_ids:
                stream_name = stream_names.get(stream_id, f"#{stream_id}")
                topics.append({
                    "stream": stream_name,
                    "topic": topic_name,
                    "count": len(msg_ids)
                })

        for pm in unread.get("pms", []):
            user_ids = pm.get("user_ids", [])
            msg_ids = pm.get("unread_message_ids", [])
            if msg_ids:
                topics.append({
                    "stream": "DM",
                    "topic": f"users:{','.join(str(u) for u in user_ids)}",
                    "count": len(msg_ids)
                })

        # Sort by count descending, take top 5
        topics.sort(key=lambda x: x["count"], reverse=True)

        # Build tooltip
        if total > 0:
            tooltip_lines = [f"💬 Zulip: {total} unread"]
            tooltip_lines.append("")
            for i, t in enumerate(topics[:5], 1):
                tooltip_lines.append(f"  {i}. {t['stream']} > {t['topic']} ({t['count']})")
            tooltip = "\n".join(tooltip_lines)
            text = f"💬 {total}"
            css_class = "zulip-has-unread"
        else:
            tooltip = "💬 Zulip: 0 unread"
            text = "💬"
            css_class = "zulip-no-unread"

        print(json.dumps({
            "text": text,
            "tooltip": tooltip,
            "class": css_class
        }))

    except urllib.error.URLError as e:
        print(json.dumps({
            "text": "💬 ❌",
            "tooltip": f"Zulip API error:\n{str(e)}",
            "class": "zulip-error"
        }))
    except Exception as e:
        print(json.dumps({
            "text": "💬 ❌",
            "tooltip": f"Error: {str(e)}",
            "class": "zulip-error"
        }))


if __name__ == "__main__":
    main()
