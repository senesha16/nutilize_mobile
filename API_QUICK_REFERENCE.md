# NUtilize Backend API Quick Reference

## Supabase Connection
✅ Already setup in `lib/main.dart`

```dart
// Initialize
await Supabase.initialize(
  url: 'https://uszlgigsuseomkwmqwan.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
);

// Access in your code
final supabase = Supabase.instance.client;
```

---

## 🏢 InventoryService
**File:** `lib/core/services/inventory_service.dart`
**Purpose:** Manage rooms and items

### Methods

#### Rooms
```dart
final service = InventoryService();

// Get all available rooms
List<Room> rooms = await service.getAvailableRooms();

// Get specific room
Room room = await service.getRoom(roomId: 5);
```

#### Items
```dart
// Get all available items
List<Item> items = await service.getAvailableItems();

// Get specific item
Item item = await service.getItem(itemId: 10);

// Get items by category
List<Item> cameras = await service.getItemsByCategory(category: 'Electronics');
```

---

## 📅 ReservationService
**File:** `lib/core/services/reservation_service.dart`
**Purpose:** Create and manage reservations

### Methods

#### Create Reservations
```dart
final service = ReservationService();

// Create a new reservation
Reservation reservation = await service.createReservation(
  userId: 1,
  activityName: 'Team Meeting',
  overallStatus: 'pending', // optional
);

// Add room to reservation
await service.addRoomToReservation(
  reservationId: reservation.reservationId,
  roomId: 5,
);

// Add item to reservation
await service.addItemToReservation(
  reservationId: reservation.reservationId,
  itemId: 10,
  quantity: 2, // optional, defaults to 1
);
```

#### Query Reservations
```dart
// Get specific reservation
Reservation res = await service.getReservation(reservationId: 1);

// Get all user's reservations
List<Reservation> userRes = await service.getUserReservations(userId: 1);

// Get approval details
List<ReservationApproval> approvals = await service.getReservationApprovals(
  reservationId: 1,
);

// Get all pending approvals (for staff)
List<ReservationApproval> pending = await service.getPendingApprovals();
```

#### Update Reservations
```dart
// Change status
Reservation updated = await service.updateReservationStatus(
  reservationId: 1,
  newStatus: 'approved', // 'pending', 'approved', 'rejected', 'completed'
);

// Approve (for office staff)
ReservationApproval approval = await service.approveReservation(
  approvalId: 5,
);

// Reject (for office staff)
ReservationApproval rejection = await service.rejectReservation(
  approvalId: 5,
);

// Delete reservation
await service.deleteReservation(reservationId: 1);
```

---

## 👤 UserService
**File:** `lib/core/services/user_service.dart`
**Purpose:** User management and authentication

### Methods

#### User Info
```dart
final service = UserService();

// Get current user (if logged in)
User? current = service.getCurrentUser();

// Get user profile
User user = await service.getUserProfile(userId: 1);

// Get user by email
User? user = await service.getUserByEmail(email: 'student@nu.edu.ph');
```

#### Create & Update
```dart
// Create new user
User newUser = await service.createUser(
  username: 'john_doe',
  email: 'john@nu.edu.ph',
  password: 'securepassword123',
  role: 'student', // or 'staff', 'admin'
);

// Update user profile
User updated = await service.updateUserProfile(
  userId: 1,
  username: 'jane_doe',
  email: 'jane@nu.edu.ph',
  role: 'staff',
);
```

#### Authentication
```dart
// Verify login credentials
User? user = await service.verifyCredentials(
  email: 'john@nu.edu.ph',
  password: 'password123',
);

if (user != null) {
  // Login successful
} else {
  // Invalid credentials
}

// Get all staff
List<User> staff = await service.getUsersByRole(role: 'staff');

// Get all admins
List<User> admins = await service.getUsersByRole(role: 'admin');
```

---

## 🏛️ OfficeService
**File:** `lib/core/services/office_service.dart`
**Purpose:** Manage offices/departments

### Methods

```dart
final service = OfficeService();

// Get all offices
List<Office> offices = await service.getAllOffices();

// Get specific office
Office office = await service.getOffice(officeId: 3);

// Get offices that approve a specific room
List<Office> approvers = await service.getRoomApprovalOffices(roomId: 5);

// Find office by department name
Office? office = await service.getOfficeByDepartment(
  departmentName: 'Facilities Management'
);
```

---

## 📊 Data Models

### User
```dart
User(
  userId: 1,
  username: 'john_doe',
  email: 'john@nu.edu.ph',
  role: 'student',
  createdAt: DateTime.now(),
  updatedAt: null,
)

// Usage
user.userId
user.username
user.email
user.role
```

### Room
```dart
Room(
  roomId: 5,
  roomNumber: '101',
  maintenanceStatus: false,
  availabilityStatus: true,
  dateReserved: null,
  createdAt: DateTime.now(),
  updatedAt: null,
)

// Check if available
if (!room.maintenanceStatus && room.availabilityStatus) {
  // Room is available
}
```

