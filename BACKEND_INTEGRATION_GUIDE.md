# NUtilize Backend Integration Guide

## Overview
Your app now has a complete backend integration layer with:
- **Data Models** - Dart classes matching your Supabase database
- **Service Layer** - Supabase repositories for all CRUD operations
- **Supabase Connection** - Already initialized in `main.dart`

## File Structure
```
lib/
├── core/
│   ├── models/          ← Dart models matching database tables
│   │   ├── user.dart
│   │   ├── room.dart
│   │   ├── item.dart
│   │   ├── reservation.dart
│   │   ├── reservation_approval.dart
│   │   └── office.dart
│   └── services/        ← Supabase services for database operations
│       ├── inventory_service.dart     (rooms & items)
│       ├── reservation_service.dart   (reservations & approvals)
│       ├── user_service.dart          (user management)
│       └── office_service.dart        (offices)
└── features/
    └── requests/        ← Your UI screens
```

## How to Use Services in Your UI

### 1. Basic Service Usage in Widgets

#### Fetch Available Rooms
```dart
import 'package:nutilize/core/services/inventory_service.dart';
import 'package:nutilize/core/models/room.dart';

class RoomListWidget extends StatefulWidget {
  @override
  State<RoomListWidget> createState() => _RoomListWidgetState();
}

class _RoomListWidgetState extends State<RoomListWidget> {
  final _inventoryService = InventoryService();
  late Future<List<Room>> _roomsFuture;

  @override
  void initState() {
    super.initState();
    _roomsFuture = _inventoryService.getAvailableRooms();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Room>>(
      future: _roomsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        
        final rooms = snapshot.data ?? [];
        return ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return ListTile(
              title: Text(room.roomNumber),
              subtitle: Text(room.maintenanceStatus ? 'In Maintenance' : 'Available'),
            );
          },
        );
      },
    );
  }
}
```

#### Create a Reservation
```dart
import 'package:nutilize/core/services/reservation_service.dart';

// In your form submission handler
Future<void> _submitReservation() async {
  final reservationService = ReservationService();
  
  try {
    // Step 1: Create the reservation
    final reservation = await reservationService.createReservation(
      userId: 1, // Get from current user context
      activityName: _activityNameController.text,
      overallStatus: 'pending',
    );

    print('Reservation created: ${reservation.reservationId}');

    // Step 2: Add selected rooms
    for (int roomId in _selectedRoomIds) {
      await reservationService.addRoomToReservation(
        reservationId: reservation.reservationId,
        roomId: roomId,
      );
    }

    // Step 3: Add selected items
    for (int itemId in _selectedItemIds) {
      await reservationService.addItemToReservation(
        reservationId: reservation.reservationId,
        itemId: itemId,
        quantity: 1,
      );
    }

    // Step 4: Show success
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reservation submitted successfully!')),
    );

    // Navigate to success screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SuccessScreen()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

### 2. Complete Reservation Workflow

#### Step 1: Display Available Rooms and Items
```dart
class RoomReservationFormPage extends StatefulWidget {
  const RoomReservationFormPage({super.key});

  @override
  State<RoomReservationFormPage> createState() => _RoomReservationFormPageState();
}

class _RoomReservationFormPageState extends State<RoomReservationFormPage> {
  final _inventoryService = InventoryService();
  final _reservationService = ReservationService();
  final _activityController = TextEditingController();
  
  late Future<List<Room>> _roomsFuture;
  late Future<List<Item>> _itemsFuture;
  
