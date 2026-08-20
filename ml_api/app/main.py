from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import prediction, model_metrics, quiz_results, leaderboard
from app.ml import predictor
from app.database import init_db


@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    print("Tabel database siap.")

    try:
        predictor.load_models()
        print("Model SVM berhasil dimuat.")
    except FileNotFoundError as e:
        print(f"PERINGATAN: {e}")

    yield

    print("Server dimatikan.")


app = FastAPI(
    title="WastraQuest ML API",
    description="Backend prediksi kelulusan peserta - SVM",
    version="1.1.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(prediction.router)
app.include_router(model_metrics.router)
app.include_router(quiz_results.router)
app.include_router(leaderboard.router)


@app.get("/")
def root():
    return {"status": "ok", "message": "WastraQuest ML API is running"}


@app.get("/health")
def health_check():
    return {"status": "healthy"}