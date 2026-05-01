import 'package:nutilize/core/widgets/notification_panel.dart';
import 'package:nutilize/core/services/notification_service.dart';
import 'package:nutilize/features/auth/shared/presentation/widgets/auth_ui.dart';
import 'package:nutilize/features/home/presentation/widgets/reservation_status_dialog.dart';
import 'package:flutter/material.dart';
import 'package:nutilize/shared/components/nutilize_header.dart';
import 'package:nutilize/features/auth/data/auth_service.dart';
import 'package:nutilize/core/services/reservation_service.dart';
import 'package:nutilize/core/models/reservation.dart';
import 'package:nutilize/core/services/office_service.dart';
import 'dart:async';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.viewKey});

  final Key? viewKey;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 9999;
    if (isDesktop) {
      return const _HomeDesktopDashboard();
    }

    return _HomeMobileView(key: viewKey);
  }
}

class _HomeMobileView extends StatefulWidget {
  const _HomeMobileView({super.key});

  @override
  State<_HomeMobileView> createState() => _HomeMobileViewState();
}

class _HomeMobileViewState extends State<_HomeMobileView>
    with WidgetsBindingObserver {
  final GlobalKey<_ReservationHighlightCardState> _reservationKey =
      GlobalKey<_ReservationHighlightCardState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reservationKey.currentState?.refreshReservations();
    }
  }

  void refreshReservations() {
    _reservationKey.currentState?.refreshReservations();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF2F2F2),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const NutilizeHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 20),
                children: [
                  const _GreetingRow(),
                  const SizedBox(height: 14),
                  _ReservationHighlightCard(key: _reservationKey),
                  const SizedBox(height: 14),
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF151515),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const _ActivityCard(
                    icon: Icons.meeting_room_outlined,
                    title: 'Room 531',
                    subtitle: 'Organizational Meeting',
                  ),
                  const SizedBox(height: 10),
                  const _ActivityCard(
                    icon: Icons.tv,
                    title: 'NU Lipa TV',
                    subtitle: 'Organizational Meeting',
                  ),
                  const SizedBox(height: 10),
                  const _ActivityCard(
                    icon: Icons.kitchen_outlined,
                    title: 'Room 533',
                    subtitle: 'Cooking Mama Tournament',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeDesktopDashboard extends StatelessWidget {
  const _HomeDesktopDashboard();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3E4FA8), Color(0xFF5E71C7)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'PHYSICAL FACILITIES DASHBOARD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 44 / 1.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.copy_all_rounded,
                  value: '17',
                  label: 'Total Request',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.folder_copy_outlined,
                  value: '09',
                  label: 'Borrowed',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_outline_rounded,
                  value: '74',
                  label: 'Available',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.miscellaneous_services_outlined,
                  value: '20',
                  label: 'Maintenance',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7EAF5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1B60D),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.error, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Report Quick View',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36 / 1.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(14),
                        child: _QuickReportTable(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7EAF5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tasks To\nAccomplish',
                        style: TextStyle(
                          fontSize: 42 / 1.8,
                          height: 1.05,
                          color: Color(0xFF4151A2),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '(This week)',
                        style: TextStyle(color: Color(0xFF7A7A7A)),
                      ),
                      Divider(height: 20),
                      _TaskLine(text: 'Pending Final Approvals (7)'),
                      Divider(height: 20),
                      _TaskLine(text: 'Review Damaged Items (3)'),
                      Divider(height: 20),
                      _TaskLine(text: 'Need of repair (2)'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(child: _MiniPanel(title: 'Upcoming Requests')),
              SizedBox(width: 14),
              Expanded(child: _MiniPanel(title: 'Daily Highlights')),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EAF5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: AuthPalette.royalBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 54 / 1.8,
                  fontWeight: FontWeight.w700,
                  color: AuthPalette.royalBlue,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  color: AuthPalette.royalBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickReportTable extends StatelessWidget {
  const _QuickReportTable();

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('Projector', 'Mr. Martin Espanoso', '2 Images', 'Pending', false),
      ('Speaker', 'Mrs. Nina Tamaza', '1 Video 2 Images', 'Pending', false),
      ('Microphone', 'Mr. Drei Punzalan', 'No attachment', 'Pending', false),
      ('Speaker', 'Mr. Jed Perez', '2 Images', 'Solved', true),
    ];

    return Column(
      children: [
        const Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Item',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                'Reported by:',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Attachment',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...rows.map(
          (row) => Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0x2E6E6E6E))),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(row.$1)),
                Expanded(flex: 3, child: Text(row.$2)),
                Expanded(flex: 2, child: Text(row.$3)),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: row.$5
                          ? const Color(0xFF9FD4A7)
                          : const Color(0xFFECC67E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(row.$4, textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskLine extends StatelessWidget {
  const _TaskLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      '◉ $text',
      style: const TextStyle(color: AuthPalette.royalBlue, fontSize: 19 / 1.2),
    );
  }
}

class _MiniPanel extends StatelessWidget {
  const _MiniPanel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EAF5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: AuthPalette.royalBlue,
          fontSize: 38 / 1.8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HomeTopStrip extends StatelessWidget {
  const _HomeTopStrip();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 56,
          color: AuthPalette.royalBlue,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: SizedBox(
            height: 24,
            child: Image.asset(
              'assets/images/nutilize_logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        Container(height: 4, color: AuthPalette.yellow),
      ],
    );
  }
}

class _GreetingRow extends StatefulWidget {
  const _GreetingRow();

  @override
  State<_GreetingRow> createState() => _GreetingRowState();
}

class _GreetingRowState extends State<_GreetingRow> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authService.getCurrentUser(),
      builder: (context, snapshot) {
        String userName = 'User';
        
        if (snapshot.hasData && snapshot.data != null) {
          userName = snapshot.data!.username;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good Evening',
              style: TextStyle(
                fontSize: 34 / 1.7,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _PillLabel(text: userName),
                const SizedBox(width: 6),
                const Text('👋', style: TextStyle(fontSize: 20)),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _PillLabel extends StatelessWidget {
  const _PillLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF5664AE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        children: [
          SizedBox(width: 12),
          Icon(Icons.search, color: Colors.black54),
          SizedBox(width: 8),
          Text(
            'Search',
            style: TextStyle(
              color: Color(0xFF8A8A8A),
              fontSize: 18 / 1.1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ReservationStatusStep {
  final String time;
  final String title;
  final String? subtitle;
  final String? description;
  final bool isDone;

  ReservationStatusStep({
    required this.time,
    required this.title,
    this.subtitle,
    this.description,
    this.isDone = false,
  });
}

class ReservationStatusDialog extends StatelessWidget {
  final List<ReservationStatusStep> steps;
  final int currentStep;
  final VoidCallback onIssueReport;
  final VoidCallback onPrint;

  const ReservationStatusDialog({
    super.key,
    required this.steps,
    required this.currentStep,
    required this.onIssueReport,
    required this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('Reservation Status Dialog', style: TextStyle(fontSize: 18)),
          // You can add the detailed steps UI here
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E8F2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1D000000),
            blurRadius: 7,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AuthPalette.royalBlue,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22 / 1.2,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationHighlightCard extends StatefulWidget {
  const _ReservationHighlightCard({super.key});

  @override
  State<_ReservationHighlightCard> createState() =>
      _ReservationHighlightCardState();
}

class _ReservationHighlightCardState extends State<_ReservationHighlightCard> {
  final _authService = AuthService();
  final _reservationService = ReservationService();
  late Future<List<Reservation>> _reservationsFuture;
  bool _showAllReservations = false;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  void _loadReservations() {
    _reservationsFuture = _getReservations();
  }

  void refreshReservations() {
    setState(() {
      _loadReservations();
    });
  }

  Future<List<Reservation>> _getReservations() async {
    final user = await _authService.getCurrentUser();
    if (user == null) return [];
    return await _reservationService.getUserReservations(user.userId);
  }

  int _reservationPriority(Reservation reservation) {
    final status = (reservation.overallStatus ?? '').toLowerCase();
    final now = DateTime.now();
    final end = reservation.endOfActivity;

    if (end != null && now.isAfter(end.add(const Duration(hours: 24))) && status != 'returned') {
      return 0; // overdue returning
    }
    if (end != null && now.isAfter(end) && now.isBefore(end.add(const Duration(hours: 24))) && status != 'returned') {
      return 1; // to return
    }
    if (status == 'approved') {
      return 2; // approved upcoming or active
    }
    // pending (includes pending, pending_office_approvals, etc.)
    return 3;
  }

  int _reservationSecondarySort(Reservation reservation) {
    final status = (reservation.overallStatus ?? '').toLowerCase();
    final now = DateTime.now();
    if (_reservationPriority(reservation) == 0) {
      final deadline = reservation.endOfActivity?.add(const Duration(hours: 24));
      return deadline?.millisecondsSinceEpoch ?? now.millisecondsSinceEpoch;
    }
    if (_reservationPriority(reservation) == 1) {
      final deadline = reservation.endOfActivity?.add(const Duration(hours: 24));
      return deadline?.millisecondsSinceEpoch ?? now.millisecondsSinceEpoch;
    }
    if (_reservationPriority(reservation) == 2) {
      final start = reservation.startOfActivity ?? reservation.dateOfActivity;
      return start?.millisecondsSinceEpoch ?? reservation.createdAt.millisecondsSinceEpoch;
    }
    // Pending: newest created first (smaller values = more recent = sort first)
    return now.millisecondsSinceEpoch - reservation.createdAt.millisecondsSinceEpoch;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Reservation>>(
      future: _reservationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE6E8F2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE6E8F2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final reservations = snapshot.data ?? [];

        // Filter out returned/cancelled/rejected/completed requests only.
        // Keep approved events that are in the return window or overdue return.
        final activeReservations = reservations.where((r) {
          final status = (r.overallStatus ?? '').toLowerCase();
          if (status == 'rejected' || status == 'cancelled' || status == 'completed' || status == 'returned') {
            return false;
          }
          return true;
        }).toList();

        activeReservations.sort((a, b) {
          final priorityDiff = _reservationPriority(a) - _reservationPriority(b);
          if (priorityDiff != 0) return priorityDiff;
          return _reservationSecondarySort(a).compareTo(_reservationSecondarySort(b));
        });

        if (activeReservations.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE6E8F2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text(
                'No active reservations',
                style: TextStyle(color: Color(0xFF696969)),
              ),
            ),
          );
        }

        final hasOverflow = activeReservations.length > 3;
        final visibleReservations = _showAllReservations
            ? activeReservations
            : activeReservations.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Active Requests (${activeReservations.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF233B7A),
                  ),
                ),
                const Spacer(),
                if (hasOverflow)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showAllReservations = !_showAllReservations;
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF233B7A),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(10, 10),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _showAllReservations
                          ? 'Show less'
                          : 'Show ${activeReservations.length - visibleReservations.length} more',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            ...visibleReservations.map((reservation) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ReservationCardWidget(
                  reservation: reservation,
                  onRefresh: _loadReservations,
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

class _ReservationCardWidget extends StatefulWidget {
  final Reservation reservation;
  final VoidCallback onRefresh;

  const _ReservationCardWidget({
    required this.reservation,
    required this.onRefresh,
  });

  @override
  State<_ReservationCardWidget> createState() => _ReservationCardWidgetState();
}

class _ReservationCardWidgetState extends State<_ReservationCardWidget> {
  Future<_ApprovalProgress> _getApprovalProgress(int reservationId) async {
    try {
      final reservationService = ReservationService();
      final officeService = OfficeService();
      final approvals = await reservationService.getReservationApprovals(reservationId);
      final borrowedItems = await reservationService.getReservationItems(reservationId);
      final borrowedRooms = await reservationService.getReservationRooms(reservationId);
      final offices = await officeService.getAllOffices();
      final officeMap = {for (var office in offices) office.officeId: office};

      final hasGymSpace = borrowedRooms.any(
        (room) => room.roomType.toLowerCase().contains('gym'),
      );
      final hasNonPhysicalFacilitiesItems = borrowedItems.any(
        (item) => item.ownerName != 'Physical Facilities',
      );

      final approvalStages = [
        if (hasGymSpace) ['general education', 'gened', 'gen ed'],
        ['designated item owner', 'item owner', 'designated owner'],
        ['program chair', 'programchair', 'chair'],
        ['sdao'],
        ['do'],
        ['security'],
        ['physical facilities', 'facilities', 'physical'],
      ];

      final applicableStages = <List<String>>[];
      if (hasGymSpace) {
        applicableStages.add(approvalStages.first);
      }
      if (hasNonPhysicalFacilitiesItems) {
        applicableStages.add(
          approvalStages[hasGymSpace ? 1 : 0],
        );
      }
      applicableStages.addAll(
        approvalStages.sublist(hasGymSpace ? 2 : 1),
      );

      final approvedStages = <int>{};
      for (final approval in approvals) {
        if (approval.status != 'approved') continue;
        final office = officeMap[approval.officeId];
        if (office == null) continue;

        final normalized = office.departmentName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
        for (var i = 0; i < applicableStages.length; i++) {
          final hasMatch = applicableStages[i].any((alias) {
            final normalizedAlias = alias.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
            return normalized == normalizedAlias;
          });
          if (hasMatch) {
            approvedStages.add(i);
            break;
          }
        }
      }
      return _ApprovalProgress(
        completedCount: approvedStages.length,
        totalCount: applicableStages.length,
      );
    } catch (e) {
      return const _ApprovalProgress(completedCount: 0, totalCount: 0);
    }
  }

  String _formatDurationLabel(Duration diff) {
    if (diff.isNegative) diff = diff.abs();
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    if (days > 0) return '${days}d ${hours}h';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  bool get _hasStart => widget.reservation.startOfActivity != null;
  bool get _hasEnd => widget.reservation.endOfActivity != null;
  DateTime get _now => DateTime.now();
  bool get _isReturned => (widget.reservation.overallStatus ?? '').toLowerCase() == 'returned';
  bool get _isOverdueReturn {
    if (!_hasEnd || _isReturned) return false;
    return _now.isAfter(widget.reservation.endOfActivity!.add(const Duration(hours: 24)));
  }

  bool get _isToReturn {
    if (!_hasEnd || _isReturned) return false;
    final end = widget.reservation.endOfActivity!;
    return _now.isAfter(end) && _now.isBefore(end.add(const Duration(hours: 24)));
  }

  bool get _isEventInProgress {
    if (!_hasStart || !_hasEnd) return false;
    return _now.isAfter(widget.reservation.startOfActivity!) && _now.isBefore(widget.reservation.endOfActivity!);
  }

  bool get _isEventUpcoming {
    if (!_hasStart) return false;
    return _now.isBefore(widget.reservation.startOfActivity!);
  }

  Widget _buildEventStatusBlock() {
    if (!_hasStart || !_hasEnd) return const SizedBox.shrink();

    String label;
    Color backgroundColor;
    Color textColor = const Color(0xFFF5BC1D);

    if (_isOverdueReturn) {
      final overdue = _now.difference(widget.reservation.endOfActivity!.add(const Duration(hours: 24)));
      label = 'Overdue Returning • ${_formatDurationLabel(overdue)} late';
      backgroundColor = const Color(0xFFEF5350);
      textColor = Colors.white;
    } else if (_isToReturn) {
      final due = widget.reservation.endOfActivity!.add(const Duration(hours: 24)).difference(_now);
      label = 'Return within 24h • ${_formatDurationLabel(due)}';
      backgroundColor = const Color(0xFFF5BC1D);
      textColor = Colors.black;
    } else if (_isEventInProgress) {
      final remaining = widget.reservation.endOfActivity!.difference(_now);
      label = 'Event ongoing • ${_formatDurationLabel(remaining)} left';
      backgroundColor = const Color(0xFF233B7A);
      textColor = const Color(0xFFF5BC1D);
    } else if (_isEventUpcoming) {
      final untilStart = widget.reservation.startOfActivity!.difference(_now);
      final status = (widget.reservation.overallStatus ?? '').toLowerCase() == 'pending' ? 'Pending Approval' : 'Approved';
      label = '$status • Starts in ${_formatDurationLabel(untilStart)}';
      backgroundColor = const Color(0xFF233B7A);
      textColor = const Color(0xFFF5BC1D);
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _isOverdueReturn ? Icons.warning_rounded : Icons.schedule,
            color: textColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine icon based on activity type
    IconData getIconForActivity(String activityName) {
      final name = activityName.toLowerCase();
      if (name.contains('room')) return Icons.apartment_rounded;
      if (name.contains('item') || name.contains('borrow')) return Icons.shopping_bag_rounded;
      if (name.contains('gym')) return Icons.sports_gymnastics_rounded;
      if (name.contains('av') || name.contains('multimedia')) return Icons.videocam_rounded;
      return Icons.event_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E8F4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AuthPalette.royalBlue,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  getIconForActivity(widget.reservation.activityName),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.reservation.activityName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _getStatusLabel(widget.reservation.overallStatus),
                      style: TextStyle(
                        fontSize: 13,
                        color: _getStatusColor(widget.reservation.overallStatus),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x18000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Color(0xFF848484)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _formatDate(
                      widget.reservation.dateOfActivity ?? widget.reservation.createdAt,
                    ),
                    style: const TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final didCancel = await showReservationStatusDialog(
                      context,
                      reservationId: widget.reservation.reservationId,
                    );
                    if (didCancel == true) {
                      widget.onRefresh();
                    }
                  },
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: AuthPalette.royalBlue,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4D4D4),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.edit_square, color: Color(0xFF8E8E8E), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildEventStatusBlock(),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getStatusLabel(String? status) {
    final normalized = (status ?? '').toLowerCase();
    if (normalized == 'pending' || normalized.contains('pending')) {
      return 'Pending Approval';
    }
    switch (normalized) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      case 'returned':
        return 'Returned';
      default:
        return status ?? 'Unknown';
    }
  }

  Color _getStatusColor(String? status) {
    final normalized = (status ?? '').toLowerCase();
    if (normalized == 'pending' || normalized.contains('pending')) {
      return const Color(0xFFECC67E);
    }
    switch (normalized) {
      case 'approved':
        return const Color(0xFF4CAF50);
      case 'rejected':
        return const Color(0xFFEF5350);
      case 'completed':
        return const Color(0xFF9FD4A7);
      case 'returned':
        return const Color(0xFF9FD4A7);
      default:
        return const Color(0xFF696969);
    }
  }
}

class _ApprovalProgress {
  final int completedCount;
  final int totalCount;

  const _ApprovalProgress({
    required this.completedCount,
    required this.totalCount,
  });

  bool get isComplete => totalCount > 0 && completedCount >= totalCount;
}

class _CountdownTimerWidget extends StatefulWidget {
  final DateTime startTime;
  final DateTime endTime;

  const _CountdownTimerWidget({
    required this.startTime,
    required this.endTime,
  });

  @override
  State<_CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<_CountdownTimerWidget> {
  late Timer _timer;
  String _timerText = '';

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _updateCountdown();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    final now = DateTime.now();
    String newText;

    if (now.isAfter(widget.endTime)) {
      newText = 'Event completed';
    } else if (now.isBefore(widget.startTime)) {
      final diff = widget.startTime.difference(now);
      if (diff.inDays > 0) {
        newText = 'In ${diff.inDays}d ${diff.inHours % 24}h';
      } else if (diff.inHours > 0) {
        newText = 'In ${diff.inHours}h ${diff.inMinutes % 60}m';
      } else {
        newText = 'In ${diff.inMinutes}m';
      }
    } else {
      final diff = widget.endTime.difference(now);
      newText = '${diff.inHours}h ${diff.inMinutes % 60}m left';
    }

    if (mounted && _timerText != newText) {
      setState(() {
        _timerText = newText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF233B7A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, color: Color(0xFFF5BC1D), size: 16),
          const SizedBox(width: 6),
          Text(
            _timerText,
            style: const TextStyle(
              color: Color(0xFFF5BC1D),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Unified Nutilize header widget
class NutilizeHeader extends StatelessWidget {
  const NutilizeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AuthPalette.royalBlueDark, AuthPalette.royalBlue],
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: SizedBox(
                  height: 38,
                  child: Image.asset(
                    'assets/images/nutilize_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [
                    AnimatedBuilder(
                      animation: NotificationService.instance,
                      builder: (context, _) {
                        final hasUnread =
                            NotificationService.instance.unreadCount > 0;
                        return Stack(
                          children: [
                            _HeaderIconButton(
                              icon: Icons.notifications,
                              onTap: () {
                                showNotificationsPanel(context);
                              },
                            ),
                            if (hasUnread)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(height: 3, color: AuthPalette.yellow),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEAF0FF),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: AuthPalette.royalBlue, size: 21),
        ),
      ),
    );
  }
}
