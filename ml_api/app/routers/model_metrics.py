import json
import os

from fastapi import APIRouter, HTTPException

router = APIRouter(prefix="/api", tags=["model-metrics"])

# Sesuaikan path ini kalau struktur folder ml_api lo beda
METRICS_PATH = os.path.join(
    os.path.dirname(os.path.dirname(__file__)), "data", "model_metrics.json"
)


@router.get("/model-metrics")
def get_model_metrics():
    """
    Mengembalikan hasil evaluasi model (cross-validation & hold-out test)
    untuk SVM dan Random Forest, dibuat oleh train.py.
    """
    if not os.path.exists(METRICS_PATH):
        raise HTTPException(
            status_code=404,
            detail="model_metrics.json belum ada. Jalankan train.py dulu.",
        )

    with open(METRICS_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    return data