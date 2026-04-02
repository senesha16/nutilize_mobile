import 'package:flutter/material.dart';

class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key, this.size = 34});

  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showNotificationsPanel(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: Color(0xFF34479A),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.notifications,
              color: Colors.white,
              size: size * 0.56,
            ),
          ),
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF2F2F2), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showNotificationsPanel(BuildContext context) async {
  const items = [
    ('Maria Lerma has submitte...', true, true),
    ('Joel Enriquez has submitte...', true, true),
    ('Mars Fha Uthang has sub...', false, false),
    ('Maria Santos has submitt...', true, true),
    ('Anne Lopez has submitted ...', false, false),
    ('Juan Dela Cruz has submit...', false, false),
    ('Phengie Pira has submitte...', false, false),
    ('Jepoy Dizon has submitte...', true, true),
  ];

  await showGeneralDialog<void>(
    context: context,
    barrierLabel: 'Notifications',
    barrierDismissible: true,
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, _, __) {
      return SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFF1E2D59)),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
                  decoration: const BoxDecoration(color: Color(0xFF2B3C72)),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Notifications',
                          style: TextStyle(
                            color: Color(0xFFEFF2FF),
                            fontSize: 42 / 1.8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        color: const Color(0xFFEFF2FF),
                        splashRadius: 22,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    radius: const Radius.circular(8),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final alternate = index.isEven;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          color: alternate
                              ? const Color(0xFF2C3D6D)
                              : const Color(0xFF243662),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF50618D),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 24,
                                  color: item.$2
                                      ? const Color(0xFFF5BC1D)
                                      : const Color(0xFFCDD5E8),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.$1,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFFEFF2FF),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Text(
                                      'Check the status update',
                                      style: TextStyle(
                                        color: Color(0xFFCDD5E8),
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: item.$3
                                      ? const Color(0xFF4BA0FF)
                                      : const Color(0xFF62749C),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
