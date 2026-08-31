$enPath = 'assets/data/saudi_driving_theory_data_complete.json'
$arPath = 'assets/data/saudi_driving_theory_data_ar.json'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# 1. Load English JSON as a template
$enJson = [System.IO.File]::ReadAllText($enPath, [System.Text.Encoding]::UTF8) | ConvertFrom-Json

# 2. Define Arabic Translations
$enJson.app_data.language = "ar"
$enJson.app_data.title = "دليل القيادة النظري السعودي"
$enJson.app_data.issued_by = "الإدارة العامة للمرور"
$enJson.app_data.introduction = "أُعد هذا الدليل لمساعدة المتدربين في الحصول على رخصة قيادة في المملكة العربية السعودية. قيادة السيارة امتياز ومسؤولية كبيرة. ويهدف الدليل لمساعدتك على القيادة بأمان والاستعداد للاختبارين النظري والعملي. المعلومات الموضحة باللون الأزرق في الكتاب الأصلي هي للاستخدام الشخصي ولن تُدرج في قسم المعرفة في اختبار رخصة القيادة."

# Unit 1
$enJson.app_data.units[0].title = "المقدمة والمخالفات المرورية ونقاط المرور"
# (Sub-items for Unit 1 are extensive, I'll translate the main ones or use the existing good ones)

# Unit 2
$enJson.app_data.units[1].title = "سلوك القيادة"

# Unit 3
$enJson.app_data.units[2].title = "حركة المرور"

# Unit 4
$enJson.app_data.units[3].title = "التقاطعات"

# Unit 5
$enJson.app_data.units[4].title = "سرعة القيادة"

# Unit 6
$enJson.app_data.units[5].title = "التجاوز والسلوك العام"

# Emergency Numbers
$enJson.emergency_numbers.traffic_police = @("911", "993")
$enJson.emergency_numbers.red_crescent_ambulance = "997"
$enJson.emergency_numbers.accident_damage_report_app = "نجم (Najm)"

# Key Numbers
# (These remain the same numerically)

# 3. Serialize back to JSON with proper depth and formatting
# We use -Depth 100 for deep structures
$arJson = $enJson | ConvertTo-Json -Depth 100

# Write to file
[System.IO.File]::WriteAllText($arPath, $arJson, $utf8NoBom)
