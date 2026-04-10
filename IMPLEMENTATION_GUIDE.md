# Implementation Checklist - Connect Your UI to Supabase

Follow this checklist to integrate the backend services into your existing UI screens.

## ✅ Setup Complete
- [x] Data models created in `lib/core/models/`
- [x] Supabase services created in `lib/core/services/`
- [x] Supabase initialized in `main.dart`
- [x] API Quick Reference ready

## 🚀 Next Steps - Update Your Screens

### Step 1: Update Room Reservation Form

**File:** `lib/features/requests/presentation/screens/room_reservation_form_widgets.dart`

Add to the top of the file:
```dart
import 'package:nutilize/core/services/inventory_service.dart';
import 'package:nutilize/core/services/reservation_service.dart';
import 'package:nutilize/core/models/room.dart';
import 'package:nutilize/core/models/item.dart';
```

Update the `RoomReservationFormPage` widget:
```dart
class RoomReservationFormPage extends StatefulWidget {
  const RoomReservationFormPage({super.key});

  @override
  State<RoomReservationFormPage> createState() => _RoomReservationFormPageState();
}

class _RoomReservationFormPageState extends State<RoomReservationFormPage> {
  final _inventoryService = InventoryService();
  final _reservationService = ReservationService();
  final _activityNameController = TextEditingController();
  
  late Future<List<Room>> _roomsFuture;
  late Future<List<Item>> _itemsFuture;
  
  final Set<int> _selectedRoomIds = {};
  final Set<int> _selectedItemIds = {};
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Load available rooms and items when page opens
    _roomsFuture = _inventoryService.getAvailableRooms();
    _itemsFuture = _inventoryService.getAvailableItems();
  }

  @override
  void dispose() {
    _activityNameController.dispose();
    super.dispose();
  }

  Future<void> _submitReservation() async {
    // Validate input
    if (_activityNameController.text.isEmpty) {
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
      // Create reservation
      final reservation = await _reservationService.createReservation(
        userId: 1, // TODO: Replace with actual user ID from auth
        activityName: _activityNameController.text,
        overallStatus: 'pending',
      );

      // Add selected rooms
      for (int roomId in _selectedRoomIds) {
        await _reservationService.addRoomToReservation(
          reservationId: reservation.reservationId,
          roomId: roomId,
        );
      }

      // Add selected items
      for (int itemId in _selectedItemIds) {
        await _reservationService.addItemToReservation(
          reservationId: reservation.reservationId,
          itemId: itemId,
          quantity: 1,
        );
      }

      // Show success message
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const _RequestSubmittedFeedbackPage(
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
    // Keep your existing UI but add data binding
    return Scaffold(
      appBar: AppBar(title: const Text('Room Reservation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity Name Field
            TextField(
              controller: _activityNameController,
              decoration: const InputDecoration(
                labelText: 'Activity Name',
                border: OutlineInputBorder(),
                hintText: 'e.g., Team Meeting, Conference',
              ),
            ),
            const SizedBox(height: 24),

            // Rooms Selection
            const Text(
              'Select Rooms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Room>>(
              future: _roomsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Text('Error loading rooms: ${snapshot.error}');
                }

                final rooms = snapshot.data ?? [];
                if (rooms.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No rooms available'),
                  );
                }

                return Column(
                  children: rooms.map((room) {
                    return CheckboxListTile(
                      value: _selectedRoomIds.contains(room.roomId),
                      onChanged: (selected) {
                        setState(() {
                          if (selected ?? false) {
                            _selectedRoomIds.add(room.roomId);
                          } else {
                            _selectedRoomIds.remove(room.roomId);
                          }
                        });
                      },
                      title: Text('Room ${room.roomNumber}'),
                      subtitle: Text(
                        room.maintenanceStatus ? 'In Maintenance' : 'Available',
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // Items Selection
            const Text(
              'Select Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Item>>(
              future: _itemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Text('Error loading items: ${snapshot.error}');
                }

                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No items available'),
                  );
                }

                return Column(
                  children: items.map((item) {
                    return CheckboxListTile(
                      value: _selectedItemIds.contains(item.itemId),
                      onChanged: (selected) {
                        setState(() {
                          if (selected ?? false) {
                            _selectedItemIds.add(item.itemId);
                          } else {
                            _selectedItemIds.remove(item.itemId);
                          }
                        });
                      },
                      title: Text(item.itemName),
                      subtitle: Text(item.category ?? 'Uncategorized'),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReservation,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit Reservation',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 2: Update Success Feedback Page

Rename the old `_RequestSubmittedFeedbackPage` to `_RequestSubmittedFeedbackPage` and update it:

```dart
class _RequestSubmittedFeedbackPage extends StatelessWidget {
  final int reservationId;
  
