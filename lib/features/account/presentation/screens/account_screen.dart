import 'package:flutter/material.dart';
import 'package:nutilize/core/widgets/notification_panel.dart';
import 'package:nutilize/features/auth/shared/presentation/widgets/auth_ui.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1100;
    if (isDesktop) {
      return const _AccountDesktopPage();
    }

    return Stack(
      children: [
        const _AtmosphericBackdrop(),
        SafeArea(
          top: false,
          child: Column(
            children: [
              const _AccountTopStrip(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                  children: const [
                    _AccountGreeting(),
                    SizedBox(height: 10),
                    _PageTitle(),
                    SizedBox(height: 16),
                    _ProfileCard(),
                    SizedBox(height: 14),
                    _BorrowingHeader(),
                    SizedBox(height: 10),
                    _BorrowingHistoryCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountDesktopPage extends StatelessWidget {
  const _AccountDesktopPage();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _AtmosphericBackdrop(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3E4FA8), Color(0xFF5E71C7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x23000000),
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: const Text(
                  'PROFILE & BORROWING HISTORY',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xDDE8ECF8),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0x77FFFFFF)),
                        ),
                        child: const _ProfileCard(),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xDDE8ECF8),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0x77FFFFFF)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _BorrowingHeader(),
                            SizedBox(height: 10),
                            Expanded(child: _BorrowingHistoryCard()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AtmosphericBackdrop extends StatelessWidget {
  const _AtmosphericBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F6FA), Color(0xFFE8ECF7)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -50,
            child: Container(
              width: 190,
              height: 190,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x26FFFFFF),
              ),
            ),
          ),
          Positioned(
            bottom: -70,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1D4B5BB5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTopStrip extends StatelessWidget {
  const _AccountTopStrip();

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
                return const Text(
                  'NU TILIZE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
          ),
        ),
        Container(height: 4, color: AuthPalette.yellow),
      ],
    );
  }
}

class _AccountGreeting extends StatelessWidget {
  const _AccountGreeting();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Evening',
                style: TextStyle(
                  fontSize: 35 / 1.7,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  _UserPillLabel(),
                  SizedBox(width: 6),
                  Text('👋', style: TextStyle(fontSize: 20)),
                ],
              ),
            ],
          ),
        ),
        const NotificationBellButton(),
      ],
    );
  }
}

class _UserPillLabel extends StatelessWidget {
  const _UserPillLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF5664AE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Kirk Popiolek',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Reservation Calendar',
          style: TextStyle(
            fontSize: 38 / 1.7,
            color: Color(0xFF4C4C52),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 58),
          child: Divider(color: Color(0xFFB2B7C7), height: 1),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF1F3FA), Color(0xFFE2E7F5)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x7FFFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Column(
        children: [
          _InfoBlock(
            icon: Icons.account_circle,
            title: 'Full Name',
            lines: [
              ('First name:', 'Kirk'),
              ('Middle Name:', 'Paramil'),
              ('Last Name:', 'Papiolek'),
            ],
          ),
          SizedBox(height: 14),
          _InfoBlock(
            icon: Icons.apartment_rounded,
            title: 'Department',
            lines: [('Position:', 'Faculty Teacher'), ('Affiliation:', 'SACE')],
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.icon,
    required this.title,
    required this.lines,
  });

  final IconData icon;
  final String title;
  final List<(String, String)> lines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
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
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              ...lines.map(
                (line) => Text.rich(
                  TextSpan(
                    text: '${line.$1} ',
                    style: const TextStyle(
                      fontSize: 18 / 1.2,
                      color: Color(0xFF767676),
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: line.$2,
                        style: const TextStyle(
                          color: Color(0xFF191919),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BorrowingHeader extends StatelessWidget {
  const _BorrowingHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _HistoryIcon(),
        SizedBox(width: 10),
        Text(
          'History of borrowing',
          style: TextStyle(
            fontSize: 34 / 2,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F3A),
          ),
        ),
      ],
    );
  }
}

class _HistoryIcon extends StatelessWidget {
  const _HistoryIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AuthPalette.royalBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.history_rounded, color: Colors.white, size: 24),
    );
  }
}

class _BorrowingHistoryCard extends StatelessWidget {
  const _BorrowingHistoryCard();

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('Room 530', 'ML Tournament', '03/19/2026 - 03/20/2026'),
      ('Room 531', 'Badminton class', '03/17/2026 - 03/18/2026'),
      ('Room 532', 'Christmas party', '03/15/2026 - 03/16/2026'),
      ('Room 533', 'Awarding session', '03/13/2026 - 03/14/2026'),
      ('Room 534', 'Org Meeting', '03/10/2026 - 03/11/2026'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0F3FB), Color(0xFFE2E7F5)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x7FFFFFFF)),
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
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFDDE2F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: rows.asMap().entries.map((entry) {
                  final row = entry.value;
                  return Container(
                    color: entry.key.isEven
                        ? const Color(0x31FFFFFF)
                        : Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              row.$1,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF535353),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              row.$2,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF535353),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              row.$3,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF535353),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 4,
            height: 160,
            decoration: BoxDecoration(
              color: AuthPalette.royalBlue,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}
