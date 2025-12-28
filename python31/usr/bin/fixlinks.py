#!/bin/python3

import sys
from pathlib import Path


def fix_link(target: Path, link: Path) -> None:
    if not link.samefile(target):
        print(f"! {link} is not a symlink to {target}")
        return

    link.unlink()
    link.symlink_to(target)


def main() -> None:
    if len(sys.argv) < 3:
        print("Usage: fixlinks.py <target> <link>...")
        raise SystemExit(1)

    target = Path(sys.argv[1])
    links = [Path(link) for link in sys.argv[2:] if Path(link).is_symlink()]

    if not target.exists():
        print(f"Path does not exists: {target}")
        raise SystemExit(1)

    for link in links:
        fix_link(target, link)


if __name__ == "__main__":
    main()
