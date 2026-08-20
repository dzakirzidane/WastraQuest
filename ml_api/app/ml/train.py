import os
import json
import joblib
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split, StratifiedKFold, cross_validate, GridSearchCV
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVC
from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    confusion_matrix,
    classification_report,
)

from app.database import SessionLocal
from app.models.db_models import QuizResult

RANDOM_SEED = 42

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
DATA_PATH = os.path.join(BASE_DIR, "app", "data", "dataset.csv")
MODELS_DIR = os.path.join(BASE_DIR, "saved_models")
REPORT_PATH = os.path.join(BASE_DIR, "app", "data", "model_report.txt")
METRICS_JSON_PATH = os.path.join(BASE_DIR, "app", "data", "model_metrics.json")
PLOTS_DIR = os.path.join(BASE_DIR, "app", "data", "plots")
FEATURE_COLUMNS = ["jawaban_benar", "tingkat_kesulitan"]
TARGET_COLUMN = "kelulusan"
CV_FOLDS = 5
SCORING = ["accuracy", "precision", "recall", "f1"]

# Grid buat GridSearchCV. Silakan diperluas kalau mau coba kombinasi lain,
# tapi makin banyak kombinasi makin lama waktu training.
PARAM_GRID = {
    "C": [0.1, 1, 10, 100],
    "gamma": ["scale", "auto", 0.001, 0.01, 0.1],
    "kernel": ["rbf", "linear"],
    "class_weight": [None, "balanced"],
}


def load_data():
    """Gabungin dataset.csv (data awal) dengan hasil kuis siswa yang udah
    kesimpen di database (tabel quiz_results), supaya model retrain pakai
    data terbaru juga."""
    df_csv = pd.read_csv(DATA_PATH)

    db = SessionLocal()
    try:
        rows = db.query(QuizResult).all()
    finally:
        db.close()

    if rows:
        df_db = pd.DataFrame([
            {
                "total_soal": r.total_soal,
                "jawaban_benar": r.jawaban_benar,
                "skor_akhir": r.skor_akhir,
                "tingkat_kesulitan": r.tingkat_kesulitan,
                "persentase_benar": r.persentase_benar,
                "kelulusan": r.kelulusan,
            }
            for r in rows
        ])
        df = pd.concat([df_csv, df_db], ignore_index=True)
        print(f"Data dari database ikut digabung: {len(df_db)} baris baru.")
    else:
        df = df_csv
        print("Belum ada data baru di database, pakai dataset.csv saja.")

    X = df[FEATURE_COLUMNS]
    y = df[TARGET_COLUMN]
    return X, y


def tune_hyperparameters(X_scaled, y):
    """Cari kombinasi hyperparameter SVM terbaik pakai GridSearchCV,
    dievaluasi dengan StratifiedKFold + F1 score (lebih cocok buat data
    yang agak imbalance dibanding accuracy doang)."""
    skf = StratifiedKFold(n_splits=CV_FOLDS, shuffle=True, random_state=RANDOM_SEED)

    base_model = SVC(probability=True, random_state=RANDOM_SEED)
    grid = GridSearchCV(
        base_model,
        PARAM_GRID,
        cv=skf,
        scoring="f1",
        n_jobs=-1,
        refit=True,
    )
    grid.fit(X_scaled, y)

    print("\n" + "=" * 50)
    print("Hasil GridSearchCV")
    print("=" * 50)
    print(f"Best params : {grid.best_params_}")
    print(f"Best F1 (CV): {grid.best_score_:.4f}\n")

    return grid.best_params_, grid.best_score_


def run_cross_validation(name, model, X_scaled, y):
    skf = StratifiedKFold(n_splits=CV_FOLDS, shuffle=True, random_state=RANDOM_SEED)
    cv_results = cross_validate(model, X_scaled, y, cv=skf, scoring=SCORING)

    summary = {}
    lines = [f"\n{CV_FOLDS}-Fold Cross Validation - {name}\n{'-' * 40}"]
    for metric in SCORING:
        scores = cv_results[f"test_{metric}"]
        mean, std = scores.mean(), scores.std()
        summary[metric] = {"mean": mean, "std": std, "scores": scores.tolist()}
        lines.append(f"{metric.capitalize():<12}: {mean:.4f} (+/- {std:.4f})")

    text = "\n".join(lines) + "\n"
    print(text)
    return summary, text


