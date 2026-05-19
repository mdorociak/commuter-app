from pydantic import BaseModel


class Platform(BaseModel):
    id: str
    code: str | None


class Station(BaseModel):
    id: str
    name: str
    code: str | None
    lat: float
    lon: float
    platforms: list[Platform]
