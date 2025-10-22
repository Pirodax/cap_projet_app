-- Supprime tous les utilisateurs Supabase
DELETE FROM auth.users;

-- Supprime également les sessions actives (facultatif mais propre)
DELETE FROM auth.sessions;

-- Supprime les identités (Google, GitHub, etc.) associées
DELETE FROM auth.identities;
