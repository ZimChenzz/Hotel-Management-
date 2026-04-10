---
title: "Multi-Room Booking Assignment Optimization"
description: "Consolidate multi-room booking assignment into single page with bulk check-in capability"
status: pending
priority: P1
effort: 6h
branch: main
tags: [staff-booking, jsp, multi-room, bulk-assignment]
created: 2026-04-02
---

# Multi-Room Booking Assignment Optimization Plan

## Context

Staff currently must navigate between multiple pages to assign rooms for multi-room bookings. The new design consolidates all unassigned rooms, available rooms, and suggestions into a single page with bulk assignment capability.

## Desired Flow

1. Staff navigates to `/staff/bookings/assign?bookingId=X`
2. Page displays ALL unassigned BookingRooms with their types
3. For each unassigned BookingRoom, displays:
   - Room type info
   - Available rooms for that type
   - Suggested rooms (if available)
4. Staff assigns rooms via dropdown/radio selection per BookingRoom
5. "Check-in all" button appears when all rooms assigned
6. Single confirmation completes all assignments

## Key Changes

### Files to Modify

| File | Changes |
|------|---------|
| `StaffBookingController.java` | Enhance `handleAssignRoomGet()` to load all unassigned rooms with suggestions |
| `assign-room.jsp` | Redesign to show all unassigned rooms in accordion/card layout |
| `detail.jsp` | Minor: update "Gán phòng" button link to pass bookingId only |

### Files to Create (if needed)

| File | Purpose |
|------|---------|
| None | Reuse existing `bulkAssignRooms` service method |

## Phases

### Phase 1: Controller Enhancement (1.5h)

**Goal:** Modify `handleAssignRoomGet()` to provide data for all unassigned BookingRooms

**Changes in `StaffBookingController.java`:**

1. Rename method from `handleAssignRoomGet` to `handleAssignMultiRoomGet` (or keep for backward compat)
2. Load all unassigned BookingRooms instead of just one
3. For each unassigned BookingRoom, fetch:
   - Available rooms by type
   - Suggested rooms via `RoomSuggestionService`
4. Pass `List<UnassignedRoomInfo>` to JSP where `UnassignedRoomInfo` contains:
   - `BookingRoom` entity
   - `List<Room>` availableRooms
   - `List<RoomSuggestionItem>` suggestions

**Backend DTO needed:**
```java
// New class: UnassignedRoomInfo (inline or separate)
public class UnassignedRoomInfo {
    private BookingRoom bookingRoom;
    private List<Room> availableRooms;
    private List<Room> suggestedRooms;
}
```

**Service method to add:**
```java
// In StaffBookingService.java
public List<UnassignedRoomInfo> getUnassignedRoomsWithSuggestions(int bookingId)
```

---

### Phase 2: JSP Redesign (2.5h)

**Goal:** Redesign `assign-room.jsp` to display all unassigned rooms in a unified view

**Layout Design:**

```
+----------------------------------------------------------+
| [Back to List]  [Back to Detail]                         |
+----------------------------------------------------------+
| Booking #123 - Customer: Nguyen Van A                     |
| Check-in: 01/04/2026 14:00 | Check-out: 03/04/2026 12:00|
| Total: 3,500,000 VND                                     |
+----------------------------------------------------------+
| UNASSIGNED ROOMS (3)                      [Check-in All]  |
+----------------------------------------------------------+
| +------------------------------------------------------+ |
| | BookingRoom #1 - Superior Room                       | |
| | Suggested: 201, 202 (consecutive)                   | |
| | [Select Room: ▼ 201 ]  [ ] Use suggestion           | |
| +------------------------------------------------------+ |
| | BookingRoom #2 - Deluxe Room                        | |
| | Suggested: 301                                      | |
| | [Select Room: ▼ 301 ]  [ ] Use suggestion          | |
| +------------------------------------------------------+ |
| | BookingRoom #3 - Superior Room                      | |
| | No suggestions available                            | |
| | [Select Room: ▼ Select... ]                         | |
| +------------------------------------------------------+ |
+----------------------------------------------------------+
| [Assign Selected & Check-in All]                         |
+----------------------------------------------------------+
```

**Key UI Components:**

1. **Summary Header**: Booking info, total unassigned count
2. **Room Cards**: One card per unassigned BookingRoom
   - Shows BookingRoom ID, type name
   - Dropdown of available rooms
   - Highlight suggested rooms
3. **Check-in All Button**: Enabled only when all rooms assigned
4. **Bulk Assignment Form**: Hidden inputs for all bookingRoomId:roomId pairs

**Form Structure:**
```html
<form method="post" action="/staff/bookings/bulk-assign">
  <input type="hidden" name="bookingId" value="${booking.bookingId}">
  <input type="hidden" name="bookingRoomId" value="1">
  <input type="hidden" name="suggestedRoomId" value="201">
  <!-- repeat for each -->
  <button type="submit">Check-in All</button>
</form>
```

---

### Phase 3: Suggestions Integration (1h)

**Goal:** Integrate `RoomSuggestionService` per BookingRoom type

**Implementation:**

1. Group unassigned rooms by typeId
2. For each typeId, calculate quantity needed
3. Call `RoomSuggestionService.suggestNearbyRooms(needs, checkIn, checkOut)`
4. Map suggestions back to individual BookingRooms

**Logic in Controller:**
```java
// Pseudo-code
Map<Integer, Integer> needs = new LinkedHashMap<>();
for (BookingRoom br : unassigned) {
    needs.merge(br.getTypeId(), 1, Integer::sum);
}
Map<Integer, List<Room>> suggestions = suggestionService.suggestNearbyRooms(
    needs, booking.getCheckInExpected(), booking.getCheckOutExpected());
// Distribute suggestions to UnassignedRoomInfo objects by typeId
```

---

### Phase 4: Detail.jsp Update (0.5h)

**Goal:** Update detail page to use simplified assign flow

**Changes:**

1. For multi-room with unassigned rooms, link to:
   ```
   /staff/bookings/assign?bookingId=${booking.bookingId}
   ```
   (NOT `/assign-room?bookingId=X&bookingRoomId=Y`)

2. Button text: "Gán tất cả phòng" instead of individual "Gán phòng"

---

### Phase 5: Testing (0.5h)

**Test Cases:**

1. Single unassigned room - shows single card, works as before
2. Multiple unassigned rooms - shows all, bulk assign works
3. Partial assignment - "Check-in all" disabled until all assigned
4. No available rooms - shows warning per card
5. Suggestions available - highlighted in dropdown
6. All rooms assigned - redirect to detail page

---

## Success Criteria

1. Staff can assign all rooms for a booking without leaving the page
2. Suggestions are visible per BookingRoom type
3. "Check-in all" only enabled when all rooms have assignments
4. After bulk assign, booking status updated to CheckedIn
5. No regression for single-room bookings

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Breaking single-room flow | Keep existing `assignRoom` path working; new UI is additive |
| Performance with many available rooms | Lazy-load available rooms per type via AJAX (future) |
| Concurrent assignment conflicts | Rely on existing room availability check in repository |

## Unresolved Questions

1. Should available rooms list be fetched via AJAX on card expansion (performance)?
2. What to show if a type has 0 available rooms - allow assignment anyway or show error?
3. Keep or remove `/staff/bookings/suggest-rooms` page after this change?
