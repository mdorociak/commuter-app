from fastapi import FastAPI

app = FastAPI(
    title="Commuter Backend",
    version="0.1.0",
    description="Aggregates KD and MPK transit data for the Brzeg commuter iOS app.",
)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
