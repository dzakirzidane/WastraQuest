from datetime import datetime

from sqlalchemy import Column, Integer, Float, String, Boolean, DateTime

from app.database import Base


class QuizResult(Base):
    __tablename__ = "quiz_results"

    id = Column(Integer, primary_key=True, index=True)

    total_soal = Column(Integer, nullable=False)
    jawaban_benar = Column(Integer, nullable=False)
    skor_akhir = Column(Integer, nullable=False)
    tingkat_kesulitan = Column(Integer, nullable=False) 
    persentase_benar = Column(Float, nullable=False)
    kelulusan = Column(Integer, nullable=False)  
    nama_siswa = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)