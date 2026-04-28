import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutilize/core/services/inventory_service.dart';
import 'package:nutilize/core/services/reservation_service.dart';
import 'package:nutilize/core/models/room.dart';
import 'package:nutilize/core/models/item.dart';
import 'package:nutilize/app/shell/main_shell.dart';
import 'package:nutilize/features/auth/data/auth_service.dart';

class _MaxValueTextInputFormatter extends TextInputFormatter {
  final int maxValue;

  _MaxValueTextInputFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final value = int.tryParse(newValue.text);
    if (value == null) {
      return oldValue;
    }

    if (value > maxValue) {
      return oldValue;
    }

    return newValue;
  }
}

class _ReservationSummaryCard extends StatefulWidget {
  final Set<int> selectedRoomIds;
  final Set<int> selectedItemIds;
  final String? chairQuantityRange;
  final String? tableType;
  final String tableQuantity;

  const _ReservationSummaryCard({
    super.key,
    required this.selectedRoomIds,
    required this.selectedItemIds,
    this.chairQuantityRange,
    this.tableType,
    required this.tableQuantity,
  });

  @override
  State<_ReservationSummaryCard> createState() => _ReservationSummaryCardState();
}

class _ReservationSummaryCardState extends State<_ReservationSummaryCard> {
  final _inventoryService = InventoryService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        _inventoryService.getAvailableRooms(),
        _inventoryService.getAvailableItems(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final rooms = (snapshot.data?[0] as List<Room>?) ?? [];
        final items = (snapshot.data?[1] as List<Item>?) ?? [];

        final selectedRooms = rooms.where((r) => widget.selectedRoomIds.contains(r.roomId)).toList();
        final selectedItems = items.where((i) => widget.selectedItemIds.contains(i.itemId)).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.apartment_rounded, color: Colors.white, size: 32),
                const SizedBox(width: 10),
                Text(
                  'NUtilize ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const Text(
                  'Reservation Form',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Items up for borrowing',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Rooms:', style: TextStyle(fontWeight: FontWeight.w600)),
                  if (selectedRooms.isEmpty)
                    const Text('No rooms selected')
                  else
                    ...selectedRooms.map((room) => Text('Room ${room.roomNumber}')).toList(),
                  const SizedBox(height: 8),
                  const Text('Chairs:', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('Quantity: ${widget.chairQuantityRange ?? 'Not selected'}'),
                  const SizedBox(height: 8),
                  const Text('Tables:', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('Type: ${widget.tableType ?? 'Not selected'}'),
                  const SizedBox(height: 8),
                  const Text('Items:', style: TextStyle(fontWeight: FontWeight.w600)),
                  if (selectedItems.isEmpty)
                    const Text('No items selected')
                  else
                    ...selectedItems.map((item) => Text(item.itemName)).toList(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // LABEL: TERMS AND CONDITIONS section at the bottom (client requirement)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Policies and Guidelines on the Use of School Facilities',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF233B7A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTermsPoint('Fill up and submit the reservation form together with the layout of the venue (if applicable).'),
                  _buildTermsPoint('The venue shall be used only for the purpose stated in the reservation form.'),
                  _buildTermsPoint('All decorations must be arranged/setup in coordination with the Physical Facilities Management Office. Decorations should not be hung from or placed on ceilings, fire safety equipment or overhead lighting. At no time may any items be attached to or hung from sprinkler system piping.'),
                  _buildTermsPoint('Posting of banners, temporary signage, decorations and other materials that can possibly damage the facilities are strictly prohibited.'),
                  _buildTermsPoint('The organization/department must assume the responsibility of preparing the place. Removal of decorations, posters and any related items and cleaning the facility are likewise the responsibilities of the organization/department.'),
                  _buildTermsPoint('The organization/department must see to it that the facility is not filled beyond its capacity.'),
                  _buildTermsPoint('Bringing of alcoholic beverages and drugs are strictly prohibited.'),
                  _buildTermsPoint('Persons under the influence of alcohol/drug are not allowed within the premises.'),
                  _buildTermsPoint('The organization/department must peacefully vacate the facility after the reserved date and time.'),
                  _buildTermsPoint('The organization must observe cleanliness and orderliness within and after the duration of the activity.'),
                  _buildTermsPoint('Final coordination with the Physical Facilities Management Office three or four days before the scheduled activity is a must.'),
                  const SizedBox(height: 16),
                  const Text(
                    'I/We have read, understand and agree to abide by all the rules listed in the application form.',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF233B7A),
                    ),
                  ),
                ],
              ),
            ),
            ],
        );
      },
    );
  }

  // LABEL: Helper method to build bullet points for terms and conditions
  Widget _buildTermsPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 10, top: 4),
            child: Text('•', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, height: 1.5),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestSubmittedFeedbackPage extends StatefulWidget {
  final int reservationId;

  const _RequestSubmittedFeedbackPage({
    super.key,
    required this.reservationId,
  });

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
        Navigator.of(context).pushNamedAndRemoveUntil(
          MainShell.routeName,
          (route) => false,
        );
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

class RoomReservationFormPage extends StatefulWidget {
  final int step;
  const RoomReservationFormPage({super.key, this.step = 1});

  @override
  State<RoomReservationFormPage> createState() => _RoomReservationFormPageState();
}

class _RoomReservationFormPageState extends State<RoomReservationFormPage> {
  final _inventoryService = InventoryService();
  final _reservationService = ReservationService();
  
  late Future<List<Room>> _roomsFuture;
  late Future<List<Item>> _itemsFuture;
  
  final Set<int> _selectedRoomIds = {};
  final Set<int> _selectedItemIds = {};
  // LABEL: Track quantity requested for each item (itemId -> quantity)
  final Map<int, int> _itemQuantities = {};
  
  bool _isSubmitting = false;
  late int _currentStep;
  String? _selectedRoomType = 'Classroom';
  String? _selectedAttendance;
  String _activityName = '';
  String? _chairQuantityRange;
  int? _customChairExtraCount;
  String? _tableType;
  String _tableQuantity = '';
  bool _noNeedItemsSelected = false;
  String _userFirstName = 'User'; // Default fallback
  
  // Date and time fields
  DateTime? _eventDate;
  TimeOfDay? _eventStartTime;
  TimeOfDay? _eventEndTime;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.step;
    _roomsFuture = _inventoryService.getAvailableRooms();
    _itemsFuture = _inventoryService.getAvailableItems();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final authService = AuthService();
      final currentUser = await authService.getCurrentUser();
      if (currentUser != null && mounted) {
        setState(() {
          _userFirstName = currentUser.firstName;
        });
      }
    } catch (e) {
      // Keep default name if loading fails
    }
  }

  bool get _canProceedToNext {
    if (_currentStep == 1) {
      return _activityName.isNotEmpty && _eventDate != null && _eventStartTime != null && _eventEndTime != null;
    }

    if (_currentStep == 2) {
      final bool chairSelectionValid = _chairQuantityRange != null && _chairQuantityRange!.isNotEmpty &&
          (_chairQuantityRange != 'custom' ||
              (_customChairExtraCount != null && _customChairExtraCount! > 0 && _customChairExtraCount! <= 50));

      return _chairQuantityRange != null && _selectedRoomType != null && _selectedRoomType!.isNotEmpty &&
          chairSelectionValid &&
          _tableType != null && _tableType!.isNotEmpty;
    }
    if (_currentStep == 3) {
      return _selectedRoomIds.isNotEmpty;
    }
    if (_currentStep == 4) {
      return _selectedItemIds.isNotEmpty || _noNeedItemsSelected;
    }
    return false;
  }

  void _goToNextStep() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    }
  }

  String get _chairQuantityDisplay {
    if (_chairQuantityRange == null || _chairQuantityRange!.isEmpty) {
      return '';
    }
    if (_chairQuantityRange == '45') {
      return '45';
    }
    if (_chairQuantityRange == 'custom' && _customChairExtraCount != null) {
      return '45 + $_customChairExtraCount (total ${45 + _customChairExtraCount!})';
    }
    return _chairQuantityRange!;
  }

  Future<void> _submitReservation() async {
    if (_activityName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter activity name')),
      );
      return;
    }

    if (_selectedRoomIds.isEmpty && _selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one room or item')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Get the currently logged-in user
      final authService = AuthService();
      final currentUser = await authService.getCurrentUser();
      
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in')),
          );
        }
        return;
      }

      final reservation = await _reservationService.createReservation(
        userId: currentUser.userId,
        activityName: _activityName,
        overallStatus: 'pending',
        dateOfActivity: _eventDate,
        startOfActivity: _eventStartTime,
        endOfActivity: _eventEndTime,
      );

      for (int roomId in _selectedRoomIds) {
        await _reservationService.addRoomToReservation(
          reservationId: reservation.reservationId,
          roomId: roomId,
        );
      }

      for (int itemId in _selectedItemIds) {
        // LABEL: Use quantity specified by user, default to 1 if not set
        final quantity = _itemQuantities[itemId] ?? 1;
        await _reservationService.addItemToReservation(
          reservationId: reservation.reservationId,
          itemId: itemId,
          quantity: quantity,
        );
      }

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _RequestSubmittedFeedbackPage(
              reservationId: reservation.reservationId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
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
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28),
                      onPressed: () => setState(() => _currentStep--),
                    ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 32),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 24),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: step == 5
                          ? _ReservationSummaryCard(
                              selectedRoomIds: _selectedRoomIds,
                              selectedItemIds: _selectedItemIds,
                              chairQuantityRange: _chairQuantityDisplay,
                              tableType: _tableType,
                              tableQuantity: _tableQuantity,
                            )
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
                                const Text('Lets start your reservation',
                                    style: TextStyle(color: Colors.white, fontSize: 15)),
                                const SizedBox(height: 12),
                                const Text('Take a moment to fill in your details',
                                    style: TextStyle(color: Colors.white, fontSize: 15)),
                                const SizedBox(height: 8),
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2),
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
                    if (step != 5)
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
                        child: Column(
                          children: [
                            if (step == 4)
                              _PeripheralsFormFields(
                                selectedItemIds: _selectedItemIds,
                                onItemsChanged: (items) {
                                  setState(() {
                                    _selectedItemIds.clear();
                                    _selectedItemIds.addAll(items);
                                    _noNeedItemsSelected = false;
                                  });
                                },
                                // LABEL: Capture item quantities from child widget for submission
                                onQuantitiesChanged: (quantities) {
                                  setState(() {
                                    _itemQuantities.clear();
                                    _itemQuantities.addAll(quantities);
                                  });
                                },
                                onNoNeedChanged: (hasNoNeed) {
                                  setState(() {
                                    _noNeedItemsSelected = hasNoNeed;
                                    if (hasNoNeed) {
                                      _selectedItemIds.clear();
                                    }
                                  });
                                },
                              )
                            else if (step == 3)
                              _RoomSuggestionsList(
                                selectedRoomIds: _selectedRoomIds,
                                selectedRoomType: _selectedRoomType,
                                selectedAttendance: _selectedAttendance,
                                chairQuantityRange: _chairQuantityRange,
                                tableType: _tableType,
                                tableQuantity: _tableQuantity,
                                onSelectedRoomIdsChanged: (ids) {
                                  setState(() {
                                    _selectedRoomIds.clear();
                                    _selectedRoomIds.addAll(ids);
                                  });
                                },
                              )
                            else if (step == 2)
                              _ReservationDetailsFormFields(
                                onRoomTypeChanged: (roomType) {
                                  setState(() => _selectedRoomType = roomType);
                                },
                                onChairQuantityChanged: (qty) {
                                  setState(() => _chairQuantityRange = qty);
                                },
                                onCustomChairCountChanged: (count) {
                                  setState(() => _customChairExtraCount = count);
                                },
                                onTableTypeChanged: (type) {
                                  setState(() => _tableType = type);
                                },
                              )
                            else
                              _ReservationFormFields(
                                onActivityNameChanged: (name) {
                                  setState(() => _activityName = name);
                                },
                                onAttendanceChanged: (attendance) {
                                  setState(() => _selectedAttendance = attendance);
                                },
                                onDateChanged: (date) {
                                  setState(() => _eventDate = date);
                                },
                                onFromTimeChanged: (time) {
                                  setState(() => _eventStartTime = time);
                                },
                                onToTimeChanged: (time) {
                                  setState(() => _eventEndTime = time);
                                },
                              ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _canProceedToNext ? _goToNextStep : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF233B7A),
                                  disabledBackgroundColor: Colors.grey[300],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Next',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (step != 5) const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: step == 5
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF233B7A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isSubmitting ? null : _submitReservation,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          )
                        : const Text(
                            'Finish',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

// ==================== FIXED PERIPHERALS SECTION ====================

class _PeripheralsFormFields extends StatefulWidget {
  final Set<int> selectedItemIds;
  final Function(Set<int>)? onItemsChanged;
  final Function(Map<int, int>)? onQuantitiesChanged;
  final Function(bool)? onNoNeedChanged;

  const _PeripheralsFormFields({
    required this.selectedItemIds,
    this.onItemsChanged,
    this.onQuantitiesChanged,
    this.onNoNeedChanged,
  });

  @override
  State<_PeripheralsFormFields> createState() => _PeripheralsFormFieldsState();
}

class _PeripheralsFormFieldsState extends State<_PeripheralsFormFields> {
  final _inventoryService = InventoryService();
  late Future<List<Item>> _itemsFuture;

  final Map<String, bool> _categoryNoNeed = {};
  late Set<int> _localSelectedIds;
  // LABEL: Track the quantity requested for each item (itemId -> requested quantity)
  final Map<int, int> _itemQuantities = {};

  @override
  void initState() {
    super.initState();
    _itemsFuture = _inventoryService.getAvailableItems();
    _localSelectedIds = Set.from(widget.selectedItemIds);
  }

  @override
  void didUpdateWidget(covariant _PeripheralsFormFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!setEquals(_localSelectedIds, widget.selectedItemIds)) {
      _localSelectedIds = Set.from(widget.selectedItemIds);
    }
  }

  int _countSelected(List<Item> items) =>
      items.where((item) => _localSelectedIds.contains(item.itemId)).length;

  void _notifyParent() {
    widget.onItemsChanged?.call(Set.from(_localSelectedIds));
    // LABEL: Also notify parent about quantity changes for each selected item
    widget.onQuantitiesChanged?.call(Map.from(_itemQuantities));
    widget.onNoNeedChanged?.call(_categoryNoNeed.values.any((v) => v));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Item>>(
      future: _itemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error loading items: ${snapshot.error}'),
          );
        }

        final allItems = snapshot.data ?? [];

        final itemsByCategory = <String, List<Item>>{};
        for (var item in allItems) {
          itemsByCategory.putIfAbsent(item.category, () => []).add(item);
        }

        final sortedCategoryEntries = itemsByCategory.entries.toList()
          ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

        for (var category in itemsByCategory.keys) {
          _categoryNoNeed.putIfAbsent(category, () => false);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.apartment_rounded, color: Color(0xFF233B7A), size: 32),
                const SizedBox(width: 8),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'NUtilize ',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 18),
                      ),
                      TextSpan(text: 'Reservation Form', style: TextStyle(color: Colors.black, fontSize: 18)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            ...sortedCategoryEntries.map((entry) {
              final category = entry.key;
              final items = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(category, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEDED),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _countSelected(items).toString(),
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      // No need option
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _categoryNoNeed[category] ?? false,
                            onChanged: (val) {
                              setState(() {
                                final isNoNeed = val ?? false;
                                _categoryNoNeed[category] = isNoNeed;

                                if (isNoNeed) {
                                  for (var item in items) {
                                    _localSelectedIds.remove(item.itemId);
                                  }
                                }
                              });
                              _notifyParent();
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            activeColor: const Color(0xFF233B7A),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                final isNoNeed = !(_categoryNoNeed[category] ?? false);
                                _categoryNoNeed[category] = isNoNeed;
                                if (isNoNeed) {
                                  for (var item in items) {
                                    _localSelectedIds.remove(item.itemId);
                                  }
                                }
                              });
                              _notifyParent();
                            },
                            child: const Text('No need', style: TextStyle(fontSize: 15)),
                          ),
                        ],
                      ),

                      // Item checkboxes
                      ...items.map((item) => _buildItemCheckbox(item, category)).toList(),
                    ],
                  ),
                  const SizedBox(height: 18),
                ],
              );
            }).toList(),
          ],
        );
      },
    );
  }

  // LABEL: Build item checkbox with quantity info and custom request input
  // Shows: available quantity in database, checkbox to select, input for how many user wants
  Widget _buildItemCheckbox(Item item, String category) {
    final isSelected = _localSelectedIds.contains(item.itemId);
    final requestedQty = _itemQuantities[item.itemId] ?? 1; // Default to 1 if not set
    final availableQty = item.availableQuantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? const Color(0xFFF5BC1D).withOpacity(0.1) : Colors.transparent,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // LABEL: Checkbox to select this item
              Checkbox(
                value: isSelected,
                onChanged: availableQty > 0
                    ? (_) {
                        setState(() {
                          if (isSelected) {
                            _localSelectedIds.remove(item.itemId);
                            _itemQuantities.remove(item.itemId);
                          } else {
                            _localSelectedIds.add(item.itemId);
                            // Initialize quantity to 1 when selected
                            _itemQuantities[item.itemId] = 1;
                            _categoryNoNeed[category] = false;
                          }
                        });
                        _notifyParent();
                      }
                    : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                activeColor: const Color(0xFF233B7A),
              ),
              // LABEL: Item name and available quantity from database
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: availableQty > 0 ? Colors.black : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Remaining: $availableQty / ${item.quantityTotal}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                    if (item.quantityReserved > 0)
                      Text(
                        'Reserved: ${item.quantityReserved}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // LABEL: Quantity input field - only show when item is selected
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Text('Request: ', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: TextFormField(
                      key: ValueKey('${item.itemId}-${requestedQty}'),
                      initialValue: requestedQty.toString(),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _MaxValueTextInputFormatter(availableQty),
                      ],
                      onChanged: (value) {
                        final qty = int.tryParse(value) ?? 0;
                        if (qty > 0 && qty <= availableQty) {
                          setState(() {
                            _itemQuantities[item.itemId] = qty;
                          });
                          _notifyParent();
                        } else if (value.isEmpty) {
                          setState(() {
                            _itemQuantities.remove(item.itemId);
                          });
                          _notifyParent();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: '1',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                        errorText: requestedQty > availableQty
                            ? 'Max: $availableQty'
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'of $availableQty',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// The rest of your code remains unchanged (RoomSuggestionsList, _ReservationDetailsFormFields, etc.)

class _RoomSuggestionsList extends StatefulWidget {
  final Set<int> selectedRoomIds;
  final String? selectedRoomType;
  final String? selectedAttendance;
  final String? chairQuantityRange;
  final String? tableType;
  final String tableQuantity;
  final Function(Set<int>)? onSelectedRoomIdsChanged;
  
  const _RoomSuggestionsList({
    required this.selectedRoomIds,
    this.selectedRoomType,
    this.selectedAttendance,
    this.chairQuantityRange,
    this.tableType,
    required this.tableQuantity,
    this.onSelectedRoomIdsChanged,
  });

  @override
  State<_RoomSuggestionsList> createState() => _RoomSuggestionsListState();
}

class _RoomSuggestionsListState extends State<_RoomSuggestionsList> {
  final _inventoryService = InventoryService();
  late Future<List<Room>> _roomsFuture;
  late Set<int> _localSelectedRoomIds;

  @override
  void initState() {
    super.initState();
    _roomsFuture = _inventoryService.getAvailableRooms();
    _localSelectedRoomIds = Set.from(widget.selectedRoomIds);
  }

  @override
  void didUpdateWidget(covariant _RoomSuggestionsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!setEquals(oldWidget.selectedRoomIds, widget.selectedRoomIds)) {
      _localSelectedRoomIds = Set.from(widget.selectedRoomIds);
    }
  }

  int _getMinCapacityFromAttendance(String? attendance) {
    if (attendance == null) return 0;
    switch (attendance) {
      case '1-10': return 1;
      case '11-20': return 11;
      case '21-50': return 21;
      case '51-100': return 51;
      case '100+': return 100;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Available Rooms',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Room>>(
          future: _roomsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading rooms: ${snapshot.error}'),
              );
            }

            final rooms = snapshot.data ?? [];

            // LABEL: Filter rooms BASED ON TABLE TYPE - Attendance check removed (no longer needed)
            // Rooms are filtered primarily by the selected table type (arm chair, Trapezoidal, accounting table)
            List<MapEntry<Room, int>> roomScores = [];
            
            for (var room in rooms) {
              // CRITICAL FILTER 1: All rooms must be Classroom type
              if (room.roomType != 'Classroom') {
                continue;
              }
              
              // CRITICAL FILTER 2: Room table type MUST match user's selection
              // This ensures we show rooms with the correct table setup
              if (widget.tableType != null && widget.tableType!.isNotEmpty) {
                if (room.roomTableType != widget.tableType) {
                  continue; // Skip - table type doesn't match
                }
              }
              
              // LABEL: Scoring system for room recommendations
              int score = 100; // Base score for passing required filters
              
              // OPTIONAL: Bonus points if room has adequate chairs (45+ standard)
              if (room.roomCapacity != null && room.roomCapacity! >= 45) {
                score += 20; // Prefer rooms with minimum chair requirement met
              }
              
              // OPTIONAL: Bonus points if room has multiple tables
              if (room.roomTableCount != null && room.roomTableCount! > 1) {
                score += 10; // More tables means more flexibility
              }
              
              roomScores.add(MapEntry(room, score));
            }
            
            // Sort by score (highest first) for best recommendations
            roomScores.sort((a, b) => b.value.compareTo(a.value));
            final filteredRooms = roomScores.map((e) => e.key).toList();

            if (filteredRooms.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No rooms available for your criteria'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredRooms.length,
              itemBuilder: (context, index) {
                final room = filteredRooms[index];
                final isSelected = widget.selectedRoomIds.contains(room.roomId);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _localSelectedRoomIds.remove(room.roomId);
                        } else {
                          _localSelectedRoomIds.clear();
                          _localSelectedRoomIds.add(room.roomId);
                        }
                      });
                      widget.onSelectedRoomIdsChanged?.call(Set.from(_localSelectedRoomIds));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF5BC1D) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Room ${room.roomNumber}',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color(0xFFF5BC1D),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    room.displayRoomType,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color(0xFF233B7A),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.people, size: 18, color: isSelected ? Colors.white : const Color(0xFF233B7A)),
                                      const SizedBox(width: 4),
                                      Text('Cap: ${room.roomCapacity}', style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : Colors.black)),
                                      const SizedBox(width: 12),
                                      Icon(
                                        room.maintenanceStatus ? Icons.warning : Icons.check_circle,
                                        size: 18,
                                        color: room.maintenanceStatus ? Colors.red : (isSelected ? Colors.white : Colors.green),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        room.maintenanceStatus ? 'In Maintenance' : 'Available',
                                        style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : Colors.black),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.event_seat, size: 18, color: isSelected ? Colors.white : const Color(0xFF233B7A)),
                                      const SizedBox(width: 4),
                                      Text('Chairs: ${room.roomChairQuantity ?? 'N/A'}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.black)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.table_chart, size: 18, color: isSelected ? Colors.white : const Color(0xFF233B7A)),
                                      const SizedBox(width: 4),
                                      Text('Tables: ${room.roomTableType ?? 'N/A'} (', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.black)),
                                      Text('${room.roomTableCount ?? 'N/A'}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : const Color(0xFFF5BC1D))),
                                      Text(')', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.black)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isSelected)
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                              child: Container(
                                width: 60,
                                height: 70,
                                color: Colors.white,
                                child: const Icon(Icons.check_circle, color: Color(0xFFF5BC1D), size: 40),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ==================== Remaining unchanged classes ====================

class _ReservationDetailsFormFields extends StatefulWidget {
  final Function(String?)? onRoomTypeChanged;
  final Function(String?)? onChairQuantityChanged;
  final Function(int?)? onCustomChairCountChanged;
  final Function(String?)? onTableTypeChanged;

  const _ReservationDetailsFormFields({
    this.onRoomTypeChanged,
    this.onChairQuantityChanged,
    this.onCustomChairCountChanged,
    this.onTableTypeChanged,
  });

  @override
  State<_ReservationDetailsFormFields> createState() => _ReservationDetailsFormFieldsState();
}

class _ReservationDetailsFormFieldsState extends State<_ReservationDetailsFormFields> {
  // LABEL: Room type is now hardcoded to Classroom only (removed Laboratory option)
  String? _roomType = 'Classroom';
  String? _chairQuantityRange;
  String? _tableType;
  final TextEditingController _customChairCountController = TextEditingController();
  int? _customChairCount;

  @override
  void initState() {
    super.initState();
    // Classroom is the default and only option
  }

  @override
  void dispose() {
    _customChairCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.apartment_rounded, color: Color(0xFF233B7A), size: 32),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(text: 'NUtilize ', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 18)),
                  TextSpan(text: 'Reservation Form', style: TextStyle(color: Colors.black, fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        // LABEL: Room type is hardcoded to Classroom - no selection needed
        const Text('Room Type *', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEDEDED),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Classroom', style: TextStyle(fontSize: 16, color: Colors.black)),
        ),
        const SizedBox(height: 18),
        // LABEL: Base chair quantity is always 45. Users can add extra chairs if needed
        const Text('Chair Quantity', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            // Standard 45 chairs is the default minimum
            _buildChairRadio('45 (Standard)', '45', _chairQuantityRange, (val) {
              setState(() {
                _chairQuantityRange = val;
                _customChairCount = null;
                _customChairCountController.clear();
              });
              widget.onChairQuantityChanged?.call(val);
              widget.onCustomChairCountChanged?.call(null);
            }),
            // Users can select if they want extra chairs
            _buildChairRadio('45 + Extra (custom)', 'custom', _chairQuantityRange, (val) {
              setState(() {
                _chairQuantityRange = val;
                _customChairCount = null;
                _customChairCountController.clear();
              });
              widget.onChairQuantityChanged?.call(val);
              widget.onCustomChairCountChanged?.call(null);
            }),
          ],
        ),
        if (_chairQuantityRange == 'custom') ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _customChairCountController,
            keyboardType: TextInputType.number,
            maxLength: 2,
            decoration: const InputDecoration(
              labelText: 'Extra chairs (max 50)',
              hintText: 'Enter number of additional chairs',
              border: OutlineInputBorder(),
              counterText: '',
            ),
            onChanged: (value) {
              final parsedValue = int.tryParse(value) ?? 0;
              final clampedValue = parsedValue.clamp(0, 50);
              if (parsedValue != clampedValue) {
                _customChairCountController.text = clampedValue.toString();
                _customChairCountController.selection = TextSelection.fromPosition(TextPosition(offset: _customChairCountController.text.length));
              }
              setState(() {
                _customChairCount = clampedValue > 0 ? clampedValue : null;
              });
              final displayValue = clampedValue > 0
                  ? '45 + $clampedValue (total ${45 + clampedValue})'
                  : 'custom';
              widget.onChairQuantityChanged?.call(displayValue);
              widget.onCustomChairCountChanged?.call(_customChairCount);
            },
          ),
          const SizedBox(height: 8),
          Text(
            _customChairCount != null
                ? 'Total chairs: ${45 + _customChairCount!}'
                : 'Enter up to 50 extra chairs',
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
        ],
        const SizedBox(height: 18),
        // LABEL: Select table type - only 3 options: arm chair, Trapezoidal, accounting table
        const Text('Select Table Type *', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            _buildRadio('arm chair', _tableType, (val) {
              setState(() => _tableType = val);
              widget.onTableTypeChanged?.call(val);
            }),
            _buildRadio('Trapezoidal', _tableType, (val) {
              setState(() => _tableType = val);
              widget.onTableTypeChanged?.call(val);
            }),
            _buildRadio('accounting table', _tableType, (val) {
              setState(() => _tableType = val);
              widget.onTableTypeChanged?.call(val);
            }),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // LABEL: Checkbox radio button helper for standard options
  Widget _buildRadio(String label, String? groupValue, ValueChanged<String> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: groupValue == label,
          onChanged: (_) => onChanged(label),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          activeColor: const Color(0xFF233B7A),
        ),
        GestureDetector(onTap: () => onChanged(label), child: Text(label, style: const TextStyle(fontSize: 15))),
      ],
    );
  }

  // LABEL: Checkbox radio button helper for chair quantity options (45 base + extra)
  Widget _buildChairRadio(String label, String value, String? groupValue, ValueChanged<String> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: groupValue == value,
          onChanged: (_) => onChanged(value),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          activeColor: const Color(0xFF233B7A),
        ),
        GestureDetector(onTap: () => onChanged(value), child: Text(label, style: const TextStyle(fontSize: 15))),
      ],
    );
  }
}

