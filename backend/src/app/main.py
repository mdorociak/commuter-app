import os
from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI

from .gtfs.loader import load_stations
from .stops import router as stops_router


_DEFAULT_GTFS_DIR = Path(__file__).resolve().parents[2] / "data" / "kd_gtfs"


@asynccontextmanager
async def lifespan(app: FastAPI):
    gtfs_dir = Path(os.environ.get("KD_GTFS_DIR", _DEFAULT_GTFS_DIR))
    if (gtfs_dir / "stops.txt").exists():
        app.state.stations = load_stations(gtfs_dir)
    else:
        app.state.stations = {}
    yield


app = FastAPI(
    title="Commuter Backend",
    version="0.1.0",
    description="Aggregates KD and MPK transit data for the Brzeg commuter iOS app.",
    lifespan=lifespan,
)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


app.include_router(stops_router)
