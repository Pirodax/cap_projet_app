-- 🩹 1. Soins courants
-- 🏥 2. Hospitalisation
-- 🦷 3. Dentaire
-- 👓 4. Optique
-- 🦻 5. Appareillage & Audition
-- 🤰 6. Maternité / Naissance
-- 🧘 7. Psychologie & Médecines douces
-- 🌿 8. Prévention & Divers
-- 🚑 9. Transports médicaux

CREATE TABLE public.categories_soins (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO public.categories_soins (name, icon) VALUES
('Soins courants', '🩹'),
('Hospitalisation', '🏥'),
('Dentaire', '🦷'),
('Optique', '👓'),
('Appareillage & Audition', '🦻'),
('Maternité / Naissance', '🤰'),
('Psychologie & Médecines douces', '🧘'),
('Prévention & Divers', '🌿'),
('Transports médicaux', '🚑');
DROP TABLE IF EXISTS public.mutuelle_formule_categories CASCADE;
CREATE TABLE public.mutuelle_formule_categories (
  id BIGSERIAL PRIMARY KEY,
  formule_id BIGINT REFERENCES public.mutuelle_formules(id) ON DELETE CASCADE,
  categorie_id BIGINT REFERENCES public.categories_soins(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now()
);
INSERT INTO public.mutuelle_formule_categories (formule_id, categorie_id)
SELECT f.id, c.id
FROM public.mutuelle_formules f
CROSS JOIN public.categories_soins c;
