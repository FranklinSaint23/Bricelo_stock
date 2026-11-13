-- =================================================================================
-- BRICELO STOCK : CRÉATION / CONFIGURATION DU COMPTE SUPER ADMINISTRATEUR
-- Copiez et collez ce script dans l'éditeur SQL de Supabase (SQL Editor) et cliquez sur "Run".
-- =================================================================================

-- 1. S'assurer que toutes les colonnes nécessaires existent dans la table user_profiles
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS password_hash TEXT;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'Propriétaire';
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS is_super_admin BOOLEAN DEFAULT FALSE;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS subscription_plan TEXT DEFAULT 'Gratuit';
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS subscription_status TEXT DEFAULT 'Actif';
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS subscription_billing TEXT DEFAULT 'mensuel';
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS subscription_expires_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS subscription_notes TEXT;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS access_groups JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS cash_desks JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS available_stores JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS is_shifts_tracking_enabled BOOLEAN DEFAULT FALSE;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS recovery_email TEXT;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS is_email_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS email_verified_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now());

-- 2. Sécurité RLS : Permettre les lectures et mises à jour des profils (Super Admin & Utilisateurs)
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all access to user_profiles" ON public.user_profiles;
CREATE POLICY "Allow all access to user_profiles"
  ON public.user_profiles FOR ALL
  USING (true)
  WITH CHECK (true);

-- 3. Création ou mise à jour du Super Administrateur
-- Vous pouvez modifier le numéro de téléphone, l'email ou le mot de passe ci-dessous :
INSERT INTO public.user_profiles (
  id,
  full_name,
  company_name,
  phone,
  email,
  password_hash,
  role,
  is_super_admin,
  subscription_plan,
  subscription_status,
  created_at,
  updated_at
) VALUES (
  'superadmin_master',
  'Super Administrateur',
  'Bricelo Cloud Administration',
  '+237699000000',            -- Numéro à utiliser pour vous connecter
  'admin@bricelo.com',         -- Email (optionnel)
  'admin123',                  -- Mot de passe de votre choix
  'super_admin',               -- Rôle Super Admin déclenchant la console isolée
  true,
  'Entreprise',
  'Actif',
  NOW(),
  NOW()
)
ON CONFLICT (id) DO UPDATE 
SET 
  role = 'super_admin',
  is_super_admin = true,
  password_hash = EXCLUDED.password_hash,
  phone = EXCLUDED.phone,
  email = EXCLUDED.email,
  updated_at = NOW();

-- 4. (Optionnel) Si vous préférez promouvoir votre compte existant sans en créer un nouveau,
-- décommentez la ligne suivante et indiquez votre numéro de téléphone :
-- UPDATE public.user_profiles SET role = 'super_admin', is_super_admin = true WHERE phone = '+237XXXXXXXXX';
