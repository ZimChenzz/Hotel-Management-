# Walk-in Multi-Room Booking Plan

## Context
Staff walk-in booking currently only supports single room. Customer online booking already supports multi-room. Need to add multi-room capability to walk-in.

## Desired Flow
1. Staff enters customer info (existing step 1)
2. Staff selects room types and quantities (new step 2 - multi)
3. System auto-assigns rooms if available
4. Staff confirms and creates booking

## Key Changes

### Files to Modify

| File | Changes |
|------|---------|
| `StaffBookingController.java` | Add `handleWalkInMultiRoomPost` to handle selections |
| `walkin-step2.jsp` | Add multi-room selection UI (type + qty) |
| `walkin-step2.jsp` | Auto-assign rooms via `RoomSuggestionService` |

### Files to Create

| File | Purpose |
|------|---------|
| `walkin-step2-multi.jsp` | New page for multi-room selection |

## Phases

### Phase 1: Add Multi-Room Room Selection JSP

**New page: `walkin-step2-multi.jsp`**

UI similar to customer booking step 1:
- Room type dropdown with qty selector
- "Add Room" button to add more room types
- Real-time price calculation
- Availability check before proceeding

### Phase 2: Controller Enhancement

**Changes in `StaffBookingController.java`:**

1. Add URL pattern `/staff/bookings/walkin-multi`
2. Add `handleWalkInMultiRoomGet()` - show multi selection page
3. Add `handleWalkInMultiRoomPost()`:
   - Parse room type + quantity selections
   - Use `RoomSuggestionService` to find available rooms
   - Store selections in session as `List<RoomSelectionItem>`
   - Redirect to confirm page

4. Modify `handleWalkInStep3Post()`:
   - If `walkin_selections` exists → call `createWalkInMultiRoom()`
   - Else → call `createWalkInBooking()` (single room)

### Phase 3: Session Data Structure

Store in session:
```java
session.setAttribute("walkin_selections", List<RoomSelectionItem>); // NEW
session.setAttribute("walkin_customerId", customerId);
session.setAttribute("walkin_checkIn", checkIn);
session.setAttribute("walkin_checkOut", checkOut);
```

### Phase 4: Service Method

Use existing `createWalkInMultiRoom()` in `StaffBookingService`:
```java
public BookingResult createWalkInMultiRoom(int customerId, List<RoomSelectionItem> selections,
        LocalDateTime checkIn, LocalDateTime checkOut,
        BigDecimal totalPrice, String note, List<Occupant> occupants)
```

### Phase 5: Update walkin-step1.jsp

Add link to choose between:
- "Đặt 1 phòng" → existing walkin flow
- "Đặt nhiều phòng" → new multi-room flow

## Implementation Steps

1. Create `walkin-step2-multi.jsp` with room type + qty selection
2. Add `/staff/bookings/walkin-multi` to servlet URL patterns
3. Add `handleWalkInMultiRoomGet()` and `handleWalkInMultiRoomPost()`
4. Modify `walkin-step1.jsp` to show both options
5. Modify `handleWalkInStep3Post()` to check session for single vs multi
6. Test full flow

## Success Criteria
- Staff can book 1 or multiple rooms at once for walk-in
- Room suggestions work for auto-assignment
- Booking created correctly with all BookingRoom records
- All sessions cleaned up after booking
