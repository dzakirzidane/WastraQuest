from datetime import datetime
from typing import Optional, Literal

from pydantic import BaseModel, Field

Difficulty = Literal["easy", "medium", "hard"]


class PredictionRequest(BaseModel):
    jawaban_benar: int = Field(..., ge=0, le=15)
    tingkat_kesulitan: Difficulty


class ModelPrediction(BaseModel):
    prediksi: str
    probabilitas_lulus: float


class PredictionResponse(BaseModel):
    jawaban_benar: int
    tingkat_kesulitan: str
    svm: ModelPrediction



class QuizResultCreate(BaseModel):
    total_soal: int = Field(..., gt=0)
    jawaban_benar: int = Field(..., ge=0)
    skor_akhir: int = Field(..., ge=0)
    tingkat_kesulitan: int = Field(..., ge=1, le=3)  
    persentase_benar: float = Field(..., ge=0, le=100)
    kelulusan: int = Field(..., ge=0, le=1)  
    nama_siswa: Optional[str] = None


class QuizResultOut(QuizResultCreate):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True


class LeaderboardEntry(BaseModel):
    peringkat: int
    nama_siswa: str
    skor_akhir: int
    persentase_benar: float
    tingkat_kesulitan: int
    created_at: datetime

    class Config:
        from_attributes = True