  final Set<int> _selectedRoomIds = {};
  final Set<int> _selectedItemIds = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _roomsFuture = _inventoryService.getAvailableRooms();
    _itemsFuture = _inventoryService.getAvailableItems();
  }

  @override
  void dispose() {
    _activityController.dispose();
    super.dispose();
  }

  Future<void> _submitReservation() async {
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
        userId: 1, // TODO: Get from auth context
        activityName: _activityController.text,
      );

      // Add rooms
      for (int roomId in _selectedRoomIds) {
        await _reservationService.addRoomToReservation(
          reservationId: reservation.reservationId,
          roomId: roomId,
        );
      }

      // Add items
      for (int itemId in _selectedItemIds) {
        await _reservationService.addItemToReservation(
          reservationId: reservation.reservationId,
          itemId: itemId,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(); // Go back to requests screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation submitted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Room Reservation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity name field
            TextField(
              controller: _activityController,
              decoration: const InputDecoration(
                labelText: 'Activity Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Rooms section
            const Text('Select Rooms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            FutureBuilder<List<Room>>(
              future: _roomsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                
                final rooms = snapshot.data ?? [];
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
                      title: Text(room.roomNumber),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // Items section
            const Text('Select Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            FutureBuilder<List<Item>>(
              future: _itemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                
                final items = snapshot.data ?? [];
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
                      subtitle: Text(item.category ?? ''),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReservation,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Submit Reservation'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Displaying User Reservations

```dart
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Reservation>>(
      future: _reservationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final reservations = snapshot.data ?? [];

        return Scaffold(
          appBar: AppBar(title: const Text('My Reservations')),
          body: reservations.isEmpty
              ? const Center(child: Text('No reservations yet'))
              : ListView.builder(
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];
                    return Card(
                      child: ListTile(
                        title: Text(reservation.activityName),
                        subtitle: Text(
                          'Status: ${reservation.overallStatus ?? "pending"}',
                        ),
                        trailing: Chip(
                          label: Text(
                            reservation.overallStatus ?? 'pending',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: reservation.overallStatus == 'approved'
                              ? Colors.green
                              : reservation.overallStatus == 'rejected'
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                        onTap: () {
                          // Navigate to reservation details screen
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
```

## Key Service Classes

### InventoryService
- `getAvailableRooms()` - Get all available rooms
- `getAvailableItems()` - Get all available items
- `getItemsByCategory(category)` - Filter items by category
- `getRoom(roomId)` - Get specific room
- `getItem(itemId)` - Get specific item

### ReservationService
- `createReservation(userId, activityName, overallStatus)` - Create new reservation
- `addRoomToReservation(reservationId, roomId)` - Add room to reservation
- `addItemToReservation(reservationId, itemId, quantity)` - Add item to reservation
- `getUserReservations(userId)` - Get all user's reservations
- `getReservationApprovals(reservationId)` - Get approval statuses
- `updateReservationStatus(reservationId, newStatus)` - Update status
- `approveReservation(approvalId)` - Approve (for office staff)
- `rejectReservation(approvalId)` - Reject (for office staff)
- `deleteReservation(reservationId)` - Delete reservation

### UserService
- `getCurrentUser()` - Get logged-in user
- `getUserProfile(userId)` - Fetch user data
- `createUser(username, email, password, role)` - Create new user
- `updateUserProfile(userId, ...)` - Update user info
- `verifyCredentials(email, password)` - Login verification
- `getUsersByRole(role)` - Get staff/admin users

### OfficeService
- `getAllOffices()` - Get all departments/offices
- `getOffice(officeId)` - Get specific office
- `getRoomApprovalOffices(roomId)` - Get offices that approve a room

## Common Patterns

### Pattern 1: Load Data Once on Init
```dart
@override
void initState() {
  super.initState();
  _dataFuture = _service.fetchData();
}

@override
Widget build(BuildContext context) {
  return FutureBuilder(
    future: _dataFuture,
    builder: (context, snapshot) {
      // Handle loading, error, and data states
    },
  );
}
```

### Pattern 2: Refresh Data
```dart
void _refreshData() {
  setState(() {
    _dataFuture = _service.fetchData();
  });
}
```

### Pattern 3: Handle Loading State
```dart
bool _isLoading = false;

Future<void> _doSomething() async {
  setState(() => _isLoading = true);
  try {
    // Do work
  } catch (e) {
    // Handle error
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

## Next Steps

1. **Update your request form screens** to use these services
2. **Add a user authentication screen** using UserService
3. **Create a reservation details screen** to show approval status
4. **Add error handling** - wrap service calls in try-catch
5. **Implement real-time updates** - consider using Supabase Realtime subscriptions
6. **Add state management** - consider Provider, Riverpod, or GetX for shared state

## Important Notes

- Replace hardcoded `userId: 1` with actual user context from your auth system
- Add proper error handling in production
- Consider implementing caching for frequently accessed data
- Use Supabase RLS (Row Level Security) to protect data in production
- Never expose sensitive data in error messages to users
