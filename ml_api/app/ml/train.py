import os
import json
import joblib
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split, StratifiedKFold, cross_validate
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.svm import SVC
from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    confusion_matrix,
    classification_report,
)

RANDOM_SEED = 42

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
DATA_PATH = os.path.join(BASE_DIR, "app", "data", "dataset.csv")
MODELS_DIR = os.path.join(BASE_DIR, "saved_models")
REPORT_PATH = os.path.join(BASE_DIR, "app", "data", "model_comparison_report.txt")
FEATURE_COLUMNS = ["jawaban_benar", "tingkat_kesulitan"]
TARGET_COLUMN = "kelulusan"
CV_FOLDS = 5
SCORING = ["accuracy", "precision", "recall", "f1"]


def load_data():
    df = pd.read_csv(DATA_PATH)
    X = df[FEATURE_COLUMNS]
    y = df[TARGET_COLUMN]
    return X, y


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
    return {"accuracy": acc, "precision": prec, "recall": rec, "f1_score": f1}, text


def main():
    os.makedirs(MODELS_DIR, exist_ok=True)

    print("Memuat dataset...")
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

    rf_model = RandomForestClassifier(n_estimators=100, random_state=RANDOM_SEED)
    svm_model = SVC(kernel="rbf", C=1.0, gamma="scale", probability=True, random_state=RANDOM_SEED)

    report_chunks = []

    print("Menjalankan 5-Fold Cross Validation...")
    rf_cv, rf_cv_text = run_cross_validation("Random Forest", rf_model, X_full_scaled, y)
    svm_cv, svm_cv_text = run_cross_validation("SVM", svm_model, X_full_scaled, y)
    report_chunks += [rf_cv_text, svm_cv_text]

    rf_model.fit(X_train_scaled, y_train)
    svm_model.fit(X_train_scaled, y_train)

    rf_holdout, rf_holdout_text = evaluate_holdout("Random Forest", rf_model, X_test_scaled, y_test)
    svm_holdout, svm_holdout_text = evaluate_holdout("SVM", svm_model, X_test_scaled, y_test)
    report_chunks += [rf_holdout_text, svm_holdout_text]

    comparison_text = (
        f"\n{'=' * 60}\n"
        f"RINGKASAN PERBANDINGAN (rata-rata {CV_FOLDS}-Fold Cross Validation)\n"
        f"{'=' * 60}\n"
        f"{'Metrik':<15}{'Random Forest':<25}{'SVM':<25}\n"
        f"{'-' * 60}\n"
    )
    for metric in SCORING:
        rf_m = rf_cv[metric]
        svm_m = svm_cv[metric]
        comparison_text += (
            f"{metric.capitalize():<15}"
            f"{rf_m['mean']:.4f} (+/- {rf_m['std']:.4f})    "
            f"{svm_m['mean']:.4f} (+/- {svm_m['std']:.4f})\n"
        )

    print(comparison_text)

    winner = "Random Forest" if rf_cv["accuracy"]["mean"] >= svm_cv["accuracy"]["mean"] else "SVM"
    winner_line = f"Model dengan rata-rata accuracy CV lebih tinggi: {winner}\n"
    print(winner_line)
    report_chunks.append(comparison_text + "\n" + winner_line)
    rf_model.fit(X_full_scaled, y)
    svm_model.fit(X_full_scaled, y)

    joblib.dump(rf_model, os.path.join(MODELS_DIR, "random_forest_model.pkl"))
    joblib.dump(svm_model, os.path.join(MODELS_DIR, "svm_model.pkl"))
    joblib.dump(scaler, os.path.join(MODELS_DIR, "scaler.pkl"))

    with open(os.path.join(MODELS_DIR, "feature_columns.json"), "w") as f:
        json.dump(FEATURE_COLUMNS, f, indent=2)

    print(f"Model final (dilatih di seluruh data) tersimpan di: {MODELS_DIR}")

    with open(REPORT_PATH, "w", encoding="utf-8") as f:
        f.write("LAPORAN PERBANDINGAN MODEL\n")
        f.write("Random Forest vs Support Vector Machine (SVM)\n")
        f.write("Prediksi Kelulusan Peserta - WastraQuest\n")
        f.write(f"Fitur yang digunakan: {FEATURE_COLUMNS}\n")
        f.write("\n".join(report_chunks))

    print(f"Laporan tersimpan di: {REPORT_PATH}")


if __name__ == "__main__":
    main()