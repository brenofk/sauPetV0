-- Create triggers for automatic profile creation and notifications

-- Function to create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, cpf, full_name, phone)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data ->> 'cpf', ''),
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', ''),
    COALESCE(NEW.raw_user_meta_data ->> 'phone', '')
  )
  ON CONFLICT (id) DO NOTHING;
  
  RETURN NEW;
END;
$$;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- Function to create vaccine reminder notifications
CREATE OR REPLACE FUNCTION public.create_vaccine_reminder()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  pet_owner_id UUID;
  pet_name TEXT;
BEGIN
  -- Get pet owner and name
  SELECT pets.user_id, pets.name INTO pet_owner_id, pet_name
  FROM public.pets 
  WHERE pets.id = NEW.pet_id;
  
  -- Create notification if next_dose_date is set
  IF NEW.next_dose_date IS NOT NULL THEN
    INSERT INTO public.notifications (
      user_id,
      pet_id,
      vaccine_id,
      title,
      message,
      type,
      scheduled_for
    ) VALUES (
      pet_owner_id,
      NEW.pet_id,
      NEW.id,
      'Lembrete de Vacina',
      'A vacina ' || NEW.name || ' do ' || pet_name || ' está próxima do vencimento.',
      'vaccine_reminder',
      NEW.next_dose_date - INTERVAL '7 days'
    );
  END IF;
  
  RETURN NEW;
END;
$$;

-- Create triggers
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Updated_at triggers
DROP TRIGGER IF EXISTS profiles_updated_at ON public.profiles;
CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS pets_updated_at ON public.pets;
CREATE TRIGGER pets_updated_at
  BEFORE UPDATE ON public.pets
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS vaccines_updated_at ON public.vaccines;
CREATE TRIGGER vaccines_updated_at
  BEFORE UPDATE ON public.vaccines
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- Vaccine reminder trigger
DROP TRIGGER IF EXISTS vaccine_reminder_trigger ON public.vaccines;
CREATE TRIGGER vaccine_reminder_trigger
  AFTER INSERT OR UPDATE ON public.vaccines
  FOR EACH ROW
  EXECUTE FUNCTION public.create_vaccine_reminder();
