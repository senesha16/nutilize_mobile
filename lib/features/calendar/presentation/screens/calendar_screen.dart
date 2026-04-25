import 'package:flutter/material.dart';
//import 'package:flutter/cupertino.dart';
import 'package:nutilize/core/models/reservation.dart';
import 'package:nutilize/core/services/reservation_service.dart';
import 'package:nutilize/core/widgets/notification_panel.dart';
import 'package:nutilize/features/auth/data/auth_service.dart';
import 'package:nutilize/features/home/presentation/widgets/reservation_status_dialog.dart';
//import 'package:nutilize/shared/components/nutilize_header.dart';
import 'package:nutilize/shared/components/simple_header.dart';

import 'package:nutilize/features/auth/shared/presentation/widgets/auth_ui.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1100;
    if (isDesktop) {
      return const _CalendarDesktopPage();
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF2F2F2), Color(0xFFE6E8F2)],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SimpleHeader(title: 'CALENDAR'),
            Expanded(child: _IphoneStyleCalendar()),
          ],
        ),
      ),
    );
  }
}

class _IphoneStyleCalendar extends StatefulWidget {
  const _IphoneStyleCalendar();

  @override
  State<_IphoneStyleCalendar> createState() => _IphoneStyleCalendarState();
}

class _IphoneStyleCalendarState extends State<_IphoneStyleCalendar> {
  int selectedDay = DateTime.now().day;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  final AuthService _authService = AuthService();
  final ReservationService _reservationService = ReservationService();
  bool _isLoadingReservations = true;
  String? _reservationError;
  final Map<String, List<_CalendarReservationEvent>> reservations = {};

  @override
  void initState() {
    super.initState();
    _loadApprovedReservations();
  }

