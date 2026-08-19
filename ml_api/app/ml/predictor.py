import os
import json
import joblib
import numpy as np

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
MODELS_DIR = os.path.join(BASE_DIR, "saved_models")

DIFFICULTY_MAP = {"easy": 1, "medium": 2, "hard": 3}

_svm_model = None
_scaler = None
_feature_columns = None


def load_models():
    """Memuat model, scaler, dan urutan fitur ke memori. Dipanggil sekali
    saat aplikasi FastAPI startup."""
    global _svm_model, _scaler, _feature_columns

    svm_path = os.path.join(MODELS_DIR, "svm_model.pkl")
    scaler_path = os.path.join(MODELS_DIR, "scaler.pkl")
    features_path = os.path.join(MODELS_DIR, "feature_columns.json")

    for path in [svm_path, scaler_path, features_path]:
        if not os.path.exists(path):
            raise FileNotFoundError(
                f"File model tidak ditemukan: {path}. "
                f"Jalankan 'python -m app.ml.train' terlebih dahulu."
            )

    _svm_model = joblib.load(svm_path)
    _scaler = joblib.load(scaler_path)
    with open(features_path) as f:
        _feature_columns = json.load(f)


def _build_feature_vector(jawaban_benar: int, tingkat_kesulitan: str) -> np.ndarray:
    tingkat_encoded = DIFFICULTY_MAP[tingkat_kesulitan]
    raw_values = {
        "jawaban_benar": jawaban_benar,
        "tingkat_kesulitan": tingkat_encoded,
    }
    ordered = [raw_values[col] for col in _feature_columns]
    return np.array(ordered, dtype=float).reshape(1, -1)


def predict(jawaban_benar: int, tingkat_kesulitan: str) -> dict:

    if _svm_model is None or _scaler is None:
        load_models()

    X = _build_feature_vector(jawaban_benar, tingkat_kesulitan)
    X_scaled = _scaler.transform(X)

    svm_pred = _svm_model.predict(X_scaled)[0]
    svm_proba = _svm_model.predict_proba(X_scaled)[0][1]  # probabilitas kelas "Lulus"

    return {
        "svm": {
            "prediksi": "Lulus" if svm_pred == 1 else "Tidak Lulus",
            "probabilitas_lulus": round(float(svm_proba), 4),
        },
    }