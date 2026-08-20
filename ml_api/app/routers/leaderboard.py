from typing import List, Optional

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.db_models import QuizResult
from app.models.schemas import LeaderboardEntry

router = APIRouter(prefix="/leaderboard", tags=["Leaderboard"])


@router.get("", response_model=List[LeaderboardEntry])
def get_leaderboard(
    tingkat_kesulitan: Optional[int] = Query(
        None, ge=1, le=3, description="1=easy, 2=medium, 3=hard. Kosongkan untuk semua level."
    ),
    limit: int = Query(50, ge=1, le=200),
    db: Session = Depends(get_db),
):
    """
    Papan peringkat real-time: skor TERBAIK tiap siswa (nama_siswa),
    diambil langsung dari tabel quiz_results. Siswa tanpa nama (nama_siswa
    kosong) tidak ditampilkan karena gak bisa diatribusikan.
    """
    query = db.query(QuizResult).filter(QuizResult.nama_siswa.isnot(None))

    if tingkat_kesulitan is not None:
        query = query.filter(QuizResult.tingkat_kesulitan == tingkat_kesulitan)

    rows = query.order_by(
        QuizResult.skor_akhir.desc(), QuizResult.created_at.asc()
    ).all()

    best_per_student: dict[str, QuizResult] = {}
    for row in rows:
        if row.nama_siswa not in best_per_student:
            best_per_student[row.nama_siswa] = row

    ranked = sorted(
        best_per_student.values(),
        key=lambda r: (-r.skor_akhir, r.created_at),
    )[:limit]

    return [
        LeaderboardEntry(
            peringkat=i + 1,
            nama_siswa=r.nama_siswa,
            skor_akhir=r.skor_akhir,
            persentase_benar=r.persentase_benar,
            tingkat_kesulitan=r.tingkat_kesulitan,
            created_at=r.created_at,
        )
        for i, r in enumerate(ranked)
    ]