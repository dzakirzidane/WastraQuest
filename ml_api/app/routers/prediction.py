from fastapi import APIRouter, HTTPException
from app.models.schemas import PredictionRequest, PredictionResponse
from app.ml import predictor

router = APIRouter(prefix="/predict", tags=["Prediction"])


@router.post("", response_model=PredictionResponse)
def predict_kelulusan(request: PredictionRequest):
    try:
        result = predictor.predict(request.jawaban_benar, request.tingkat_kesulitan)
    except FileNotFoundError as e:
        raise HTTPException(
            status_code=503,
            detail=str(e),
        )

    return PredictionResponse(
        jawaban_benar=request.jawaban_benar,
        tingkat_kesulitan=request.tingkat_kesulitan,
        random_forest=result["random_forest"],
        svm=result["svm"],
    )