class _ReservationFormFields extends StatefulWidget {
  final Function(String)? onActivityNameChanged;
  final Function(String)? onAttendanceChanged;
  final Function(DateTime)? onDateChanged;
  final Function(TimeOfDay)? onFromTimeChanged;
  final Function(TimeOfDay)? onToTimeChanged;

  const _ReservationFormFields({
    this.onActivityNameChanged,
    this.onAttendanceChanged,
    this.onDateChanged,
    this.onFromTimeChanged,
    this.onToTimeChanged,
  });

  @override
  State<_ReservationFormFields> createState() => _ReservationFormFieldsState();
}

class _ReservationFormFieldsState extends State<_ReservationFormFields> {
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;
  String? _attendance;

  final List<String> _attendanceOptions = ['1-10', '11-20', '21-50', '51-100', '100+'];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
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
          colorScheme: ColorScheme.light(primary: const Color(0xFF233B7A), onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      widget.onDateChanged?.call(picked);
    }
  }

  Future<void> _pickTime(bool isFrom) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: const Color(0xFF233B7A), onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromTime = picked;
          widget.onFromTimeChanged?.call(picked);
        } else {
          _toTime = picked;
          widget.onToTimeChanged?.call(picked);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.apartment_rounded, color: Color(0xFF233B7A), size: 32),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(text: 'NUtilize ', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 18)),
                  TextSpan(text: 'Reservation Form', style: TextStyle(color: Colors.black, fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text('Title of activity:'),
        const SizedBox(height: 6),
        TextField(
          controller: _titleController,
          onChanged: widget.onActivityNameChanged,
          decoration: InputDecoration(
            hintText: 'Enter title of activity',
            filled: true,
            fillColor: const Color(0xFFEDEDED),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            decoration: BoxDecoration(color: const Color(0xFFEDEDED), borderRadius: BorderRadius.circular(12)),
            child: Text(
              _selectedDate != null
                  ? '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}'
                  : 'Select Date of Activity',
              style: TextStyle(color: _selectedDate != null ? Colors.black : Colors.grey[600], fontSize: 16),
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
                onTap: () => _pickTime(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: const Color(0xFFEDEDED), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    _fromTime != null ? _fromTime!.format(context) : 'From:',
                    style: TextStyle(color: _fromTime != null ? Colors.black : Colors.grey[600], fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _pickTime(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: const Color(0xFFEDEDED), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    _toTime != null ? _toTime!.format(context) : 'To:',
                    style: TextStyle(color: _toTime != null ? Colors.black : Colors.grey[600], fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Simple Item Reservation Form - Only items, no rooms
class ItemReservationFormPage extends StatefulWidget {
  const ItemReservationFormPage({super.key});

  @override
  State<ItemReservationFormPage> createState() => _ItemReservationFormPageState();
}

class _ItemReservationFormPageState extends State<ItemReservationFormPage> {
  final _inventoryService = InventoryService();
  final _reservationService = ReservationService();
  final _authService = AuthService();
  
  late Future<List<Item>> _itemsFuture;
  final Set<int> _selectedItemIds = {};
  final Map<int, int> _itemQuantities = {};
  String _activityName = '';
  DateTime? _selectedDate;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;
  int _currentStep = 1; // Step 1: Activity details, Step 2: Items, Step 3: Confirmation
  bool _isSubmitting = false;
  Map<String, bool> _categoryNoNeed = {};

  @override
  void initState() {
    super.initState();
    _itemsFuture = _inventoryService.getAvailableItems();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    if (_fromTime == null || _toTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select time range')),
      );
      return;
    }

    if (_selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one item')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in')),
          );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF233B7A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (_currentStep > 1)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28),
                          onPressed: () => setState(() => _currentStep--),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FutureBuilder(
                          future: _authService.getCurrentUser(),
                          builder: (context, snapshot) {
                            final userName = snapshot.data?.firstName ?? 'User';
                            return Text(
                              'Hello, $userName 👋',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            );
                          },
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Lets start your reservation',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Take a moment to fill in your details',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Step 1: Activity details
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          Icons.check_circle,
                          color: _currentStep >= 1
                              ? const Color(0xFFF5BC1D)
                              : const Color(0xFFD1D5DB),
                          size: 22,
                        ),
                      ),
                      // Step 2: Items
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          Icons.check_circle,
                          color: _currentStep >= 2
                              ? const Color(0xFFF5BC1D)
                              : const Color(0xFFD1D5DB),
                          size: 22,
                        ),
                      ),
                      // Step 3: Confirmation
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          Icons.check_circle,
                          color: _currentStep >= 3
                              ? const Color(0xFFF5BC1D)
                              : const Color(0xFFD1D5DB),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _currentStep == 1
                  ? _buildActivityDetailsStep()
                  : _currentStep == 2
                      ? _buildItemSelectionStep()
                      : _buildConfirmationStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityDetailsStep() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
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
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                // Activity Name
                const Text(
                  'Activity Name',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => setState(() => _activityName = value),
                  decoration: InputDecoration(
                    hintText: 'Enter activity name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 24),
                // Date Selection
                const Text(
                  'Date',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEDED),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                          : 'Select date',
                      style: TextStyle(
                        color: _selectedDate != null ? Colors.black : Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Time Range
                const Text(
                  'Time Range',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickFromTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEDED),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _fromTime != null
                                ? _fromTime!.format(context)
                                : 'From:',
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
                      child: InkWell(
                        onTap: _pickToTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEDED),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _toTime != null ? _toTime!.format(context) : 'To:',
                            style: TextStyle(
                              color: _toTime != null
                                  ? Colors.black
                                  : Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _activityName.isEmpty ||
                        _selectedDate == null ||
                        _fromTime == null ||
                        _toTime == null
                    ? null
                    : () => setState(() => _currentStep = 2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF233B7A),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemSelectionStep() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
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
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const Text(
                  'Select Items to Borrow',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 18),
                _buildItemsSection(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedItemIds.isEmpty
                        ? null
                        : () => setState(() => _currentStep = 3),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF233B7A),
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
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
    );
  }

  Widget _buildItemsSection() {
    return FutureBuilder<List<Item>>(
      future: _itemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error loading items: ${snapshot.error}'),
          );
        }

        final allItems = snapshot.data ?? [];
        final itemsByCategory = <String, List<Item>>{};

        for (var item in allItems) {
          itemsByCategory.putIfAbsent(item.category, () => []).add(item);
        }

        final sortedCategoryEntries = itemsByCategory.entries.toList()
          ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

        for (var category in itemsByCategory.keys) {
          _categoryNoNeed.putIfAbsent(category, () => false);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sortedCategoryEntries.map((entry) {
            final category = entry.key;
            final items = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${items.length}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _categoryNoNeed[category] ?? false,
                      onChanged: (_) {
                        setState(() {
                          final isNoNeed = !(_categoryNoNeed[category] ?? false);
                          _categoryNoNeed[category] = isNoNeed;
                          if (isNoNeed) {
                            for (var item in items) {
                              _selectedItemIds.remove(item.itemId);
                              _itemQuantities.remove(item.itemId);
                            }
                          }
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      activeColor: const Color(0xFF233B7A),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          final isNoNeed = !(_categoryNoNeed[category] ?? false);
                          _categoryNoNeed[category] = isNoNeed;
                          if (isNoNeed) {
                            for (var item in items) {
                              _selectedItemIds.remove(item.itemId);
                              _itemQuantities.remove(item.itemId);
                            }
                          }
                        });
                      },
                      child: const Text('No need',
                          style: TextStyle(fontSize: 15)),
                    ),
                  ],
                ),
                ...items.map((item) {
                  final isSelected = _selectedItemIds.contains(item.itemId);
                  final requestedQty = _itemQuantities[item.itemId] ?? 1;
                  final availableQty = item.availableQuantity;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected ? const Color(0xFFF5BC1D).withOpacity(0.1) : Colors.transparent,
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
                                          _selectedItemIds.remove(item.itemId);
                                          _itemQuantities.remove(item.itemId);
                                        } else {
                                          _selectedItemIds.add(item.itemId);
                                          _itemQuantities[item.itemId] = 1;
                                          _categoryNoNeed[category] = false;
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.itemName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: availableQty > 0 ? Colors.black : Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Remaining: $availableQty / ${item.quantityTotal}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                  ),
                                  if (item.quantityReserved > 0)
                                    Text(
                                      'Reserved: ${item.quantityReserved}',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                                const Text('Request: ', style: TextStyle(fontSize: 12)),
                                Expanded(
                                  child: TextFormField(
                                    key: ValueKey('${item.itemId}-${requestedQty}'),
                                    initialValue: requestedQty.toString(),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      _MaxValueTextInputFormatter(availableQty),
                                    ],
                                    onChanged: (value) {
                                      final qty = int.tryParse(value) ?? 1;
                                      if (qty > 0 && qty <= availableQty) {
                                        setState(() {
                                          _itemQuantities[item.itemId] = qty;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText: '1',
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                                      errorText: requestedQty > availableQty
                                          ? 'Max: $availableQty'
                                          : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'of $availableQty',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 18),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildConfirmationStep() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
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
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const Text(
                  'Confirm Your Reservation',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 8),
                const Text('Activity:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text(_activityName),
                const SizedBox(height: 16),
                const Text('Date:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                      : 'N/A',
                ),
                const SizedBox(height: 16),
                const Text('Time Range:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  _fromTime != null && _toTime != null
                      ? '${_fromTime!.format(context)} - ${_toTime!.format(context)}'
                      : 'N/A',
                ),
                const SizedBox(height: 16),
                const Text('Items Selected:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
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
                        children: selectedItems
                            .map((item) => Text('• ${item.itemName} (x${_itemQuantities[item.itemId] ?? 1})'))
                            .toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _currentStep = 2),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Back',
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReservation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF233B7A),
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isSubmitting ? 'Submitting...' : 'Confirm',
                      style: const TextStyle(
                        color: Colors.white,
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
    );
  }
}