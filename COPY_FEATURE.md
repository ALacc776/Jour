# 📋 Copy to Clipboard Feature

## Overview
Easy export to Google Drive and other apps with formatted bullet-list copy.

---

## Features

### 1. **Calendar View - Copy Single Day**
- **Button**: 📋 icon next to "+ Add" button
- **Action**: Copies all entries for the selected day
- **Format**:
  ```
  Dec 6:
  - Amazing lunch with Sarah!
  - went shopping with james
  - ate at raising canes
  ```

### 2. **Menu View - Copy Ranges**

#### **Copy Today**
- Copies all entries from today

#### **Copy This Week**
- Copies entries from start of week to now
- Week starts on Sunday

#### **Copy This Month**
- Copies entries from start of current month to now

#### **Copy Custom Range**
- Opens date picker sheet
- Select start and end dates
- Shows preview of how many entries found
- Copies all entries in selected range

---

## Output Format

All copy functions export in this format:

```
Dec 6:
- first entry
- second entry
- third entry

Dec 5:
- entry from yesterday
- another entry

Dec 4:
- older entry
```

**Perfect for:**
- ✅ Google Drive
- ✅ Apple Notes
- ✅ Email
- ✅ Slack/Discord
- ✅ Any text editor

---

## User Experience

1. **Haptic Feedback**: Success vibration on copy
2. **Confirmation Alert**: Shows number of entries copied
3. **Empty State**: Won't copy if no entries found
4. **Auto-dismiss**: Custom range sheet closes after successful copy

---

## Implementation Details

### New Files:
- `CustomRangeCopyView.swift` - Custom date range picker

### Modified Files:
- `JournalManager.swift` - Added export functions
  - `getEntriesForWeek()`
  - `getEntriesForMonth()`
  - `getEntriesInRange(from:to:)`
  - `formatEntriesForClipboard()`

- `CalendarView.swift` - Added copy button

- `MenuView.swift` - Added export section with 4 copy options

---

## Technical Details

### Date Grouping
- Entries automatically grouped by day
- Sorted chronologically (oldest to newest)
- Formatted with "MMM d" format (e.g., "Dec 6")

### Performance
- Efficient filtering using `Calendar.startOfDay()`
- No limits on number of entries
- Handles large date ranges gracefully

---

## Future Enhancements (Optional)

Could add in the future:
- [ ] Copy as markdown format
- [ ] Copy with photos included
- [ ] Export as PDF
- [ ] Automatic upload to Google Drive
- [ ] Share sheet integration

---

**Status**: ✅ Complete and Ready to Use!

