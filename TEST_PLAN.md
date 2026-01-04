# Manual Test Plan
## Saudi Driving Theory Test - Flutter App

**Purpose:** Verify all permanent fixes work correctly and no regressions were introduced.  
**Platform:** Android device (physical or emulator)  
**Prerequisites:** App installed with all fixes applied

---

## Test Environment Setup

1. **Install app** on Android device
2. **Clear app data** (Settings → Apps → Saudi Driving Theory Test → Storage → Clear Data)
3. **Launch app** fresh

---

## 1. Language Selection & Persistence

### Test 1.1: Change Language to Arabic
**Steps:**
1. Open app → Navigate to Settings (gear icon)
2. Tap "Language" option
3. Select "العربية (Arabic)"

**Expected Results:**
- ✅ UI updates immediately to Arabic
- ✅ Layout switches to RTL (right-to-left)
- ✅ All text displays in Arabic
- ✅ No "Locale: XX" debug text visible

**Verification:**
- [ ] UI is in Arabic
- [ ] RTL layout correct
- [ ] No debug text

---

### Test 1.2: Language Persists After Restart
**Steps:**
1. With app in Arabic, press Home button
2. Force stop app (Settings → Apps → Force Stop)
3. Relaunch app

**Expected Results:**
- ✅ App opens in Arabic (not English)
- ✅ RTL layout maintained

**Verification:**
- [ ] App opens in Arabic
- [ ] No language reset

---

### Test 1.3: Test All Languages
**Steps:**
Repeat Test 1.1 and 1.2 for each language:
- English (en)
- Urdu (ur)
- Hindi (hi)
- Bengali (bn)

**Expected Results:**
- ✅ Each language works and persists

**Verification:**
- [ ] English works
- [ ] Arabic works
- [ ] Urdu works
- [ ] Hindi works
- [ ] Bengali works

---

## 2. Navigation & Back Button Behavior

### Test 2.1: Home → Practice → Back
**Steps:**
1. From Home screen, tap Practice tab
2. Select "All Categories"
3. Tap "Start Practice"
4. Answer 1 question
5. Press Android back button

**Expected Results:**
- ✅ Confirmation dialog appears: "Exit practice?"
- ✅ Tap "Cancel" → Returns to practice
- ✅ Press back again → Tap "Exit" → Returns to Practice category selection (NOT app exit)

**Verification:**
- [ ] Confirmation dialog shows
- [ ] Cancel works
- [ ] Exit returns to category selection
- [ ] Does NOT exit app

---

### Test 2.2: Home → Exam → Back During Exam
**Steps:**
1. From Home screen, tap Exam tab
2. Start "Quick Exam" (20 questions)
3. Answer 2-3 questions
4. Press Android back button

**Expected Results:**
- ✅ Confirmation dialog appears: "Exit exam?"
- ✅ Tap "Exit" → Returns to Home screen
- ✅ Exam progress is lost (expected)

**Verification:**
- [ ] Confirmation dialog shows
- [ ] Exit returns to Home
- [ ] No crash

---

### Test 2.3: Results → Review → Back
**Steps:**
1. Complete an exam (any mode)
2. On Results screen, tap "Review Answers"
3. Press Android back button

**Expected Results:**
- ✅ Returns to Results screen (NOT Home)
- ✅ Can tap "Back Home" to go to Home

**Verification:**
- [ ] Back goes to Results
- [ ] "Back Home" button works

---

### Test 2.4: Back Button on Home Screen
**Steps:**
1. Navigate to Home screen (tap Home tab)
2. Press Android back button

**Expected Results:**
- ✅ App exits (or shows "Exit app?" dialog if implemented)

**Verification:**
- [ ] App exits cleanly

---

## 3. Asset Error Handling

### Test 3.1: Simulate Missing Assets (Manual)
**Note:** This test requires manually corrupting data files.

**Steps:**
1. Using file manager, navigate to app's assets directory
2. Rename `questions.json` to `questions.json.bak`
3. Restart app
4. Navigate to Practice tab

**Expected Results:**
- ✅ User-friendly error UI appears (NOT just "Error")
- ✅ Error shows icon, message, and "Retry" button
- ✅ "Technical Details" expandable section visible
- ✅ Tap "Retry" → Error persists (file still missing)

