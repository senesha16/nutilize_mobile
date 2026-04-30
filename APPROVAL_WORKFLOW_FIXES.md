# Approval Workflow Bug Fixes

## Summary of Issues Found & Fixed

### 1. **SQL Trigger Logic Bug** (CREATE_APPROVAL_TRIGGER.sql)
**Problem**: The trigger was checking ALL items at once on the first insertion, but would fail for subsequent items added to the same reservation.

**Old Logic**:
- Got only the ONE item being added
- Checked if that single item's owner != Physical Facilities
- Would add approvals for just that item's owner
- Then added the standard approval chain
- **BUT** - It would exit early on subsequent items because approvals already existed

**Fixed Logic**:
- When the FIRST item is added to a reservation, trigger fires
- Query finds ALL items currently in that reservation
- Checks if ANY of them have owner != Physical Facilities
- Creates a comprehensive approval chain based on ALL owners
- Subsequent items don't re-trigger (due to duplicate prevention check)
- Creates unique owner approvals for each non-Physical Facilities owner found

### 2. **Flutter Approval Stages Definition** (reservation_status_dialog.dart)
**Problem**: The approval stages were built based on `hasBorrowedItems` (whether items exist), but should be based on whether ANY item has a non-Physical Facilities owner.

**Changed**:
- Updated `_buildApprovalStages()` parameter from `hasBorrowedItems` to `hasNonPhysicalFacilitiesItems`
- Now correctly includes "Designated Item Owner" stage only if needed

### 3. **Missing Item Owner Information** (reservation_service.dart)
**Problem**: The `BorrowedItem` class didn't include owner information, so the UI couldn't determine if items were from Physical Facilities.

**Fixed**:
- Enhanced the SQL query in `getReservationItems()` to fetch `item_owners.owner_name`
- Added `ownerName` field to `BorrowedItem` class
- Updated `BorrowedItem.fromJson()` to parse owner data

### 4. **Timeline and Progress Indicator** (reservation_status_dialog.dart)
**Problem**: Both components used `hasBorrowedItems` instead of checking actual item owners.

**Fixed**:
- Updated `_ReservationTimelineState._loadTimelineData()` to check `hasNonPhysicalFacilitiesItems`
- Updated `_ProgressIndicatorState._getCompletedApprovals()` to use new logic
- Updated `_ProgressIndicator.build()` to fetch actual items and determine owner types

## Approval Workflow Now Works As Follows

### Scenario 1: Item from Physical Facilities
```
Item: TV (Owner: Physical Facilities)
Approval Chain: Program Chair → SDAO → DO → Security → Physical Facilities (5 stages)
```

### Scenario 2: Item from Different Owner
```
Item: Microphone (Owner: IT)
Approval Chain: IT → Program Chair → SDAO → DO → Security → Physical Facilities (6 stages)
```

### Scenario 3: Mixed Ownership
```
Item 1: TV (Owner: Physical Facilities)
Item 2: Microphone (Owner: IT)
Item 3: Projector (Owner: IT)

Approval Chain: IT → Program Chair → SDAO → DO → Security → Physical Facilities (6 stages)
Notes: 
- "Designated Item Owner" (IT) comes first
- Only unique non-PF owners included
- Standard chain always follows
```

## How to Deploy

### 1. Update the SQL Trigger
Run the complete SQL in `CREATE_APPROVAL_TRIGGER.sql`:
- Go to Supabase Dashboard → SQL Editor
- Create a NEW query
- Copy the entire CREATE_APPROVAL_TRIGGER.sql
- Click "Run"

### 2. Verify the Database Setup
Run these verification queries:
```sql
-- Check offices are set up correctly
SELECT office_id, department_name, order_sequence 
FROM offices 
ORDER BY order_sequence;

-- Check item owners exist
SELECT owner_id, owner_name 
FROM item_owners;
```

Expected results:
- Item Owner departments: "Physical Facilities", "Item Owner", [others per your needs]
- offices table should have: Program Chair, SDAO, DO, Security, Physical Facilities
- order_sequence should be sequential starting from 1

### 3. Rebuild Flutter App
```bash
flutter pub get
flutter run
```

## Testing Steps

1. **Test Case 1: Physical Facilities Item Only**
   - Create reservation with items owned by "Physical Facilities"
   - Check that approval chain has 5 stages (no designated owner)

2. **Test Case 2: Non-PF Item**
   - Create reservation with item owned by "IT" 
   - Check that approval chain has 6 stages (includes IT as first approver)

3. **Test Case 3: Mixed Items**
   - Create reservation with items from both "Physical Facilities" and "IT"
   - Check that approval chain includes IT owner first

4. **Test Case 4: Multiple Non-PF Owners**
   - Create reservation with items from "IT" and "HR"
   - Check that both owners appear in approval chain in order

## Files Modified

1. **CREATE_APPROVAL_TRIGGER.sql** - Fixed SQL trigger logic
2. **lib/core/services/reservation_service.dart** - Enhanced query and BorrowedItem class
3. **lib/features/home/presentation/widgets/reservation_status_dialog.dart** - Updated approval stage building logic

## Key Database Relationships

```
reservation
  ├── reservation_items
  │   └── items
  │       ├── item_owners (owner_id)
  │       └── item_categories (category_id)
  └── reservation_approvals
      └── offices (office_id)
```

The trigger runs AFTER INSERT on reservation_items and:
1. Queries all items in the reservation
2. Finds all non-PF owners
3. Creates approvals in the correct order