  Future<void> _loadApprovedReservations() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        if (!mounted) return;
        setState(() {
          _isLoadingReservations = false;
          _reservationError = 'Please log in to view calendar reservations.';
        });
        return;
      }

      final userReservations = await _reservationService.getUserReservations(
        user.userId,
      );
      final mapped = <String, List<_CalendarReservationEvent>>{};

      for (final reservation in userReservations) {
        if ((reservation.overallStatus ?? '').toLowerCase() != 'approved') {
          continue;
        }

        final eventStart = reservation.startOfActivity ?? reservation.dateOfActivity;
        final eventEnd = reservation.endOfActivity;
        if (eventStart == null) continue;

        final dateKey = _formatDateKey(eventStart);
        mapped.putIfAbsent(dateKey, () => []);
        mapped[dateKey]!.add(
          _CalendarReservationEvent(
            reservationId: reservation.reservationId,
            title: reservation.activityName,
            description: _buildEventDescription(reservation),
            startTime: eventStart,
            endTime: eventEnd,
          ),
        );
      }

      for (final events in mapped.values) {
        events.sort((a, b) => a.startTime.compareTo(b.startTime));
      }

      if (!mounted) return;
      setState(() {
        reservations
          ..clear()
          ..addAll(mapped);
        _isLoadingReservations = false;
        _reservationError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingReservations = false;
        _reservationError = 'Failed to load reservations.';
      });
    }
  }

  String _formatDateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final isPm = hour >= 12;
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final suffix = isPm ? 'PM' : 'AM';
    return '$hour12:$minute $suffix';
  }

  String _buildEventDescription(Reservation reservation) {
    if (reservation.startOfActivity != null && reservation.endOfActivity != null) {
      return '${_formatTime(reservation.startOfActivity!)} - ${_formatTime(reservation.endOfActivity!)}';
    }
    if (reservation.startOfActivity != null) {
      return _formatTime(reservation.startOfActivity!);
    }
    return 'Approved reservation';
  }

  Future<void> _showSchedulePopup(_CalendarReservationEvent event) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFFF2F2F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NUtilize Reservation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 22),
                _PopupInfoRow(
                  icon: Icons.apartment_rounded,
                  title: event.title,
                  subtitle: event.description,
                ),
                const SizedBox(height: 14),
                const _PopupInfoRow(
                  icon: Icons.place,
                  title: 'Location',
                  subtitle: 'Fifth Floor of NU Lipa Infront of Library',
                ),
                const SizedBox(height: 14),
                _PopupInfoRow(
                  icon: Icons.access_time_filled,
                  title: 'Time',
                  subtitle: event.endTime == null
                      ? _formatTime(event.startTime)
                      : '${_formatTime(event.startTime)} - ${_formatTime(event.endTime!)}',
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E4FA8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      await showReservationStatusDialog(
                        context,
                        reservationId: event.reservationId,
                      );
                    },
                    child: const Text(
                      'Check Reservation',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
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
    // Colors (light theme, blue/yellow)
    const bgColor = Color(0xFFF2F2F2);
    const textColor = Color(0xFF222222);
    const subTextColor = Color(0xFF757575);
    const selectedColor = Color(0xFF3E4FA8); // Royal Blue
    const eventDotColor = Color(0xFFFFD600); // Yellow

    // Helper to get number of days in a month
    int _daysInMonth(int year, int month) {
      if (month == 12) return DateTime(year + 1, 1, 0).day;
      return DateTime(year, month + 1, 0).day;
    }

    // Helper to get first weekday (0=Sun, 1=Mon...)
    int _firstWeekday(int year, int month) {
      return DateTime(year, month, 1).weekday % 7;
    }

    // Helper to get month name
    String _monthName(int month) {
      const names = [
        '',
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return names[month];
    }

    final numDaysInMonth = _daysInMonth(selectedYear, selectedMonth);
    final firstDayWeekday = _firstWeekday(selectedYear, selectedMonth);
    final days = List.generate(numDaysInMonth, (i) => i + 1);
    final List<Widget> rows = [];
    int dayIndex = 0;

    // Collect event days for this month
    final eventDays = <int>{};
    reservations.forEach((key, value) {
      final parts = key.split('-');
      if (parts.length == 3 &&
          int.parse(parts[0]) == selectedYear &&
          int.parse(parts[1]) == selectedMonth) {
        eventDays.add(int.parse(parts[2]));
      }
    });

    for (int week = 0; week < 6; week++) {
      List<Widget> weekRow = [];
      for (int weekday = 0; weekday < 7; weekday++) {
        if (week == 0 && weekday < firstDayWeekday) {
          weekRow.add(const Expanded(child: SizedBox.shrink()));
        } else if (dayIndex < days.length) {
          final day = days[dayIndex];
          final isSelected = day == selectedDay;
          final hasEvent = eventDays.contains(day);
          weekRow.add(
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDay = day;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: isSelected
                      ? BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: selectedColor.withOpacity(0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        )
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Text(
                          '$day',
                          style: TextStyle(
                            color: isSelected ? Colors.white : textColor,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      if (hasEvent)
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(bottom: 2),
                          decoration: BoxDecoration(
                            color: eventDotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
          dayIndex++;
        } else {
          weekRow.add(const Expanded(child: SizedBox.shrink()));
        }
      }
      rows.add(Row(children: weekRow));
      if (dayIndex >= days.length) break;
    }

    // Agenda for selected day
    final String selectedKey =
        '${selectedYear.toString().padLeft(4, '0')}-${selectedMonth.toString().padLeft(2, '0')}-${selectedDay.toString().padLeft(2, '0')}';
    final agenda = List<_CalendarReservationEvent>.from(
      reservations[selectedKey] ?? const [],
    )..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Container(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month and year header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        _monthName(selectedMonth),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedYear.toString(),
                        style: const TextStyle(
                          fontSize: 22,
                          color: subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Navigation arrows
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: subTextColor,
                          size: 28,
                        ),
                        onPressed: () {
                          setState(() {
                            if (selectedMonth == 1) {
                              selectedMonth = 12;
                              selectedYear--;
                            } else {
                              selectedMonth--;
                            }
                            // Clamp selectedDay to new month
                            final maxDay = _daysInMonth(
                              selectedYear,
                              selectedMonth,
                            );
                            if (selectedDay > maxDay) selectedDay = maxDay;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_right,
                          color: subTextColor,
                          size: 28,
                        ),
                        onPressed: () {
                          setState(() {
                            if (selectedMonth == 12) {
                              selectedMonth = 1;
                              selectedYear++;
                            } else {
                              selectedMonth++;
                            }
                            // Clamp selectedDay to new month
                            final maxDay = _daysInMonth(
                              selectedYear,
                              selectedMonth,
                            );
                            if (selectedDay > maxDay) selectedDay = maxDay;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Weekday labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Expanded(
                    child: Center(
                      child: Text(
                        'S',
                        style: TextStyle(
                          color: subTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'M',
                        style: TextStyle(
                          color: subTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'T',
                        style: TextStyle(
                          color: subTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'W',
                        style: TextStyle(
                          color: subTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'T',
                        style: TextStyle(
                          color: subTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'F',
                        style: TextStyle(
                          color: subTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'S',
                        style: TextStyle(
                          color: subTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Calendar grid
              ...rows,
              const SizedBox(height: 18),
              // Agenda view (time slots)
              const Divider(thickness: 1.1, color: Color(0xFFBDBDBD)),
              const SizedBox(height: 8),
              Text(
                selectedDay == DateTime.now().day &&
                        selectedMonth == DateTime.now().month &&
                        selectedYear == DateTime.now().year
                    ? 'Today'
                    : '',
                style: const TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              if (_isLoadingReservations)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(color: selectedColor),
                  ),
                )
              else if (_reservationError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    _reservationError!,
                    style: const TextStyle(
                      color: Color(0xFFEF5350),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else if (agenda.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'No approved reservations for this day.',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                ...agenda.map((event) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => _showSchedulePopup(event),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9ECF7),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 10, top: 2),
                              child: const Icon(
                                Icons.apartment_rounded,
                                color: selectedColor,
                                size: 22,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: selectedColor,
                                    ),
                                  ),
                                  Text(
                                    event.description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    event.endTime == null
                                        ? _formatTime(event.startTime)
                                        : '${_formatTime(event.startTime)} - ${_formatTime(event.endTime!)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: subTextColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarReservationEvent {
  final int reservationId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime? endTime;

  const _CalendarReservationEvent({
    required this.reservationId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
  });
}

// _CalendarGrid widget at top level
class _CalendarGrid extends StatelessWidget {
  final List<int> eventDays = const [2, 5, 8, 15, 18, 22, 25, 28];
  final int selectedDay = 15;

  @override
  Widget build(BuildContext context) {
    // March 2026 starts on Sunday (index 0), 31 days
    const daysInMonth = 31;
    const firstWeekday = 0; // Sunday
    final days = List.generate(daysInMonth, (i) => i + 1);
    final List<Widget> rows = [];
    int dayIndex = 0;

    for (int week = 0; week < 6; week++) {
      List<Widget> weekRow = [];
      for (int weekday = 0; weekday < 7; weekday++) {
        if (week == 0 && weekday < firstWeekday) {
          weekRow.add(const Expanded(child: SizedBox.shrink()));
        } else if (dayIndex < days.length) {
          final day = days[dayIndex];
          final isSelected = day == selectedDay;
          final hasEvent = eventDays.contains(day);
          weekRow.add(
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: isSelected
                    ? BoxDecoration(
                        color: AuthPalette.royalBlue,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AuthPalette.royalBlue.withOpacity(0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      )
                    : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF222222),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    if (hasEvent)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AuthPalette.yellow
                              : AuthPalette.royalBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
          dayIndex++;
        } else {
          weekRow.add(const Expanded(child: SizedBox.shrink()));
        }
      }
      rows.add(Row(children: weekRow));
      if (dayIndex >= days.length) break;
    }

    return Column(
      children: [
        // Weekday labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Expanded(
              child: Center(
                child: Text('S', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('M', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('T', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('W', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('T', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('F', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('S', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...rows,
      ],
    );
  }
}

class _PopupInfoRow extends StatelessWidget {
  const _PopupInfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFF3E4FA8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6F6F6F),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Remove all duplicate widget classes below this point (from line ~550 onward).

// (Remove duplicate widget class de                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               this comment. Only keep the first definition of each widget class.)

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'March',
                    style: TextStyle(
                      fontSize: 34 / 1.7,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                ],
              ),
              Text(
                '2026',
                style: TextStyle(
                  fontSize: 33 / 2,
                  color: Color(0xFF222222),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _HeaderIcon(icon: Icons.phone_android_rounded, active: true),
        const SizedBox(width: 8),
        _HeaderIcon(icon: Icons.calendar_month_rounded),
        const SizedBox(width: 8),
        const NotificationBellButton(),
      ],
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 9),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E6ED),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: const [
          _MiniBlueIcon(icon: Icons.notifications),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Reminder',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '(Room 530)',
                      style: TextStyle(fontSize: 16, color: Color(0xFF777777)),
                    ),
                  ],
                ),
                Text(
                  'Your event starts in a\nFew minutes',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF777777),
                    height: 1.2,
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

class _EventBlock extends StatelessWidget {
  const _EventBlock();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 98,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0x24A8A8B4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0x33858590)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _MiniBlueIcon(icon: Icons.apartment_rounded),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Room 530',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'ML Tournament | Intrams',
                  style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: Color(0xFF757575)),
                    SizedBox(width: 4),
                    Text(
                      '10:00 am - 5:00 pm',
                      style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarDesktopPage extends StatelessWidget {
  const _CalendarDesktopPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              'CALENDAR OVERVIEW',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42 / 1.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7EAF5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const _WeekStrip(),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7EAF5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const _TimelineView(),
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

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, this.active = false});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: active ? AuthPalette.royalBlue : const Color(0xFFD3D3D3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: active ? Colors.white : const Color(0xFF7A7A7A),
        size: 19,
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  @override
  Widget build(BuildContext context) {
    const days = ['sun', 'mon', 'tue', 'wed', 'thurs', 'fri', 'sat'];
    const dates = ['15', '16', '17', '18', '19', '20', '21'];
    const selectedIndex = 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(days.length, (index) {
            final selected = index == selectedIndex;
            return Container(
              width: 42,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AuthPalette.royalBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 15,
                      color: selected ? Colors.white : const Color(0xFF8B8B8B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dates[index],
                    style: TextStyle(
                      fontSize: 34 / 2,
                      color: selected ? Colors.white : const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(days.length, (index) {
            final selected = index == selectedIndex;
            return SizedBox(
              width: 42,
              child: Center(
                child: selected
                    ? const Text(
                        '•••',
                        style: TextStyle(
                          color: AuthPalette.yellow,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _TimelineView extends StatelessWidget {
  const _TimelineView();

  @override
  Widget build(BuildContext context) {
    const times = [
      '7:00\nAM',
      '8:00\nAM',
      '9:00\nAM',
      '10:00\nAM',
      '11:00\nAM',
      '12:00\nPM',
      '1:00\nPM',
      '2:00\nPM',
    ];

    return Column(
      children: List.generate(times.length, (index) {
        return SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 46,
                child: Text(
                  times[index],
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF8B8B8B),
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: Divider(color: Color(0xFFB8B8B8), height: 1),
                    ),
                    if (index == 1)
                      const Positioned(
                        left: 0,
                        right: 4,
                        top: -2,
                        child: _ReminderCard(),
                      ),
                    if (index == 4)
                      const Positioned(
                        left: 8,
                        right: 8,
                        top: -2,
                        child: _EventBlock(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _MiniBlueIcon extends StatelessWidget {
  const _MiniBlueIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AuthPalette.royalBlue,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}
