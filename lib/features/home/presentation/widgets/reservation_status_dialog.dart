import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:nutilize/core/services/reservation_service.dart';
import 'package:nutilize/core/services/office_service.dart';
import 'package:nutilize/core/models/reservation_approval.dart';
import 'package:nutilize/core/models/office.dart';
import 'package:nutilize/core/models/reservation.dart';
import 'package:nutilize/features/home/presentation/pages/report_issue_page.dart';

const List<_ApprovalStageDefinition> _approvalStages = [
  _ApprovalStageDefinition(
    displayName: 'Designated Item Owner',
    aliases: [
      'designated item owner',
      'item owner',
      'designated owner',
    ],
    requiresBorrowedItems: true,
  ),
  _ApprovalStageDefinition(
    displayName: 'Program chair',
    aliases: ['program chair', 'programchair', 'chair'],
  ),
  _ApprovalStageDefinition(
    displayName: 'SDAO',
    aliases: ['sdao'],
  ),
  _ApprovalStageDefinition(
    displayName: 'DO',
    aliases: ['do'],
  ),
  _ApprovalStageDefinition(
    displayName: 'Security',
    aliases: ['security'],
  ),
  _ApprovalStageDefinition(
    displayName: 'Physical Facilities',
    aliases: ['physical facilities', 'facilities', 'physical'],
  ),
];

List<_ApprovalStageDefinition> _buildApprovalStages({
  required bool hasBorrowedItems,
}) {
  return _approvalStages
      .where((stage) => !stage.requiresBorrowedItems || hasBorrowedItems)
      .toList();
}

String _normalizeOfficeName(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}

int? _findStageIndex(
  String departmentName,
  List<_ApprovalStageDefinition> stages,
) {
  final normalized = _normalizeOfficeName(departmentName);
  for (var i = 0; i < stages.length; i++) {
    final hasMatch = stages[i].aliases
        .map(_normalizeOfficeName)
        .contains(normalized);
    if (hasMatch) {
      return i;
    }
  }
  return null;
}

class _ApprovalStageDefinition {
  final String displayName;
  final List<String> aliases;
  final bool requiresBorrowedItems;

  const _ApprovalStageDefinition({
    required this.displayName,
    required this.aliases,
    this.requiresBorrowedItems = false,
  });
}

class NUtilizeLogo extends StatelessWidget {
  final double height;
  const NUtilizeLogo({this.height = 56, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'N',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: height * 0.85,
              color: const Color(0xFF233B7A),
              letterSpacing: -2,
              fontFamily: 'Roboto',
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: height * 0.08),
            child: Text(
              'UTILIZE',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: height * 0.67,
                color: const Color(0xFFF5BC1D),
                letterSpacing: -2,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool?> showReservationStatusDialog(
  BuildContext context, {
  int? reservationId,
}) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final size = MediaQuery.of(context).size;
      final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
      return _ReservationStatusDialogContent(
        size: size,
        bottomPadding: bottomPadding,
        reservationId: reservationId,
      );
    },
  );
}

class _ReservationStatusDialogContent extends StatefulWidget {
  final Size size;
  final double bottomPadding;
  final int? reservationId;
  const _ReservationStatusDialogContent({
    required this.size,
    required this.bottomPadding,
    this.reservationId,
  });

  @override
  State<_ReservationStatusDialogContent> createState() =>
      _ReservationStatusDialogContentState();
}

