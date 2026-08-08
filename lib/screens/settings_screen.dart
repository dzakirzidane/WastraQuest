import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';
import '../services/audio_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _audioService.init();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 16),
              const Text(
                'Pengaturan',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Atur preferensi aplikasi',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),

              // Profile Section
              if (user != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1F26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_rounded,
                        size: 40,
                        color: Color(0xFFD4AF37),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total Skor: ${user.totalScore}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Audio Settings
              const _SectionTitle('Audio'),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.music_note_rounded,
                title: 'Musik Latar',
                subtitle: 'Musik tradisional saat bermain',
                trailing: Switch(
                  value: _audioService.isMusicEnabled,
                  onChanged: (value) async {
                    await _audioService.toggleMusic();
                    setState(() {}); // Refresh UI
                  },
                  activeTrackColor: const Color(0xFFD4AF37),
                ),
              ),
              _SettingsTile(
                icon: Icons.volume_up_rounded,
                title: 'Efek Suara',
                subtitle: 'Suara saat menjawab pertanyaan',
                trailing: Switch(
                  value: _audioService.isSfxEnabled,
                  onChanged: (value) async {
                    await _audioService.toggleSfx();
                    setState(() {}); // Refresh UI
                  },
                  activeTrackColor: const Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(height: 24),

              // Data Settings
              const _SectionTitle('Data'),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.refresh_rounded,
                title: 'Reset Progress',
                subtitle: 'Hapus semua skor dan statistik',
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1F26),
                      title: const Text(
                        'Reset Progress?',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'Semua skor dan statistik akan dihapus. Tindakan ini tidak dapat dibatalkan.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Reset',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    await ref.read(userProvider.notifier).resetProgress();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Progress berhasil direset'),
                          backgroundColor: Color(0xFFD4AF37),
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 24),

              // About
              const _SectionTitle('Tentang'),
              const SizedBox(height: 12),
              const _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'Versi Aplikasi',
                subtitle: '1.0.0',
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Tentang WastraQuest',
                subtitle: 'Jelajahi kekayaan budaya Indonesia',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1F26),
                      title: const Text(
                        'WastraQuest',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: const Text(
                        'Aplikasi kuis interaktif untuk mempelajari pakaian adat tradisional Indonesia dari berbagai daerah.\n\nMari lestarikan budaya Indonesia!',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Tutup',
                            style: TextStyle(color: Color(0xFFD4AF37)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.analytics_outlined,
                title: 'Tentang Model',
                subtitle: 'Perbandingan akurasi Random Forest vs SVM',
                onTap: () {
                  context.push('/model-info');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFFD4AF37),
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: const Color(0xFFD4AF37),
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        trailing: trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}