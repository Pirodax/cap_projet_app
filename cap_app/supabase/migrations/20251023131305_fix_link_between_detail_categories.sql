ALTER TABLE public.mutuelle_formule_categories_details
DROP CONSTRAINT IF EXISTS fk_mutuelle_formule_categories;



ALTER TABLE public.mutuelle_formule_categories_details
ADD CONSTRAINT fk_mutuelle_formule_categories
FOREIGN KEY (mutuelle_formule_categories_id)
REFERENCES public.mutuelle_formule_categories(id)
ON DELETE CASCADE
ON UPDATE CASCADE;
