import 'package:flutter/material.dart';

void main() => runApp(const DailyJournalApp());

const Color kBackground = Color(0xFF0E0A2A);
const Color kCard = Color(0xFF1A1440);
const Color kPaper = Color(0xFFFFFDF9);
const Color kInk = Color(0xFF16112E);
const Color kPurple = Color(0xFF7B61FF);
const Color kMuted = Color(0xFF9C96C4);

const List<String> kMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

const List<String> kWeekdays = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

String fullDate(DateTime date) =>
    '${kWeekdays[date.weekday - 1]}, ${date.day} ${kMonths[date.month - 1]} ${date.year}';

String shortDate(DateTime date) =>
    '${date.day} ${kMonths[date.month - 1]} ${date.year}';

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String timeOf(DateTime date) {
  final h = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final m = date.minute.toString().padLeft(2, '0');
  return '$h:$m ${date.hour >= 12 ? 'PM' : 'AM'}';
}

class JournalEntry {
  JournalEntry({required this.createdAt, required this.text})
      : id = createdAt.microsecondsSinceEpoch;

  final int id;
  final DateTime createdAt;
  final String text;
}

class DailyJournalApp extends StatelessWidget {
  const DailyJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ColorScheme.fromSeed(
      seedColor: kPurple,
      brightness: Brightness.dark,
    );
    return MaterialApp(
      title: 'Daily Journal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: base.copyWith(
          primary: kPurple,
          surface: kBackground,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: kBackground,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF2A2260),
          contentTextStyle: TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<JournalEntry> _entries = [];

  Future<void> _write() async {
    final entry = await Navigator.of(context).push<JournalEntry>(
      MaterialPageRoute(builder: (_) => const EditorScreen()),
    );
    if (entry == null) return;
    setState(() => _entries.insert(0, entry));
  }

  Future<void> _delete(JournalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Delete entry?'),
        content: const Text(
          'This entry will be removed from your journal.',
          style: TextStyle(color: kMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: kMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF6B81))),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _entries.removeWhere((e) => e.id == entry.id));
  }

  Future<void> _open(JournalEntry entry) async {
    final deleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EntryScreen(entry: entry)),
    );
    if (deleted == true) {
      setState(() => _entries.removeWhere((e) => e.id == entry.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _write,
        backgroundColor: kPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_rounded),
        label: const Text(
          'Write',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(count: _entries.length)),
            if (_entries.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                sliver: SliverList.separated(
                  itemCount: _entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    return EntryCard(
                      entry: entry,
                      onTap: () => _open(entry),
                      onDelete: () => _delete(entry),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: kPurple,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: kPurple.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.menu_book_rounded, color: Colors.white),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Daily Journal',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            fullDate(DateTime.now()),
            style: const TextStyle(fontSize: 13, color: kMuted),
          ),
          const SizedBox(height: 6),
          Text(
            count == 0
                ? 'A blank page is waiting for you.'
                : '$count ${count == 1 ? 'entry' : 'entries'}',
            style: const TextStyle(fontSize: 13, color: kMuted),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: const Icon(
                Icons.auto_stories_outlined,
                size: 38,
                color: kPurple,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No entries yet',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Write down how your day went.\nTap Write to begin.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: kMuted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class EntryCard extends StatelessWidget {
  const EntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  final JournalEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final today = sameDay(entry.createdAt, DateTime.now());
    return Material(
      color: kPaper,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0ECFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      '${entry.createdAt.day}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: kPurple,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      kMonths[entry.createdAt.month - 1].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: kPurple,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          today ? 'Today' : shortDate(entry.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8B84B8),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '· ${timeOf(entry.createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFA9A3C9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.45,
                        color: kInk,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: const Color(0xFFB3ADCC),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something first')),
      );
      return;
    }
    Navigator.of(context).pop(
      JournalEntry(createdAt: DateTime.now(), text: text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackground,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'New entry',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                fullDate(DateTime.now()),
                style: const TextStyle(fontSize: 12.5, color: kMuted),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: kPaper,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focus,
                    autofocus: true,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    maxLength: 2000,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.55,
                      color: kInk,
                    ),
                    cursorColor: kPurple,
                    decoration: const InputDecoration(
                      counterStyle: TextStyle(
                        color: Color(0xFFA9A3C9),
                        fontSize: 11,
                      ),
                      border: InputBorder.none,
                      hintText: 'How was your day?',
                      hintStyle: TextStyle(color: Color(0xFFB3ADCC)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: kPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: const Text(
                    'Save entry',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key, required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackground,
        surfaceTintColor: Colors.transparent,
        title: Text(
          shortDate(entry.createdAt),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Delete entry',
            color: const Color(0xFFFF6B81),
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            Text(
              '${fullDate(entry.createdAt)} · ${timeOf(entry.createdAt)}',
              style: const TextStyle(fontSize: 12.5, color: kMuted),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: kPaper,
                borderRadius: BorderRadius.circular(22),
              ),
              padding: const EdgeInsets.all(20),
              child: SelectableText(
                entry.text,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: kInk,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
