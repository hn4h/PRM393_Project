/// Supabase table name constants - do NOT hard-code table names in code.
abstract class SupabaseTables {
  static const String profiles = 'profiles';
  static const String services = 'services';
  static const String categories = 'categories';
  static const String bookings = 'bookings';
  static const String reviews = 'reviews';
  static const String workers = 'workers';
  static const String serviceStatsView = 'service_stats_view';
  static const String customerNotifications = 'customer_notifications';
  static const String workerNotifications = 'worker_notifications';
}

/// Supabase Storage bucket names
abstract class SupabaseBuckets {
  static const String avatars = 'avatars';
  static const String serviceImages = 'service-images';
}
