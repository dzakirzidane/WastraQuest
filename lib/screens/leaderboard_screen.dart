import 'package:flutter/material.dart';
import '../models/leaderboard_entry.dart';
import '../services/leaderboard_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = LeaderboardService();

  // index tab -> tingkat_kesulitan (null = semua)
  static const List<int?> _difficultyPerTab = [null, 1, 2, 3];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1419),
        elevation: 0,
        title: const Text(
          'Papan Peringkat',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFD4AF37),
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: 'SEMUA'),
            Tab(text: 'MUDAH'),
            Tab(text: 'SEDANG'),
            Tab(text: 'SULIT'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _difficultyPerTab
            .map((difficulty) => _LeaderboardList(
                  service: _service,
                  tingkatKesulitan: difficulty,
                ))
            .toList(),
      ),
    );
  }
}

class _LeaderboardList extends StatefulWidget {
  const _LeaderboardList({required this.service, required this.tingkatKesulitan});

  final LeaderboardService service;
  final int? tingkatKesulitan;

  @override
  State<_LeaderboardList> createState() => _LeaderboardListState();
}

class _LeaderboardListState extends State<_LeaderboardList> {
  late Future<List<LeaderboardEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.service.fetchLeaderboard(tingkatKesulitan: widget.tingkatKesulitan);
  }

  void _reload() {
    setState(() {
      _future = widget.service.fetchLeaderboard(tingkatKesulitan: widget.tingkatKesulitan);
    });
  }

  static const _difficultyColors = {
    1: Color(0xFF2ECC71), // easy
    2: Color(0xFFF39C12), // medium
    3: Color(0xFFE74C3C), // hard
  };
  static const _difficultyLabels = {1: 'Mudah', 2: 'Sedang', 3: 'Sulit'};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LeaderboardEntry>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off, size: 40, color: Colors.white.withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text(
                    'Gagal memuat papan peringkat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _reload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0B1320),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        final entries = snapshot.data ?? [];

        if (entries.isEmpty) {
          return RefreshIndicator(
            color: const Color(0xFFD4AF37),
            backgroundColor: const Color(0xFF1A1F26),
            onRefresh: () async => _reload(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Center(
                    child: Text(
                      'Belum ada peserta di papan ini.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFFD4AF37),
          backgroundColor: const Color(0xFF1A1F26),
          onRefresh: () async => _reload(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: entries.length,
            itemBuilder: (context, index) => _LeaderboardTile(
              entry: entries[index],
              difficultyColor: _difficultyColors[entries[index].tingkatKesulitan],
              difficultyLabel: _difficultyLabels[entries[index].tingkatKesulitan],
              showDifficultyBadge: widget.tingkatKesulitan == null,
            ),
          ),
        );
      },
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({
    required this.entry,
    required this.difficultyColor,
    required this.difficultyLabel,
    required this.showDifficultyBadge,
  });

  final LeaderboardEntry entry;
  final Color? difficultyColor;
  final String? difficultyLabel;
  final bool showDifficultyBadge;

  static const _medalColors = {
    1: Color(0xFFD4AF37), // gold
    2: Color(0xFFC0C0C0), // silver
    3: Color(0xFFCD7F32), // bronze
  };

  @override
  Widget build(BuildContext context) {
    final isTopThree = entry.peringkat <= 3;
    final medalColor = _medalColors[entry.peringkat];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F26),
        borderRadius: BorderRadius.circular(14),
        border: isTopThree
            ? Border.all(color: medalColor!.withValues(alpha: 0.5), width: 1)
            : null,
        boxShadow: isTopThree
            ? [
                BoxShadow(
                  color: medalColor!.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTopThree
                  ? medalColor!.withValues(alpha: 0.15)
                  : const Color(0xFF232930),
            ),
            child: Center(
              child: isTopThree
                  ? Icon(Icons.emoji_events, color: medalColor, size: 18)
                  : Text(
                      '${entry.peringkat}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Name + difficulty badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.namaSiswa,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (showDifficultyBadge && difficultyLabel != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: difficultyColor?.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      difficultyLabel!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: difficultyColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.skorAkhir}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                ),
              ),
              Text(
                '${entry.persentaseBenar.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}