### Item
```dart
Item(
  itemId: 10,
  ownerId: 2,
  itemName: 'Projector',
  category: 'Electronics',
  maintenanceStatus: false,
  availabilityStatus: true,
  dateReserved: null,
  createdAt: DateTime.now(),
  updatedAt: null,
)

// Check if available
if (!item.maintenanceStatus && item.availabilityStatus) {
  // Item is available
}
```

### Reservation
```dart
Reservation(
  reservationId: 1,
  userId: 1,
  activityName: 'Team Meeting',
  overallStatus: 'pending',
  createdAt: DateTime.now(),
  updatedAt: null,
)

// Status values: 'pending', 'approved', 'rejected', 'completed'
```

### ReservationApproval
```dart
ReservationApproval(
  approvalId: 5,
  reservationId: 1,
  officeId: 2,
  status: 'pending',
  approvedAt: null,
  createdAt: DateTime.now(),
  updatedAt: null,
)

// Status values: 'pending', 'approved', 'rejected'
```

### Office
```dart
Office(
  officeId: 2,
  departmentName: 'Facilities Management',
  officerName: 'Maria Santos',
  statusCheckType: 'approval',
  shortCode: 'FM',
  orderSequence: 1,
  createdAt: DateTime.now(),
  updatedAt: null,
)
```

---

## 🔄 Common Workflows

### Workflow 1: User Submits Room Reservation

```dart
// 1. Get current user (from auth)
int currentUserId = 1; // TODO: get from auth context

// 2. Fetch available rooms
final inventoryService = InventoryService();
List<Room> availableRooms = await inventoryService.getAvailableRooms();

// 3. User selects rooms and items in UI

// 4. Create reservation
final reservationService = ReservationService();
Reservation reservation = await reservationService.createReservation(
  userId: currentUserId,
  activityName: 'Team Standup',
);

// 5. Add selected items
for (int roomId in selectedRoomIds) {
  await reservationService.addRoomToReservation(
    reservationId: reservation.reservationId,
    roomId: roomId,
  );
}

// 6. Show confirmation
showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: const Text('Success!'),
    content: Text('Reservation #${reservation.reservationId} submitted'),
  ),
);
```

### Workflow 2: Office Staff Approves Request

```dart
final reservationService = ReservationService();

// 1. Get all pending approvals
List<ReservationApproval> pending = await reservationService.getPendingApprovals();

// 2. Display to staff
// ...

// 3. Staff clicks approve/reject
if (staffApproved) {
  await reservationService.approveReservation(approvalId: approvalId);
} else {
  await reservationService.rejectReservation(approvalId: approvalId);
}

// 4. Update main reservation status if all approvals done
// (This would be done on the backend/cloud functions in production)
```

### Workflow 3: Check Reservation Status

```dart
final reservationService = ReservationService();

// Get user's reservations
List<Reservation> myReservations = await reservationService.getUserReservations(userId: 1);

// Check each reservation's approvals
for (var reservation in myReservations) {
  List<ReservationApproval> approvals = 
    await reservationService.getReservationApprovals(
      reservationId: reservation.reservationId,
    );
  
  // Show approval status to user
  for (var approval in approvals) {
    print('${approval.officeId}: ${approval.status}');
  }
}
```

---

## ⚠️ Error Handling

All service methods can throw exceptions. Always wrap in try-catch:

```dart
try {
  List<Room> rooms = await inventoryService.getAvailableRooms();
  // Use rooms
} on Exception catch (e) {
  print('Error: $e');
  // Show error to user
}
```

---

## 💡 Tips

1. **Instantiate once**: Create service instances at the class level to avoid recreating them
   ```dart
   class MyWidget extends StatefulWidget {
     final _inventoryService = InventoryService();
     // ...
   }
   ```

2. **Cache data**: Store frequently used data to avoid repeated calls
   ```dart
   List<Room>? _cachedRooms;
   
   Future<List<Room>> _getRooms() async {
     return _cachedRooms ??= await _inventoryService.getAvailableRooms();
   }
   ```

3. **Use FutureBuilder**: For async operations in widgets
   ```dart
   FutureBuilder<List<Room>>(
     future: _inventoryService.getAvailableRooms(),
     builder: (context, snapshot) { /* ... */ },
   )
   ```

4. **Handle loading state**: Show progress indicators
   ```dart
   bool _isLoading = false;
   setState(() => _isLoading = true);
   try { /* ... */ }
   finally { setState(() => _isLoading = false); }
   ```

5. **Real-time updates**: Use Supabase Realtime for live data
   ```dart
   // Listen to changes
   final subscription = Supabase.instance.client
       .from('reservations')
       .on(RealtimeListenTypes.all, ...)
       .subscribe();
   ```
