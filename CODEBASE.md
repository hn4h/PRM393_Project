# CODEBASE.md — HoSe: Home Services App

> **Stack:** Flutter + Riverpod (MVVM) · Supabase (Auth, DB, Storage, Realtime, Edge Functions)  
> **Team:** 4 devs · **Deadline:** ~1 tuần · **Roles:** admin / customer / worker  

---

## 📐 Architecture: MVVM + Riverpod

### Mapping MVVM → Flutter/Riverpod

| MVVM Layer   | Flutter/Riverpod Equivalent     | Nhiệm vụ                                 |
|--------------|---------------------------------|------------------------------------------|
| **Model**    | `*_model.dart` + `*_schema.dart` | Data class, fromJson/toJson, Supabase schema |
| **ViewModel**| `*_viewmodel.dart` (Riverpod `AsyncNotifier` / `Notifier`) | Business logic, state management |
| **View**     | `*_screen.dart` + `*_widget.dart` | UI only, không chứa logic               |
| **Repository**| `*_repository.dart`            | Giao tiếp với Supabase (Data Layer)      |

### Rule quan trọng

- **View KHÔNG gọi Supabase trực tiếp** - luôn qua ViewModel
- **ViewModel KHÔNG biết UI exists** - không dùng `BuildContext` trong ViewModel
- **Repository KHÔNG chứa business logic** - chỉ CRUD + transform data
- **Model là immutable** - dùng `copyWith`, không mutate trực tiếp

---

## 📁 Folder Structure (Bắt buộc)

```
lib/
├── main.dart                        # App entry point, Supabase.initialize()
├── core/
│   ├── config/
│   │   ├── supabase_config.dart     # URL, anonKey constants
│   │   └── app_config.dart          # App-wide constants
│   ├── constants/
│   │   ├── supabase_tables.dart     # Table name constants
│   │   └── app_strings.dart
│   ├── models/                      # Shared models (dùng nhiều features)
│   │   ├── booking.dart
│   │   ├── service.dart
│   │   ├── worker.dart
│   │   └── user_profile.dart        # Model cho cả 3 roles
│   ├── enums/
│   │   ├── user_role.dart           # UserRole.admin / .customer / .worker
│   │   └── booking_status.dart
│   ├── providers/
│   │   ├── supabase_provider.dart   # Global Supabase client provider
│   │   └── auth_provider.dart       # Current user + role provider
│   ├── router/
│   │   └── app_router.dart          # GoRouter với redirect theo role
│   ├── theme/
│   │   └── app_theme.dart
│   └── widgets/                     # Shared UI components
│       ├── loading_widget.dart
│       ├── error_widget.dart
│       └── role_guard_widget.dart   # Widget ẩn/hiện theo role
│
└── features/
    ├── auth/
    │   ├── models/
    │   │   └── auth_state_model.dart
    │   ├── repositories/
    │   │   └── auth_repository.dart
    │   ├── viewmodels/
    │   │   └── auth_viewmodel.dart
    │   └── screens/
    │       ├── login_screen.dart
    │       ├── register_screen.dart
    │       └── widgets/
    │
    ├── home/               # Feature template (mỗi feature follow pattern này)
    │   ├── models/         # Model riêng của feature (nếu cần)
    │   ├── repositories/
    │   │   └── home_repository.dart
    │   ├── viewmodels/
    │   │   └── home_viewmodel.dart
    │   └── screens/
    │       ├── home_screen.dart
    │       └── widgets/
    │
    ├── booking/
    ├── booking_history/
    ├── discover/
    ├── profile/
    ├── service/
    ├── settings/
    └── worker/
```

---

## 🏗️ Code Templates (Copy-paste khi tạo feature mới)

### 1. Model Template

```dart
// features/xyz/models/xyz_model.dart
import 'package:flutter/foundation.dart';

@immutable
class XyzModel {
  final String id;
  final String name;
  final DateTime createdAt;

  const XyzModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  // Từ Supabase response
  factory XyzModel.fromJson(Map<String, dynamic> json) {
    return XyzModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Gửi lên Supabase
  Map<String, dynamic> toJson() => {
    'name': name,
    // Không include 'id' và 'created_at' khi insert mới
  };

  XyzModel copyWith({String? id, String? name, DateTime? createdAt}) {
    return XyzModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is XyzModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
```

### 2. Repository Template

