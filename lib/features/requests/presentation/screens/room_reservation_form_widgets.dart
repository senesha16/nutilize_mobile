import 'package:flutter/material.dart';

class _ReservationSummaryCard extends StatelessWidget {
  const _ReservationSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual reservation data
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
            children: const [
              Text(
                'Items up for borrowing',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              Divider(),
              SizedBox(height: 8),
              Text('Rooms:', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('Room 530'),
              SizedBox(height: 8),
              Text('Items:', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('Podium'),
              Text('Camera'),
              Text('HDMI'),
              Text('Projector'),
            ],
          ),
        ),
      ],
    );
  }
}

class _RequestSubmittedFeedbackPage extends StatelessWidget {
  const _RequestSubmittedFeedbackPage();

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
              const Text(
                'You have successfully requested.\nThe admin has already received your request.',
                style: TextStyle(
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

class RoomReservationFormPage extends StatelessWidget {
  final int step;
  const RoomReservationFormPage({super.key, this.step = 1});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF233B7A),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with close button
            Padding(
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 0,
              ),
              child: Row(
                children: [
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
                    // Greeting and progress
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: step == 5
                          ? const _ReservationSummaryCard()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Hello, Kirk  👋',
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
                                  'Lets start your reservation',
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
                                    5,
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
                    // Form Card
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
                        child: step == 4
                            ? _PeripheralsFormFields()
                            : step == 3
                            ? _RoomSuggestionsList()
                            : step == 2
                            ? _ReservationDetailsFormFields()
                            : _ReservationFormFields(),
                      ),
                    if (step != 5)
                      const SizedBox(
                        height: 80,
                      ), // Add space for the swipe button
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>
                              const _RequestSubmittedFeedbackPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Finish',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
                child: _SwipeToProceedButton(
                  onProceed: () {
                    if (step == 1) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>
                              const RoomReservationFormPage(step: 2),
                        ),
                      );
                    } else if (step == 2) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>
                              const RoomReservationFormPage(step: 3),
                        ),
                      );
                    } else if (step == 3) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>
                              const RoomReservationFormPage(step: 4),
                        ),
                      );
                    } else if (step == 4) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>
                              const RoomReservationFormPage(step: 5),
                        ),
                      );
                    } else {
                      // Optionally handle after last step
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Done'),
                          content: const Text(
                            'You have reached the end of the form.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
    );
  }
}

// Step 4: Peripherals selection form (file level)
class _PeripheralsFormFields extends StatefulWidget {
  @override
  State<_PeripheralsFormFields> createState() => _PeripheralsFormFieldsState();
}

class _PeripheralsFormFieldsState extends State<_PeripheralsFormFields> {
  final Map<String, bool> _peripherals = {
    // Multi Media
    'Projector': false,
    'Camera': false,
    'Speaker': false,
    // Electronics
    'HDMI': false,
    'Port Dongles': false,
    'Power Strip': false,
    // Utility
    'Podium': false,
    'Monoblock': false,
    'Industrial Fan': false,
  };