  const _RequestSubmittedFeedbackPage({
    required this.reservationId,
  });

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
                'Your reservation #$reservationId has been submitted.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'You will receive updates about your request status.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil(
                      (route) => route.isFirst,
                    );
                  },
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Step 3: Create a User Reservations Screen (Optional but Recommended)

Create new file: `lib/features/requests/presentation/screens/my_reservations_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:nutilize/core/services/reservation_service.dart';
import 'package:nutilize/core/models/reservation.dart';

class MyReservationsScreen extends StatefulWidget {
  final int userId;

  const MyReservationsScreen({required this.userId, super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  final _reservationService = ReservationService();
  late Future<List<Reservation>> _reservationsFuture;

  @override
  void initState() {
    super.initState();
    _reservationsFuture = _reservationService.getUserReservations(widget.userId);
  }

  void _refreshReservations() {
    setState(() {
      _reservationsFuture = _reservationService.getUserReservations(widget.userId);
    });
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reservations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshReservations,
          ),
        ],
      ),
      body: FutureBuilder<List<Reservation>>(
        future: _reservationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshReservations,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final reservations = snapshot.data ?? [];

          if (reservations.isEmpty) {
            return const Center(
              child: Text('You have no reservations yet'),
            );
          }

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(
                    reservation.activityName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'ID: #${reservation.reservationId}\n${reservation.createdAt.toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Chip(
                    label: Text(
                      reservation.overallStatus ?? 'pending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: _getStatusColor(reservation.overallStatus),
                  ),
                  isThreeLine: true,
                  onTap: () {
                    // TODO: Navigate to reservation details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

### Step 4: Add to Your Requests Screen

Update `lib/features/requests/presentation/screens/requests_screen.dart` to include a link to view reservations:

```dart
// In the _RequestsDesktopPage or mobile version, add:
ElevatedButton.icon(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MyReservationsScreen(userId: 1), // TODO: Use real user ID
      ),
    );
  },
  icon: const Icon(Icons.list),
  label: const Text('View My Reservations'),
)
```

---

## 📝 Important Todos

These are critical items you need to address:

### 1. **User Context Management** (HIGH PRIORITY)
Every service method needs a valid `userId`. Currently using hardcoded `1`.

**Solution:** Create a user context or auth state
```dart
// Option 1: Use provider package
final userProvider = StateNotifierProvider<UserNotifier, User>(...);

// Option 2: Use shared preferences
final userId = await prefs.getInt('current_user_id');

// Option 3: Use Supabase auth
final user = supabase.auth.currentUser;
```

### 2. **Password Security** (CRITICAL)
Currently storing passwords in plain text. **This is UNSAFE.**

**Solution:** Use proper authentication
```dart
// Use Supabase Auth instead
final response = await supabase.auth.signUpWithPassword(
  email: email,
  password: password,
);
```

### 3. **Error Messages** (MEDIUM)
Show user-friendly error messages instead of technical ones
```dart
// Instead of
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(error.toString())),
);

// Do this
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Failed to submit reservation. Please try again.')),
);
```

### 4. **Loading States** (MEDIUM)
Add loading indicators for all async operations

### 5. **Data Caching** (LOW)
Cache frequently accessed data to reduce API calls

---

## 🧪 Testing Your Integration

### Test 1: Load Rooms & Items
```
1. Open Room Reservation form
2. Wait for rooms and items to load
3. Verify they appear in the lists
```

### Test 2: Submit Reservation
```
1. Enter activity name
2. Select a room and item
3. Click submit
4. See success message with reservation ID
5. Check Supabase dashboard to verify data was saved
```

### Test 3: View Reservations
```
1. Go to My Reservations
2. See previously submitted reservations
3. Check status is 'pending'
```

---

## 🐛 Debugging Tips

### Check if Supabase is connected:
```dart
final supabase = Supabase.instance.client;
print(supabase.auth.currentUser); // Should print user info if logged in
```

### Check if data is saved:
1. Go to Supabase dashboard: https://supabase.com/dashboard/project/uszlgigsuseomkwmqwan
2. Click on "Reservations" table
3. Should see your submitted reservation

### Print API responses:
```dart
print('Response: $reservation');
print('Rooms: $rooms');
```

---

## ✅ Completion Checklist

- [ ] Updated `room_reservation_form_widgets.dart` with service integration
- [ ] Updated `requests_screen.dart` to use new services
- [ ] Created `my_reservations_screen.dart`
- [ ] Implemented error handling
- [ ] Tested room/item loading
- [ ] Tested reservation submission
- [ ] Verified data appears in Supabase dashboard
- [ ] Replaced hardcoded `userId: 1` with real user context
- [ ] Added user-friendly error messages
- [ ] Considered authentication implementation

---

## 📚 Additional Resources

- [Supabase Flutter Docs](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [Flutter FutureBuilder](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)
- [Dart Async/Await](https://dart.dev/codelabs/async-await)
- [Managing State in Flutter](https://flutter.dev/docs/development/data-and-backend/state-mgmt)
