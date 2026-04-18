import 'package:flutter/material.dart';
import 'package:nutilize/features/auth/shared/presentation/widgets/auth_ui.dart';
import 'package:nutilize/features/account/presentation/screens/account_screen.dart';
import 'package:nutilize/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:nutilize/features/home/presentation/screens/home_screen.dart';
import 'package:nutilize/features/requests/presentation/screens/requests_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static const routeName = '/app';

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _labels = ['Home', 'Calendar', 'Requests', 'Account'];
  static const _icons = [
    Icons.home_rounded,
    Icons.calendar_month_rounded,
    Icons.edit_square,
    Icons.person_rounded,
  ];

  static final List<Widget> _tabs = [
    HomeScreen(),
    CalendarScreen(),
    RequestsScreen(),
    AccountScreen(),
  ];

  static const _desktopIcons = [
    Icons.home_rounded,
    Icons.calendar_month_outlined,
    Icons.assignment_turned_in_outlined,
    Icons.person_outline_rounded,
  ];

  static const _desktopLabels = ['Home', 'Calendar', 'Requests', 'Account'];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1100;

        if (isDesktop) {
          return Scaffold(
            backgroundColor: const Color(0xFFDCE1EF),
            body: Column(
              children: [
                const _DesktopTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    child: Row(
                      children: [
                        _DesktopSidebar(
                          selectedIndex: _currentIndex,
                          labels: _desktopLabels,
                          icons: _desktopIcons,
                          onTap: (index) =>
                              setState(() => _currentIndex = index),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFCFD5E6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFC1C9DF),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x15000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: IndexedStack(
                                index: _currentIndex,
                                children: _tabs,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: _tabs),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: _FloatingDockNavBar(
              currentIndex: _currentIndex,
              labels: _labels,
              icons: _icons,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ),
        );
      },
    );
  }
}

class _DesktopTopBar extends StatelessWidget {
  const _DesktopTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: AuthPalette.royalBlue,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  height: 38,
                  child: Image.asset(
                    'assets/images/nutilize_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'NU TILIZE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                ),
                const Spacer(),
                const _TopIcon(icon: Icons.search_rounded),
                const SizedBox(width: 14),
                const _TopIcon(icon: Icons.chat_bubble),
                const SizedBox(width: 14),
                const _TopIcon(icon: Icons.notifications),
                const SizedBox(width: 14),
                Container(width: 1, height: 42, color: const Color(0x66FFFFFF)),
                const SizedBox(width: 14),
                const CircleAvatar(
                  radius: 19,
                  backgroundColor: Color(0x2CFFFFFF),
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
              ],
            ),
          ),
          Container(height: 4, color: AuthPalette.yellow),
        ],
      ),
    );
  }
}

class _TopIcon extends StatelessWidget {
  const _TopIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0x2CFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x3AFFFFFF)),
      ),
      child: Icon(icon, color: Colors.white, size: 25),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.selectedIndex,
    required this.labels,
    required this.icons,
    required this.onTap,
  });

  final int selectedIndex;
  final List<String> labels;
  final List<IconData> icons;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFC4CBDE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xB0AFB9D2)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
      child: Column(
        children: List.generate(
          labels.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DesktopSidebarItem(
              icon: icons[index],
              label: labels[index],
              selected: selectedIndex == index,
              onTap: () => onTap(index),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopSidebarItem extends StatelessWidget {
  const _DesktopSidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4458B3) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x27000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : const Color(0xFF232323),
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF222222),
                  fontSize: 31 / 1.8,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingDockNavBar extends StatelessWidget {
  const _FloatingDockNavBar({
    required this.currentIndex,
    required this.labels,
    required this.icons,
    required this.onTap,
  });

  final int currentIndex;
  final List<String> labels;
  final List<IconData> icons;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isCompactWidth = MediaQuery.sizeOf(context).width < 420;

    return Container(
      height: isCompactWidth ? 60 : 64,
      padding: EdgeInsets.symmetric(
        horizontal: isCompactWidth ? 6 : 8,
        vertical: isCompactWidth ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFD1D1D1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(
          icons.length,
          (index) => Expanded(
            child: _DockNavItem(
              icon: icons[index],
              label: labels[index],
              isActive: currentIndex == index,
              onTap: () => onTap(index),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockNavItem extends StatelessWidget {
  const _DockNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCompactWidth = MediaQuery.sizeOf(context).width < 420;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        height: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: isCompactWidth ? 3 : 4),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF5A67B0) : const Color(0xFFD8D8D8),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Icon(
            icon,
            size: isCompactWidth ? 20 : 21,
            color: isActive ? Colors.white : const Color(0xFF8D8D8D),
          ),
        ),
      ),
    );
  }
}
