import 'package:flutter/material.dart';

/// Reusable group form dialog/sheet content used for both create & edit flows.
/// Mirrors styling of the create group bottom sheet (rounded fields on dark bg).
class GroupFormDialog extends StatefulWidget {
  final String title;
  final String? initialName;
  final String? initialDescription;
  final bool initialPrivate;
  final int? initialMaxMembers; // kept for symmetry (unused in edit currently)
  final bool showMaxMembers;
  final bool showPrivateToggle;
  final Future<bool> Function({required String name, String? description, required bool isPrivate}) onSubmit;

  const GroupFormDialog({
    super.key,
    required this.title,
    this.initialName,
    this.initialDescription,
    this.initialPrivate = false,
    this.initialMaxMembers,
    this.showMaxMembers = false,
    this.showPrivateToggle = true,
    required this.onSubmit,
  });

  @override
  State<GroupFormDialog> createState() => _GroupFormDialogState();
}

class _GroupFormDialogState extends State<GroupFormDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _maxCtrl;
  bool _isPrivate = false;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _descCtrl = TextEditingController(text: widget.initialDescription ?? '');
    _maxCtrl = TextEditingController(text: widget.initialMaxMembers?.toString() ?? '');
    _isPrivate = widget.initialPrivate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(BuildContext context, String label) {
    final theme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.primary.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.grey.shade900,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final ok = await widget.onSubmit(
        name: name,
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        isPrivate: _isPrivate);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: theme.primary,
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(color: theme.primary),
                  decoration: _fieldDecoration(context, 'Name *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descCtrl,
                  maxLines: 3,
                  style: TextStyle(color: theme.primary),
                  decoration: _fieldDecoration(context, 'Description'),
                ),
                if (widget.showMaxMembers) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _maxCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: theme.primary),
                    decoration: _fieldDecoration(context, 'Max Members (optional)'),
                  ),
                ],
                if (widget.showPrivateToggle) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Private', style: TextStyle(color: theme.primary.withOpacity(0.7))),
                      const SizedBox(width: 8),
                      Switch(
                        value: _isPrivate,
                        activeColor: theme.secondary,
                        onChanged: (v) => setState(() => _isPrivate = v),
                      ),
                    ],
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 6),
                  Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(_submitting ? 'Saving...' : 'Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.secondary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}