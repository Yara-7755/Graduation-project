

-- DROP TABLE IF EXISTS public.users;
-- Table: public.users
CREATE TABLE IF NOT EXISTS public.users
(
    id integer NOT NULL DEFAULT nextval('users_id_seq'::regclass),
    name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    email character varying(120) COLLATE pg_catalog."default" NOT NULL,
    password character varying(255) COLLATE pg_catalog."default" NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    field character varying(50) COLLATE pg_catalog."default",
    level character varying(20) COLLATE pg_catalog."default",
    placement_score integer,
    CONSTRAINT users_pkey PRIMARY KEY (id),
    CONSTRAINT users_email_key UNIQUE (email)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.users
    OWNER to postgres;

    ----------------------------------------------------------------------------------------------------------------------------
    -- Table: public.questions

-- DROP TABLE IF EXISTS public.questions;
CREATE TABLE public.user_paths (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  path_name VARCHAR NOT NULL,
  selected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.questions
(
    id integer NOT NULL DEFAULT nextval('questions_id_seq'::regclass),
    question text COLLATE pg_catalog."default" NOT NULL,
    option_a text COLLATE pg_catalog."default" NOT NULL,
    option_b text COLLATE pg_catalog."default" NOT NULL,
    option_c text COLLATE pg_catalog."default" NOT NULL,
    option_d text COLLATE pg_catalog."default" NOT NULL,
    correct_option character(1) COLLATE pg_catalog."default",
    category character varying(50) COLLATE pg_catalog."default",
    difficulty character varying(20) COLLATE pg_catalog."default",
    field_id integer,
    type character varying(20) COLLATE pg_catalog."default" DEFAULT 'general'::character varying,
    CONSTRAINT questions_pkey PRIMARY KEY (id),
    CONSTRAINT fk_questions_field FOREIGN KEY (field_id)
        REFERENCES public.fields (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT questions_correct_option_check CHECK (correct_option = ANY (ARRAY['A'::bpchar, 'B'::bpchar, 'C'::bpchar, 'D'::bpchar]))
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.questions
    OWNER to postgres;
        ----------------------------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------------------------
-- Table: public.fields

-- DROP TABLE IF EXISTS public.fields;

CREATE TABLE IF NOT EXISTS public.fields
(
    id integer NOT NULL DEFAULT nextval('fields_id_seq'::regclass),
    name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    description text COLLATE pg_catalog."default",
    CONSTRAINT fields_pkey PRIMARY KEY (id),
    CONSTRAINT fields_name_key UNIQUE (name)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.fields
    OWNER to postgres;