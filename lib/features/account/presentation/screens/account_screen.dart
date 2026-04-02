import 'package:flutter/material.dart';
import 'package:nutilize/core/widgets/notification_panel.dart';
import 'package:nutilize/features/auth/shared/presentation/widgets/auth_ui.dart';
// import 'package:nutilize/shared/components/nutilize_header.dart';
import 'package:nutilize/shared/components/simple_header.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: GoogleFonts.poppins(fontSize: 18),
      child: Stack(
        children: [
          const _AtmosphericBackdrop(),
          SafeArea(
            top: false,
            child: Column(
              children: [
                const SimpleHeader(title: 'ACCOUNT'),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                    children: [
                      // Profile Card
                      _ProfileCardV2(),
                      const SizedBox(height: 18),
                      // Status Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Expanded(
                            child: _StatusCardV2(
                              icon: Icons.calendar_today_rounded,
                              count: 12,
                              label: 'Reserved',
                              color: Color(0xFFF1B60D),
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: _StatusCardV2(
                              icon: Icons.hourglass_top_rounded,
                              count: 3,
                              label: 'Pending',
                              color: Color(0xFFF57C1F),
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: _StatusCardV2(
                              icon: Icons.check_circle_rounded,
                              count: 9,
                              label: 'Approved',
                              color: Color(0xFF1BC47D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Navigation Tiles
                      _NavTile(
                        icon: Icons.calendar_month_rounded,
                        label: 'My Reservation',
                        onTap: () {},
                      ),
                      _NavTile(
                        icon: Icons.assignment_rounded,
                        label: 'My Requests',
                        onTap: () {},
                      ),
                      _NavTile(
                        icon: Icons.history_rounded,
                        label: 'History',
                        onTap: () {},
                      ),
                      const SizedBox(height: 18),
                      // Settings
                      _SettingsTile(),
                      const SizedBox(height: 18),
                      // Logout
                      _LogoutButton(),
                    ],
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

class _ProfileCardV2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF5664AE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 38),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Kirk Papiolek',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'papiollekks@nu-lipa.edu.ph',
                      style: TextStyle(fontSize: 14, color: Color(0xFF7A7A7A)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Professor 2 | SACE',
                      style: TextStyle(fontSize: 14, color: Color(0xFF7A7A7A)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.edit, size: 20, color: Color(0xFF5664AE)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCardV2 extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;
  const _StatusCardV2({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Remove fixed width, let Expanded control width
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF7A7A7A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF5664AE)),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Color(0xFF232323),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFFB2B7C7),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7FB),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SwitchListTile(
            value: false,
            onChanged: (v) {},
            title: const Text(
              'Dark Mode',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            secondary: const Icon(
              Icons.nightlight_round,
              color: Color(0xFF5664AE),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _NavTile(
          icon: Icons.privacy_tip_rounded,
          label: 'Privacy and Security',
          onTap: () {},
        ),
        _NavTile(
          icon: Icons.info_rounded,
          label: 'About NUtilize',
          onTap: () {},
        ),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout, color: Color(0xFF5664AE)),
        label: const Text(
          'Log out',
          style: TextStyle(
            color: Color(0xFF5664AE),
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF6F7FB),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
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
