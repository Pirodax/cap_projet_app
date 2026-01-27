-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.assurance_maladie_regimes (
  id bigint NOT NULL DEFAULT nextval('regime_assurance_maladies_id_seq'::regclass),
  name text NOT NULL,
  description text,
  icon text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT assurance_maladie_regimes_pkey PRIMARY KEY (id)
);
CREATE TABLE public.assurance_maladie_remboursements (
  id bigint NOT NULL DEFAULT nextval('mutuelle_formule_details_remboursement_id_seq'::regclass),
  regimes_id bigint NOT NULL,
  soins_id bigint NOT NULL,
  taux_assurance_maladie numeric NOT NULL,
  nbr_max integer,
  CONSTRAINT assurance_maladie_remboursements_pkey PRIMARY KEY (id),
  CONSTRAINT assurance_maladie_remboursements_soins_id_fkey FOREIGN KEY (soins_id) REFERENCES public.soins(id),
  CONSTRAINT assurance_maladie_remboursements_regimes_id_fkey FOREIGN KEY (regimes_id) REFERENCES public.assurance_maladie_regimes(id)
);
CREATE TABLE public.categories_soins (
  id bigint NOT NULL DEFAULT nextval('categories_soins_id_seq'::regclass),
  name text NOT NULL UNIQUE,
  icon text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT categories_soins_pkey PRIMARY KEY (id)
);
CREATE TABLE public.mutuelle_formules (
  id bigint NOT NULL DEFAULT nextval('mituelle_formules_id_seq'::regclass),
  mutuelle_id bigint NOT NULL,
  name text NOT NULL,
  description text,
  icon text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT mutuelle_formules_pkey PRIMARY KEY (id),
  CONSTRAINT mituelle_formules_mutuelle_id_fkey FOREIGN KEY (mutuelle_id) REFERENCES public.mutuelles(id)
);
CREATE TABLE public.mutuelle_remboursements (
  id bigint NOT NULL DEFAULT nextval('mutuelle_formule_details_remboursement_id_seq'::regclass),
  formule_id bigint NOT NULL,
  soins_id bigint NOT NULL,
  taux_mutuelle_conventionne numeric,
  nbr_max integer,
  taux_mutuelle_non_conventionne numeric,
  detail text,
  type text CHECK (type = ANY (ARRAY['pourcentage'::text, 'forfait'::text, 'forfait_annuel'::text])),
  forfait_conventionne numeric,
  forfait_non_conventionne numeric,
  CONSTRAINT mutuelle_remboursements_pkey PRIMARY KEY (id),
  CONSTRAINT mutuelle_formule_details_remboursement_formule_id_fkey FOREIGN KEY (formule_id) REFERENCES public.mutuelle_formules(id),
  CONSTRAINT mutuelle_remboursements_soins_id_fkey FOREIGN KEY (soins_id) REFERENCES public.soins(id)
);
CREATE TABLE public.mutuelles (
  id bigint NOT NULL DEFAULT nextval('mituelles_id_seq'::regclass),
  name text NOT NULL,
  description text,
  icon text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT mutuelles_pkey PRIMARY KEY (id)
);
CREATE TABLE public.simulation_history (
  id bigint NOT NULL DEFAULT nextval('simulation_history_id_seq'::regclass),
  user_id uuid NOT NULL,
  soin_id bigint NOT NULL,
  soin_name text NOT NULL,
  soin_icon text,
  categorie_name text,
  prix_facture numeric NOT NULL,
  brss numeric NOT NULL,
  taux_secu numeric NOT NULL,
  remboursement_secu numeric NOT NULL,
  remboursement_mutuelle numeric NOT NULL,
  participation_forfaitaire numeric NOT NULL DEFAULT 0,
  total_autorise_mutuelle numeric NOT NULL DEFAULT 0,
  total_rembourse numeric NOT NULL,
  reste_a_charge numeric NOT NULL,
  montant_depassement numeric NOT NULL DEFAULT 0,
  est_conventionne boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT simulation_history_pkey PRIMARY KEY (id),
  CONSTRAINT simulation_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT simulation_history_soin_id_fkey FOREIGN KEY (soin_id) REFERENCES public.soins(id)
);
CREATE TABLE public.soins (
  id bigint NOT NULL DEFAULT nextval('detail_soins_id_seq'::regclass),
  categorie_id bigint NOT NULL,
  name text NOT NULL,
  brss numeric NOT NULL,
  detail text,
  type_brss text,
  icon text,
  CONSTRAINT soins_pkey PRIMARY KEY (id),
  CONSTRAINT detail_soins_categorie_id_fkey FOREIGN KEY (categorie_id) REFERENCES public.categories_soins(id)
);
CREATE TABLE public.user_infos (
  id bigint NOT NULL DEFAULT nextval('user_infos_id_seq'::regclass),
  user_id uuid NOT NULL UNIQUE,
  username text NOT NULL,
  date_of_birth date,
  mutuelle_id bigint,
  mutuelle_formule_id bigint,
  regime_assurance_maladie_id bigint,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_infos_pkey PRIMARY KEY (id),
  CONSTRAINT user_infos_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT user_infos_regime_assurance_maladie_id_fkey FOREIGN KEY (regime_assurance_maladie_id) REFERENCES public.assurance_maladie_regimes(id),
  CONSTRAINT user_infos_mutuelle_formule_id_fkey FOREIGN KEY (mutuelle_formule_id) REFERENCES public.mutuelle_formules(id),
  CONSTRAINT user_infos_mutuelle_id_fkey FOREIGN KEY (mutuelle_id) REFERENCES public.mutuelles(id)
);