class _ReservationStatusDialogContentState
    extends State<_ReservationStatusDialogContent> {
  File? _selectedImage;
  final TextEditingController _descController = TextEditingController();
  late Future<Reservation?> _reservationFuture;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _reservationFuture = widget.reservationId != null
        ? ReservationService().getReservation(widget.reservationId!)
        : Future.value(null);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width,
      height: widget.size.height - widget.bottomPadding,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // ...existing code...
          // Header
          Container(
            width: double.infinity,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFF233B7A),
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const Center(
                  child: Text(
                    'Reservation Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Progress Bar
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 8),
            child: _ProgressIndicator(
              reservationId: widget.reservationId,
            ),
          ),
          // Main Card with Timeline
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF233B7A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.apartment,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'NUtilize Status Reservation',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _ReservationTimeline(
                          reservationId: widget.reservationId,
                        ),
                      ],
                    ),
                  ),
                  // Countdown Timer Section
                  FutureBuilder<Reservation?>(
                    future: _reservationFuture,
                    builder: (context, snapshot) {
                      final reservation = snapshot.data;
                      if (reservation == null ||
                          reservation.startOfActivity == null ||
                          reservation.endOfActivity == null) {
                        return const SizedBox.shrink();
                      }

                      return _CountdownTimer(
                        eventStartDate: reservation.startOfActivity,
                        eventEndDate: reservation.endOfActivity,
                        reservationId: widget.reservationId,
                      );
                    },
                  ),
                  // Borrowed Items Section
                  _BorrowedItemsSection(
                    reservationId: widget.reservationId,
                  ),
                  // Buttons
                  FutureBuilder<Reservation?>(
                    future: _reservationFuture,
                    builder: (context, snapshot) {
                      final reservation = snapshot.data;
                      final status = reservation?.overallStatus?.toLowerCase() ?? '';
                      final canCancel = status == 'pending' || status == 'approved';

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            if (canCancel)
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  onPressed: _isCancelling || reservation == null
                                      ? null
                                      : () async {
                                          // Show confirmation dialog
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Are you sure you want to cancel?'),
                                              content: const Text(
                                                'This action cannot be undone. Your reservation will be cancelled.',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text('No, keep it'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: const Text(
                                                    'Yes, cancel',
                                                    style: TextStyle(color: Colors.red),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirmed != true) return;

                                          setState(() => _isCancelling = true);
                                          try {
                                            await ReservationService()
                                                .cancelReservation(widget.reservationId!);
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content:
                                                      Text('Reservation cancelled successfully'),
                                                ),
                                              );
                                              Navigator.of(context).pop(true);
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Failed to cancel reservation: $e'),
                                                ),
                                              );
                                              setState(() => _isCancelling = false);
                                            }
                                          }
                                        },
                                  child: Text(
                                    _isCancelling ? 'Cancelling...' : 'Cancel Request',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            if (canCancel) const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF233B7A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ReportIssuePage(
                                        reservationId: widget.reservationId,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Issue report',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF233B7A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {},
                                child: const Text(
                                  'Print',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationTimeline extends StatefulWidget {
  final int? reservationId;

  const _ReservationTimeline({
    required this.reservationId,
  });

  @override
  State<_ReservationTimeline> createState() => _ReservationTimelineState();
}

class _ReservationTimelineState extends State<_ReservationTimeline> {
  late Future<_TimelineData> _timelineDataFuture;

  @override
  void initState() {
    super.initState();
    _timelineDataFuture = _loadTimelineData();
  }

  Future<_TimelineData> _loadTimelineData() async {
    if (widget.reservationId == null) {
      return _TimelineData(steps: []);
    }

    final reservationService = ReservationService();
    final officeService = OfficeService();

    try {
      // Fetch approvals and offices
      final approvals =
          await reservationService.getReservationApprovals(widget.reservationId!);
      final offices = await officeService.getAllOffices();
      final borrowedItems =
          await reservationService.getReservationItems(widget.reservationId!);
      final approvalStages = _buildApprovalStages(
        hasBorrowedItems: borrowedItems.isNotEmpty,
      );

      final officeMap = {for (var office in offices) office.officeId: office};
      final List<ReservationApproval?> approvalPerStage =
          List<ReservationApproval?>.filled(approvalStages.length, null);

      for (final approval in approvals) {
        final office = officeMap[approval.officeId];
        if (office == null) {
          continue;
        }

        final stageIndex = _findStageIndex(office.departmentName, approvalStages);
        if (stageIndex == null) {
          continue;
        }

        final current = approvalPerStage[stageIndex];
        if (current == null) {
          approvalPerStage[stageIndex] = approval;
          continue;
        }

        final currentIsApproved = current.status == 'approved';
        final nextIsApproved = approval.status == 'approved';
        if (!currentIsApproved && nextIsApproved) {
          approvalPerStage[stageIndex] = approval;
          continue;
        }

        final currentUpdated = current.updatedAt ?? current.createdAt;
        final nextUpdated = approval.updatedAt ?? approval.createdAt;
        if (nextUpdated.isAfter(currentUpdated)) {
          approvalPerStage[stageIndex] = approval;
        }
      }

      final List<_TimelineStep> steps = [];

      for (int i = 0; i < approvalStages.length; i++) {
        final stageName = approvalStages[i].displayName;
        final approval = approvalPerStage[i] ??
            ReservationApproval(
              approvalId: 0,
              reservationId: widget.reservationId!,
              officeId: 0,
              status: 'pending',
              createdAt: DateTime.now(),
            );

        // Determine if this stage is completed
        final isApproved = approval.status == 'approved';

        // Generate title and subtitle based on stage and status
        final (title, subtitle) = _generateStatusText(
          stageName,
          approval.status,
          approval.approvedAt,
        );

        // Generate time (use approval time if available)
        final timeStr = approval.approvedAt != null
            ? _formatDateTime(approval.approvedAt!)
            : 'Pending';

        steps.add(
          _TimelineStep(
            time: timeStr,
            title: title,
            subtitle: subtitle,
            isActive: isApproved,
            status: approval.status,
            stage: stageName,
          ),
        );
      }

      return _TimelineData(steps: steps, approvalCount: approvals.length);
    } catch (e) {
      // Fallback to empty state or error handling
      return _TimelineData(steps: [], approvalCount: 0);
    }
  }

  (String, String) _generateStatusText(
    String stageName,
    String status,
    DateTime? approvedAt,
  ) {
    switch (status) {
      case 'approved':
        return (
          'Approved by $stageName',
          'Your request has been approved by $stageName.'
        );
      case 'rejected':
        return (
          'Rejected by $stageName',
          'Your request was rejected by $stageName.'
        );
      case 'pending':
      default:
        return (
          'Awaiting $stageName approval',
          'Your request is awaiting approval from $stageName.'
        );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final displayHour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);

    return '$month $day $displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_TimelineData>(
      future: _timelineDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading timeline: ${snapshot.error}'),
          );
        }

        final timelineData = snapshot.data ?? _TimelineData(steps: []);
        final steps = timelineData.steps;

        if (steps.isEmpty) {
          return const Center(
            child: Text('No reservation selected yet.'),
          );
        }

        return Column(
          children: List.generate(steps.length, (i) {
            final step = steps[i];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: step.isActive
                            ? const Color(0xFFF5BC1D)
                            : const Color(0xFF233B7A),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: step.isActive
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                    if (i < steps.length - 1)
                      Container(
                        width: 4,
                        height: 38,
                        color: const Color(0xFF233B7A),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.time,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF233B7A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          step.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: step.isActive
                                ? const Color(0xFFF5BC1D)
                                : const Color(0xFF233B7A),
                          ),
                        ),
                        Text(
                          step.subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B6B6B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}

class _TimelineStep {
  final String time;
  final String title;
  final String subtitle;
  final bool isActive;
  final String status;
  final String stage;

  _TimelineStep({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.status,
    required this.stage,
  });
}

class _TimelineData {
  final List<_TimelineStep> steps;
  final int approvalCount;

  _TimelineData({
    required this.steps,
    this.approvalCount = 0,
  });
}

class _ProgressIndicator extends StatefulWidget {
  final int? reservationId;

  const _ProgressIndicator({
    required this.reservationId,
  });

  @override
  State<_ProgressIndicator> createState() => _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<_ProgressIndicator> {
  late Future<int> _completedCountFuture;

  @override
  void initState() {
    super.initState();
    _completedCountFuture = _getCompletedApprovals();
  }

  Future<int> _getCompletedApprovals() async {
    if (widget.reservationId == null) {
      return 0;
    }

    final reservationService = ReservationService();
    final officeService = OfficeService();
    try {
      final approvals =
          await reservationService.getReservationApprovals(widget.reservationId!);
      final offices = await officeService.getAllOffices();
      final borrowedItems =
          await reservationService.getReservationItems(widget.reservationId!);
      final approvalStages = _buildApprovalStages(
        hasBorrowedItems: borrowedItems.isNotEmpty,
      );
      final officeMap = {for (var office in offices) office.officeId: office};

      final approvedStages = <int>{};
      for (final approval in approvals) {
        if (approval.status != 'approved') {
          continue;
        }

        final office = officeMap[approval.officeId];
        if (office == null) {
          continue;
        }

        final stageIndex = _findStageIndex(office.departmentName, approvalStages);
        if (stageIndex != null) {
          approvedStages.add(stageIndex);
        }
      }

      return approvedStages.length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _completedCountFuture,
      builder: (context, snapshot) {
        final completedCount = snapshot.data ?? 0;
        return FutureBuilder<bool>(
          future: widget.reservationId == null
              ? Future.value(false)
              : ReservationService()
                  .getReservationItems(widget.reservationId!)
                  .then((items) => items.isNotEmpty),
          builder: (context, itemsSnapshot) {
            final hasBorrowedItems = itemsSnapshot.data ?? false;
            final totalStages = _buildApprovalStages(
              hasBorrowedItems: hasBorrowedItems,
            ).length;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                totalStages,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.check_circle,
                    color: i < completedCount
                        ? const Color(0xFFF5BC1D)
                        : const Color(0xFFD0D0D0),
                    size: 28,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CountdownTimer extends StatefulWidget {
  final DateTime? eventStartDate;
  final DateTime? eventEndDate;
  final int? reservationId;

  const _CountdownTimer({
    required this.eventStartDate,
    required this.eventEndDate,
    this.reservationId,
  });

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late Timer? _updateTimer;
  late String _timerText;
  late String _timerLabel;
  late bool _isEventComplete;

  @override
  void initState() {
    super.initState();
    _updateTimerText();
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _updateTimerText());
      }
    });
  }

  void _updateTimerText() {
    final now = DateTime.now();
    final startDate = widget.eventStartDate;
    final endDate = widget.eventEndDate;

    if (endDate != null && now.isAfter(endDate)) {
      _isEventComplete = true;
      _timerText = 'Event Completed';
      _timerLabel = '';
      return;
    }

    _isEventComplete = false;

    if (startDate != null && now.isBefore(startDate)) {
      final diff = startDate.difference(now);
      final days = diff.inDays;
      final hours = diff.inHours % 24;
      final minutes = diff.inMinutes % 60;
      final seconds = diff.inSeconds % 60;

      _timerLabel = 'Event starts in';
      if (days > 0) {
        _timerText = '$days days $hours hrs $minutes min';
      } else if (hours > 0) {
        _timerText = '$hours hrs $minutes min $seconds sec';
      } else {
        _timerText = '$minutes min $seconds sec';
      }
    } else if (endDate != null) {
      final diff = endDate.difference(now);
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      final seconds = diff.inSeconds % 60;

      _timerLabel = 'Event time remaining';
      _timerText = '$hours hrs $minutes min $seconds sec';
    } else {
      _timerText = 'No event date set';
      _timerLabel = '';
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEventComplete) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF233B7A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _timerLabel,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _timerText,
            style: const TextStyle(
              color: Color(0xFFF5BC1D),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BorrowedItemsSection extends StatefulWidget {
  final int? reservationId;

  const _BorrowedItemsSection({required this.reservationId});

  @override
  State<_BorrowedItemsSection> createState() => _BorrowedItemsSectionState();
}

class _BorrowedItemsSectionState extends State<_BorrowedItemsSection> {
  late Future<_BorrowedItemsData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadBorrowedItems();
  }

  Future<_BorrowedItemsData> _loadBorrowedItems() async {
    if (widget.reservationId == null) {
      return _BorrowedItemsData(rooms: [], items: []);
    }

    final reservationService = ReservationService();
    try {
      final rooms = await reservationService.getReservationRooms(widget.reservationId!);
      final items = await reservationService.getReservationItems(widget.reservationId!);
      return _BorrowedItemsData(rooms: rooms, items: items);
    } catch (e) {
      return _BorrowedItemsData(rooms: [], items: []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_BorrowedItemsData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? _BorrowedItemsData(rooms: [], items: []);

        if (data.rooms.isEmpty && data.items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Borrowed Items & Rooms',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              if (data.rooms.isNotEmpty) ...[
                const Text(
                  'Rooms',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF233B7A),
                  ),
                ),
                const SizedBox(height: 8),
                ...data.rooms.map(
                  (room) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5BC1D),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.apartment,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Room ${room.roomNumber}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                room.roomType,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (data.rooms.isNotEmpty && data.items.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
              if (data.items.isNotEmpty) ...[
                const Text(
                  'Items',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF233B7A),
                  ),
                ),
                const SizedBox(height: 8),
                ...data.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5BC1D),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.inventory_2,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.itemName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${item.category} • Qty: ${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BorrowedItemsData {
  final List<BorrowedRoom> rooms;
  final List<BorrowedItem> items;

  _BorrowedItemsData({required this.rooms, required this.items});
}