  int _countSelected(List<String> keys) =>
      keys.where((k) => _peripherals[k] == true).length;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.apartment_rounded,
              color: Color(0xFF233B7A),
              size: 32,
            ),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'NUtilize ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  TextSpan(
                    text: 'Reservation Form',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        // Multi Media
        Row(
          children: [
            const Text(
              'Multi Media',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEDED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _countSelected(['Projector', 'Camera', 'Speaker']).toString(),
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 24,
          runSpacing: 6,
          children: [
            _buildCheckbox('Projector'),
            _buildCheckbox('Camera'),
            _buildCheckbox('Speaker'),
          ],
        ),
        const SizedBox(height: 18),
        // Electronics
        Row(
          children: [
            const Text(
              'Electronics',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEDED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _countSelected([
                  'HDMI',
                  'Port Dongles',
                  'Power Strip',
                ]).toString(),
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 24,
          runSpacing: 6,
          children: [
            _buildCheckbox('HDMI'),
            _buildCheckbox('Port Dongles'),
            _buildCheckbox('Power Strip'),
          ],
        ),
        const SizedBox(height: 18),
        // Utility
        Row(
          children: [
            const Text(
              'Utility',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEDED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _countSelected([
                  'Podium',
                  'Monoblock',
                  'Industrial Fan',
                ]).toString(),
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 24,
          runSpacing: 6,
          children: [
            _buildCheckbox('Podium'),
            _buildCheckbox('Monoblock'),
            _buildCheckbox('Industrial Fan'),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCheckbox(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: _peripherals[label],
          onChanged: (val) =>
              setState(() => _peripherals[label] = val ?? false),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          activeColor: const Color(0xFF233B7A),
        ),
        GestureDetector(
          onTap: () => setState(
            () => _peripherals[label] = !(_peripherals[label] ?? false),
          ),
          child: Text(label, style: const TextStyle(fontSize: 15)),
        ),
      ],
    );
  }
}

// Step 3: Room suggestions list (file level)
class _RoomSuggestionsList extends StatefulWidget {
  @override
  State<_RoomSuggestionsList> createState() => _RoomSuggestionsListState();
}

class _RoomSuggestionsListState extends State<_RoomSuggestionsList> {
  final List<int> roomNumbers = const [522, 523, 524, 525, 526, 527, 528];
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Top Suggestions',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: roomNumbers.length,
          itemBuilder: (context, index) {
            final room = roomNumbers[index];
            final isSelected = selectedIndex == index;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF5BC1D) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Room $room',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFFF5BC1D),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'A spacious lecture room with organized seating, ideal for large classes and presentations.',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF233B7A),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people,
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF233B7A),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '40',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.event_seat,
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF233B7A),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '5',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.star,
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF233B7A),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '50',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        child: Image.asset(
                          'assets/images/room.jpg',
                          width: 80,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// Step 2 form fields widget (file level)
class _ReservationDetailsFormFields extends StatefulWidget {
  @override
  State<_ReservationDetailsFormFields> createState() =>
      _ReservationDetailsFormFieldsState();
}

class _ReservationDetailsFormFieldsState
    extends State<_ReservationDetailsFormFields> {
  String? _roomType;
  String? _chairType;
  String? _chairMaterial;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.apartment_rounded,
              color: Color(0xFF233B7A),
              size: 32,
            ),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'NUtilize ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  TextSpan(
                    text: 'Reservation Form',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        // Select a room type
        const Text(
          'Select a room type *',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            _buildRadio(
              'Classroom',
              _roomType,
              (val) => setState(() => _roomType = val),
            ),
            _buildRadio(
              'Chem Lab',
              _roomType,
              (val) => setState(() => _roomType = val),
            ),
            _buildRadio(
              'Computer Lab',
              _roomType,
              (val) => setState(() => _roomType = val),
            ),
          ],
        ),
        const SizedBox(height: 18),
        // Select chair type
        const Text(
          'Select chair Type',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            _buildRadio(
              'Monoblock',
              _chairType,
              (val) => setState(() => _chairType = val),
            ),
            _buildRadio(
              'Plastic',
              _chairType,
              (val) => setState(() => _chairType = val),
            ),
            _buildRadio(
              'Steel',
              _chairType,
              (val) => setState(() => _chairType = val),
            ),
            _buildRadio(
              'No need',
              _chairType,
              (val) => setState(() => _chairType = val),
            ),
          ],
        ),
        const SizedBox(height: 18),
        // Select type of chair
        const Text(
          'Select Type of Chair',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            _buildRadio(
              'Monoblock',
              _chairMaterial,
              (val) => setState(() => _chairMaterial = val),
            ),
            _buildRadio(
              'Plastic',
              _chairMaterial,
              (val) => setState(() => _chairMaterial = val),
            ),
            _buildRadio(
              'Steel',
              _chairMaterial,
              (val) => setState(() => _chairMaterial = val),
            ),
            _buildRadio(
              'No need',
              _chairMaterial,
              (val) => setState(() => _chairMaterial = val),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRadio(
    String label,
    String? groupValue,
    ValueChanged<String> onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: groupValue == label,
          onChanged: (_) => onChanged(label),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          activeColor: const Color(0xFF233B7A),
        ),
        GestureDetector(
          onTap: () => onChanged(label),
          child: Text(label, style: const TextStyle(fontSize: 15)),
        ),
      ],
    );
  }
}

class _ReservationFormFields extends StatefulWidget {
  @override
  State<_ReservationFormFields> createState() => _ReservationFormFieldsState();
}

class _ReservationFormFieldsState extends State<_ReservationFormFields> {
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;
  String? _attendance;
  final List<String> _attendanceOptions = [
    '1-10',
    '11-20',
    '21-50',
    '51-100',
    '100+',
  ];

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
          colorScheme: ColorScheme.light(
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

  Future<void> _pickTime(bool isFrom) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: Color(0xFF233B7A),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromTime = picked;
        } else {
          _toTime = picked;
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
            const Icon(
              Icons.apartment_rounded,
              color: Color(0xFF233B7A),
              size: 32,
            ),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'NUtilize ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  TextSpan(
                    text: 'Reservation Form',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        // Title
        const Text('Title of activity:'),
        const SizedBox(height: 6),
        TextField(
          controller: _titleController,
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
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Date
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
        // Time
        const Text('Time of Activity:'),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _pickTime(true),
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
                onTap: () => _pickTime(false),
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
        const SizedBox(height: 16),
        // Attendance
        const Text('Expected Attendance:'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _attendance,
          items: _attendanceOptions
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) => setState(() => _attendance = val),
          decoration: InputDecoration(
            hintText: 'Select Expected Attendees',
            filled: true,
            fillColor: const Color(0xFFEDEDED),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SwipeToProceedButton extends StatefulWidget {
  final VoidCallback onProceed;
  const _SwipeToProceedButton({required this.onProceed});

  @override
  State<_SwipeToProceedButton> createState() => _SwipeToProceedButtonState();
}

class _SwipeToProceedButtonState extends State<_SwipeToProceedButton> {
  double _drag = 0;
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 80;
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _drag += details.delta.dx;
          if (_drag < 0) _drag = 0;
          if (_drag > width - 60) _drag = width - 60;
        });
      },
      onHorizontalDragEnd: (details) {
        if (_drag > width * 0.6) {
          setState(() => _completed = true);
          Future.delayed(const Duration(milliseconds: 300), widget.onProceed);
        } else {
          setState(() => _drag = 0);
        }
      },
      child: Stack(
        children: [
          Container(
            width: width,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x14000000),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _completed ? 'Proceeding...' : 'Swipe Right To proceed',
              style: const TextStyle(
                color: Color(0xFF233B7A),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 80),
            left: _drag,
            top: 0,
            bottom: 0,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF233B7A),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
