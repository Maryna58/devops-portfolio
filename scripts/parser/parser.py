import argparse
import re
from collections import Counter
import sys

def main():
    parser = argparse.ArgumentParser(description="Web server log analyzer")
    parser.add_argument("logfile", nargs='?', default="access.log", help="Path to the Apache/Nginx log file")
    parser.add_argument("-o", "--output", default="report.html", help="Output HTML report")
    args = parser.parse_args()

    ip_counter = Counter()
    ua_counter = Counter()
    status_counter = Counter()

    log_pattern = re.compile(
        r'(?P<ip>\d+\.\d+\.\d+\.\d+) - - \[.*?\] ".*?" (?P<status>\d+) .* ".*?" "(?P<ua>.*?)"'
    )

    print(f"Analyzing {args.logfile}...")

    try:
        with open(args.logfile, "r", encoding="utf-8") as f:
            for line in f:
                match = log_pattern.match(line)
                if match:
                    ip_counter[match.group("ip")] += 1
                    status_counter[match.group("status")] += 1
                    ua_counter[match.group("ua")] += 1
    except FileNotFoundError:
        print(f"Error: File '{args.logfile}' not found.")
        return
    except Exception as e:
        print(f"Error: {e}")
        return

    html = f"""
    <html>
    <head>
        <title>Web Server Log Report</title>
        <style>
            body {{ font-family: sans-serif; margin: 20px; }}
            h1 {{ color: #2c3e50; }}
            h2 {{ color: #34495e; border-bottom: 2px solid #ddd; padding-bottom: 5px; }}
            ul {{ background: #f9f9f9; padding: 15px; border-radius: 5px; }}
            li {{ margin-bottom: 5px; list-style: none; }}
        </style>
    </head>
    <body>
    <h1>Web Server Log Report</h1>

    <h2>Top IP Addresses</h2>
    <ul>
    {''.join(f"<li><b>{ip}</b>: {count}</li>" for ip, count in ip_counter.most_common(10))}
    </ul>

    <h2>Top User Agents</h2>
    <ul>
    {''.join(f"<li>{ua}: {count}</li>" for ua, count in ua_counter.most_common(10))}
    </ul>

    <h2>HTTP Status Codes</h2>
    <ul>
    {''.join(f"<li>Status <b>{status}</b>: {count}</li>" for status, count in status_counter.items())}
    </ul>

    </body>
    </html>
    """

    try:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(html)
        print(f"Report saved to {args.output}")
    except Exception as e:
        print(f"Error saving report: {e}")

if __name__ == "__main__":
    main()