#!/usr/bin/env python3
"""
Check Gmail unread count via IMAP and output for waybar.
Outputs JSON for waybar custom module with rich tooltips.

Usage:
    1. Enable IMAP in Gmail: Settings → See all settings → Forwarding and POP/IMAP → Enable IMAP
    2. Create an App Password: https://myaccount.google.com/apppasswords
    3. Set GMAIL_USER and GMAIL_PASS environment variables, or create ~/.config/gmail_waybar.conf:
       GMAIL_USER=your.email@gmail.com
       GMAIL_PASS=xxxx xxxx xxxx xxxx
    4. Add the custom/gmail module to your waybar config
"""

import imaplib
import email
import json
import os
from pathlib import Path

# Configuration
IMAP_SERVER = "imap.gmail.com"
IMAP_PORT = 993
REFRESH_INTERVAL = 10  # seconds between checks
MAILBOX = "INBOX"

# Labels/folders to check (comma-separated, or use INBOX only)
# You can add "[Gmail]/Starred", etc.
MAILBOXES = ["INBOX"]

def load_config():
    """Load credentials from config file or environment."""
    config_path = Path.home() / ".config" / "gmail_waybar.conf"
    
    if config_path.exists():
        config = {}
        with open(config_path) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, value = line.split("=", 1)
                    config[key.strip()] = value.strip()
        return config
    else:
        return {
            "GMAIL_USER": os.environ.get("GMAIL_USER", ""),
            "GMAIL_PASS": os.environ.get("GMAIL_PASS", "")
        }

def get_unread_count(mail, mailbox):
    """Get unread message count for a mailbox."""
    status, messages = mail.select(mailbox, readonly=True)
    if status != "OK":
        return 0, []
    
    # Search for unseen messages
    status, messages = mail.search(None, "UNSEEN")
    if status != "OK":
        return 0, []
    
    message_ids = messages[0].split()
    count = len(message_ids)
    
    # Get snippet of latest unread emails for tooltip (max 5)
    emails_info = []
    if count > 0:
        # Get the latest 5 unread emails
        latest_ids = message_ids[-5:]
        for msg_id in reversed(latest_ids):
            status, msg_data = mail.fetch(msg_id, "(BODY.PEEK[HEADER.FIELDS (FROM SUBJECT DATE)])")
            if status == "OK":
                msg = email.message_from_bytes(msg_data[0][1])
                frm = msg.get("From", "Unknown")
                subj = msg.get("Subject", "(No subject)")
                emails_info.append({"from": frm, "subject": subj})
    
    return count, emails_info

def main():
    config = load_config()
    username = config.get("GMAIL_USER", "")
    password = config.get("GMAIL_PASS", "")
    
    if not username or not password:
        # Config not set up yet - show helpful message
        print(json.dumps({
            "text": "📧 ⚠",
            "tooltip": "Gmail module not configured.\nCreate ~/.config/gmail_waybar.conf with:\nGMAIL_USER=your.email@gmail.com\nGMAIL_PASS=xxxx xxxx xxxx xxxx",
            "class": "gmail-unconfigured"
        }))
        return
    
    try:
        # Connect to Gmail IMAP
        mail = imaplib.IMAP4_SSL(IMAP_SERVER, IMAP_PORT)
        mail.login(username, password)
        
        # Count unread across all mailboxes
        total_unread = 0
        all_emails = []
        
        for mailbox in MAILBOXES:
            count, emails = get_unread_count(mail, mailbox)
            total_unread += count
            all_emails.extend(emails)
        
        mail.logout()
        
        # Build tooltip
        if total_unread > 0:
            tooltip_lines = [f"📧 {total_unread} unread email(s)"]
            tooltip_lines.append("")
            for i, e in enumerate(all_emails[:5], 1):
                tooltip_lines.append(f"{i}. {e['from']}")
                tooltip_lines.append(f"   {e['subject']}")
            tooltip = "\n".join(tooltip_lines)
        else:
            tooltip = "📧 No unread emails"
        
        # Output for waybar
        if total_unread > 0:
            output = {
                "text": f"📧 {total_unread}",
                "tooltip": tooltip,
                "class": "gmail-has-unread",
                "alt": str(total_unread)
            }
        else:
            output = {
                "text": "📧",
                "tooltip": tooltip,
                "class": "gmail-no-unread",
                "alt": "0"
            }
        
        print(json.dumps(output))
        
    except imaplib.IMAP4.error as e:
        print(json.dumps({
            "text": "📧 ❌",
            "tooltip": f"Gmail IMAP error:\n{str(e)}\n\nCheck your credentials in ~/.config/gmail_waybar.conf",
            "class": "gmail-error"
        }))
    except Exception as e:
        print(json.dumps({
            "text": "📧 ❌",
            "tooltip": f"Error checking Gmail:\n{str(e)}",
            "class": "gmail-error"
        }))

if __name__ == "__main__":
    main()
