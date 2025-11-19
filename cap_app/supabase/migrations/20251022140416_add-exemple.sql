

-- =========================================
-- MiTUELLES
-- =========================================
INSERT INTO public.mituelles (name, description, icon) VALUES
('Alan', 'Alan la nouvelle mutuelle moderne', '🐻'),
('CIC', 'CIC la mituelle de confiance', '🟦🟩');

-- =========================================
-- FORMULES PAR MUTUELLE
-- =========================================
-- Alan
INSERT INTO public.mituelle_formules (name, mutuelle_id) VALUES
('Standard', (SELECT id FROM public.mituelles WHERE name = 'Alan')),
('Premium', (SELECT id FROM public.mituelles WHERE name = 'Alan')),
('Jeune', (SELECT id FROM public.mituelles WHERE name = 'Alan'));

-- CIC
INSERT INTO public.mituelle_formules (name, mutuelle_id) VALUES
('Base', (SELECT id FROM public.mituelles WHERE name = 'CIC')),
('Équilibre', (SELECT id FROM public.mituelles WHERE name = 'CIC')),
('Renforcée', (SELECT id FROM public.mituelles WHERE name = 'CIC'));

ALTER TABLE public.mituelles RENAME TO mutuelles;
ALTER TABLE public.mituelle_formules RENAME TO mutuelle_formules;
