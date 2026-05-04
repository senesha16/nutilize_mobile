import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutilize/core/services/inventory_service.dart';
import 'package:nutilize/core/services/reservation_service.dart';
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
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      MainShell.routeName,
                      (route) => false,
                    );
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

class ItemReservationFormPage extends StatefulWidget {
  const ItemReservationFormPage({super.key});

  @override
  State<ItemReservationFormPage> createState() => _ItemReservationFormPageState();
}

class _ItemReservationFormPageState extends State<ItemReservationFormPage> {
  final _inventoryService = InventoryService();
  final _reservationService = ReservationService();
  final TextEditingController _activityNameController = TextEditingController();

  late Future<List<Item>> _itemsFuture;

  final Set<int> _selectedItemIds = {};
  final Map<int, int> _itemQuantities = {};

  bool _isSubmitting = false;
  bool _hasConfirmedTerms = false;
  late int _currentStep;
  String _activityName = '';
  String _userFirstName = 'User'; // Default fallback

  // Date and time fields
  DateTime? _eventDate;
  TimeOfDay? _eventStartTime;
  TimeOfDay? _eventEndTime;

  @override
  void initState() {
    super.initState();
    _currentStep = 1;
    _itemsFuture = _inventoryService.getAvailableItems();
    _activityNameController.text = _activityName;
    _loadUserName();
  }

  @override
  void dispose() {
    _activityNameController.dispose();
    super.dispose();
  }

