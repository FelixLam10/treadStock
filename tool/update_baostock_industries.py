#!/usr/bin/env python3
"""Refresh the bundled A-share industry membership snapshot from BaoStock."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

import baostock as bs


INDUSTRY_CODE_PREFIX = re.compile(r"^[A-Z]\d+")


def normalized_industry(value: str) -> str:
    return INDUSTRY_CODE_PREFIX.sub("", value.strip()).strip()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output",
        default="assets/data/baostock_industries.json",
        help="Repository-relative output path",
    )
    args = parser.parse_args()

    login = bs.login()
    if login.error_code != "0":
        raise RuntimeError(f"BaoStock login failed: {login.error_msg}")

    try:
        result = bs.query_stock_industry()
        if result.error_code != "0":
            raise RuntimeError(
                f"BaoStock query failed: {result.error_code} {result.error_msg}"
            )

        stocks: dict[str, str] = {}
        update_dates: list[str] = []
        while result.next():
            update_date, raw_code, _, raw_industry, _ = result.get_row_data()
            market, separator, code = raw_code.partition(".")
            industry = normalized_industry(raw_industry)
            if (
                separator
                and market in {"sh", "sz"}
                and len(code) == 6
                and code.isdigit()
                and industry
            ):
                stocks[code] = industry
                if update_date:
                    update_dates.append(update_date)

        payload = {
            "schemaVersion": 1,
            "source": "BaoStock query_stock_industry",
            "sourceUrl": "https://www.baostock.com/",
            "updatedAt": max(update_dates) if update_dates else None,
            "stocks": dict(sorted(stocks.items())),
        }
        output = Path(args.output)
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(
            json.dumps(payload, ensure_ascii=False, separators=(",", ":")),
            encoding="utf-8",
        )
        print(f"wrote {len(stocks)} memberships to {output}")
        return 0
    finally:
        bs.logout()


if __name__ == "__main__":
    raise SystemExit(main())
