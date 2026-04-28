import 'package:flutter/material.dart';
import 'package:nutilize/core/services/inventory_service.dart';
import 'package:nutilize/core/services/reservation_service.dart';
import 'package:nutilize/core/models/room.dart';
import 'package:nutilize/core/models/item.dart';
import 'package:nutilize/app/shell/main_shell.dart';
import 'package:nutilize/features/auth/data/auth_service.dart';

class BiggerSpacesReservationFormPage extends StatefulWidget {
  const BiggerSpacesReservationFormPage({super.key});

  @override
  State<BiggerSpacesReservationFormPage> createState() =>
      _BiggerSpacesReservationFormPageState();
}

class _BiggerSpacesReservationFormPageState
    extends State<BiggerSpacesReservationFormPage> {
  final _inventoryService = InventoryService();
  final _reservationService = ReservationService();
  final _authService = AuthService();

  late Future<List<Room>> _spacesFuture;
  late Future<List<Item>> _itemsFuture;

  static const Set<String> _allowedSpaceTypes = {
    'AVR',
    'Lobby',
    'Student Lounge',
    'Students',
    'Gym',
  };

  String _activityName = '';
  DateTime? _selectedDate;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;
  Room? _selectedSpace;
  final Set<int> _selectedItemIds = {};
  final Map<int, int> _itemQuantities = {};
  int _currentStep =
      1; // Step 1: Activity details & space, Step 2: Items, Step 3: Confirmation
  bool _isSubmitting = false;
  String _userFirstName = 'User'; // Default fallback

  @override
  void initState() {
    super.initState();
    _spacesFuture = _inventoryService.getAvailableRooms().then((rooms) {
      return rooms
          .where((room) => _allowedSpaceTypes.contains(room.roomType))
          .toList();
    });
    _itemsFuture = _inventoryService.getAvailableItems();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null && mounted) {
        setState(() {
          _userFirstName = currentUser.firstName;
        });
      }
    } catch (e) {
      // Keep default name if loading fails
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF233B7A),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickFromTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _fromTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF233B7A),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _fromTime = picked);
    }
  }

  Future<void> _pickToTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _toTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF233B7A),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _toTime = picked);
    }
  }

  Future<void> _submitReservation() async {
    if (_activityName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter activity name')),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }

    if (_fromTime == null || _toTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select time range')));
      return;
    }

    if (_selectedSpace == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a space')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('User not logged in')));
        }
        return;
      }

      final reservation = await _reservationService.createReservation(
        userId: currentUser.userId,
        activityName: _activityName,
        overallStatus: 'pending',
        dateOfActivity: _selectedDate,
        startOfActivity: _fromTime,
        endOfActivity: _toTime,
      );

      // Add the chosen bigger space as a room reservation
      await _reservationService.addRoomToReservation(
        reservationId: reservation.reservationId,
        roomId: _selectedSpace!.roomId,
      );

      // Add items to reservation
      for (int itemId in _selectedItemIds) {
        await _reservationService.addItemToReservation(
          reservationId: reservation.reservationId,
          itemId: itemId,
          quantity: _itemQuantities[itemId] ?? 1,
        );
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => _RequestSubmittedFeedbackPage(
              reservationId: reservation.reservationId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int step = _currentStep;
    return Scaffold(
      backgroundColor: const Color(0xFF233B7A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 0,
              ),
              child: Row(
                children: [
                  if (step > 1)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => setState(() => _currentStep--),
                    ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 24,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: step == 4
                          ? const SizedBox.shrink()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Hello, $_userFirstName  👋',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Book your bigger space',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Take a moment to fill in your details',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: List.generate(
                                    3,
                                    (i) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: i < step
                                            ? const Color(0xFFF5BC1D)
                                            : const Color(0xFFD1D5DB),
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 18),
                    if (step != 4)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 18),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x14000000),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: step == 1
                            ? _buildStep1()
                            : step == 2
                            ? _buildStep2()
                            : _buildStep3(),
                      ),
                    if (step != 4)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () {
                                        if (step < 3) {
                                          setState(() => _currentStep++);
                                        } else {
                                          _submitReservation();
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF5BC1D),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  step < 3
                                      ? 'Next'
                                      : (_isSubmitting
                                            ? 'Submitting...'
                                            : 'Confirm'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.apartment_rounded, color: Color(0xFF233B7A), size: 32),
            SizedBox(width: 10),
            Text(
              'NUtilize Reservation Form',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text('Title of activity:'),
        const SizedBox(height: 6),
        TextField(
          onChanged: (value) => setState(() => _activityName = value),
          decoration: InputDecoration(
            hintText: 'Enter title of activity',
            filled: true,
            fillColor: const Color(0xFFEDEDED),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Date of Activity:'),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _selectedDate != null
                  ? '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}'
                  : 'Select Date of Activity',
              style: TextStyle(
                color: _selectedDate != null ? Colors.black : Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Time of Activity:'),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _pickFromTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEDED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _fromTime != null ? _fromTime!.format(context) : 'From:',
                    style: TextStyle(
                      color: _fromTime != null
                          ? Colors.black
                          : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _pickToTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEDED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _toTime != null ? _toTime!.format(context) : 'To:',
                    style: TextStyle(
                      color: _toTime != null ? Colors.black : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'Select Space',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Room>>(
          future: _spacesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final rooms = snapshot.data ?? [];
            if (rooms.isEmpty) {
              return const Text('No bigger spaces available');
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rooms.map((room) {
                final isSelected = _selectedSpace?.roomId == room.roomId;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSpace = room),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF5BC1D)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFF5BC1D)
                            : const Color(0xFFE0E0E0),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.roomType,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          room.roomNumber.isNotEmpty
                              ? 'Room: ${room.roomNumber}'
                              : 'Space: ${room.roomType}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white70
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Items',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Item>>(
            future: _itemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final items = snapshot.data ?? [];
              final itemsByCategory = <String, List<Item>>{};

              for (var item in items) {
                itemsByCategory.putIfAbsent(item.category, () => []).add(item);
              }

              final sortedCategoryEntries = itemsByCategory.entries.toList()
                ..sort(
                  (a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()),
                );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: sortedCategoryEntries.map((entry) {
                  final category = entry.key;
                  final categoryItems = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...categoryItems.map((item) {
                        final isSelected = _selectedItemIds.contains(
                          item.itemId,
                        );
                        final requestedQty = _itemQuantities[item.itemId] ?? 1;
                        final availableQty = item.availableQuantity;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(8),
                            color: isSelected
                                ? const Color.fromRGBO(245, 188, 29, 0.1)
                                : Colors.transparent,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: availableQty > 0
                                        ? (_) {
                                            setState(() {
                                              if (isSelected) {
                                                _selectedItemIds.remove(
                                                  item.itemId,
                                                );
                                                _itemQuantities.remove(
                                                  item.itemId,
                                                );
                                              } else {
                                                _selectedItemIds.add(
                                                  item.itemId,
                                                );
                                                _itemQuantities[item.itemId] =
                                                    1;
                                              }
                                            });
                                          }
                                        : null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    activeColor: const Color(0xFF233B7A),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.itemName,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: availableQty > 0
                                                ? Colors.black
                                                : Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Available: $availableQty / ${item.quantityTotal}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (isSelected)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Request: ',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          key: ValueKey(
                                            '${item.itemId}-$requestedQty',
                                          ),
                                          initialValue: requestedQty.toString(),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            final qty =
                                                int.tryParse(value) ?? 1;
                                            if (qty > 0 &&
                                                qty <= availableQty) {
                                              setState(() {
                                                _itemQuantities[item.itemId] =
                                                    qty;
                                              });
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: '1',
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 6,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'of $availableQty',
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
                        );
                      }),
                      const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirm Reservation',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Activity:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(_activityName),
          const SizedBox(height: 16),
          const Text('Date:', style: TextStyle(fontWeight: FontWeight.w600)),
          Text(
            _selectedDate != null
                ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                : 'N/A',
          ),
          const SizedBox(height: 16),
          const Text(
            'Time Range:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            _fromTime != null && _toTime != null
                ? '${_fromTime!.format(context)} - ${_toTime!.format(context)}'
                : 'N/A',
          ),
          const SizedBox(height: 16),
          const Text('Space:', style: TextStyle(fontWeight: FontWeight.w600)),
          Text(
            _selectedSpace != null
                ? '${_selectedSpace!.roomType} • ${_selectedSpace!.roomNumber}'
                : 'N/A',
          ),
          const SizedBox(height: 16),
          const Text(
            'Items Selected:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          FutureBuilder<List<Item>>(
            future: _itemsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final allItems = snapshot.data ?? [];
                final selectedItems = allItems
                    .where((i) => _selectedItemIds.contains(i.itemId))
                    .toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in selectedItems)
                      Text(
                        '• ${item.itemName} (x${_itemQuantities[item.itemId] ?? 1})',
                      ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _RequestSubmittedFeedbackPage extends StatefulWidget {
  final int reservationId;

  const _RequestSubmittedFeedbackPage({required this.reservationId});

  @override
  State<_RequestSubmittedFeedbackPage> createState() =>
      _RequestSubmittedFeedbackPageState();
}

class _RequestSubmittedFeedbackPageState
    extends State<_RequestSubmittedFeedbackPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(MainShell.routeName, (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1CC),
                  borderRadius: BorderRadius.circular(70),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFF5BC1D),
                  size: 78,
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'Congratulations!',
                style: TextStyle(
                  color: Color(0xFF23266B),
                  fontWeight: FontWeight.w800,
                  fontSize: 40,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Reservation #${widget.reservationId} submitted!\nThe admin has already received your request.',
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 20,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5BC1D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text(
                    'Finish',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