  DateTime? _combineDateAndTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _refreshItemsAvailability() {
    setState(() {
      _itemsFuture = _inventoryService.getAvailableItems(
        startDateTime: _combineDateAndTime(_eventDate, _eventStartTime),
        endDateTime: _combineDateAndTime(_eventDate, _eventEndTime),
      );
    });
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
      return _selectedItemIds.isNotEmpty;
    }
    return false;
  }

  void _goToNextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  Future<void> _submitReservation() async {
    if (_activityName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter activity name')),
      );
      return;
    }

    if (_selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one item')),
      );
      return;
    }

    if (!_hasConfirmedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please confirm you have read the policies before finishing.')),
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

      // Check if user has overdue returning reservations
      final hasOverdue = await _reservationService.hasOverdueReturningReservations(currentUser.userId);
      if (hasOverdue) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have overdue items to return. Please return your items first before making new reservations.'),
              backgroundColor: Colors.red,
            ),
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

      for (int itemId in _selectedItemIds) {
        // Use quantity specified by user, default to 1 if not set
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
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Icon(Icons.chair_alt_rounded, color: Colors.white, size: 32),
                              const SizedBox(width: 10),
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'NUtilize ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Item Reservation Form',
                                      style: TextStyle(color: Colors.white, fontSize: 20),
                                    ),
                                  ],
                                ),
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
                                Text(
                                  'Step $step of 3',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Color(0xFF233B7A),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: step / 3,
                                  backgroundColor: const Color(0xFFE0E0E0),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF233B7A)),
                                ),
                                const SizedBox(height: 20),
                                if (step == 1) ...[
                                  const Text(
                                    'Activity Details',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _activityNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Activity Name',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) => setState(() => _activityName = value),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          decoration: const InputDecoration(
                                            labelText: 'Date',
                                            border: OutlineInputBorder(),
                                          ),
                                          readOnly: true,
                                          controller: TextEditingController(
                                            text: _eventDate != null
                                                ? '${_eventDate!.month}/${_eventDate!.day}/${_eventDate!.year}'
                                                : '',
                                          ),
                                          onTap: () async {
                                            final now = DateTime.now();
                                            final picked = await showDatePicker(
                                              context: context,
                                              initialDate: _eventDate ?? now,
                                              firstDate: now,
                                              lastDate: DateTime(now.year + 2),
                                            );
                                            if (picked != null) {
                                              setState(() => _eventDate = picked);
                                              _refreshItemsAvailability();
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          decoration: const InputDecoration(
                                            labelText: 'Start Time',
                                            border: OutlineInputBorder(),
                                          ),
                                          readOnly: true,
                                          controller: TextEditingController(
                                            text: _eventStartTime != null
                                                ? _eventStartTime!.format(context)
                                                : '',
                                          ),
                                          onTap: () async {
                                            final picked = await showTimePicker(
                                              context: context,
                                              initialTime: _eventStartTime ?? TimeOfDay.now(),
                                            );
                                            if (picked != null) {
                                              setState(() => _eventStartTime = picked);
                                              _refreshItemsAvailability();
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextField(
                                          decoration: const InputDecoration(
                                            labelText: 'End Time',
                                            border: OutlineInputBorder(),
                                          ),
                                          readOnly: true,
                                          controller: TextEditingController(
                                            text: _eventEndTime != null
                                                ? _eventEndTime!.format(context)
                                                : '',
                                          ),
                                          onTap: () async {
                                            final picked = await showTimePicker(
                                              context: context,
                                              initialTime: _eventEndTime ?? TimeOfDay.now(),
                                            );
                                            if (picked != null) {
                                              setState(() => _eventEndTime = picked);
                                              _refreshItemsAvailability();
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else if (step == 2) ...[
                                  const Text(
                                    'Select Items',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                                  ),
                                  const SizedBox(height: 16),
                                  FutureBuilder<List<Item>>(
                                    future: _itemsFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      }

                                      final items = snapshot.data ?? [];
                                      if (items.isEmpty) {
                                        return const Text('No items available');
                                      }

                                      return Column(
                                        children: items.map((item) {
                                          final isSelected = _selectedItemIds.contains(item.itemId);
                                          return Card(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            child: CheckboxListTile(
                                              title: Text(item.itemName),
                                              subtitle: Text('Available: ${item.availableQuantity}/${item.quantityTotal}'),
                                              value: isSelected,
                                              onChanged: (value) {
                                                setState(() {
                                                  if (value == true) {
                                                    _selectedItemIds.add(item.itemId);
                                                    _itemQuantities[item.itemId] = 1; // Default quantity
                                                  } else {
                                                    _selectedItemIds.remove(item.itemId);
                                                    _itemQuantities.remove(item.itemId);
                                                  }
                                                });
                                              },
                                              secondary: isSelected
                                                  ? SizedBox(
                                                      width: 60,
                                                      child: TextField(
                                                        decoration: const InputDecoration(
                                                          labelText: 'Qty',
                                                          border: OutlineInputBorder(),
                                                        ),
                                                        keyboardType: TextInputType.number,
                                                        inputFormatters: [
                                                          _MaxValueTextInputFormatter(item.availableQuantity),
                                                        ],
                                                        onChanged: (value) {
                                                          final qty = int.tryParse(value) ?? 1;
                                                          setState(() {
                                                            _itemQuantities[item.itemId] = qty;
                                                          });
                                                        },
                                                        controller: TextEditingController(
                                                          text: (_itemQuantities[item.itemId] ?? 1).toString(),
                                                        ),
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ] else if (step == 3) ...[
                                  const Text(
                                    'Confirmation',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                                  ),
                                  const SizedBox(height: 16),
                                  FutureBuilder<List<Item>>(
                                    future: _itemsFuture,
                                    builder: (context, snapshot) {
                                      final items = snapshot.data ?? [];
                                      final selectedItems = items.where((i) => _selectedItemIds.contains(i.itemId)).toList();

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Activity:', style: TextStyle(fontWeight: FontWeight.w600)),
                                          Text(_activityName),
                                          const SizedBox(height: 8),
                                          const Text('Date:', style: TextStyle(fontWeight: FontWeight.w600)),
                                          Text(_eventDate != null
                                              ? '${_eventDate!.month}/${_eventDate!.day}/${_eventDate!.year}'
                                              : 'Not selected'),
                                          const SizedBox(height: 8),
                                          const Text('Time:', style: TextStyle(fontWeight: FontWeight.w600)),
                                          Text(_eventStartTime != null && _eventEndTime != null
                                              ? '${_eventStartTime!.format(context)} - ${_eventEndTime!.format(context)}'
                                              : 'Not selected'),
                                          const SizedBox(height: 8),
                                          const Text('Items:', style: TextStyle(fontWeight: FontWeight.w600)),
                                          if (selectedItems.isEmpty)
                                            const Text('No items selected')
                                          else
                                            ...selectedItems.map((item) {
                                              final quantity = _itemQuantities[item.itemId] ?? 1;
                                              return Text('${item.itemName} (Qty: $quantity)');
                                            }).toList(),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  // Terms and conditions
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8F9FA),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Policies and Guidelines',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: Color(0xFF233B7A),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        _buildTermsPoint('Fill up and submit the reservation form together with the layout of the venue (if applicable).'),
                                        _buildTermsPoint('All items must be returned in good condition.'),
                                        _buildTermsPoint('Late returns may result in penalties or restrictions on future reservations.'),
                                        const SizedBox(height: 16),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Checkbox(
                                                value: _hasConfirmedTerms,
                                                activeColor: const Color(0xFF233B7A),
                                                onChanged: (value) {
                                                  setState(() => _hasConfirmedTerms = value ?? false);
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () => setState(() => _hasConfirmedTerms = !_hasConfirmedTerms),
                                                child: const Text(
                                                  'I/We have read, understand and agree to abide by all the rules listed in the application form.',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 13,
                                                    color: Color(0xFF233B7A),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (!_hasConfirmedTerms)
                                          const Padding(
                                            padding: EdgeInsets.only(top: 8),
                                            child: Text(
                                              'Please confirm that you have read the policies before finishing.',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (step < 3)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canProceedToNext ? const Color(0xFF233B7A) : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _canProceedToNext ? _goToNextStep : null,
                    child: Text(
                      step == 2 ? 'Review Reservation' : 'Next',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF233B7A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _submitReservation,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Submit Reservation',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

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