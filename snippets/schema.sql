-- ==========================================
-- BOARDING.LK DATABASE SCHEMA
-- ==========================================

-- 1. USERS TABLE
-- Extends Supabase Auth with custom profile data
create table public.users (
  id uuid references auth.users not null primary key,
  full_name text,
  email text,
  role text default 'student', -- 'student', 'landlord', 'admin'
  whatsapp_number text,
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 2. PROPERTIES TABLE
-- Stores accommodation listings
create table public.properties (
  id uuid default uuid_generate_v4() primary key,
  owner_id uuid references public.users(id) not null,
  title text not null,
  description text,
  address_text text,
  province text,
  district text,
  city text,
  lat double precision,
  lng double precision,
  price_per_person numeric,
  total_beds int,
  occupied_beds int default 0,
  images text[], -- Array of image URLs
  amenities text[], -- Array of tags (WiFi, AC, etc)
  status text default 'pending', -- 'pending', 'active', 'rejected'
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 3. CONVERSATIONS TABLE
-- Parent table for chat sessions
create table public.conversations (
  id uuid default uuid_generate_v4() primary key,
  property_id uuid references public.properties(id),
  student_id uuid references public.users(id),
  owner_id uuid references public.users(id),
  created_at timestamp with time zone default timezone('utc'::text, now()),
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- 4. MESSAGES TABLE
-- Individual messages linked to a conversation
create table public.messages (
  id uuid default uuid_generate_v4() primary key,
  conversation_id uuid references public.conversations(id) on delete cascade,
  sender_id uuid references public.users(id),
  content text not null,
  is_read boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- ==========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================

-- Enable Security
alter table properties enable row level security;
alter table users enable row level security;
alter table messages enable row level security;

-- A. PUBLIC ACCESS
-- Public can view profiles and active ads
create policy "Public view profiles" on users for select using (true);
create policy "Public view active ads" on properties for select using (status = 'active');

-- B. LANDLORD ACCESS
-- Owners can CRUD their own properties
create policy "Owners manage own properties" 
  on properties for all 
  using (auth.uid() = owner_id);

-- C. ADMIN ACCESS (GOD MODE)
-- Admins can view/edit EVERYTHING based on secure email check
create policy "Admin Full Access"
  on properties for all
  using ((auth.jwt() ->> 'email') = 'isurusasanga3@gmail.com');

create policy "Admin View Users"
  on users for all
  using ((auth.jwt() ->> 'email') = 'isurusasanga3@gmail.com');

-- ==========================================
-- AUTOMATION TRIGGERS
-- ==========================================

-- Trigger: Automatically create user profile on Sign Up
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users (id, full_name, email, avatar_url, role)
  values (
    new.id,
    new.raw_user_meta_data->>'full_name',
    new.email,
    new.raw_user_meta_data->>'avatar_url',
    'student'
  );
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();