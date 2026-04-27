import 'package:flutter/material.dart';
import 'package:nutilize/core/widgets/notification_panel.dart';
import 'package:nutilize/features/auth/shared/presentation/widgets/auth_ui.dart';
import 'room_reservation_form_widgets.dart';
import 'bigger_spaces_form_widgets.dart';
import 'package:nutilize/shared/components/nutilize_header.dart';
import 'package:nutilize/shared/components/simple_header.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1100;
    if (isDesktop) {
      return const _RequestsDesktopPage();
    }

    return ColoredBox(
      color: const Color(0xFFF2F2F2),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SimpleHeader(title: 'REQUESTS'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                children: [
                  const _RequestHeadline(),
                  const SizedBox(height: 20),
                  _RequestTypeCard(
                    icon: Icons.apartment_rounded,
                    titleTop: 'NU Lipa',
                    titleBottom: 'Room Reservation',
                    subtitle: 'Borrow Rooms & Items',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RoomReservationFormPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _RequestTypeCard(
                    icon: Icons.chair_alt_rounded,
                    titleTop: 'NU Lipa',
                    titleBottom: 'Item Reservation',
                    subtitle: 'Borrow Items',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ItemReservationFormPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _RequestTypeCard(
                    icon: Icons.fitness_center_rounded,
                    titleTop: 'Bigger Spaces',
                    titleBottom: 'Within NU',
                    subtitle: 'Borrow bigger spaces',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const BiggerSpacesReservationFormPage(),
                        ),
                      );
                    },
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

class _RequestsDesktopPage extends StatelessWidget {
  const _RequestsDesktopPage();

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
              'REQUEST CENTER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42 / 1.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE7EAF5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const _RequestHeadline(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _RequestTypeCard(
                          icon: Icons.apartment_rounded,
                          titleTop: 'NU Lipa',
                          titleBottom: 'Room Reservation',
                          subtitle: 'Borrow Rooms & Items',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RoomReservationFormPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _RequestTypeCard(
                          icon: Icons.chair_alt_rounded,
                          titleTop: 'NU Lipa',
                          titleBottom: 'Item Reservation',
                          subtitle: 'Borrow Items',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ItemReservationFormPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _RequestTypeCard(
                          icon: Icons.fitness_center_rounded,
                          titleTop: 'Bigger Spaces',
                          titleBottom: 'Within NU',
                          subtitle: 'Borrow bigger spaces',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const BiggerSpacesReservationFormPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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

class _RequestHeadline extends StatelessWidget {
  const _RequestHeadline();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Select Your Request',
          style: TextStyle(
            fontSize: 38 / 1.7,
            color: Color(0xFF656565),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 58),
          child: Divider(color: Color(0xFFB7B7B7), height: 1),
        ),
      ],
    );
  }
}

class _RequestTypeCard extends StatelessWidget {
  const _RequestTypeCard({
    required this.icon,
    required this.titleTop,
    required this.titleBottom,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String titleTop;
  final String titleBottom;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE6E8F2),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x28000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AuthPalette.royalBlue,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: Colors.white, size: 34),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleTop,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    titleBottom,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 19 / 1.2,
                      color: Color(0xFF7A7A7A),
                      fontWeight: FontWeight.w500,
                    ),
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
