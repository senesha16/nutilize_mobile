import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutilize/features/auth/data/auth_service.dart';
import 'package:nutilize/core/services/report_service.dart';
import 'package:nutilize/core/services/reservation_service.dart';

class ReportIssuePage extends StatefulWidget {
  final int? reservationId;

  const ReportIssuePage({super.key, this.reservationId});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final _reservationService = ReservationService();
  final _reportService = ReportService();
  final _authService = AuthService();
  final _descController = TextEditingController();
  final _picker = ImagePicker();

  Future<List<ReportTarget>>? _targetsFuture;
  final List<ReportTarget> _selectedTargets = [];
  final List<File> _images = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _targetsFuture = _loadTargets();
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<List<ReportTarget>> _loadTargets() async {
    if (widget.reservationId == null) return [];

    final rooms = await _reservationService.getReservationRooms(widget.reservationId!);
    final items = await _reservationService.getReservationItems(widget.reservationId!);

    final targets = <ReportTarget>[];

    for (final room in rooms) {
      targets.add(
        ReportTarget(
          roomId: room.roomId,
          label: 'Room ${room.roomNumber}',
          type: 'Room',
        ),
      );
    }

    for (final item in items) {
      targets.add(
        ReportTarget(
          itemId: item.itemId,
          label: item.itemName,
          type: 'Item • ${item.category}',
        ),
      );
    }

    return targets;
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.gallery) {
      final pickedFiles = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (!mounted || pickedFiles.isEmpty) return;

      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)));
      });
      return;
    }

    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
      maxHeight: 1600,
    );

    if (!mounted || pickedFile == null) return;

    setState(() {
      _images.add(File(pickedFile.path));
    });
  }

  Future<void> _showImageSourceActionSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      await _pickImage(source);
    }
  }

  Future<void> _showTargetPicker(List<ReportTarget> targets) async {
    final tempSelected = _selectedTargets.map((t) => t.label).toSet();

    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What would you like to report?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: targets.length,
                        separatorBuilder: (_, __) => const Divider(height: 12),
                        itemBuilder: (context, index) {
                          final target = targets[index];
                          final selected = tempSelected.contains(target.label);
                          return CheckboxListTile(
                            value: selected,
                            onChanged: (value) {
                              setModalState(() {
                                if (value ?? false) {
                                  tempSelected.add(target.label);
                                } else {
                                  tempSelected.remove(target.label);
                                }
                              });
                            },
                            title: Text(target.label),
                            subtitle: Text(target.type),
                            activeColor: const Color(0xFF233B7A),
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, tempSelected),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF233B7A),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) return;

    setState(() {
      _selectedTargets
        ..clear()
        ..addAll(targets.where((target) => result.contains(target.label)));
    });
  }

  Future<void> _submit() async {
    final description = _descController.text.trim();
    if (_selectedTargets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one room or item to report.')),
      );
      return;
    }
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one proof photo.')),
      );
      return;
    }
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description.')),
      );
      return;
    }

    final user = await _authService.getCurrentUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in again to submit a report.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _reportService.submitReports(
        userId: user.userId,
        targets: _selectedTargets,
        description: description,
        proofImagePaths: _images.map((image) => image.path).toList(),
        reservationId: widget.reservationId,
      );

      if (!mounted) return;

      await _showSuccessDialog();

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit report: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFF233B7A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Report Submitted',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF233B7A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your issue report has been submitted successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4F4F4F),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF233B7A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Done',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('NUtilize Reporting form'),
        backgroundColor: const Color(0xFF233B7A),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<ReportTarget>>(
        future: _targetsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final targets = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Issue Report',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'What would you like to report?',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: targets.isEmpty ? null : () => _showTargetPicker(targets),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F7FB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD8DDEB)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedTargets.isEmpty
                                      ? (targets.isEmpty ? 'No reportable rooms/items found' : 'Select room(s) or item(s)')
                                      : _selectedTargets.map((e) => e.label).join(', '),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedTargets
                            .map(
                              (target) => Chip(
                                label: Text(target.label),
                                backgroundColor: const Color(0xFFE6E8F2),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Proof Photo',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _showImageSourceActionSheet,
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 140),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F7FB),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFD8DDEB)),
                          ),
                          child: _images.isEmpty
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cloud_upload_outlined, size: 38, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text(
                                      'Upload photo proof (multiple allowed)',
                                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'JPG or PNG',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_images.length} photo(s) selected',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 92,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _images.length,
                                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                                          itemBuilder: (context, index) {
                                            final image = _images[index];
                                            return Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: Image.file(
                                                    image,
                                                    width: 110,
                                                    height: 92,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 4,
                                                  right: 4,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _images.removeAt(index);
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 22,
                                                      height: 22,
                                                      decoration: const BoxDecoration(
                                                        color: Colors.black54,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                        size: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _showImageSourceActionSheet,
                          icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                          label: const Text('Add more photos'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF233B7A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Description',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Describe the issue in detail',
                          filled: true,
                          fillColor: const Color(0xFFF6F7FB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD8DDEB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD8DDEB)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF233B7A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Submit Report',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}