**Steps to Restore:**
5. Rename file back to `questions.json`
6. Tap "Retry" button

**Expected Results:**
- ✅ App loads successfully after retry

**Verification:**
- [ ] Error UI is user-friendly
- [ ] Retry button works
- [ ] Technical details available
- [ ] Recovery works

---

## 4. Practice Flow

### Test 4.1: Practice Mode - Correct Answer
**Steps:**
1. Start practice (any category)
2. Select correct answer for a question

**Expected Results:**
- ✅ Answer highlights in green
- ✅ "Correct!" message appears
- ✅ Explanation shows (if available)
- ✅ "Next" button enabled

**Verification:**
- [ ] Green feedback
- [ ] Correct message
- [ ] Next button works

---

### Test 4.2: Practice Mode - Wrong Answer
**Steps:**
1. In practice mode, select wrong answer

**Expected Results:**
- ✅ Selected answer highlights in red
- ✅ Correct answer highlights in green
- ✅ "Incorrect!" message appears
- ✅ Explanation shows
- ✅ "Next" button enabled

**Verification:**
- [ ] Red feedback on wrong answer
- [ ] Green feedback on correct answer
- [ ] Explanation visible
- [ ] Next button works

---

### Test 4.3: Complete Practice Session
**Steps:**
1. Complete entire practice session (all questions)

**Expected Results:**
- ✅ Results screen appears
- ✅ Score displayed correctly
- ✅ "Review Answers" button works
- ✅ "Try Again" button works

**Verification:**
- [ ] Results screen shows
- [ ] Score accurate
- [ ] Review works
- [ ] Try Again works

---

## 5. Exam Flow

### Test 5.1: Start Exam
**Steps:**
1. Tap Exam tab
2. Select "Standard Exam" (30 questions, 20 minutes)
3. Tap "Start Exam" in confirmation dialog

**Expected Results:**
- ✅ Exam starts
- ✅ Timer counts down
- ✅ Question counter shows (1/30, 2/30, etc.)
- ✅ Can select answers
- ✅ Can flag questions

**Verification:**
- [ ] Exam starts
- [ ] Timer works
- [ ] Question counter accurate
- [ ] Answers selectable
- [ ] Flag works

---

### Test 5.2: Navigate Between Questions
**Steps:**
1. During exam, answer 5 questions
2. Tap "Review Answers" button (if not in strict mode)
3. Tap question #2 in grid

**Expected Results:**
- ✅ Jumps to question #2
- ✅ Previous answer still selected
- ✅ Can change answer

**Verification:**
- [ ] Navigation works
- [ ] Answers persist
- [ ] Can change answers

---

### Test 5.3: Complete Exam
**Steps:**
1. Complete all questions in exam
2. Tap "Submit" button

**Expected Results:**
- ✅ Results screen appears
- ✅ Score displayed (e.g., "70%")
- ✅ Pass/Fail status shown
- ✅ "Review Answers" button available
- ✅ "Try Again" button available

**Verification:**
- [ ] Results screen shows
- [ ] Score accurate
- [ ] Pass/Fail correct
- [ ] Buttons work

---

### Test 5.4: Review Exam Answers
**Steps:**
1. From Results screen, tap "Review Answers"
2. Scroll through all questions

**Expected Results:**
- ✅ All questions listed
- ✅ User answer shown (red if wrong, green if correct)
- ✅ Correct answer highlighted in green
- ✅ Explanation expandable
- ✅ Can scroll smoothly

**Verification:**
- [ ] All questions visible
- [ ] Color coding correct
- [ ] Explanations work
- [ ] Scrolling smooth

---

## 6. Edge Cases

### Test 6.1: Small Screen
**Device:** Smallest supported Android device/emulator

**Steps:**
1. Navigate through all screens
2. Check Practice, Exam, Results, Review

**Expected Results:**
- ✅ No text overflow
- ✅ No UI elements cut off
- ✅ All buttons accessible

**Verification:**
- [ ] No overflow
- [ ] All elements visible
- [ ] Buttons accessible

---

### Test 6.2: Large Text Scale
**Steps:**
1. Enable large text in Android settings (Settings → Display → Font Size → Largest)
2. Open app
3. Navigate through all screens

