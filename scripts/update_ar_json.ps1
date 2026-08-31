$path = 'assets/data/saudi_driving_theory_data_ar.json'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$content = [System.IO.File]::ReadAllText($path, $utf8NoBom)

# Final metadata and key numbers
$emergAr = @'
    "emergency_numbers": {
      "traffic_police": ["911", "993"],
      "red_crescent_ambulance": "997",
      "accident_damage_report_app": "نجم (Najm)"
    }
'@

$keyNumbersAr = @'
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
    }
'@

# We already translated some quizzes. Let's just make sure the block structure is correct.
# I will do a final cleanup of the file.

if ($content.Contains('"emergency_numbers"')) {
    $eStart = $content.IndexOf('"emergency_numbers"')
    $eStartIdx = $content.LastIndexOf('{', $eStart)
    $kStart = $content.IndexOf('"key_numbers_summary"')
    $kStartIdx = $content.LastIndexOf('{', $kStart)
    $qStart = $content.IndexOf('"quiz_bank"')
    
    # Replace emergency numbers
    $oldE = $content.Substring($eStartIdx, $kStartIdx - $eStartIdx)
    $content = $content.Replace($oldE, $emergAr + "," + "`r`n" + "    ")
    
    # Re-search key numbers
    $kStart = $content.IndexOf('"key_numbers_summary"')
    $kStartIdx = $content.LastIndexOf('{', $kStart)
    $qStart = $content.IndexOf('"quiz_bank"')
    $oldK = $content.Substring($kStartIdx, $qStart - $kStartIdx)
    $content = $content.Replace($oldK, $keyNumbersAr + "," + "`r`n`n" + "    ")
}

[System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
