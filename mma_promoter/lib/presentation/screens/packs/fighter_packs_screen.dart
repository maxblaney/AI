import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../../domain/packs/fighter_pack.dart';
import '../../state/game_controller.dart';
import '../../widgets/fighter_avatar.dart';

/// Manage the player's fighter packs: build one out of fighters they
/// have, bring one in from somebody else, and push either into the open
/// save.
class FighterPacksScreen extends StatefulWidget {
  const FighterPacksScreen({super.key});

  @override
  State<FighterPacksScreen> createState() => _FighterPacksScreenState();
}

class _FighterPacksScreenState extends State<FighterPacksScreen> {
  late Future<List<FighterPack>> _packs;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _packs = context.read<GameController>().listPacks();
  }

  void _say(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final hasSave = controller.organization != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Fighter Packs')),
      body: FutureBuilder<List<FighterPack>>(
        future: _packs,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final packs = snapshot.data ?? const <FighterPack>[];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'A pack is a group of fighters that lives outside your '
                'saves. Build one from a roster, import it into whichever '
                'promotions you like, and share the code with someone '
                'else so they can use the same fighters.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.group_add),
                      label: const Text('Build a pack'),
                      onPressed: hasSave ? _buildPack : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Paste a code'),
                      onPressed: _importCode,
                    ),
                  ),
                ],
              ),
              if (!hasSave)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Open a save to build a pack from its fighters. '
                    'Pasting a code works either way.',
                  ),
                ),
              const SizedBox(height: 24),
              if (packs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('No packs yet.', textAlign: TextAlign.center),
                ),
              for (final pack in packs)
                _PackCard(
                  pack: pack,
                  canImport: hasSave,
                  onAdd: () => _addToSave(pack),
                  onShare: () => _share(pack),
                  onDelete: () => _confirmDelete(pack),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _buildPack() async {
    final controller = context.read<GameController>();
    // Everyone in the save, roster and talent pool alike — a pack is
    // built out of whoever you like, not only whoever you signed.
    final candidates = [
      ...controller.signedRoster,
      ...controller.talentPool,
    ]..sort((a, b) => a.name.compareTo(b.name));

    if (candidates.isEmpty) {
      _say('There are no fighters in this save to build a pack from.');
      return;
    }

    final picked = await showDialog<Set<String>>(
      context: context,
      builder: (_) => _PickFightersDialog(candidates: candidates),
    );
    if (picked == null || picked.isEmpty || !mounted) return;

    final details = await showDialog<_PackDetails>(
      context: context,
      builder: (_) => const _PackDetailsDialog(),
    );
    if (details == null || !mounted) return;

    final pack = await controller.createPack(
      name: details.name,
      description: details.description,
      author: details.author,
      fighters: [
        for (final fighter in candidates)
          if (picked.contains(fighter.id)) fighter,
      ],
    );
    if (!mounted) return;
    setState(_reload);
    _say('Saved "${pack.name}" — ${pack.summary}.');
  }

  Future<void> _importCode() async {
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const _PasteCodeDialog(),
    );
    if (code == null || !mounted) return;

    final controller = context.read<GameController>();
    try {
      final pack = await controller.importPackCode(code);
      if (!mounted) return;
      setState(_reload);
      _say('Imported "${pack.name}" — ${pack.summary}.');
    } on FighterPackFormatException catch (e) {
      _say(e.message);
    }
  }

  Future<void> _addToSave(FighterPack pack) async {
    final controller = context.read<GameController>();
    final added = await controller.addPackToSave(pack);
    if (!mounted) return;
    _say(added == 0
        ? 'Open a save first.'
        : '$added fighter${added == 1 ? '' : 's'} added to the talent pool.');
  }

  Future<void> _share(FighterPack pack) async {
    final code = context.read<GameController>().sharePackCode(pack);
    // The dialog opens first and copies for itself. Awaiting the
    // clipboard here would put a permission the browser may never
    // answer between the player and their own pack code — and the code
    // is selectable in the dialog, so there is always a way through.
    await showDialog<void>(
      context: context,
      builder: (_) => _ShareCodeDialog(pack: pack, code: code),
    );
  }

  Future<void> _confirmDelete(FighterPack pack) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${pack.name}?'),
        content: const Text(
          'This removes the pack. Fighters already imported into a save '
          'stay where they are.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<GameController>().deletePack(pack.id);
    if (!mounted) return;
    setState(_reload);
  }
}

/// Puts [text] on the clipboard, reporting whether it landed.
///
/// Writing to the clipboard is a permission on the web and can simply be
/// refused. Nothing here should break when it is.
Future<bool> copyToClipboard(String text) async {
  try {
    await Clipboard.setData(ClipboardData(text: text));
    return true;
  } catch (_) {
    return false;
  }
}

class _PackCard extends StatelessWidget {
  final FighterPack pack;
  final bool canImport;
  final VoidCallback onAdd;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _PackCard({
    required this.pack,
    required this.canImport,
    required this.onAdd,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      pack.summary,
      if (pack.author.isNotEmpty) 'by ${pack.author}',
    ].join(' · ');

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(pack.name),
            subtitle: Text(subtitle),
          ),
          if (pack.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                pack.description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  onPressed: onDelete,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.ios_share, size: 18),
                  label: const Text('Share code'),
                  onPressed: onShare,
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.person_add_alt, size: 18),
                  label: const Text('Add to save'),
                  onPressed: canImport ? onAdd : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ticks whichever fighters go in the pack.