**Expected Results:**
- ✅ Text scales properly
- ✅ No overflow
- ✅ UI remains usable

**Verification:**
- [ ] Text scales
- [ ] No overflow
- [ ] Usable

---

### Test 6.3: Arabic RTL Layout
**Steps:**
1. Change language to Arabic
2. Navigate through Practice and Exam flows
3. Check all screens

**Expected Results:**
- ✅ All UI elements properly mirrored
- ✅ Text alignment correct (right-aligned)
- ✅ Icons and buttons in correct positions
- ✅ Navigation arrows reversed

**Verification:**
- [ ] UI mirrored correctly
- [ ] Text aligned right
- [ ] Icons positioned correctly
- [ ] Navigation correct

---

### Test 6.4: Orientation Change
**Steps:**
1. Start practice session
2. Rotate device to landscape
3. Rotate back to portrait

**Expected Results:**
- ✅ UI adapts to orientation
- ✅ Progress maintained
- ✅ No crash

**Verification:**
- [ ] Orientation works
- [ ] Progress maintained
- [ ] No crash

---

### Test 6.5: Empty Favorites
**Steps:**
1. Navigate to Favorites screen (if accessible)
2. Verify empty state

**Expected Results:**
- ✅ Empty state message shown
- ✅ No crash

**Verification:**
- [ ] Empty state handled
- [ ] No crash

---

### Test 6.6: No Exam History
**Steps:**
1. Fresh install (or clear data)
2. Navigate to History screen

**Expected Results:**
- ✅ Empty state message shown
- ✅ No crash

**Verification:**
- [ ] Empty state handled
- [ ] No crash

---

## 7. Regression Testing

### Test 7.1: Full Practice Flow
**Steps:**
1. Home → Practice → Select category → Start
2. Answer all questions (mix of correct/incorrect)
3. Complete practice
4. View results
5. Review answers
6. Return to Home

**Expected Results:**
- ✅ Entire flow works without errors
- ✅ Feedback correct
- ✅ Results accurate
- ✅ Review shows all questions

**Verification:**
- [ ] Flow completes
- [ ] No errors
- [ ] Results accurate

---

### Test 7.2: Full Exam Flow
**Steps:**
1. Home → Exam → Select mode → Start
2. Answer all questions
3. Submit exam
4. View results
5. Review answers
6. Tap "Try Again"
7. Start new exam

**Expected Results:**
- ✅ Entire flow works without errors
- ✅ Timer works
- ✅ Results accurate
- ✅ Try Again starts fresh exam

**Verification:**
- [ ] Flow completes
- [ ] Timer works
- [ ] Results accurate
- [ ] Try Again works

---

### Test 7.3: Settings Persistence
**Steps:**
1. Change language to Urdu
2. Change theme to Dark
3. Toggle sound OFF
4. Toggle vibration OFF
5. Restart app

**Expected Results:**
- ✅ Language is Urdu
- ✅ Theme is Dark
- ✅ Sound is OFF
- ✅ Vibration is OFF

**Verification:**
- [ ] Language persists
- [ ] Theme persists
- [ ] Sound setting persists
- [ ] Vibration setting persists

---

## Test Summary

**Total Tests:** 24  
**Critical Tests:** 15  
**Edge Case Tests:** 6  
**Regression Tests:** 3

**Completion Criteria:**
- [ ] All critical tests pass
- [ ] No crashes observed
- [ ] No UI overflow/layout issues
- [ ] Language selection works and persists
- [ ] Navigation back button behaves correctly
- [ ] Asset error handling works
- [ ] Practice and Exam flows complete successfully

---

## Bug Reporting Template

If issues are found during testing, report using this format:

**Test ID:** [e.g., Test 2.1]  
**Device:** [e.g., Pixel 6, Android 13]  
**Language:** [e.g., English, Arabic]  
**Steps to Reproduce:**
1. Step 1
2. Step 2
3. Step 3

**Expected Result:** [What should happen]  
**Actual Result:** [What actually happened]  
**Screenshots:** [If applicable]  
**Severity:** [Critical / High / Medium / Low]

---

**Test Plan Version:** 1.0  
**Last Updated:** 2026-01-04  
**Created By:** Stabilization Pass
