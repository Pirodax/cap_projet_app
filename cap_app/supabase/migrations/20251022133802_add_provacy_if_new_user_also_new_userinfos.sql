-- ===================================================================
-- 🔄 TRIGGER : créer automatiquement une ligne user_infos
-- à chaque création d'utilisateur dans auth.users
-- ===================================================================

-- 1️⃣ Crée la fonction
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_infos (user_id, username)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', 'Nouvel utilisateur')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2️⃣ Crée le trigger lié à la création d’un user Supabase Auth
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();