class _PickFightersDialog extends StatefulWidget {
  final List<Fighter> candidates;

  const _PickFightersDialog({required this.candidates});

  @override
  State<_PickFightersDialog> createState() => _PickFightersDialogState();
}

class _PickFightersDialogState extends State<_PickFightersDialog> {
  final Set<String> _picked = {};
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final query = _search.toLowerCase();
    final matches = _search.isEmpty
        ? widget.candidates
        : widget.candidates
            .where((f) =>
                f.name.toLowerCase().contains(query) ||
                f.weightClass.label.toLowerCase().contains(query))
            .toList();

    return AlertDialog(
      title: Text('Pick fighters (${_picked.length})'),
      content: SizedBox(
        width: 400,
        height: 420,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: matches.isEmpty
                  ? const Center(child: Text('Nobody matches that.'))
                  : ListView.builder(
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final fighter = matches[index];
                        return CheckboxListTile(
                          dense: true,
                          value: _picked.contains(fighter.id),
                          onChanged: (on) => setState(() {
                            if (on == true) {
                              _picked.add(fighter.id);
                            } else {
                              _picked.remove(fighter.id);
                            }
                          }),
                          secondary: FighterAvatar(fighter: fighter),
                          title: Text(fighter.name),
                          subtitle: Text(
                            '${fighter.weightClass.label} · '
                            'OVR ${fighter.overall.round()}',
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        // Selecting everyone that matches the current search is the
        // difference between building a division pack in one tap and in
        // fifty.
        TextButton(
          onPressed: matches.isEmpty
              ? null
              : () =>
                  setState(() => _picked.addAll(matches.map((f) => f.id))),
          child: const Text('Select shown'),
        ),
        FilledButton(
          onPressed:
              _picked.isEmpty ? null : () => Navigator.of(context).pop(_picked),
          child: const Text('Next'),
        ),
      ],
    );
  }
}

class _PackDetails {
  final String name;
  final String description;
  final String author;

  const _PackDetails({
    required this.name,
    required this.description,
    required this.author,
  });
}

class _PackDetailsDialog extends StatefulWidget {
  const _PackDetailsDialog();

  @override
  State<_PackDetailsDialog> createState() => _PackDetailsDialogState();
}

class _PackDetailsDialogState extends State<_PackDetailsDialog> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _author = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _author.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Name the pack'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Pack name'),
          ),
          TextField(
            controller: _description,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          TextField(
            controller: _author,
            decoration: const InputDecoration(
              labelText: 'Your name',
              helperText: 'Travels with the pack when you share it.',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_PackDetails(
            name: _name.text,
            description: _description.text,
            author: _author.text,
          )),
          child: const Text('Save Pack'),
        ),
      ],
    );
  }
}

class _PasteCodeDialog extends StatefulWidget {
  const _PasteCodeDialog();

  @override
  State<_PasteCodeDialog> createState() => _PasteCodeDialogState();
}

class _PasteCodeDialogState extends State<_PasteCodeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Paste a pack code'),
      content: SizedBox(
        width: 400,
        child: TextField(
          controller: _controller,
          autofocus: true,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Paste the whole code, { to }',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        // Straight from the clipboard, since that is where it almost
        // always is and a code this long is miserable to paste by hand
        // on a phone.
        // Reading the clipboard is a stricter permission than writing it
        // and some browsers don't offer it at all, so this is a
        // convenience with a fallback rather than the way in: the field
        // above takes an ordinary paste.
        TextButton(
          onPressed: () async {
            String? text;
            try {
              text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
            } catch (_) {
              text = null;
            }
            if (!context.mounted) return;
            if (text == null || text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                  "Couldn't read the clipboard — paste into the box instead.",
                ),
              ));
              return;
            }
            _controller.text = text;
          },
          child: const Text('Paste'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Import'),
        ),
      ],
    );
  }
}

class _ShareCodeDialog extends StatefulWidget {
  final FighterPack pack;
  final String code;

  const _ShareCodeDialog({required this.pack, required this.code});

  @override
  State<_ShareCodeDialog> createState() => _ShareCodeDialogState();
}

class _ShareCodeDialogState extends State<_ShareCodeDialog> {
  /// Null while the copy is still being attempted; then whether it
  /// landed. The dialog is useful either way — it just says which.
  bool? _copied;

  @override
  void initState() {
    super.initState();
    _copy();
  }

  Future<void> _copy() async {
    final ok = await copyToClipboard(widget.code);
    if (!mounted) return;
    setState(() => _copied = ok);
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.code;
    final kb = (code.length / 1024).toStringAsFixed(1);
    final size = '${code.length} characters ($kb KB)';
    final message = switch (_copied) {
      true => 'Copied to your clipboard — $size. Send it however you like; '
          'whoever gets it pastes it into Fighter Packs.',
      false => "Couldn't reach the clipboard, so select the code below and "
          'copy it yourself — $size.',
      null => 'Copying — $size.',
    };

    return AlertDialog(
      title: Text('Share ${widget.pack.name}'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Container(
              height: 120,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  code,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final ok = await copyToClipboard(code);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(ok
                  ? 'Copied.'
                  : "Couldn't reach the clipboard — select the code and "
                      'copy it yourself.'),
            ));
          },
          child: const Text('Copy again'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