```dart
// features/xyz/repositories/xyz_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/xyz_model.dart';
import '../../../core/constants/supabase_tables.dart';

part 'xyz_repository.g.dart';

@riverpod
XyzRepository xyzRepository(XyzRepositoryRef ref) {
  return XyzRepository(Supabase.instance.client);
}

class XyzRepository {
  final SupabaseClient _client;

  const XyzRepository(this._client);

  Future<List<XyzModel>> getAll() async {
    final response = await _client
        .from(SupabaseTables.xyz)
        .select()
        .order('created_at', ascending: false);
    return response.map(XyzModel.fromJson).toList();
  }

  Future<XyzModel> getById(String id) async {
    final response = await _client
        .from(SupabaseTables.xyz)
        .select()
        .eq('id', id)
        .single();
    return XyzModel.fromJson(response);
  }

  Future<XyzModel> create(XyzModel model) async {
    final response = await _client
        .from(SupabaseTables.xyz)
        .insert(model.toJson())
        .select()
        .single();
    return XyzModel.fromJson(response);
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _client.from(SupabaseTables.xyz).update(data).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from(SupabaseTables.xyz).delete().eq('id', id);
  }
}
```

### 3. ViewModel Template

```dart
// features/xyz/viewmodels/xyz_viewmodel.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/xyz_model.dart';
import '../repositories/xyz_repository.dart';

part 'xyz_viewmodel.g.dart';

// State class (immutable)
class XyzState {
  final List<XyzModel> items;
  final bool isLoading;
  final String? error;

  const XyzState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  XyzState copyWith({List<XyzModel>? items, bool? isLoading, String? error}) {
    return XyzState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ViewModel (Notifier)
@riverpod
class XyzViewModel extends _$XyzViewModel {
  @override
  Future<XyzState> build() async {
    final items = await ref.watch(xyzRepositoryProvider).getAll();
    return XyzState(items: items);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async {
        final items = await ref.read(xyzRepositoryProvider).getAll();
        return XyzState(items: items);
      },
    );
  }

  Future<void> create(XyzModel model) async {
    // Optimistic update hoặc reload sau action
    await ref.read(xyzRepositoryProvider).create(model);
    await refresh();
  }
}
```

### 4. Screen Template

```dart
// features/xyz/screens/xyz_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/xyz_viewmodel.dart';

class XyzScreen extends ConsumerWidget {
  const XyzScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(xyzViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Xyz')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) => _buildContent(context, ref, data),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, XyzState data) {
    if (data.items.isEmpty) {
      return const Center(child: Text('No items found'));
    }
    return ListView.builder(
      itemCount: data.items.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(data.items[index].name),
      ),
    );
  }
}
```

---

## 🔐 Supabase Rules

### Auth & Role System

```dart
// core/enums/user_role.dart
enum UserRole { admin, customer, worker;

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (r) => r.name == role,
      orElse: () => UserRole.customer,
    );
  }
}
```

```dart
// core/providers/auth_provider.dart
@riverpod
Stream<AuthState> authState(AuthStateRef ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
}

@riverpod
Future<UserRole?> currentUserRole(CurrentUserRoleRef ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;
  
  final response = await Supabase.instance.client
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single();
  
  return UserRole.fromString(response['role'] as String);
}
```

### RLS Policy Pattern (SQL - để reference)

```sql
-- Chỉ customer thấy booking của chính họ
CREATE POLICY "Customers see own bookings" ON bookings
  FOR SELECT USING (
    auth.uid() = customer_id AND
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role = 'customer'
    )
  );

-- Worker chỉ thấy booking được assign cho họ
CREATE POLICY "Workers see assigned bookings" ON bookings
  FOR SELECT USING (
    auth.uid() = worker_id AND
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role = 'worker'
    )
  );

-- Admin thấy tất cả
CREATE POLICY "Admin full access" ON bookings
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );
```

### GoRouter với Role-based Redirect

```dart
// Trong app_router.dart - thêm redirect global:
redirect: (context, state) async {
  final user = Supabase.instance.client.auth.currentUser;
  final isLoggedIn = user != null;
  final isLoginPage = state.matchedLocation == '/login';

  if (!isLoggedIn && !isLoginPage) return '/login';
  if (isLoggedIn && isLoginPage) return '/home';
  return null;
}
```

---

## 📦 Packages (pubspec.yaml)

```yaml
dependencies:
  # Core
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^13.2.1

  # Supabase (ALL features)
  supabase_flutter: ^2.5.0

  # UI
  flutter_svg: ^2.0.10+1
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  hugeicons: ^0.0.11
  flutter_rating_bar: ^4.0.1

  # Utils
  intl: ^0.19.0
  logger: ^2.0.2+1

dev_dependencies:
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.8
  flutter_lints: ^6.0.0
  flutter_test:
    sdk: flutter
```

---

