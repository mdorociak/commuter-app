from pathlib import Path

from app.gtfs.loader import load_stations

FIXTURE_DIR = Path(__file__).parent / "fixtures" / "mini_gtfs"


def test_load_stations_returns_only_stations_not_platforms() -> None:
    stations = load_stations(FIXTURE_DIR)
    assert len(stations) == 3
    assert "2246799" in stations  
    assert "1413092" in stations  
    assert "2333170" not in stations 


def test_brzeg_has_one_platform_with_correct_code() -> None:
    brzeg = load_stations(FIXTURE_DIR)["2246799"]
    assert brzeg.name == "Brzeg"
    assert brzeg.code == "11"
    assert len(brzeg.platforms) == 1
    assert brzeg.platforms[0].code == "II"


def test_platform_with_blank_code_keeps_code_as_none() -> None:
    brzeg_dolny = load_stations(FIXTURE_DIR)["1413092"]
    codes = [p.code for p in brzeg_dolny.platforms]
    assert None in codes
    assert "II" in codes


def test_station_with_no_platforms_has_empty_list() -> None:
    empty = load_stations(FIXTURE_DIR)["9999999"]
    assert empty.platforms == []


def test_orphan_platform_pointing_at_nonexistent_parent_is_dropped() -> None:
    stations = load_stations(FIXTURE_DIR)
    all_platform_ids = [p.id for s in stations.values() for p in s.platforms]
    assert "8888888" not in all_platform_ids
