#!/usr/bin/env python3
"""
Cross-platform desktop notification for Claude Code.

Windows: PowerShell toast notification (WinRT, built into Windows 10+)
macOS:   osascript display notification
Linux:   notify-send (libnotify)

Hook Event: (not wired by default --- add to settings.json if desired)
"""

import json
import platform
import subprocess
import sys
from html import escape


def notify_windows(title: str, message: str) -> None:
    """Send a Windows 10/11 toast notification via PowerShell WinRT."""
    title_xml = escape(title)
    message_xml = escape(message)
    xml = (
        '<toast><visual><binding template="ToastText02">'
        f'<text id="1">{title_xml}</text>'
        f'<text id="2">{message_xml}</text>'
        '</binding></visual></toast>'
    )
    # Escape single quotes for PowerShell string literal
    xml_ps = xml.replace("'", "''")
    ps_cmd = (
        "[Windows.UI.Notifications.ToastNotificationManager,"
        " Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null; "
        "[Windows.Data.Xml.Dom.XmlDocument,"
        " Windows.Data.Xml.Dom, ContentType = WindowsRuntime] | Out-Null; "
        "$xml = New-Object Windows.Data.Xml.Dom.XmlDocument; "
        f"$xml.LoadXml('{xml_ps}'); "
        "$toast = New-Object Windows.UI.Notifications.ToastNotification $xml; "
        "[Windows.UI.Notifications.ToastNotificationManager]"
        "::CreateToastNotifier('Claude Code').Show($toast)"
    )
    subprocess.run(
        ["powershell.exe", "-NoProfile", "-Command", ps_cmd],
        capture_output=True, timeout=5,
    )


def notify_macos(title: str, message: str) -> None:
    """Send a macOS notification via osascript."""
    title_esc = title.replace('"', '\\"')
    message_esc = message.replace('"', '\\"')
    subprocess.run(
        [
            "osascript", "-e",
            f'display notification "{message_esc}" with title "{title_esc}"',
        ],
        capture_output=True, timeout=5,
    )


def notify_linux(title: str, message: str) -> None:
    """Send a Linux notification via notify-send (libnotify)."""
    subprocess.run(
        ["notify-send", title, message],
        capture_output=True, timeout=5,
    )


def main() -> int:
    try:
        hook_input = json.load(sys.stdin)
    except (json.JSONDecodeError, IOError):
        return 0

    message = hook_input.get("message", "Claude needs attention")
    title = hook_input.get("title", "Claude Code")

    system = platform.system()
    try:
        if system == "Windows":
            notify_windows(title, message)
        elif system == "Darwin":
            notify_macos(title, message)
        elif system == "Linux":
            notify_linux(title, message)
    except (subprocess.TimeoutExpired, FileNotFoundError, OSError):
        pass  # Fail silently if notification tool unavailable

    return 0


if __name__ == "__main__":
    sys.exit(main())
