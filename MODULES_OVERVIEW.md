# NUtilize Modules Overview

This file lists the working modules in the app and the basic needs and features for each one.

## 1. Splash Module

**Basic Needs**

[/] User Interface Design
[/] Loading/Delay Handling
[/] Navigation Control

**Feature(s)**

[/] Show the app logo on startup
[/] Auto-redirect to the login screen after a short delay

## 2. Authentication Module

**Basic Needs**

[/] User Interface Design
[/] Input/Data Validation
[/] Output/Error Messages
[/] Database Management

**Feature(s)**

[/] Login with email and password
[/] Register a new account with personal details
[/] Password strength checking and confirmation matching
[/] User session handling and navigation after successful sign-in

## 3. Main Shell / Navigation Module

**Basic Needs**

[/] User Interface Design
[/] Navigation Management
[/] State Management
[/] Notification Handling

**Feature(s)**

[/] Bottom navigation for Home, Calendar, Requests, and Account
[/] Desktop sidebar navigation layout
[/] Notification polling for approval updates
[/] Preserve the active tab while switching sections

## 4. Home Dashboard Module

**Basic Needs**

[/] User Interface Design
[/] Output/Error Messages
[/] Database Management

**Feature(s)**

[/] Display recent activity and reservation highlights
[/] Show dashboard cards and summary information
[/] Refresh reservation data when the app resumes
[/] Show reservation status details through the status dialog

## 5. Calendar Module

**Basic Needs**

[/] User Interface Design
[/] Data Retrieval
[/] Output/Error Messages
[/] Date/Time Handling

**Feature(s)**

[/] Show approved reservations in a calendar view
[/] Display reservation time and activity details
[/] Open a reservation popup for more information
[/] Check reservation status from the calendar

## 6. Requests Module

**Basic Needs**

[/] User Interface Design
[/] Navigation Management
[/] Output/Error Messages

**Feature(s)**

[/] Let users choose between room reservation, item reservation, and bigger spaces
[/] Open the correct reservation form for each request type
[/] Present request cards in both mobile and desktop layouts

## 7. Reservation Forms Module

**Basic Needs**

[/] User Interface Design
[/] Input/Data Validation
[/] Output/Error Messages
[/] Database Management

**Feature(s)**

[/] Select rooms, items, and quantities for a reservation
[/] Pick date and time ranges with validation
[/] Confirm policies and terms before submission
[/] Submit reservation requests to the backend
[/] Show success feedback after submission

## 8. Account Module

**Basic Needs**

[/] User Interface Design
[/] User Profile Management
[/] Database Management
[/] Output/Error Messages

**Feature(s)**

[/] Display the logged-in user profile
[/] Show reserved, pending, and approved counts
[/] Open reservation and request history pages
[/] Allow logout and return to the login screen

## 9. Report Issue Module

**Basic Needs**

[/] User Interface Design
[/] Input/Data Validation
[/] Output/Error Messages
[/] File/Image Handling

**Feature(s)**

[/] Select the room or item to report
[/] Attach proof photos from camera or gallery
[/] Enter a description of the issue
[/] Submit the report for a reservation or borrowed item

## 10. Shared UI / Support Module

**Basic Needs**

[/] Reusable Component Design
[/] Consistent Styling
[/] Navigation Support

**Feature(s)**

[/] Shared headers, cards, buttons, and inputs
[/] Reusable reservation status dialog
[/] Common app theming and layout behavior
