# Supabase RLS Policies — HoSe App

> **Chạy các SQL này trong Supabase Dashboard → SQL Editor**  
> Roles: `admin` | `customer` | `worker`

---

## Setup: profiles table

```sql
-- 1. Tạo profiles table (linked với auth.users)
CREATE TABLE public.profiles (
  id          UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  role        TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('admin', 'customer', 'worker')),
  full_name   TEXT,
  avatar_url  TEXT,
  phone       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 3. Auto-create profile khi user đăng ký
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data ->> 'full_name',
    COALESCE(NEW.raw_user_meta_data ->> 'role', 'customer')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

---

## Helper Function (dùng trong policies)

```sql
-- Function lấy role của user hiện tại (dùng trong policies)
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE;
```

---

## Profiles Policies

```sql
-- User xem profile của chính mình
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (id = auth.uid());

-- User cập nhật profile của chính mình
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (id = auth.uid());

-- Admin xem tất cả profiles
CREATE POLICY "Admin view all profiles"
  ON public.profiles FOR SELECT
  USING (public.get_user_role() = 'admin');
```

---

## Bookings Policies

```sql
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Customer xem booking của chính mình
CREATE POLICY "Customer view own bookings"
  ON public.bookings FOR SELECT
  USING (
    customer_id = auth.uid() AND
    public.get_user_role() = 'customer'
  );

-- Customer tạo booking
CREATE POLICY "Customer create booking"
  ON public.bookings FOR INSERT
  WITH CHECK (
    customer_id = auth.uid() AND
    public.get_user_role() = 'customer'
  );

-- Customer hủy booking của mình (update status = 'cancelled')
CREATE POLICY "Customer cancel own booking"
  ON public.bookings FOR UPDATE
  USING (
    customer_id = auth.uid() AND
    public.get_user_role() = 'customer'
  );

-- Worker xem booking được assign
CREATE POLICY "Worker view assigned bookings"
  ON public.bookings FOR SELECT
  USING (
    worker_id = auth.uid() AND
    public.get_user_role() = 'worker'
  );

-- Worker cập nhật status booking của mình (accept/complete)
CREATE POLICY "Worker update assigned booking status"
  ON public.bookings FOR UPDATE
  USING (
    worker_id = auth.uid() AND
    public.get_user_role() = 'worker'
  );

-- Admin: toàn quyền
CREATE POLICY "Admin full access bookings"
  ON public.bookings FOR ALL
  USING (public.get_user_role() = 'admin');
```

---

## Services Policies

```sql
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;

-- Mọi người đều đọc được services (public data)
CREATE POLICY "Public read services"
  ON public.services FOR SELECT
  USING (true);

-- Chỉ admin mới tạo/sửa/xóa service
CREATE POLICY "Admin manage services"
  ON public.services FOR ALL
  USING (public.get_user_role() = 'admin');
```

---

## Reviews Policies

```sql
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Mọi người đọc reviews
CREATE POLICY "Public read reviews"
  ON public.reviews FOR SELECT
  USING (true);

-- Customer tạo review sau booking hoàn thành
CREATE POLICY "Customer create review"
  ON public.reviews FOR INSERT
  WITH CHECK (
    customer_id = auth.uid() AND
    public.get_user_role() = 'customer' AND
    EXISTS (
      SELECT 1 FROM public.bookings
      WHERE id = booking_id
        AND customer_id = auth.uid()
        AND status = 'completed'
    )
  );
```

---

## Storage Policies

```sql
-- avatars bucket: user chỉ upload/view ảnh của mình
CREATE POLICY "Users upload own avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Public view avatars"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

-- service-images: chỉ admin upload
CREATE POLICY "Admin upload service images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'service-images' AND
    public.get_user_role() = 'admin'
  );

CREATE POLICY "Public view service images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'service-images');
```
