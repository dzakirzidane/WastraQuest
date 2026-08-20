import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';


class ModelInfoScreen extends StatefulWidget {
  const ModelInfoScreen({super.key});
  
  @override
  State<ModelInfoScreen> createState() => _ModelInfoScreenState();
}

class _ModelInfoScreenState extends State<ModelInfoScreen> {
  static const String _baseUrl = 'https://wastraquest-production.up.railway.app';
  static const _svmColor = Color(0xFF1565C0);

  late Future<Map<String, dynamic>> _metricsFuture;

  @override
  void initState() {
    super.initState();
    _metricsFuture = _fetchMetrics();
  }

  Future<Map<String, dynamic>> _fetchMetrics() async {
    final res = await http
        .get(Uri.parse('$_baseUrl/api/model-metrics'))
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil data metrics (status ${res.statusCode})');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }

  void _retry() {
    setState(() {
      _metricsFuture = _fetchMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Model AI'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _metricsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 40, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text(
                      'Gagal memuat data model dari server.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.white60),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          return _buildContent(data);
        },
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    final svm = data['svm'] as Map<String, dynamic>;

    final svmCv = svm['cross_validation'] as Map<String, dynamic>;
    final svmHoldout = svm['holdout'] as Map<String, dynamic>;

    List<double> cvValues(Map<String, dynamic> cv) => [
          (cv['accuracy']['mean'] as num).toDouble(),
          (cv['precision']['mean'] as num).toDouble(),
          (cv['recall']['mean'] as num).toDouble(),
          (cv['f1']['mean'] as num).toDouble(),
        ];

    List<double> holdoutValues(Map<String, dynamic> h) => [
          (h['accuracy'] as num).toDouble(),
          (h['precision'] as num).toDouble(),
          (h['recall'] as num).toDouble(),
          (h['f1_score'] as num).toDouble(),
        ];

    final svmParams = svm['params'] as Map<String, dynamic>;
    final datasetSize = data['dataset_size'];
    final trainSize = data['train_size'];
    final testSize = data['test_size'];
    final cvFolds = data['cv_folds'];
    final cvAccuracy = (svmCv['accuracy']['mean'] as num).toDouble();

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _metricsFuture = _fetchMetrics();
        });
        await _metricsFuture;
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Bagaimana Sistem Ini Menilai Kelulusan?'),
            const SizedBox(height: 8),
            Text(
              'Sistem menggunakan algoritma machine learning Support Vector '
              'Machine (SVM) untuk memprediksi kelulusan peserta berdasarkan '
              'jumlah jawaban benar dan tingkat kesulitan soal. Model ini '
              'dilatih dan dievaluasi pada $datasetSize data ($trainSize '
              'untuk training dan $testSize untuk pengujian), dan terus '
              'diperbarui seiring bertambahnya data hasil kuis peserta.',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),

            _modelCard(
              title: 'Support Vector Machine (SVM)',
              color: _svmColor,
              description:
                  'SVM bekerja dengan mencari garis pemisah (hyperplane) '
                  'terbaik yang memaksimalkan jarak antara kelompok "Lulus" '
                  'dan "Tidak Lulus". Model ini menggunakan kernel RBF '
                  'sehingga mampu menangkap pola hubungan non-linear antara '
                  'jawaban benar dan tingkat kesulitan soal.',
              params: [
                'Kernel: ${svmParams['kernel']}',
                'C = ${svmParams['C']}, gamma = ${svmParams['gamma']}',
              ],
            ),

            const SizedBox(height: 32),
            _sectionTitle('Kinerja Model — $cvFolds-Fold Cross Validation'),
            const SizedBox(height: 4),
            const Text(
              'Rata-rata skor dari beberapa kali pengujian silang pada seluruh data.',
              style: TextStyle(fontSize: 12, color: Colors.white60),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: _MetricBarChart(
                values: cvValues(svmCv),
                color: _svmColor,
              ),
            ),

            const SizedBox(height: 32),
            _sectionTitle('Kinerja Model — Hold-out Test Set'),
            const SizedBox(height: 4),
            Text(
              'Skor pada $testSize data uji yang tidak dilihat model saat training.',
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: _MetricBarChart(
                values: holdoutValues(svmHoldout),
                color: _svmColor,
              ),
            ),

            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 20, color: Colors.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Rata-rata akurasi model saat ini adalah '
                      '${(cvAccuracy * 100).toStringAsFixed(1)}% (cross-validation). '
                      'Data ini diambil langsung dari hasil training terakhir '
                      'di server.',
                      style: const TextStyle(fontSize: 12.5, height: 1.4, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      );

  Widget _modelCard({
    required String title,
    required Color color,
    required String description,
    required List<String> params,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(description, style: const TextStyle(fontSize: 13.5, height: 1.5, color: Colors.black87)),
          const SizedBox(height: 10),
          ...params.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 5, color: Colors.black45),
                  const SizedBox(width: 6),
                  Text(p, style: const TextStyle(fontSize: 12.5, color: Colors.black87)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBarChart extends StatelessWidget {
  const _MetricBarChart({
    required this.values,
    required this.color,
  });

  final List<double> values;
  final Color color;

  static const _labels = ['Accuracy', 'Precision', 'Recall', 'F1-Score'];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: 1.0,
        minY: 0,
        gridData: const FlGridData(
          show: true,
          horizontalInterval: 0.2,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: 0.2,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(1),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= _labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_labels[i], style: const TextStyle(fontSize: 10.5)),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toStringAsFixed(4),
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
              );
            },
          ),
        ),
        barGroups: List.generate(_labels.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],
                color: color,
                width: 22,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
              ),
            ],
          );
        }),
      ),
    );
  }
}