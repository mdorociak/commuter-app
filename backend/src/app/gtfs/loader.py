import csv
from pathlib import Path

from .models import Platform, Station


def load_stations(gtfs_dir: Path) -> dict[str, Station]:

    stops_file = gtfs_dir / "stops.txt"
    stations: dict[str, Station] = {}
    platform_rows: list[dict[str, str]] = []

    with stops_file.open(encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            location_type = row.get("location_type", "").strip()
            if location_type == "1":
                stations[row["stop_id"]] = Station(
                    id=row["stop_id"],
                    name=row["stop_name"],
                    code=row.get("stop_code") or None,
                    lat=float(row["stop_lat"]),
                    lon=float(row["stop_lon"]),
                    platforms=[],
                )
            elif location_type == "0":
                platform_rows.append(row)

    for row in platform_rows:
        parent_id = row.get("parent_station", "")
        station = stations.get(parent_id)
        if station is None:
            continue
        station.platforms.append(
            Platform(
                id=row["stop_id"],
                code=row.get("platform_code") or None,
            )
        )

    return stations
