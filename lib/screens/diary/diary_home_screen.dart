import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/snack.dart';

class DiaryHomeScreen extends StatefulWidget {
  const DiaryHomeScreen({super.key});

  @override
  State<DiaryHomeScreen> createState() => _DiaryHomeScreenState();
}

class _DiaryHomeScreenState extends State<DiaryHomeScreen> {
  final _textCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String _tag = 'Special';
  final DateTime _today = FirestoreService.normalizeDate(DateTime.now());

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final uid = AuthService.instance.currentUser!.uid;
      final note = await FirestoreService.instance.getDiaryNoteForDay(userId: uid, day: _today);
      if (note != null) {
        _textCtrl.text = note.text;
        _tag = note.tag.isNotEmpty ? note.tag : _tag;
      }
    } catch (e) {
      if (mounted) showSnack(context, 'Failed to load note: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final uid = AuthService.instance.currentUser!.uid;
    final text = _textCtrl.text.trim();
    if (text.isEmpty) {
      showSnack(context, 'Write something first.');
      return;
    }
    setState(() => _saving = true);
    try {
      await FirestoreService.instance.upsertDiaryNoteForDay(
        userId: uid,
        day: _today,
        text: text,
        tag: _tag,
      );
      if (mounted) showSnack(context, 'Saved');
    } catch (e) {
      if (mounted) showSnack(context, 'Save failed: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(_today);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Today's Note ($dateStr)",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Reload',
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                ),
              ],
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
            Expanded(
              child: TextField(
                controller: _textCtrl,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Diary text',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Save / Update',
              icon: Icons.save,
              isLoading: _saving,
              onPressed: _save,
            ),
            const SizedBox(height: 8),
            Text(
              'Notes cannot be deleted (only edited).',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

