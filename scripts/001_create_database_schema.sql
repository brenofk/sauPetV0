-- SauPet Database Schema
-- Create tables for users, pets, vaccines, and notifications

-- Create profiles table (extends auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  cpf VARCHAR(11) UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  phone VARCHAR(15),
  email_confirmed BOOLEAN DEFAULT FALSE,
  phone_confirmed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create pets table
CREATE TABLE IF NOT EXISTS public.pets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  species VARCHAR(10) NOT NULL CHECK (species IN ('cachorro', 'gato')),
  breed TEXT,
  birth_date DATE,
  weight DECIMAL(5,2),
  photo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create vaccines table
CREATE TABLE IF NOT EXISTS public.vaccines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id UUID NOT NULL REFERENCES public.pets(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  application_date DATE NOT NULL,
  next_dose_date DATE,
  veterinarian TEXT,
  batch_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  pet_id UUID REFERENCES public.pets(id) ON DELETE CASCADE,
  vaccine_id UUID REFERENCES public.vaccines(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type VARCHAR(20) NOT NULL CHECK (type IN ('vaccine_reminder', 'general', 'system')),
  is_read BOOLEAN DEFAULT FALSE,
  scheduled_for TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vaccines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for profiles
CREATE POLICY "profiles_select_own" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "profiles_insert_own" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_update_own" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "profiles_delete_own" ON public.profiles FOR DELETE USING (auth.uid() = id);

-- Create RLS policies for pets
CREATE POLICY "pets_select_own" ON public.pets FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "pets_insert_own" ON public.pets FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "pets_update_own" ON public.pets FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "pets_delete_own" ON public.pets FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for vaccines
CREATE POLICY "vaccines_select_own" ON public.vaccines 
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.pets 
      WHERE pets.id = vaccines.pet_id AND pets.user_id = auth.uid()
    )
  );

CREATE POLICY "vaccines_insert_own" ON public.vaccines 
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.pets 
      WHERE pets.id = vaccines.pet_id AND pets.user_id = auth.uid()
    )
  );

CREATE POLICY "vaccines_update_own" ON public.vaccines 
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.pets 
      WHERE pets.id = vaccines.pet_id AND pets.user_id = auth.uid()
    )
  );

CREATE POLICY "vaccines_delete_own" ON public.vaccines 
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.pets 
      WHERE pets.id = vaccines.pet_id AND pets.user_id = auth.uid()
    )
  );

-- Create RLS policies for notifications
CREATE POLICY "notifications_select_own" ON public.notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "notifications_insert_own" ON public.notifications FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "notifications_update_own" ON public.notifications FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "notifications_delete_own" ON public.notifications FOR DELETE USING (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_pets_user_id ON public.pets(user_id);
CREATE INDEX IF NOT EXISTS idx_vaccines_pet_id ON public.vaccines(pet_id);
CREATE INDEX IF NOT EXISTS idx_vaccines_next_dose_date ON public.vaccines(next_dose_date);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_scheduled_for ON public.notifications(scheduled_for);
CREATE INDEX IF NOT EXISTS idx_profiles_cpf ON public.profiles(cpf);