## 🏷️ Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| File | `snake_case` | `booking_viewmodel.dart` |
| Class | `PascalCase` | `BookingViewModel` |
| Variable/Method | `camelCase` | `currentBooking`, `fetchBookings()` |
| Constant | `camelCase` (trong class) | `SupabaseTables.bookings` |
| Provider | `camelCase` + `Provider` suffix (auto) | `bookingViewModelProvider` |
| Supabase Table | `snake_case` plural | `bookings`, `service_categories` |
| Supabase Column | `snake_case` | `created_at`, `worker_id` |
| Private field | `_camelCase` | `_client`, `_isLoading` |

---

## 🚦 Component Responsibilities (MVVM checklist)

### ✅ View (Screen/Widget) ĐƯỢC phép:
- Render UI từ state
- Call ViewModel methods khi user action
- Navigate với `context.go()`
- Show `SnackBar`, `Dialog`

### ❌ View KHÔNG được phép:
- Gọi Supabase trực tiếp
- Chứa business logic (`if/else` phức tạp)
- Dùng `ref.read(supabaseClientProvider)` trong widget

### ✅ ViewModel ĐƯỢC phép:
- Gọi Repository methods
- Transform data (filter, sort, map)
- Handle errors → expose qua state
- Call multiple repositories

### ❌ ViewModel KHÔNG được phép:
- Import `package:flutter` (Material/Widgets)
- Navigate trực tiếp
- Gọi Supabase client trực tiếp

### ✅ Repository ĐƯỢC phép:
- CRUD với Supabase
- Transform JSON → Model
- Handle Supabase exceptions → ném lại

### ❌ Repository KHÔNG được phép:
- Business logic
- State management
- UI code

---

## ⚡ Supabase Feature Usage

### Auth (feature/auth)
```dart
// Login
await client.auth.signInWithPassword(email: email, password: password);

// Logout
await client.auth.signOut();

// Current user
client.auth.currentUser;

// Listen to auth changes
client.auth.onAuthStateChange.listen((event) { ... });
```

### Storage (upload ảnh)
```dart
final bytes = await file.readAsBytes();
await client.storage
    .from('avatars')
    .uploadBinary('${userId}/avatar.jpg', bytes);

final url = client.storage.from('avatars').getPublicUrl('${userId}/avatar.jpg');
```

### Realtime (booking status)
```dart
final channel = client.channel('booking-${bookingId}');
channel.onPostgresChanges(
  event: PostgresChangeEvent.update,
  schema: 'public',
  table: 'bookings',
  filter: PostgresChangeFilter(type: FilterType.eq, column: 'id', value: bookingId),
  callback: (payload) { /* update UI */ },
).subscribe();
```

---

## 🔄 Build Runner Commands

```bash
# Chạy code gen Riverpod (BẮT BUỘC sau khi tạo @riverpod annotation mới)
dart run build_runner build --delete-conflicting-outputs

# Watch mode (dev)
dart run build_runner watch --delete-conflicting-outputs
```

---

## 📋 Git Conventions

### Branch naming
```
feature/{feature-name}     # feature/booking-flow
fix/{bug-name}             # fix/auth-login-crash
```

### Commit format
```
feat: add booking repository
fix: null check in worker viewmodel
chore: run build_runner codegen
refactor: move auth logic to viewmodel
```

---

## 🗄️ Supabase Tables Reference

```dart
// core/constants/supabase_tables.dart
abstract class SupabaseTables {
  static const String profiles   = 'profiles';      // id, role, name, avatar_url
  static const String services   = 'services';      // id, name, category_id, price, ...
  static const String categories = 'categories';    // id, name, icon_url
  static const String bookings   = 'bookings';      // id, customer_id, worker_id, status, ...
  static const String reviews    = 'reviews';       // id, booking_id, rating, comment
  static const String workers    = 'workers';       // id, profile_id, bio, rating, ...
}

abstract class SupabaseBuckets {
  static const String avatars  = 'avatars';
  static const String services = 'service-images';
}
```

---

## ⚠️ Common Pitfalls (Tránh những lỗi này)

| ❌ Sai | ✅ Đúng |
|--------|---------|
| `Supabase.instance.client` trong Widget | Dùng repository qua ViewModel |
| `List<dynamic>` từ Supabase | Cast về `List<XyzModel>` ngay trong repository |
| Bỏ quên `build_runner` sau @riverpod | Chạy `build_runner` sau mỗi file mới |
| Business logic trong Screen | Chuyển vào ViewModel |
| Hard-code table name `'bookings'` | Dùng `SupabaseTables.bookings` |
| Model có mutable fields | Dùng `final` + `copyWith()` |
| Quên handle null từ Supabase | `.maybeSingle()` thay vì `.single()` khi có thể null |
