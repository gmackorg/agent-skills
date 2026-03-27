#!/usr/bin/env python3
"""Check likely domain status for a list of base names."""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from dataclasses import asdict, dataclass

DEFAULT_TLDS = ("com", "net", "ai", "io")
AVAILABILITY_HINTS = (
    "no match for",
    "not found",
    "no data found",
    "status: available",
    "domain not found",
    "no entries found",
    "object does not exist",
    "domain you requested is not known",
    "the queried object does not exist",
)
REGISTERED_HINTS = (
    "registrar:",
    "creation date:",
    "registry expiry date:",
    "name server:",
    "domain status:",
    "registered on:",
)


@dataclass
class DomainResult:
    domain: str
    dns: str
    web: str
    whois: str
    signal: str


def run_command(args: list[str], timeout: int = 8) -> tuple[int | None, str]:
    try:
        completed = subprocess.run(
            args,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return None, ""

    output = (completed.stdout or "") + (completed.stderr or "")
    return completed.returncode, output.strip()


def check_dns(domain: str) -> str:
    if not shutil.which("dig"):
        return "unknown"

    _, output = run_command(["dig", "+short", domain], timeout=5)
    return "resolves" if output else "none"


def check_web(domain: str) -> str:
    if not shutil.which("curl"):
        return "unknown"

    code, output = run_command(
        [
            "curl",
            "-I",
            "-L",
            "--max-time",
            "5",
            "-sS",
            f"https://{domain}",
        ],
        timeout=7,
    )
    if code is None:
        return "unknown"
    if output:
        first_line = output.splitlines()[0].strip()
        if first_line.startswith("HTTP/"):
            return first_line.split(maxsplit=2)[1]
    return "none"


def parse_whois_signal(output: str) -> tuple[str, str]:
    if not output:
        return "unknown", "missing"

    lowered = output.lower()
    if any(hint in lowered for hint in AVAILABILITY_HINTS):
        return "likely available", "available-signal"
    if any(hint in lowered for hint in REGISTERED_HINTS):
        return "likely registered", "registered-signal"
    return "unknown", "inconclusive"


def check_whois(domain: str) -> tuple[str, str]:
    if not shutil.which("whois"):
        return "missing", "unknown"

    _, output = run_command(["whois", domain], timeout=10)
    signal, summary = parse_whois_signal(output)
    return summary, signal


def build_result(domain: str) -> DomainResult:
    dns = check_dns(domain)
    web = check_web(domain)
    whois_summary, signal = check_whois(domain)
    return DomainResult(domain=domain, dns=dns, web=web, whois=whois_summary, signal=signal)


def print_markdown(results: list[DomainResult]) -> None:
    print("| Domain | DNS | HTTPS | WHOIS | Signal |")
    print("|---|---|---|---|---|")
    for result in results:
        print(
            f"| {result.domain} | {result.dns} | {result.web} | {result.whois} | {result.signal} |"
        )


def print_json(results: list[DomainResult]) -> None:
    json.dump([asdict(result) for result in results], sys.stdout, indent=2)
    sys.stdout.write("\n")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Check likely domain status across common TLDs."
    )
    parser.add_argument("names", nargs="+", help="Base names to check, without TLDs")
    parser.add_argument(
        "--tlds",
        default=",".join(DEFAULT_TLDS),
        help="Comma-separated TLDs. Default: com,net,ai,io",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Emit JSON instead of markdown.",
    )
    args = parser.parse_args()

    tlds = [tld.strip().lstrip(".") for tld in args.tlds.split(",") if tld.strip()]
    results: list[DomainResult] = []
    for name in args.names:
        base = name.strip().lower()
        if not base:
            continue
        for tld in tlds:
            results.append(build_result(f"{base}.{tld}"))

    if args.json:
        print_json(results)
    else:
        print_markdown(results)


if __name__ == "__main__":
    main()
