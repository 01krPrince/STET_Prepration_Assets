import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';

class _Resource {
  final String title;
  final String url;
  final String note;
  const _Resource(this.title, this.url, this.note);
}

class _UnitResources {
  final String unitTitle;
  final List<_Resource> resources;
  const _UnitResources(this.unitTitle, this.resources);
}

/// Curated list of FREE, LEGALLY ACCESSIBLE study hubs (official docs, NPTEL,
/// GeeksforGeeks tutorial hubs, W3Schools) — no paywalled or login-gated
/// content, per the app's strict free/legal resource rule. These open in the
/// external browser and require internet; they supplement, but are not part
/// of, the app's offline core (notes/questions/practice/mock/search/bookmarks).
const List<_UnitResources> _library = [
  _UnitResources('Official / Government', [
    _Resource('NPTEL — Free IIT/IISc Courses', 'https://nptel.ac.in', 'Search for Computer Science courses relevant to each unit below.'),
    _Resource('BSEB STET Official Portal', 'https://bsebstet.org', 'Always cross-check the latest 2026 notification and syllabus here.'),
  ]),
  _UnitResources('Digital Logic', [
    _Resource('GeeksforGeeks — Digital Logic Design', 'https://www.geeksforgeeks.org/digital-logic/digital-electronics-logic-design-tutorials/', 'Number systems, gates, K-maps, flip-flops.'),
  ]),
  _UnitResources('Computer Organization & Architecture', [
    _Resource('GeeksforGeeks — Digital Electronics & COA', 'https://www.geeksforgeeks.org/digital-electronics-and-computer-organisation/', 'CPU organisation, memory, addressing modes.'),
  ]),
  _UnitResources('Programming & Data Structures / Algorithms', [
    _Resource('GeeksforGeeks — DSA Tutorial', 'https://www.geeksforgeeks.org/dsa/dsa-tutorial-learn-data-structures-and-algorithms/', 'Arrays, lists, trees, graphs, sorting, complexity.'),
  ]),
  _UnitResources('Operating System', [
    _Resource('GeeksforGeeks — Operating Systems', 'https://www.geeksforgeeks.org/operating-systems/operating-systems/', 'Processes, scheduling, deadlock, memory, files.'),
  ]),
  _UnitResources('Database Management System', [
    _Resource('GeeksforGeeks — DBMS Tutorial', 'https://www.geeksforgeeks.org/dbms/dbms/', 'ER model, normalization, transactions.'),
  ]),
  _UnitResources('Computer Networks', [
    _Resource('GeeksforGeeks — Computer Networks', 'https://www.geeksforgeeks.org/computer-networks/computer-network-tutorials/', 'OSI/TCP-IP, routing, protocols.'),
  ]),
  _UnitResources('Theory of Computation', [
    _Resource('GeeksforGeeks — Theory of Computation', 'https://www.geeksforgeeks.org/theory-of-computation/theory-of-computation-automata-tutorials/', 'Automata, CFG, Turing machines.'),
  ]),
  _UnitResources('Web-Based Application Development', [
    _Resource('W3Schools — HTML/CSS/JS', 'https://www.w3schools.com', 'Free, beginner-friendly reference for all front-end basics.'),
  ]),
  _UnitResources('Software Engineering, OOP, IoT, AI, E-Commerce, Multimedia', [
    _Resource('NPTEL Course Search', 'https://nptel.ac.in', 'Search each topic name — free video lectures from IITs/IISc.'),
    _Resource('GeeksforGeeks — Browse All Topics', 'https://www.geeksforgeeks.org/', 'Search the unit/topic name for a free written tutorial.'),
  ]),
];

class PdfLibraryScreen extends StatelessWidget {
  const PdfLibraryScreen({super.key});

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF & Resource Library')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(10)),
            child: const Text(
              'These are free, publicly accessible resources — no login or paywall. '
              'They open in your browser and need internet. Your Notes, Questions, '
              'Practice, Mock Tests, Bookmarks and Search all work fully offline without these.',
              style: TextStyle(fontSize: 12.5, height: 1.4),
            ),
          ),
          ..._library.map((group) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.unitTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary)),
                    const SizedBox(height: 8),
                    ...group.resources.map((r) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.link, color: AppColors.accent),
                            title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                            subtitle: Text(r.note, style: const TextStyle(fontSize: 12)),
                            trailing: const Icon(Icons.open_in_new, size: 18),
                            onTap: () => _open(context, r.url),
                          ),
                        )),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
