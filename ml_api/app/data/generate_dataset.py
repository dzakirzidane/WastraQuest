import numpy as np
import pandas as pd
import os

RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)

N_SAMPLES = 1000
TOTAL_SOAL = 15

DIFFICULTY_MAP = {"easy": 1, "medium": 2, "hard": 3}
DIFFICULTY_WEIGHT = {"easy": 1.0, "medium": 1.15, "hard": 1.3}
BASE_ACCURACY = {"easy": 0.75, "medium": 0.60, "hard": 0.48}
PASSING_THRESHOLD = 230
LOGISTIC_STEEPNESS = 0.035


def sigmoid(x: float) -> float:
    return 1 / (1 + np.exp(-x))


def generate_row(rng: np.random.Generator) -> dict:
    difficulty = rng.choice(["easy", "medium", "hard"], p=[0.4, 0.35, 0.25])

    # Simulasikan kemampuan peserta (ability) yang bervariasi antar individu
    ability_noise = rng.normal(loc=0, scale=0.12)
    p_correct = np.clip(BASE_ACCURACY[difficulty] + ability_noise, 0.05, 0.98)

    jawaban_benar = int(rng.binomial(n=TOTAL_SOAL, p=p_correct))
    skor_akhir = jawaban_benar * 20
    persentase_benar = round((jawaban_benar / TOTAL_SOAL) * 100, 2)
    skor_tertimbang = skor_akhir * DIFFICULTY_WEIGHT[difficulty]
    z = LOGISTIC_STEEPNESS * (skor_tertimbang - PASSING_THRESHOLD)
    p_lulus = sigmoid(z)
    kelulusan = int(rng.binomial(n=1, p=p_lulus))

    return {
        "total_soal": TOTAL_SOAL,
        "jawaban_benar": jawaban_benar,
        "skor_akhir": skor_akhir,
        "tingkat_kesulitan": DIFFICULTY_MAP[difficulty],
        "persentase_benar": persentase_benar,
        "kelulusan": kelulusan,
    }


def main():
    rng = np.random.default_rng(RANDOM_SEED)
    rows = [generate_row(rng) for _ in range(N_SAMPLES)]
    df = pd.DataFrame(rows)

    output_dir = os.path.dirname(__file__)
    output_path = os.path.join(output_dir, "dataset.csv")
    df.to_csv(output_path, index=False)

    print(f"Dataset berhasil dibuat: {output_path}")
    print(f"Jumlah data: {len(df)}")
    print(f"Distribusi label kelulusan:\n{df['kelulusan'].value_counts()}")
    print(f"\nContoh 5 baris pertama:\n{df.head()}")


if __name__ == "__main__":
    main()