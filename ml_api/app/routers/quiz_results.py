from typing import List

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.db_models import QuizResult
from app.models.schemas import QuizResultCreate, QuizResultOut

router = APIRouter(prefix="/quiz-results", tags=["Quiz Results"])


@router.post("", response_model=QuizResultOut)
def create_quiz_result(payload: QuizResultCreate, db: Session = Depends(get_db)):
    """
    Dipanggil dari Flutter setelah siswa selesai ngerjain kuis (bukan pas
    prediksi). Hasil ASLI ini yang nantinya jadi data training tambahan.
    """
    record = QuizResult(**payload.model_dump())
    db.add(record)
    db.commit()
    db.refresh(record)
    return record


@router.get("", response_model=List[QuizResultOut])
def list_quiz_results(db: Session = Depends(get_db)):
    """Buat admin/dashboard, atau dipanggil train.py buat ambil data terbaru."""
    return db.query(QuizResult).order_by(QuizResult.created_at.desc()).all()