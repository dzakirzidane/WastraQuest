from pydantic import BaseModel, Field
from typing import Literal


class PredictionRequest(BaseModel):
    jawaban_benar: int = Field(..., ge=0, le=15, description="Jumlah jawaban benar (0-15)")
    tingkat_kesulitan: Literal["easy", "medium", "hard"]

    class Config:
        json_schema_extra = {
            "example": {
                "jawaban_benar": 11,
                "tingkat_kesulitan": "medium",
            }
        }


class ModelPrediction(BaseModel):
    prediksi: Literal["Lulus", "Tidak Lulus"]
    probabilitas_lulus: float


class PredictionResponse(BaseModel):
    jawaban_benar: int
    tingkat_kesulitan: str
    random_forest: ModelPrediction
    svm: ModelPrediction