def evaluate_holdout(name, model, X_test, y_test):
    y_pred = model.predict(X_test)

    acc = accuracy_score(y_test, y_pred)
    prec = precision_score(y_test, y_pred)
    rec = recall_score(y_test, y_pred)
    f1 = f1_score(y_test, y_pred)
    cm = confusion_matrix(y_test, y_pred)
    report = classification_report(y_test, y_pred, target_names=["Tidak Lulus", "Lulus"])

    text = (
        f"\n{'=' * 50}\n"
        f"Hold-out Test Set - {name}\n"
        f"{'=' * 50}\n"
        f"Accuracy  : {acc:.4f}\n"
        f"Precision : {prec:.4f}\n"
        f"Recall    : {rec:.4f}\n"
        f"F1-Score  : {f1:.4f}\n"
        f"\nConfusion Matrix:\n"
        f"                 Predicted Tidak Lulus  Predicted Lulus\n"
        f"Actual Tidak Lulus        {cm[0][0]:>6}                {cm[0][1]:>6}\n"
        f"Actual Lulus              {cm[1][0]:>6}                {cm[1][1]:>6}\n"
        f"\nClassification Report:\n{report}\n"
    )
    print(text)
    return {"accuracy": acc, "precision": prec, "recall": rec, "f1_score": f1, "cm": cm}, text


def plot_confusion_matrix(cm, save_path, labels=("Tidak Lulus", "Lulus")):
    fig, ax = plt.subplots(figsize=(6, 5))

    sns.heatmap(cm, annot=True, fmt='d', cmap='Greens',
                xticklabels=labels, yticklabels=labels, ax=ax, cbar=False)
    ax.set_title('Confusion Matrix - SVM')
    ax.set_xlabel('Predicted')
    ax.set_ylabel('Actual')

    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    plt.close(fig)
    print(f"Confusion matrix disimpan ke: {save_path}")


def plot_metrics(svm_holdout, save_path):
    metric_labels = ["Accuracy", "Precision", "Recall", "F1"]
    svm_values = [svm_holdout["accuracy"], svm_holdout["precision"], svm_holdout["recall"], svm_holdout["f1_score"]]

    x = np.arange(len(metric_labels))
    width = 0.5

    fig, ax = plt.subplots(figsize=(8, 6))
    bars = ax.bar(x, svm_values, width, label='SVM', color='#55A868')

    ax.set_ylabel('Score')
    ax.set_title('Metrik Hold-out Test: SVM')
    ax.set_xticks(x)
    ax.set_xticklabels(metric_labels)
    ax.set_ylim(0, 1.0)
    ax.legend()
    ax.grid(axis='y', linestyle='--', alpha=0.4)

    for bar in bars:
        height = bar.get_height()
        ax.annotate(f'{height:.4f}',
                    xy=(bar.get_x() + bar.get_width() / 2, height),
                    xytext=(0, 3), textcoords="offset points",
                    ha='center', va='bottom', fontsize=9)

    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    plt.close(fig)
    print(f"Bar chart disimpan ke: {save_path}")


def write_metrics_json(svm_model, svm_cv, svm_holdout, n_train, n_test, path):
    """Ditulis biar endpoint GET /api/model-metrics punya data buat di-serve
    ke layar 'Tentang Model AI' di Flutter (model_info_screen.dart)."""
    params = svm_model.get_params()
    data = {
        "dataset_size": n_train + n_test,
        "train_size": n_train,
        "test_size": n_test,
        "cv_folds": CV_FOLDS,
        "svm": {
            "cross_validation": {
                metric: {"mean": vals["mean"], "std": vals["std"]}
                for metric, vals in svm_cv.items()
            },
            "holdout": {
                "accuracy": svm_holdout["accuracy"],
                "precision": svm_holdout["precision"],
                "recall": svm_holdout["recall"],
                "f1_score": svm_holdout["f1_score"],
            },
            "params": {
                "kernel": params["kernel"],
                "C": params["C"],
                "gamma": params["gamma"],
                "class_weight": params["class_weight"],
            },
        },
    }
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
    print(f"model_metrics.json disimpan ke: {path}")


