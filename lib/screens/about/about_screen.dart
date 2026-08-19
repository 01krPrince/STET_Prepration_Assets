import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../repositories/content_repository.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _open(BuildContext context, String url) async {
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = ContentRepository.instance.examInfo;

    return Scaffold(
      appBar: AppBar(title: const Text('About & Exam Info')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Exam Information', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 10),
                  _row('Exam', info.examName),
                  _row('Conducting Body', info.conductingBody),
                  _row('Mode', info.mode),
                  _row('Duration', info.duration),
                  _row('Total Questions', '${info.totalQuestions}'),
                  _row('Total Marks', '${info.totalMarks}'),
                  _row('Section A', '${info.sectionAName} — ${info.sectionAQuestions} Qs'),
                  _row('Section B', '${info.sectionBName} — ${info.sectionBQuestions} Qs'),
                  _row('Negative Marking', info.negativeMarking),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(8)),
                    child: Text(info.subjectCodeNote, style: const TextStyle(fontSize: 12, height: 1.4)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                    child: Text(info.verificationStatus, style: const TextStyle(fontSize: 11.5, height: 1.4, color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 12),
                  const Text('Prince Kumar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const Text('B.Tech Computer Science', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _open(context, 'https://linkedin.com/in/01krprince'),
                          icon: const Icon(Icons.link, size: 18),
                          label: const Text('LinkedIn'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _open(context, 'https://01krprince.netlify.app/'),
                          icon: const Icon(Icons.language, size: 18),
                          label: const Text('Portfolio'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Bihar STET 2026 • Paper 2 • Computer Science\nOffline Study App',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 110, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5))),
            Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5))),
          ],
        ),
      );
}
