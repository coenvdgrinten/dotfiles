#!/usr/bin/env python3
"""
Gmail unread counter for waybar.
Shows latest unread emails in tooltip, click opens Gmail.

Config: ~/.config/unread_waybar.conf
    [gmail]
    user = your.email@gmail.com
    password = xxxx xxxx xxxx xxxx
"""

import imaplib
import email
import json
import configparser
from pathlib import Path

CONFIG_PATH = Path.home() / ".config" / "unread_waybar.conf"


def main():
    if not CONFIG_PATH.exists():
        print(json.dumps({
            "text": "📧",
            "tooltip": "Not configured. Create ~/.config/unread_waybar.conf",
            "class": "gmail-unconfigured"
        }))
        return

    config = configparser.ConfigParser()
    config.read(CONFIG_PATH)

    if not config.has_section("gmail"):
        print(json.dumps({
            "text": "📧",
            "tooltip": "Gmail section not found in ~/.config/unread_waybar.conf",
            "class": "gmail-unconfigured"
        }))
        return

    username = config.get("gmail", "user", fallback="")
    password = config.get("gmail", "password", fallback="")

    if not username or not password:
        print(json.dumps({
            "text": "📧",
            "tooltip": "Gmail credentials not set in ~/.config/unread_waybar.conf",
            "class": "gmail-unconfigured"
        }))
        return

    try:
        mail = imaplib.IMAP4_SSL("imap.gmail.com", 993)
        mail.login(username, password)
        mail.select("INBOX", readonly=True)
        status, messages = mail.search(None, "UNSEEN")

        if status != "OK":
            mail.logout()
            print(json.dumps({
                "text": "📧",
                "tooltip": "📧 Gmail: 0 unread",
                "class": "gmail-no-unread"
            }))
            return

        message_ids = messages[0].split()
        count = len(message_ids)

        # Get latest 5 for tooltip
        emails_info = []
        if count > 0:
            latest_ids = message_ids[-5:]
            for msg_id in reversed(latest_ids):
                status, msg_data = mail.fetch(msg_id, "(BODY.PEEK[HEADER.FIELDS (FROM SUBJECT)])")
                if status == "OK":
                    msg = email.message_from_bytes(msg_data[0][1])
                    emails_info.append({
                        "from": msg.get("From", "Unknown"),
                        "subject": msg.get("Subject", "(No subject)")
                    })

        mail.logout()

        # Build tooltip
        if count > 0:
            tooltip_lines = [f"📧 Gmail: {count} unread"]
            tooltip_lines.append("")
            for i, e in enumerate(emails_info, 1):
                tooltip_lines.append(f"  {i}. {e['from']}")
                tooltip_lines.append(f"     {e['subject']}")
            tooltip = "\n".join(tooltip_lines)
            text = f"📧 {count}"
            css_class = "gmail-has-unread"
        else:
            tooltip = "📧 Gmail: 0 unread"
            text = "📧"
            css_class = "gmail-no-unread"

        print(json.dumps({
            "text": text,
            "tooltip": tooltip,
            "class": css_class
        }))

    except imaplib.IMAP4.error as e:
        print(json.dumps({
            "text": "📧 ❌",
            "tooltip": f"Gmail IMAP error:\n{str(e)}",
            "class": "gmail-error"
        }))
    except Exception as e:
        print(json.dumps({
            "text": "📧 ❌",
            "tooltip": f"Error: {str(e)}",
            "class": "gmail-error"
        }))


if __name__ == "__main__":
    main()
