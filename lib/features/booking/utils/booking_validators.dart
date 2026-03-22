class BookingValidators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Name is required";
    }

    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return "Name must be at least 2 characters";
    }

    if (!RegExp(r"^[a-zA-Z\s\-'.]+$").hasMatch(trimmed)) {
      return "Name can only contain letters, spaces, hyphens, dots and apostrophes";
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone number is required";
    }

    final trimmed = value.trim();
    if (!RegExp(r'^[\d\s\-\+\(\)]+$').hasMatch(trimmed)) {
      return "Phone can only contain digits, spaces, hyphens, + and parentheses";
    }

    final digitCount = trimmed.replaceAll(RegExp(r'[^\d]'), '').length;
    if (digitCount < 7) {
      return "Phone must have at least 7 digits";
    }

    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Address is required";
    }

    final trimmed = value.trim();
    if (trimmed.length < 5) {
      return "Address must be at least 5 characters";
    }

    if (!RegExp(r'^[a-zA-Z0-9\s\,\.\-\#\/\&]+$').hasMatch(trimmed)) {
      return "Address contains invalid characters";
    }

    return null;
  }

  static String? validatePaymentMethod(String? method) {
    if (method == null || method.trim().isEmpty) {
      return "Payment method is required";
    }
    return null;
  }

  static String? validateScheduledTime(DateTime? scheduledAt) {
    if (scheduledAt == null) {
      return "Date and time are required";
    }

    const allowedHours = {9, 10, 11, 12, 13, 14, 15, 16, 17};
    if (!allowedHours.contains(scheduledAt.hour) || scheduledAt.minute != 0) {
      return "Please select one of the available time slots";
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(
      scheduledAt.year,
      scheduledAt.month,
      scheduledAt.day,
    );

    if (selectedDate.isAtSameMomentAs(today)) {
      if (scheduledAt.isBefore(now)) {
        return "Time must be in the future";
      }
      return null;
    }

    if (selectedDate.isBefore(today)) {
      return "Date must not be in the past";
    }

    return null;
  }

  static String? validateSelection(dynamic selected) {
    if (selected == null) {
      return "Please select an option";
    }
    return null;
  }
}
