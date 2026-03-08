import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/diary_note.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/snack.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _dateCtrl = TextEditingController();
  DateTime _date = FirestoreService.normalizeDate(DateTime.now());

  int _month = DateTime.now().month;
  int _year = DateTime.now().year;
  String _tag = 'Special';

  DiaryNote? _byDate;
  List<DiaryNote> _list = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = DateFormat('yyyy-MM-dd').format(_date);
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchByDate() async {
    final uid = AuthService.instance.currentUser!.uid;
    setState(() => _loading = true);
    try {
      final note = await FirestoreService.instance.getDiaryNoteForDay(userId: uid, day: _date);
      setState(() {
        _byDate = note;
        _list = const [];
      });
      if (note == null && mounted) showSnack(context, 'No note found for that date.');
    } catch (e) {
      if (mounted) showSnack(context, 'Search failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _searchByMonthYear() async {
    final uid = AuthService.instance.currentUser!.uid;
    setState(() => _loading = true);
    try {
      final list = await FirestoreService.instance.listNotesByMonth(
        userId: uid,
        year: _year,
        month: _month,
      );
      setState(() {
        _byDate = null;
        _list = list;
      });
      if (list.isEmpty && mounted) showSnack(context, 'No notes for $_month/$_year.');
    } catch (e) {
      if (mounted) showSnack(context, 'Search failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _searchByTag() async {
    final uid = AuthService.instance.currentUser!.uid;
    setState(() => _loading = true);
    try {
      final list = await FirestoreService.instance.listNotesByTag(userId: uid, tag: _tag);
      setState(() {
        _byDate = null;
        _list = list;
      });
      if (list.isEmpty && mounted) showSnack(context, 'No notes tagged "$_tag".');
    } catch (e) {
      if (mounted) showSnack(context, 'Search failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyDateText() {
    final raw = _dateCtrl.text.trim();
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      showSnack(context, 'Use date format: yyyy-MM-dd');
      return;
    }
    setState(() => _date = FirestoreService.normalizeDate(parsed));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Search',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'By date (editable)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _dateCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Date (yyyy-MM-dd)',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    onChanged: (_) => _applyDateText(),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Search by Date',
                    onPressed: _loading ? null : _searchByDate,
                    icon: Icons.search,
                  ),
                  if (_byDate != null) ...[
                    const SizedBox(height: 12),
                    _NoteCard(note: _byDate!),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'By month/year (view list only)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _month,
                          decoration: const InputDecoration(labelText: 'Month'),
                          items: List.generate(
                            12,
                            (i) => DropdownMenuItem(
                              value: i + 1,
                              child: Text('${i + 1}'),
                            ),
                          ),
                          onChanged: (v) => setState(() => _month = v ?? _month),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _year,
                          decoration: const InputDecoration(labelText: 'Year'),
                          items: List.generate(
                            6,
                            (i) => DropdownMenuItem(
                              value: DateTime.now().year - i,
                              child: Text('${DateTime.now().year - i}'),
                            ),
                          ),
                          onChanged: (v) => setState(() => _year = v ?? _year),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Search by Month/Year',
                    onPressed: _loading ? null : _searchByMonthYear,
                    icon: Icons.list,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'By tag',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _tag,
                    decoration: const InputDecoration(
                      labelText: 'Tag',
                      prefixIcon: Icon(Icons.local_offer),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Special', child: Text('Special')),
                      DropdownMenuItem(value: 'Important', child: Text('Important')),
                      DropdownMenuItem(value: 'Bad News', child: Text('Bad News')),
                    ],
                    onChanged: (v) => setState(() => _tag = v ?? _tag),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Search by Tag',
                    onPressed: _loading ? null : _searchByTag,
                    icon: Icons.filter_alt,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_loading) const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
          if (!_loading && _list.isNotEmpty) ...[
            Text('Results (${_list.length})', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final n in _list) _NoteCard(note: n),
          ],
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});
  final DiaryNote note;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(note.date.toDate());
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    dateStr,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(label: Text(note.tag.isEmpty ? 'No tag' : note.tag)),
              ],
            ),
            const SizedBox(height: 8),
            Text(note.text),
          ],
        ),
      ),
    );
  }
}

