$path = 'assets/data/saudi_driving_theory_data_ar.json'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$content = [System.IO.File]::ReadAllText($path, $utf8NoBom)

# We know the specific point of failure is around q38 or where unit 5/6 should have been.
# Let's find where Unit 4 ends.
$u4EndIdx = $content.LastIndexOf('"unit_id": 4')
if ($u4EndIdx -gt 0) {
    # Find the closing bracket of Unit 4 topic list and the unit itself.
    # Unit 4 ends around line 1300+ in the English version. 
    # In Ar version it might be different.
    
    # Actually, let's just find the last "topic_id" that starts with "4."
    $lastTopic4Idx = $content.LastIndexOf('"topic_id": "4.')
    if ($lastTopic4Idx -gt 0) {
        $bracketAfter4 = $content.IndexOf('}', $lastTopic4Idx)
        $bracketAfter4 = $content.IndexOf('}', $bracketAfter4 + 1) # Close topic
        $bracketAfter4 = $content.IndexOf(']', $bracketAfter4 + 1) # Close topics
        $bracketAfter4 = $content.IndexOf('}', $bracketAfter4 + 1) # Close unit
        
        # This $bracketAfter4 is where Unit 4 ends.
        $head = $content.Substring(0, $bracketAfter4 + 1)
        
        # New Content starting from Unit 5
        $tail = @'
,
      {
        "unit_id": 5,
        "title": "سرعة القيادة",
        "topics": [
          {
            "topic_id": "5.1",
            "title": "حدود السرعة العامة",
            "small_vehicles": {
              "rule": "يجب عدم تجاوز السرعة المحددة للطريق إذا لم تكن هناك لوحة أخرى تحدد السرعة",
              "types": ["الطرق الفرعية - حسب السرعة المحددة للطريق", "الطرق السريعة - حسب السرعة المحددة للطريق"]
            },
            "large_vehicles": {
              "within_city_roads": "الحد الأقصى 50 كم/ساعة",
              "outside_city_limits": "حسب السرعة المحددة للطريق"
            }
          },
          {
            "topic_id": "5.3",
            "title": "التفحيط",
            "definition": "شكل من أشكال السباقات يتم فيه قيادة المركبات بسرعات عالية جداً تتراوح بين 160 إلى 260 كم/ساعة على الطرق السريعة الواسعة بينما تتمايل المركبة يميناً ويساراً.",
            "legal_status": "غير قانوني – مخالفة مرورية جسيمة",
            "danger": "تقع العديد من الحوادث المرورية المروعة نتيجة التفحيط",
            "penalties": [
              { "offense": "المرة الأولى", "penalty": "حجز المركبة 15 يوماً + غرامة 20,000 ريال + السجن" },
              { "offense": "المرة الثانية", "penalty": "حجز المركبة شهر + غرامة 40,000 ريال + السجن" },
              { "offense": "المرة الثالثة", "penalty": "مصادرة المركبة + غرامة 60,000 ريال" }
            ]
          },
          {
            "topic_id": "5.5",
            "title": "مسافة الأمان",
            "minimum_following_distance": "ثانيتان (قاعدة الثانيتين)",
            "increase_distance_when": [
              "ظروف الطريق السيئة (مثل الطرق المبللة أو الرملية)",
              "القيادة خلف الدراجات النارية",
              "قيادة مركبة محملة بشكل ثقيل",
              "تغير الأحوال الجوية (عواصف، غبار، مطر)"
            ]
          }
        ]
      },
      {
        "unit_id": 6,
        "title": "التجاوز والسلوك العام",
        "topics": [
          {
            "topic_id": "6.2",
            "title": "تجاوز المركبات المتحركة",
            "normal_side": "الجانب الأيسر من الطريق",
            "overtake_on_right_when": [
              "السائق الذي أمامك ينوي الانعطاف يساراً",
              "الطريق مقسم إلى أكثر من مسارين في نفس الاتجاه"
            ]
          },
          {
            "topic_id": "6.5",
            "title": "إيقاف المركبة",
            "definitions": {
              "pause": "إيقاف المركبة لفترة قصيرة ومحدودة",
              "parking": "إيقاف المركبة وتركها واقفة"
            },
            "parking_restrictions": {
              "prohibited_at": [
                "ممرات المشاة",
                "على الرصيف",
                "تجاه حركة المرور",
                "في وسط الطريق"
              ]
            }
          },
          {
            "topic_id": "6.6",
            "title": "استخدام أنوار المركبة",
            "usage_rules": {
              "at_night": "يجب على السائقين استخدام أنوار المركبة أثناء القيادة ليلاً بغض النظر عن وجود إضاءة عامة في الطريق",
              "during_day": "يجب استخدام الأنوار أثناء الضباب الكثيف أو العواصف الرملية التي تحجب الرؤية"
            }
          }
        ]
      }
    ]
  },
  "emergency_numbers": {
    "traffic_police": ["911", "993"],
    "red_crescent_ambulance": "997",
    "accident_damage_report_app": "نجم (Najm)"
  },
  "key_numbers_summary": {
    "min_age_private_license": 18,
    "min_age_public_license": 20,
    "min_age_motorcycle_license": 18,
    "private_license_validity_years": 10,
    "public_license_validity_years": 5,
    "max_passengers_private_car_including_driver": 9,
    "max_weight_private_car_kg": 3500,
    "points_to_withdraw_license": 24,
    "min_emergency_vehicle_distance_m": 50,
    "max_reversing_distance_m": 20,
    "min_following_distance_seconds": 2,
    "right_turn_on_red_max_speed_kmh": 15,
    "right_turn_on_red_stop_duration_seconds": "2–3",
    "children_front_seat_prohibited_under_age": 10,
    "children_support_belt_required_under_age": 12,
    "minor_accident_max_damage_sar": 5000,
    "driver_held_max_hours_after_fatal_accident": 72,
    "parking_from_traffic_light_min_m": 15,
    "parking_from_bend_min_m": 15,
    "parking_from_fire_hydrant_min_m": 7,
    "parking_from_tunnel_or_bridge_min_m": 20,
    "pedestrian_crossing_school_min_m": 1.5,
    "min_speed_saving_fuel_kmh": 70,
    "max_speed_saving_fuel_kmh": 90,
    "turn_off_engine_if_idle_seconds": 20,
    "drifting_speed_range_kmh": "160–260",
    "stop_sign_hold_seconds": 3
  },
  "quiz_bank": [
    {
      "id": "q1",
      "unit": 1,
      "topic": "رخصة القيادة",
      "question": "ما هو الحد الأدنى للسن للحصول على رخصة قيادة خاصة في المملكة العربية السعودية؟",
      "options": ["16", "17", "18", "20"],
      "correct_answer": "18",
      "explanation": "يجب أن يكون عمرك 18 عاماً على الأقل. يمكن إصدار تصريح مؤقت من سن 17 عاماً لمدة أقصاها سنة واحدة."
    },
    {
      "id": "q2",
      "unit": 1,
      "topic": "رخصة القيادة",
      "question": "ما هي مدة صلاحية رخصة القيادة الخاصة؟",
      "options": ["5 سنوات", "7 سنوات", "10 سنوات", "15 سنة"],
      "correct_answer": "10 سنوات",
      "explanation": "رخصة القيادة الخاصة صالحة لمدة أقصاها 10 سنوات."
    }
  ]
}
'@
        $final = $head + $tail
        [System.IO.File]::WriteAllText($path, $final, $utf8NoBom)
    }
}
