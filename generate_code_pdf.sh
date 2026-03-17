#!/bin/bash
OUTPUT="blood_donate_code.txt"
echo "=======================================================" > "$OUTPUT"
echo "   BLOOD DONATION APP - COMPLETE SOURCE CODE" >> "$OUTPUT"
echo "=======================================================" >> "$OUTPUT"

add_file() {
    if [ -f "$1" ]; then
        echo "FILE: $1" >> "$OUTPUT"
        echo "----------------------------------------" >> "$OUTPUT"
        cat "$1" >> "$OUTPUT"
        echo "" >> "$OUTPUT"
    fi
}

add_file "lib/features/auth/presentation/providers/local_auth_provider.dart"
add_file "lib/features/auth/presentation/screens/login_screen.dart"
add_file "lib/features/auth/presentation/screens/register_screen.dart"
add_file "lib/features/auth/presentation/screens/role_selection_screen.dart"
add_file "lib/shared/services/local_admin_service.dart"
add_file "lib/features/dashboard/presentation/admin/screens/admin_dashboard_screen.dart"
add_file "lib/features/verification/data/verification_provider.dart"
add_file "lib/features/dashboard/presentation/verifier/screens/verifier_dashboard_screen.dart"
add_file "lib/features/verification/presentation/screens/verification_review_screen.dart"
add_file "lib/features/dashboard/presentation/donor/screens/donor_dashboard_screen.dart"
add_file "lib/features/blood_requests/presentation/screens/blood_requests_screen.dart"
add_file "lib/features/dashboard/presentation/receiver/screens/receiver_dashboard_screen.dart"
add_file "lib/features/blood_requests/presentation/screens/post_blood_request_screen.dart"
add_file "lib/shared/services/user_model.dart"
add_file "lib/shared/services/blood_request_model.dart"
add_file "lib/shared/services/verification_model.dart"
add_file "lib/main.dart"

echo "Done! Code saved to $OUTPUT"