def main():
    os.makedirs(MODELS_DIR, exist_ok=True)
    os.makedirs(PLOTS_DIR, exist_ok=True)

    print("Memuat dataset (CSV + database)...")
    X, y = load_data()
    print(f"Total data: {len(X)} | Fitur yang dipakai: {FEATURE_COLUMNS}")

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=RANDOM_SEED, stratify=y
    )
    print(f"Data training: {len(X_train)} | Data testing: {len(X_test)}")

    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    X_full_scaled = scaler.transform(X)  # dipakai khusus untuk cross validation

    print("Mencari hyperparameter terbaik (GridSearchCV)...")
    best_params, best_cv_f1 = tune_hyperparameters(X_train_scaled, y_train)

    svm_model = SVC(
        probability=True,
        random_state=RANDOM_SEED,
        **best_params,
    )

    report_chunks = [
        f"\nHyperparameter terbaik (GridSearchCV, scoring=F1): {best_params}\n"
        f"Best CV F1 saat tuning: {best_cv_f1:.4f}\n"
    ]

    print("Menjalankan 5-Fold Cross Validation dengan parameter terbaik...")
    svm_cv, svm_cv_text = run_cross_validation("SVM", svm_model, X_full_scaled, y)
    report_chunks += [svm_cv_text]

    svm_model.fit(X_train_scaled, y_train)

    svm_holdout, svm_holdout_text = evaluate_holdout("SVM", svm_model, X_test_scaled, y_test)
    report_chunks += [svm_holdout_text]

    plot_confusion_matrix(
        svm_holdout["cm"],
        save_path=os.path.join(PLOTS_DIR, "confusion_matrix.png"),
    )
    plot_metrics(
        svm_holdout,
        save_path=os.path.join(PLOTS_DIR, "metrics.png"),
    )

    summary_text = (
        f"\n{'=' * 60}\n"
        f"RINGKASAN ({CV_FOLDS}-Fold Cross Validation) - SVM\n"
        f"{'=' * 60}\n"
        f"{'Metrik':<15}{'SVM':<25}\n"
        f"{'-' * 60}\n"
    )
    for metric in SCORING:
        svm_m = svm_cv[metric]
        summary_text += (
            f"{metric.capitalize():<15}"
            f"{svm_m['mean']:.4f} (+/- {svm_m['std']:.4f})\n"
        )

    print(summary_text)
    report_chunks.append(summary_text)

    svm_model.fit(X_full_scaled, y)

    joblib.dump(svm_model, os.path.join(MODELS_DIR, "svm_model.pkl"))
    joblib.dump(scaler, os.path.join(MODELS_DIR, "scaler.pkl"))

    with open(os.path.join(MODELS_DIR, "feature_columns.json"), "w") as f:
        json.dump(FEATURE_COLUMNS, f, indent=2)

    print(f"Model final (dilatih di seluruh data) tersimpan di: {MODELS_DIR}")

    write_metrics_json(
        svm_model, svm_cv, svm_holdout,
        n_train=len(X_train), n_test=len(X_test),
        path=METRICS_JSON_PATH,
    )

    with open(REPORT_PATH, "w", encoding="utf-8") as f:
        f.write("LAPORAN MODEL\n")
        f.write("Support Vector Machine (SVM)\n")
        f.write("Prediksi Kelulusan Peserta - WastraQuest\n")
        f.write(f"Fitur yang digunakan: {FEATURE_COLUMNS}\n")
        f.write("\n".join(report_chunks))

    print(f"Laporan tersimpan di: {REPORT_PATH}")


if __name__ == "__main__":
    main()