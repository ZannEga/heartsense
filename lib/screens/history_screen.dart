import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = LocalStorageService.getHistory();
  }

  void _reload() {
    setState(() {
      _historyFuture = LocalStorageService.getHistory();
    });
  }

  Future<void> _confirmClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text(
            'This permanently deletes all past assessment results on this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear',
                style: TextStyle(color: AppColors.riskOrange)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await LocalStorageService.clearHistory();
      _reload();
    }
  }

  Color _riskColor(double percent) {
    if (percent >= 60) return AppColors.riskOrange;
    if (percent >= 30) return const Color(0xFFD9A400);
    return AppColors.tagGreenText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Assessment History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear history',
            onPressed: _confirmClearHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final entries = snapshot.data!;
            if (entries.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No assessments yet. Results are saved here automatically '
                    'every time you generate a prediction.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.subtitleGray),
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final e = entries[index];
                final percent = (e['percent'] as num).toDouble();
                final rawScore = (e['rawScore'] as num).toDouble();
                final model = e['model'] as String;
                final label = e['label'] as String;
                final timestamp = DateTime.tryParse(e['timestamp'] as String);
                final color = _riskColor(percent);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderGray),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Text('${percent.round()}%',
                            style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w800,
                                fontSize: 13)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(model,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.navy)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(label,
                                      style: TextStyle(
                                          color: color,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timestamp != null
                                  ? DateFormatUtil.format(timestamp)
                                  : 'Unknown date',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.subtitleGray),
                            ),
                            Text('Raw score: ${rawScore.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.subtitleGray)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
