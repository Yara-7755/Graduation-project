
-- PostgreSQL database dump
--

\restrict JN95htiKYHqGRf6e9C70AArPFhgRb7MVmhxgHzUrxjfOmDVasvTAXrXrteZxmyE

-- Dumped from database version 13.23
-- Dumped by pg_dump version 18.1

-- Started on 2026-04-22 18:35:29

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 205 (class 1259 OID 16489)
-- Name: fields; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fields (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    description text,
    is_active boolean DEFAULT true
);


ALTER TABLE public.fields OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 16487)
-- Name: fields_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fields_id_seq OWNER TO postgres;

--
-- TOC entry 3192 (class 0 OID 0)
-- Dependencies: 204
-- Name: fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fields_id_seq OWNED BY public.fields.id;


--
-- TOC entry 221 (class 1259 OID 24911)
-- Name: generated_questions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.generated_questions (
    id integer NOT NULL,
    user_id integer,
    topic_id integer,
    question_text text NOT NULL,
    code_snippet text,
    option_a text NOT NULL,
    option_b text NOT NULL,
    option_c text NOT NULL,
    option_d text NOT NULL,
    correct_option character varying(1) NOT NULL,
    explanation text,
    question_type character varying(50) NOT NULL,
    difficulty character varying(20) DEFAULT 'medium'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    question_hash text,
    generation_batch_id text,
    weakness_tag text,
    difficulty_step integer DEFAULT 1
);


ALTER TABLE public.generated_questions OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 24909)
-- Name: generated_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.generated_questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.generated_questions_id_seq OWNER TO postgres;

--
-- TOC entry 3193 (class 0 OID 0)
-- Dependencies: 220
-- Name: generated_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.generated_questions_id_seq OWNED BY public.generated_questions.id;


--
-- TOC entry 225 (class 1259 OID 24969)
-- Name: placement_questions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.placement_questions (
    id integer NOT NULL,
    question text NOT NULL,
    option_a text NOT NULL,
    option_b text NOT NULL,
    option_c text NOT NULL,
    option_d text NOT NULL,
    correct_option character varying(1) NOT NULL,
    difficulty character varying(10) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT placement_questions_correct_option_check CHECK (((correct_option)::text = ANY ((ARRAY['A'::character varying, 'B'::character varying, 'C'::character varying, 'D'::character varying])::text[]))),
    CONSTRAINT placement_questions_difficulty_check CHECK (((difficulty)::text = ANY ((ARRAY['easy'::character varying, 'medium'::character varying, 'hard'::character varying])::text[])))
);


ALTER TABLE public.placement_questions OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 24967)
-- Name: placement_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.placement_questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.placement_questions_id_seq OWNER TO postgres;

--
-- TOC entry 3194 (class 0 OID 0)
-- Dependencies: 224
-- Name: placement_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.placement_questions_id_seq OWNED BY public.placement_questions.id;


--
-- TOC entry 203 (class 1259 OID 16474)
-- Name: questions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.questions (
    id integer NOT NULL,
    question text NOT NULL,
    option_a text NOT NULL,
    option_b text NOT NULL,
    option_c text NOT NULL,
    option_d text NOT NULL,
    correct_option character(1),
    category character varying(50),
    difficulty character varying(20),
    field_id integer,
    type character varying(20) DEFAULT 'general'::character varying,
    topic_id integer,
    level character varying(50),
    quiz_type character varying(20) DEFAULT 'topic'::character varying,
    CONSTRAINT questions_correct_option_check CHECK ((correct_option = ANY (ARRAY['A'::bpchar, 'B'::bpchar, 'C'::bpchar, 'D'::bpchar]))),
    CONSTRAINT questions_quiz_type_check CHECK (((quiz_type)::text = ANY ((ARRAY['placement'::character varying, 'topic'::character varying])::text[]))),
    CONSTRAINT questions_quiz_type_topic_id_check CHECK (((((quiz_type)::text = 'placement'::text) AND (topic_id IS NULL)) OR (((quiz_type)::text = 'topic'::text) AND (topic_id IS NOT NULL))))
);


ALTER TABLE public.questions OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 16472)
-- Name: questions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.questions_id_seq OWNER TO postgres;

--
-- TOC entry 3195 (class 0 OID 0)
-- Dependencies: 202
-- Name: questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.questions_id_seq OWNED BY public.questions.id;


--
-- TOC entry 213 (class 1259 OID 24748)
-- Name: resources; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.resources (
    id integer NOT NULL,
    topic_id integer NOT NULL,
    title character varying(255) NOT NULL,
    url text NOT NULL,
    type character varying(50) DEFAULT 'video'::character varying
);


ALTER TABLE public.resources OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 24746)
-- Name: resources_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.resources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.resources_id_seq OWNER TO postgres;

--
-- TOC entry 3196 (class 0 OID 0)
-- Dependencies: 212
-- Name: resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.resources_id_seq OWNED BY public.resources.id;


--
-- TOC entry 215 (class 1259 OID 24772)
-- Name: roadmap_questions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roadmap_questions (
    id integer NOT NULL,
    topic_id integer NOT NULL,
    question text NOT NULL,
    option_a text NOT NULL,
    option_b text NOT NULL,
    option_c text NOT NULL,
    option_d text NOT NULL,
    correct_option character varying(1) NOT NULL,
    CONSTRAINT roadmap_questions_correct_option_check CHECK (((correct_option)::text = ANY ((ARRAY['A'::character varying, 'B'::character varying, 'C'::character varying, 'D'::character varying])::text[])))
);


ALTER TABLE public.roadmap_questions OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 24770)
-- Name: roadmap_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roadmap_questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roadmap_questions_id_seq OWNER TO postgres;

--
-- TOC entry 3197 (class 0 OID 0)
-- Dependencies: 214
-- Name: roadmap_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roadmap_questions_id_seq OWNED BY public.roadmap_questions.id;


--
-- TOC entry 211 (class 1259 OID 24731)
-- Name: roadmap_topics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roadmap_topics (
    id integer NOT NULL,
    roadmap_id integer NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    topic_order integer NOT NULL,
    is_locked boolean DEFAULT true,
    is_active boolean DEFAULT true
);


ALTER TABLE public.roadmap_topics OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 24729)
-- Name: roadmap_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roadmap_topics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roadmap_topics_id_seq OWNER TO postgres;

--
-- TOC entry 3198 (class 0 OID 0)
-- Dependencies: 210
-- Name: roadmap_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roadmap_topics_id_seq OWNED BY public.roadmap_topics.id;


--
-- TOC entry 209 (class 1259 OID 24720)
-- Name: roadmaps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roadmaps (
    id integer NOT NULL,
    field_name character varying(100) NOT NULL,
    level character varying(50) NOT NULL,
    title character varying(255) NOT NULL,
    description text
);


ALTER TABLE public.roadmaps OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 24718)
-- Name: roadmaps_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roadmaps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roadmaps_id_seq OWNER TO postgres;

--
-- TOC entry 3199 (class 0 OID 0)
-- Dependencies: 208
-- Name: roadmaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roadmaps_id_seq OWNED BY public.roadmaps.id;


--
-- TOC entry 219 (class 1259 OID 24814)
-- Name: user_fields; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_fields (
    id integer NOT NULL,
    user_id integer NOT NULL,
    field_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.user_fields OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 24812)
-- Name: user_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_fields_id_seq OWNER TO postgres;

--
-- TOC entry 3200 (class 0 OID 0)
-- Dependencies: 218
-- Name: user_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_fields_id_seq OWNED BY public.user_fields.id;


--
-- TOC entry 207 (class 1259 OID 24701)
-- Name: user_paths; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_paths (
    id integer NOT NULL,
    user_id integer,
    path_name character varying(255),
    selected_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_paths OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 24699)
-- Name: user_paths_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_paths_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_paths_id_seq OWNER TO postgres;

--
-- TOC entry 3201 (class 0 OID 0)
-- Dependencies: 206
-- Name: user_paths_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_paths_id_seq OWNED BY public.user_paths.id;


--
-- TOC entry 223 (class 1259 OID 24937)
-- Name: user_question_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_question_history (
    id integer NOT NULL,
    user_id integer NOT NULL,
    topic_id integer NOT NULL,
    generated_question_id integer,
    question_hash text NOT NULL,
    question_text text NOT NULL,
    question_type character varying(50),
    weakness_tag character varying(100),
    difficulty character varying(20) NOT NULL,
    difficulty_step integer DEFAULT 1,
    user_answer character varying(10),
    correct_answer character varying(10),
    was_correct boolean NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_question_history OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 24935)
-- Name: user_question_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_question_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_question_history_id_seq OWNER TO postgres;

--
-- TOC entry 3202 (class 0 OID 0)
-- Dependencies: 222
-- Name: user_question_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_question_history_id_seq OWNED BY public.user_question_history.id;


--
-- TOC entry 217 (class 1259 OID 24789)
-- Name: user_topic_progress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_topic_progress (
    id integer NOT NULL,
    user_id integer NOT NULL,
    topic_id integer NOT NULL,
    status character varying(50) DEFAULT 'locked'::character varying,
    score integer DEFAULT 0,
    completed_at timestamp without time zone,
    CONSTRAINT user_topic_progress_status_check CHECK (((status)::text = ANY ((ARRAY['locked'::character varying, 'unlocked'::character varying, 'completed'::character varying])::text[])))
);


ALTER TABLE public.user_topic_progress OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 24787)
-- Name: user_topic_progress_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_topic_progress_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_topic_progress_id_seq OWNER TO postgres;

--
-- TOC entry 3203 (class 0 OID 0)
-- Dependencies: 216
-- Name: user_topic_progress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_topic_progress_id_seq OWNED BY public.user_topic_progress.id;


--
-- TOC entry 201 (class 1259 OID 16461)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(120) NOT NULL,
    password character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    field character varying(50),
    level character varying(20),
    placement_score integer,
    phone character varying(30),
    university_major character varying(150),
    google_id character varying(255),
    auth_provider character varying(50) DEFAULT 'local'::character varying,
    avatar_url text,
    role character varying(20) DEFAULT 'learner'::character varying,
    CONSTRAINT users_field_check CHECK (((field IS NULL) OR ((field)::text = ANY ((ARRAY['Frontend Development'::character varying, 'Backend Development'::character varying, 'Databases'::character varying, 'Programming Fundamentals'::character varying, 'Cyber Security'::character varying, 'Mobile Development'::character varying, 'Cloud Computing'::character varying, 'UI/UX Design'::character varying])::text[]))))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 16459)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 3204 (class 0 OID 0)
-- Dependencies: 200
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 2939 (class 2604 OID 16492)
-- Name: fields id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fields ALTER COLUMN id SET DEFAULT nextval('public.fields_id_seq'::regclass);


--
-- TOC entry 2955 (class 2604 OID 24914)
-- Name: generated_questions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.generated_questions ALTER COLUMN id SET DEFAULT nextval('public.generated_questions_id_seq'::regclass);


--
-- TOC entry 2962 (class 2604 OID 24972)
-- Name: placement_questions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.placement_questions ALTER COLUMN id SET DEFAULT nextval('public.placement_questions_id_seq'::regclass);


--
-- TOC entry 2936 (class 2604 OID 16477)
-- Name: questions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions ALTER COLUMN id SET DEFAULT nextval('public.questions_id_seq'::regclass);


--
-- TOC entry 2947 (class 2604 OID 24751)
-- Name: resources id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resources ALTER COLUMN id SET DEFAULT nextval('public.resources_id_seq'::regclass);


--
-- TOC entry 2949 (class 2604 OID 24775)
-- Name: roadmap_questions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roadmap_questions ALTER COLUMN id SET DEFAULT nextval('public.roadmap_questions_id_seq'::regclass);


--
-- TOC entry 2944 (class 2604 OID 24734)
-- Name: roadmap_topics id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roadmap_topics ALTER COLUMN id SET DEFAULT nextval('public.roadmap_topics_id_seq'::regclass);


--
-- TOC entry 2943 (class 2604 OID 24723)
-- Name: roadmaps id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roadmaps ALTER COLUMN id SET DEFAULT nextval('public.roadmaps_id_seq'::regclass);


--
-- TOC entry 2953 (class 2604 OID 24817)
-- Name: user_fields id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_fields ALTER COLUMN id SET DEFAULT nextval('public.user_fields_id_seq'::regclass);


--
-- TOC entry 2941 (class 2604 OID 24704)
-- Name: user_paths id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_paths ALTER COLUMN id SET DEFAULT nextval('public.user_paths_id_seq'::regclass);


--
-- TOC entry 2959 (class 2604 OID 24940)
-- Name: user_question_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_question_history ALTER COLUMN id SET DEFAULT nextval('public.user_question_history_id_seq'::regclass);


--
-- TOC entry 2950 (class 2604 OID 24792)
-- Name: user_topic_progress id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_topic_progress ALTER COLUMN id SET DEFAULT nextval('public.user_topic_progress_id_seq'::regclass);


--
-- TOC entry 2932 (class 2604 OID 16464)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 3165 (class 0 OID 16489)
-- Dependencies: 205
-- Data for Name: fields; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fields (id, name, description, is_active) FROM stdin;
1	Frontend Development	Focuses on building user interfaces using HTML, CSS, JavaScript, and frameworks like React.	t
2	Backend Development	Focuses on server-side logic, APIs, databases, and system architecture.	t
5	Software Engineering	Covers software design, problem solving, algorithms, and development methodologies.	t
4	Databases	Focuses on data modeling, SQL, database management systems, and optimization.	t
3	Cybersecurity	Focuses on securing systems, networks, and data from attacks and vulnerabilities.	t
\.


--
-- TOC entry 3181 (class 0 OID 24911)
-- Dependencies: 221
-- Data for Name: generated_questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.generated_questions (id, user_id, topic_id, question_text, code_snippet, option_a, option_b, option_c, option_d, correct_option, explanation, question_type, difficulty, created_at, question_hash, generation_batch_id, weakness_tag, difficulty_step) FROM stdin;
1	2	22	What will be the output of the following code?	<h1>Hello, World!</h1>	Hello, World!	<h1>Hello, World!</h1>	Hello, World!	Error: Invalid HTML	A	The code will render the text 'Hello, World!' as a heading on the webpage.	output_prediction	easy	2026-04-13 12:16:39.062623	\N	\N	\N	1
2	2	22	Identify the error in the following HTML code.	<div><p>This is a paragraph</div></p>	The <div> tag is not closed properly.	The <p> tag is not closed properly.	There is no error in the code.	The <div> tag should be inside <p>.	B	The <p> tag is closed after the <div> tag, which is incorrect. It should be closed before the <div> tag.	find_the_error	easy	2026-04-13 12:16:39.071466	\N	\N	\N	1
3	2	22	What will be the output of the following code?	<h1>Hello, World!</h1>	<h1>Hello, World!</h1>	Hello, World!	<h1>Hello World!</h1>	Hello, World	A	The code correctly outputs an HTML heading element with the text 'Hello, World!'.	output_prediction	easy	2026-04-13 12:17:54.489509	\N	\N	\N	1
4	2	22	Identify the error in the following HTML code.	<p>This is a paragraph<p>	The tag is missing a closing tag.	The tag is incorrectly nested.	There is no error.	The tag should be <div> instead.	A	The <p> tag must be closed with </p> to be valid HTML.	find_the_error	easy	2026-04-13 12:17:54.494605	\N	\N	\N	1
5	17	52	What will be the output of the following code?	const express = require('express');\nconst app = express();\n\napp.get('/api/data', async (req, res) => {\n    const data = await fetchData();\n    res.json(data);\n});\n\nasync function fetchData() {\n    return { message: 'Hello, World!' };\n}\n\napp.listen(3000);\n\n// Simulating a request to the endpoint\nfetch('/api/data').then(res => res.json()).then(console.log);	{ message: 'Hello, World!' }	Hello, World!	undefined	Error: fetch is not defined	A	The output will be the JSON object returned by the fetchData function, which is { message: 'Hello, World!' }.	output_prediction	hard	2026-04-13 12:19:22.08862	\N	\N	\N	1
6	17	52	Identify the error in the following code.	const express = require('express');\nconst app = express();\n\napp.use(express.json());\n\napp.post('/api/user', (req, res) => {\n    const user = req.body;\n    if (!user.name) {\n        return res.status(400).send('Name is required');\n    }\n    res.status(201).send(user);\n});\n\napp.listen(3000);\n\n// Missing error handling for invalid JSON input	The route should be GET instead of POST	The error handling for invalid JSON is missing	The response status should be 200 instead of 201	The express.json() middleware is not used correctly	B	The code does not handle cases where the JSON input is invalid, which would lead to an error when trying to access req.body.	find_the_error	hard	2026-04-13 12:19:22.09054	\N	\N	\N	1
7	17	53	What will be the output of the following code?	const express = require('express');\nconst app = express();\n\napp.get('/data', async (req, res) => {\n    const data = await fetchData();\n    res.json(data);\n});\n\nasync function fetchData() {\n    return { message: 'Hello, World!' };\n}\n\napp.listen(3000);\n\n// Simulate a request to /data	{ "message": "Hello, World!" }	Hello, World!	undefined	{ message: 'Hello, World!' }	A	The output will be a JSON object with the message 'Hello, World!'.	output_prediction	hard	2026-04-13 13:27:00.479922	\N	\N	\N	1
8	17	53	Identify the error in the following code.	const express = require('express');\nconst app = express();\n\napp.get('/user', (req, res) => {\n    const user = getUser();\n    res.json(user);\n});\n\nfunction getUser() {\n    return { name: 'John Doe' };\n}\n\napp.listen(3000);\n\n// Missing async/await for asynchronous operations	The getUser function should be async.	The response should use res.send instead of res.json.	The app should listen on port 4000.	The user object should be converted to a string.	A	The getUser function is synchronous, but if it were asynchronous, it would require async/await to handle properly.	find_the_error	hard	2026-04-13 13:27:00.489897	\N	\N	\N	1
9	17	53	What will be the output of the following code?	const express = require('express');\nconst app = express();\n\napp.get('/data', async (req, res) => {\n    const data = await fetchData();\n    res.json(data);\n});\n\nasync function fetchData() {\n    return { message: 'Hello, World!' };\n}\n\napp.listen(3000);\n\n// Simulate a request\nconst fetch = require('node-fetch');\nfetch('http://localhost:3000/data')\n    .then(res => res.json())\n    .then(json => console.log(json));	{ message: 'Hello, World!' }	{ message: 'Hello, World!'}	undefined	Error: Cannot GET /data	A	The output will be the JSON object returned by the fetchData function, which is { message: 'Hello, World!' }.	output_prediction	hard	2026-04-13 14:02:35.185753	\N	\N	\N	1
10	17	53	Identify the error in the following code.	const express = require('express');\nconst app = express();\n\napp.use(express.json());\n\napp.post('/submit', (req, res) => {\n    const name = req.body.name;\n    res.send(`Hello, ${name}`);\n});\n\napp.listen(3000);\n\n// Missing middleware for JSON parsing\napp.post('/submit', (req, res) => {\n    const age = req.body.age;\n    res.send(`You are ${age} years old`);\n});	The code is correct.	The second route will not work due to missing JSON parsing.	The app.listen should be before defining routes.	The response should be sent as JSON, not a string.	B	The second route is defined after the app has already started listening, and it relies on the body-parser middleware, which is not applied to that route.	find_the_error	hard	2026-04-13 14:02:35.195446	\N	\N	\N	1
11	17	53	What will be the output of the following code?	const express = require('express');\nconst app = express();\n\napp.get('/data', async (req, res) => {\n    const data = await fetchData();\n    res.json(data);\n});\n\nasync function fetchData() {\n    return { message: 'Hello, World!' };\n}\n\napp.listen(3000);\n\n// Making a GET request to /data	{"message":"Hello, World!"}	Hello, World!	{"message":"Hello World!"}	Error: Cannot GET /data	A	The code correctly fetches data asynchronously and responds with a JSON object containing the message 'Hello, World!'.	output_prediction	hard	2026-04-13 14:12:50.939425	\N	\N	\N	1
12	17	53	Identify the error in the following code snippet.	const express = require('express');\nconst app = express();\n\napp.use(express.json());\n\napp.post('/submit', (req, res) => {\n    const userData = req.body;\n    res.send('Data received');\n});\n\napp.listen(3000);\n\n// Missing error handling for invalid JSON input	The route should be GET instead of POST.	Error handling for invalid JSON is missing.	The express.json() middleware is not used.	The server is not listening on the correct port.	B	The code lacks error handling for cases where the JSON input is invalid, which can lead to unhandled errors.	find_the_error	hard	2026-04-13 14:12:50.951866	\N	\N	\N	1
13	2	2	What will be the output of the following code?	let number = 10;\nif (number > 5) {\n    console.log('Greater than 5');\n} else {\n    console.log('5 or less');\n}	Greater than 5	5 or less	10	No output	A	The condition checks if the number is greater than 5, which it is, so 'Greater than 5' is logged.	output_prediction	easy	2026-04-15 21:25:37.537875	775ee7f842fe93c091bf6ee71db795ba40509e2755cb92d6fb15b3d0ab262ae9	1776277537536-2-2	general	3
14	2	2	Identify the error in the following code snippet.	let fruits = ['apple', 'banana', 'cherry'];\nfor (let i = 0; i <= fruits.length; i++) {\n    console.log(fruits[i]);\n}	The loop should use '<' instead of '<='	There is no error	The array should be initialized with numbers	The console.log should be inside an if statement	A	The loop condition should use '<' instead of '<=' to prevent accessing an out-of-bounds index.	find_the_error	easy	2026-04-15 21:25:37.554195	889546e381090bf8a4526fe1da719d079decc3c3688e3392a02a264691dee8c8	1776277537536-2-2	loops	3
15	2	2	Fill in the blank to complete the function that checks if a number is even.	function isEven(num) {\n    return num % ___ === 0;\n}	1	2	3	4	B	To check if a number is even, you need to check if the remainder when divided by 2 is 0.	fill_the_blank	easy	2026-04-15 21:25:37.557181	76585e1a1d2ef3edf3ac8c450d3a9df2fc8855520cf8ef2d20787aab0dc07acd	1776277537536-2-2	functions	3
16	2	2	What will be the output of the following code when executed?	let count = 0;\nwhile (count < 3) {\n    console.log(count);\n    count++;\n}	0, 1, 2	1, 2, 3	0, 1, 2, 3	0, 1	A	The while loop runs while count is less than 3, printing count before increasing it, resulting in 0, 1, and 2.	output_prediction	easy	2026-04-15 21:25:37.562528	ae3554245b578b13aba6ae34130669f69c795486f678ebe02f634d2935a43b79	1776277537536-2-2	loops	3
17	2	2	Choose the correct way to declare an array in JavaScript.	// Select the correct line to declare an array\nlet myArray = ___;	{}	[]	()	<>	B	In JavaScript, arrays are declared using square brackets [].	fill_the_blank	easy	2026-04-15 21:25:37.563633	00ba30a844d41249fc9a196e10756cc8246c25774754c25bff940ed62fcd503c	1776277537536-2-2	arrays	3
18	2	22	What will be the output of the following HTML code?	<!DOCTYPE html>\n<html>\n<head>\n<title>Test</title>\n</head>\n<body>\n<p>Hello, World!</p>\n</body>\n</html>	Hello, World!	<p>Hello, World!</p>	Test	No output	A	The output will be 'Hello, World!' displayed in the browser as part of the HTML body.	output_prediction	easy	2026-04-16 16:31:38.036926	f93da7ae095ca641dc77b4b66473562d398b297ac4ce64b0b32c840a484d74b3	1776346298034-2-22	general	3
19	2	22	What is wrong with the following HTML code?	<html>\n<head>\n<title>Page Title</title>\n</head>\n<body>\n<h1>Welcome to my website<h1>\n</body>\n</html>	The <html> tag is missing.	The <h1> tag is not closed properly.	There is no <head> section.	The body should be before the head.	B	The <h1> tag is not closed properly; it should use </h1> instead of <h1>.	find_the_error	easy	2026-04-16 16:31:38.064997	353230ad1ece74d1e20cf8ca9ffa8b2c2d8993f2228433dea2d7c33ac7059507	1776346298034-2-22	general	3
20	2	22	Fill in the blank: The ______ tag is used to create a hyperlink in HTML.	\N	<link>	<a>	<url>	<hyperlink>	B	The <a> tag is used to create hyperlinks in HTML.	fill_the_blank	easy	2026-04-16 16:31:38.067004	d25cb7c57a9363146fa7685a48df5f9eaf7845d886a67ca444afafc21b500f3a	1776346298034-2-22	general	3
21	2	22	Which of the following correctly links a CSS file to an HTML document?	<head>\n<title>My Page</title>\n<link rel="stylesheet" href="styles.css">\n</head>	<style src="styles.css">	<link rel="stylesheet" src="styles.css">	<link href="styles.css" rel="stylesheet">	<link rel="stylesheet" href="styles.css">	D	The correct way to link a CSS file is using <link rel="stylesheet" href="styles.css">.	code_logic	easy	2026-04-16 16:31:38.068372	64fe97084c686a7071366e4c52075eb3e4f02e9404793fb081c8647db2ed5dc8	1776346298034-2-22	general	3
22	2	22	Which HTML element is used to define the structure of a table?	\N	<table>	<tab>	<tbody>	<div>	A	The <table> element is used to create a table in HTML.	code_logic	easy	2026-04-16 16:31:38.069909	60ed97add86960ae6e133adf6c25649cd01629f4a9f4f5e55d951398198e944d	1776346298034-2-22	general	3
23	2	22	What will be the output of the following HTML code?	<html><body><h1>Hello, World!</h1></body></html>	<h1>Hello, World!</h1>	<html><body></body></html>	Hello, World!	<body><h1>Hello, World!</h1></body>	C	The output is rendered text 'Hello, World!' which is inside the <h1> tags.	output_prediction	easy	2026-04-16 16:32:18.831898	9a0b84b9fde010b48f8251e772981ddaa3d2fca8be03d8546ac2282739a4409f	1776346338830-2-22	general	3
24	2	22	Identify the error in the following HTML snippet.	<div><p>This is a paragraph</div></p>	The <div> tag is unclosed.	The <p> tag is unclosed.	The <p> tag is closed incorrectly.	There are no errors.	C	The <p> tag should be closed before the <div> tag, not after it.	find_the_error	easy	2026-04-16 16:32:18.838304	0eae12b37f7775103189f2df9be83d5ffbd45680fe20b04dca51a1ecd405c3f6	1776346338830-2-22	general	3
25	2	22	Which of the following is a correct way to create a link in HTML?	<a href='https://www.example.com'>Visit Example</a>	<link href='https://www.example.com'>Visit Example</link>	<a url='https://www.example.com'>Visit Example</a>	<a href='https://www.example.com'>Visit Example</a>	<a href='www.example.com'>Visit Example</a>	C	The correct syntax for a hyperlink in HTML uses the <a> tag with an href attribute.	code_logic	easy	2026-04-16 16:32:18.840242	aa8d5b3b287c7014730b7ca75d523d022f0c9e533318560cec4ecf8019714f5b	1776346338830-2-22	general	3
26	2	22	Fill in the blank: The __________ tag is used to create a list in HTML.	<ul><li>Item 1</li></ul>	list	ol	ul	list-item	C	The <ul> tag creates an unordered list in HTML.	fill_the_blank	easy	2026-04-16 16:32:18.841621	1a750728ac388f2d956caaabeb97fc07168ecb5ed02efcb230fd30965722b47e	1776346338830-2-22	general	3
27	2	22	What is the correct HTML element for the largest heading?	\N	<heading>	<h1>	<h6>	<header>	B	The <h1> tag is used for the largest heading in HTML.	code_logic	easy	2026-04-16 16:32:18.843095	4589fa97718448886e43bb03916c5cd688384876c67a2cfcbdfe785f9eaba4e4	1776346338830-2-22	loops	3
28	17	53	What will be the output of the following code snippet when an API call is made?	const express = require('express');\nconst app = express();\n\napp.get('/data', async (req, res) => {\n    const result = await fetchData();\n    res.json(result);\n});\n\napp.listen(3000);\n\nasync function fetchData() {\n    return { message: 'Hello, World!' };\n}	{ message: 'Hello, World!' }	Hello, World!	{ 'message': 'Hello, World!' }	undefined	A	The fetchData function returns an object with a message property, which is then sent as a JSON response.	output_prediction	hard	2026-04-22 12:08:11.915228	fe51ad9f745c967a57ff649f104a8142dc1ad1da33a5ed6f8f2348aba0119fa8	1776848891911-17-53	loops	3
29	17	53	Identify the error in the following middleware function intended to log request URLs.	app.use((req, res, next) => {\n    console.log('Request URL:', req.url);\n    next;\n});	The next function is not called properly.	Logging is done after next is called.	Missing req.method in the log.	Incorrect use of async/await.	A	The 'next' function should be called as 'next()' to pass control to the next middleware.	find_the_error	hard	2026-04-22 12:08:11.943514	f725b117ab34fa388d8582b1bdc1c95899e54c70098f2bb19ce06d5ff5d44367	1776848891911-17-53	loops	3
30	17	53	Fill in the blank to implement caching for an API response using a simple in-memory store.	const cache = {};\n\napp.get('/user/:id', async (req, res) => {\n    const userId = req.params.id;\n    if (cache[userId]) {\n        return res.json(cache[userId]);\n    }\n    const userData = await getUserData(userId);\n    _____;\n    res.json(userData);\n});	cache[userId] = userData;	cache.push(userData);	cache[userId] += userData;	cache.set(userId, userData);	A	The correct way to cache the user data is by assigning it to the cache object using the userId as the key.	fill_the_blank	hard	2026-04-22 12:08:11.944712	0e0d02c02072bb90849bb59a0ff343502819df651e49d94ee72ed31f2ed34be9	1776848891911-17-53	loops	3
53	17	56	What will be the output of the following Express route if the URL contains a valid user ID?	app.get('/user/:id', async (req, res) => { const user = await getUser(req.params.id); res.json(user); });	The user object will be returned as JSON.	An error will be thrown if the user ID is invalid.	The server will respond with a 404 status.	The response will be empty.	A	The route retrieves a user by ID and responds with the user object in JSON format if found.	output_prediction	hard	2026-04-22 14:01:16.931036	c739202c3635450f25fefb1a440ec5980164fa768c2a86fd3bb975c003dc51e7	1776855676928-17-56	backend_routes	3
31	17	53	What will happen if 'await' is removed from the fetchData function in the following code snippet?	app.get('/info', async (req, res) => {\n    const data = fetchData();\n    res.json(data);\n});\n\nasync function fetchData() {\n    return { info: 'Data fetched!' };\n}	The API will return a Promise instead of the actual data.	The API will throw an error.	The API will return an empty object.	The API will hang indefinitely.	A	Without 'await', fetchData will return a Promise, and the API will respond with that Promise instead of the resolved data.	code_logic	hard	2026-04-22 12:08:11.945782	a3b1ef3c520816d2abab4c9ed39a15ad35f9e5796ad129f3dec8f262fe3f9b71	1776848891911-17-53	loops	3
32	17	53	In the following code, what will be the effect of using 'res.send' instead of 'res.json'?	app.get('/status', (req, res) => {\n    res.json({ status: 'OK' });\n});	The response will be sent as plain text.	The response will be sent as JSON, but without proper headers.	The response will throw an error.	There will be no effect; both functions are identical.	B	Using 'res.send' will send the response as text unless the content type is set to JSON explicitly, while 'res.json' automatically sets the correct headers.	code_logic	hard	2026-04-22 12:08:11.948632	865b4f069d8aaec327c19332167ec3ae63a4443e338939495faf906b0bfcafe4	1776848891911-17-53	loops	3
33	17	53	What will be the output of the following Node.js code when a valid JSON object is sent in the request body?	app.post('/data', express.json(), (req, res) => { res.send(req.body); });	{"name":"John"}	undefined	Error: Cannot read property 'body' of undefined	{"error":"Invalid JSON"}	A	The express.json() middleware parses the JSON sent in the request body, making it accessible as req.body. Hence, it will return the JSON object as a response.	output_prediction	hard	2026-04-22 12:08:35.768401	e92bee45c9364ea2e19d3d7646e49c0f9d70643f16c3ba465cfccf31b334a7c6	1776848915765-17-53	loops	3
34	17	53	Identify the error in this middleware function that is supposed to cache responses.	const cacheMiddleware = (req, res, next) => { if (cache[req.url]) { res.send(cache[req.url]); } else { next(); } };	The cache variable is not defined.	The middleware does not call next() if there's a cache hit.	The if statement should check for 'undefined' instead of using 'if'.	The response should be sent with res.json() instead of res.send().	B	The middleware should call next() when there is a cache hit to allow the request to proceed, rather than responding immediately.	find_the_error	hard	2026-04-22 12:08:35.770243	381b1b375aece9f30947a0491c9fe79586edf60324fe9dedf767eba6a79abb65	1776848915765-17-53	loops	3
35	17	53	What will happen if the following asynchronous function is called without awaiting its result?	async function fetchData() { return { data: 'Hello World' }; } fetchData().then(console.log);	It will log 'Hello World' immediately.	It will log a Promise object.	It will throw an error.	It will log 'undefined'.	B	The fetchData function returns a Promise. When called without await, it returns a Promise object that resolves to the data, which is logged in the .then() method.	output_prediction	hard	2026-04-22 12:08:35.771087	4eb4e6ee507d5e28a95d28db9ad25ebe662ed99326d5be832ef6f02614c7a898	1776848915765-17-53	loops	3
36	17	53	Fill in the blank to correctly handle error responses in this Express route.	app.get('/user', async (req, res) => { try { const user = await getUser(req.params.id); res.json(user); } ________ { res.status(500).json({ error: 'Internal Server Error' }); } });	catch	finally	error	except	A	In JavaScript, .catch() is used to handle rejected Promises. Here, it should capture any errors thrown in the try block.	fill_the_blank	hard	2026-04-22 12:08:35.771996	1285e48358c6c4cb0086b00dc141ba0e8bd074d594b50b8b0f78d16b80a84177	1776848915765-17-53	loops	3
37	17	53	What is the potential issue with using a synchronous function in this Express route handler?	app.get('/data', (req, res) => { const data = syncFetchData(); res.json(data); });	It will slow down the server by blocking the event loop.	The data will not be sent in JSON format.	It will cause a memory leak in the application.	The route will not respond at all.	A	Using a synchronous function in an Express route can block the event loop, causing the server to slow down as it cannot handle other requests until the synchronous operation completes.	code_logic	hard	2026-04-22 12:08:35.772767	1f60e763165896183f4a03b97c68473e419e417415715873c5daa47817328812	1776848915765-17-53	loops	3
38	17	53	What will be the output of the following code snippet when the endpoint '/data' is accessed?	const express = require('express');\nconst app = express();\napp.get('/data', async (req, res) => {\n    const cachedData = await getFromCache('data');\n    if (cachedData) {\n        return res.json(cachedData);\n    }\n    const data = await fetchDataFromDB();\n    res.json(data);\n});\n\napp.listen(3000);	Returns cached data if available.	Always fetches new data from the database.	Throws an error if the cache is empty.	Returns undefined if the cache is empty.	A	The code checks if cached data exists; if it does, it returns that data, optimizing performance by avoiding unnecessary database calls.	output_prediction	hard	2026-04-22 12:29:19.611876	c7933b4bf185c9a6f7b9625e189611bcccc6b8df80470c08d9fdaa1a2ccebf97	1776850159598-17-53	loops	3
39	17	53	Identify the error in the following middleware implementation.	const express = require('express');\nconst app = express();\n\napp.use((req, res, next) => {\n    console.log('Request URL:', req.url);\n    next;\n});\n\napp.get('/', (req, res) => res.send('Hello World!'));\n\napp.listen(3000);	The middleware does not log the request URL.	The 'next' function is not called correctly.	Express is not imported properly.	The app does not listen on port 3000.	B	The 'next' function should be called as 'next()' to pass control to the next middleware; without parentheses, it does not execute.	find_the_error	hard	2026-04-22 12:29:19.708124	b5bf596b4e7ab9fc6e53048c71c9e52aad83b1d19ced57fcd2e78394e49f5c67	1776850159598-17-53	loops	3
40	17	53	Fill in the blank: To implement caching in the following function, you can use __________ to store the fetched result temporarily.	async function getUserData(userId) {\n    const userData = await fetchUserFromDB(userId);\n    // Store user data in cache here\n    return userData;\n}	localStorage	Redis	sessionStorage	file system	B	Redis is a popular caching solution that allows for efficient temporary storage of data fetched from a database, improving performance.	fill_the_blank	hard	2026-04-22 12:29:19.709377	abdd106ac81741fc52818094051593105207bf9ded1d023c7031064b627e5c9b	1776850159598-17-53	loops	3
41	17	53	What will happen if the following code is executed and an error occurs while fetching data?	app.get('/user', async (req, res) => {\n    try {\n        const user = await getUserFromDB(req.params.id);\n        res.json(user);\n    } catch (error) {\n        res.status(500).send('Error fetching user data');\n    }\n});	The user data will be returned even if an error occurs.	The server will crash.	A 500 status code will be sent with an error message.	The request will hang indefinitely.	C	The try-catch block handles errors by sending a 500 status code and a message if an error occurs during data fetching.	code_logic	hard	2026-04-22 12:29:19.710727	08db4f428998c3ebe4d601ff7b6f250d54fbadfaee75f498f33768495a88fd7b	1776850159598-17-53	loops	3
42	17	53	Which of the following best describes the purpose of middleware in an Express application?	app.use(express.json());\napp.use((req, res, next) => {\n    console.log('Incoming request');\n    next();\n});	Middleware is used to handle API route definitions.	Middleware acts as a way to modify the request and response objects.	Middleware is only used for error handling.	Middleware allows for synchronous code execution in Express.	B	Middleware functions have access to the request and response objects and can modify them before passing them on to the next function.	code_logic	hard	2026-04-22 12:29:19.711761	858bb3d16430c7c1f11aa839d9d42422ef8d6d1711ae85c43424da36e7d397cb	1776850159598-17-53	loops	3
43	17	54	What will be the output of the following code snippet when a GET request is made to '/api/data'?	const express = require('express');\nconst app = express();\napp.get('/api/data', async (req, res) => {\n    const data = await fetchData();\n    res.json(data);\n});\nfunction fetchData() {\n    return Promise.resolve({ message: 'Hello, World!' });\n}\napp.listen(3000);	{ message: 'Hello, World!' }	Hello, World!	Error: fetchData is not a function	{}	A	The function fetchData returns a resolved promise with an object. When the '/api/data' endpoint is hit, the server responds with this object in JSON format.	output_prediction	hard	2026-04-22 12:45:22.793282	219acf5daeb13c37de2dd129d827d016f8fc138cee6585801aa5fcf210cd9872	1776851122788-17-54	functions	3
44	17	54	Identify the error in the following middleware function that is intended to validate request data.	const validateData = (req, res, next) => {\n    if (!req.body.name) {\n        return res.status(400).send('Name is required');\n    }\n    next();\n};\napp.use(validateData);\napp.post('/api/user', (req, res) => {\n    res.send('User created');\n});	The 'next' function is not called properly.	Missing 'body-parser' middleware.	The validation checks are incorrect.	The response should be a JSON object.	B	The middleware requires body-parser to parse JSON payloads. Without it, req.body will be undefined, causing the validation to fail.	find_the_error	hard	2026-04-22 12:45:22.814432	f7177cf1e8c63f873c007c017084a46fb4f9f12fcf54559d42f46fc40b6b778d	1776851122788-17-54	functions	3
45	17	54	What will happen if the following route handler is called with an invalid JSON body?	app.post('/api/data', (req, res) => {\n    const data = req.body;\n    if (!data || !data.field) {\n        throw new Error('Invalid data');\n    }\n    res.send('Data received');\n});	The server will send a 'Data received' response.	The server will throw an unhandled error.	The server will return a 400 status code.	The server will log the error and continue.	B	Throwing an error without handling it will cause the server to crash or return an unhandled error response. It’s essential to handle errors appropriately.	code_logic	hard	2026-04-22 12:45:22.8157	d7a11a36f212da7636eafd8ef9258e78e527dec5492c6fdca673c9ad6680db32	1776851122788-17-54	backend_routes	3
46	17	54	Fill in the blank: In an Express application, to handle errors globally, you should use __________.	app.use((err, req, res, next) => {\n    res.status(500).send('Something broke!');\n});	error middleware	custom error handler	try-catch block	promise rejection	A	In Express, error middleware is a designated function that handles errors throughout the application. It has four parameters, including the error object.	fill_the_blank	hard	2026-04-22 12:45:22.817095	521d51c15674fcd3ea815f25be9f449baf4213bbe60fe07246225dc67845e60b	1776851122788-17-54	backend_routes	3
47	17	54	What is the expected behavior of the following code snippet if the API endpoint is accessed with an unsupported method?	app.route('/api/items')\n    .get((req, res) => res.send('GET method'))\n    .post((req, res) => res.send('POST method'));\napp.all('/api/items', (req, res) => {\n    res.status(405).send('Method Not Allowed');\n});	The server will respond with 'GET method'.	The server will respond with 'Method Not Allowed'.	The server will throw a 404 error.	The server will respond with 'POST method'.	B	The use of app.all captures any unsupported HTTP methods for the '/api/items' route, returning a 'Method Not Allowed' response with a 405 status code.	code_logic	hard	2026-04-22 12:45:22.818295	45928f04f51644cfb8715fb16b1006297c2d50b0c8a9d24106ae4a20968eabcd	1776851122788-17-54	backend_routes	3
48	17	55	What will the following code output when a GET request is made to '/api/data'?	const express = require('express');\nconst app = express();\n\napp.get('/api/data', async (req, res) => {\n    const data = await fetchData();\n    res.json(data);\n});\n\napp.listen(3000);\n	An object containing data from fetchData()	An empty JSON object	A string response	A status code 200 only	A	The endpoint '/api/data' sends the result of 'fetchData()' as a JSON response, assuming 'fetchData()' returns an object.	output_prediction	hard	2026-04-22 13:42:32.64621	c929a9bc5abfcb1da381b478f55b50025bb523a1b68860d177d3c91736bb50bb	1776854552638-17-55	backend_routes	3
49	17	55	Identify the error in the following middleware function.	app.use((req, res, next) => {\n    if (!req.body.name) {\n        return res.status(400).send('Name is required');\n    }\n    next();\n});	Missing body-parser middleware	next() is called incorrectly	The status code is incorrect	No error exists in this code	A	This middleware requires the body-parser middleware to parse JSON body data, which is not included here.	find_the_error	hard	2026-04-22 13:42:32.655462	f3b74d715d865b4a64fd53c11caf418c6768a1177e053ac5394b3c479e6ce005	1776854552638-17-55	functions	3
50	17	55	Fill in the blank to properly handle a promise rejection in the following async route handler.	app.get('/api/item', async (req, res) => {\n    try {\n        const item = await getItem();\n    } catch (error) {\n        _______\n    }\n});	res.status(500).send('Internal Server Error');	console.log(error);	return item;	res.send('Error occurred');	A	The catch block should send a 500 status with an appropriate message to indicate an internal server error.	fill_the_blank	hard	2026-04-22 13:42:32.656987	1274e4aa42e72875080d8c300ee2e8fc581a49eb6d82cc271d23318bdebd47dc	1776854552638-17-55	backend_routes	3
51	17	55	What is the purpose of this code block in a route handler?	app.post('/api/user', (req, res) => {\n    const user = req.body;\n    if (!user.email || !user.password) {\n        return res.status(400).json({ error: 'Email and password are required' });\n    }\n    // Logic to create user\n});	To validate user input before processing	To log user information	To authenticate the user	To fetch user data from the database	A	This code checks for the presence of email and password in the request body, validating the user's input before further processing.	code_logic	hard	2026-04-22 13:42:32.659808	1813e3fcdebde24363983102c1846b4fc5c736c4c43b9675e917e3198efac00b	1776854552638-17-55	functions	3
52	17	55	What will happen if an error occurs in the following route without a proper error handler?	app.get('/api/products', (req, res) => {\n    const products = getProducts(); // Assume this function may throw an error\n    res.json(products);\n});	The server will respond with a 500 status code automatically.	The server will crash.	The error will be logged and a 200 status will be returned.	The response will be sent as an empty JSON object.	B	If an unhandled error occurs, it may crash the server unless there is a global error handler defined.	output_prediction	hard	2026-04-22 13:42:32.662464	eddfcb36723bb2c2f0f7c82fffe23b932f35bfe75a9483b2faf1b867a1607bf6	1776854552638-17-55	functions	3
54	17	56	Identify the error in the following middleware function for error handling.	app.use((err, req, res, next) => { res.status(500).send('Something broke!'); next(); });	The next() function should not be called after sending a response.	The status code should be 200 instead of 500.	The error message should be customized.	The middleware is implemented correctly.	A	Once a response is sent using res.send, next() should not be called, as the response has already been completed.	find_the_error	hard	2026-04-22 14:01:16.94372	8f39dd2c0c898a3d0f4c61af6ddc770c1292d6e343d912e9feca521c31006486	1776855676928-17-56	loops	3
55	17	56	Fill in the blank to ensure the API validates incoming JSON data correctly.	app.post('/data', (req, res) => { const { value } = req.body; if (value) { res.send('Valid data'); } else { _______ } });	res.status(400).send('Invalid data');	console.log('No value');	next();	res.send('Data is missing');	A	To indicate invalid data, the server should respond with a 400 status and an appropriate message.	fill_the_blank	hard	2026-04-22 14:01:16.946432	65e561f84156b6e6c3be22a340e0e4b380171e67bfee8f7a96b6cf44d428b446	1776855676928-17-56	general	3
56	17	56	What is the purpose of the following line in an Express route for handling a request?	const user = await User.findById(req.params.id);	To retrieve user data from the database asynchronously.	To validate the user ID format.	To check if the user exists in the request body.	To log the user ID to the console.	A	This line retrieves user data from the database by ID, using asynchronous handling to ensure non-blocking behavior.	code_logic	hard	2026-04-22 14:01:16.94819	9a9dc8097214ace785334d79f76d833b87ed6be1584f00b0cb91fb64a79bfd0b	1776855676928-17-56	loops	3
57	17	56	Given the following Express route, what will happen if an invalid JSON is sent to it?	app.post('/submit', express.json(), (req, res) => { res.send(req.body); });	The server will crash due to invalid JSON.	A 400 error will be automatically returned.	The request will be ignored without any error.	The server will respond with an empty body.	B	Express's built-in JSON middleware automatically returns a 400 error for invalid JSON input.	output_prediction	hard	2026-04-22 14:01:16.949798	72ae15c0099ae45d9807ef7328f73e94f620d95a8beecd72601461427fa55616	1776855676928-17-56	backend_routes	3
58	17	57	What will be the output of the following Node.js code snippet?	const express = require('express');\nconst app = express();\n\napp.get('/data', async (req, res) => {\n    const data = await fetchData();\n    res.json(data);\n});\n\napp.listen(3000);\n\nasync function fetchData() {\n    return { name: 'Cognito', type: 'Learning Platform' };\n}	{ name: 'Cognito', type: 'Learning Platform' }	[{ name: 'Cognito', type: 'Learning Platform' }]	undefined	500 Internal Server Error	A	The function fetchData returns an object, which is then sent as a JSON response. Therefore, the output will be the object in option A.	output_prediction	hard	2026-04-22 14:05:34.207375	39524ac109d8005381cd7c462ee85dd182021ee83a17021aeb3010308d5a9a6a	1776855934204-17-57	loops	3
59	17	57	Identify the error in the following Express.js middleware implementation.	app.use((req, res, next) => {\n    if (!req.body.name) {\n        return res.status(400).send('Name is required');\n    }\n    next();\n});	Missing async/await syntax	Incorrect usage of req.body	No error, the middleware is correctly implemented	Missing error handling for next()	C	The middleware correctly checks if the name is present in the request body and handles the response accordingly. There is no error in the implementation.	find_the_error	hard	2026-04-22 14:05:34.236342	b2a48eefb6b71a1f8efd3806858da8c5b7c2423a93735ac4aa3e72d38f1e6008	1776855934204-17-57	functions	3
60	17	57	What will happen if the following code is executed in an Express route without proper error handling?	app.get('/user', async (req, res) => {\n    const user = await getUserById(req.params.id);\n    res.send(user);\n});	The user object will be sent successfully.	A 404 error will be returned if user is not found.	An unhandled promise rejection will occur if getUserById fails.	The server will crash due to an invalid route.	C	If getUserById fails and there is no error handling, it will result in an unhandled promise rejection, which can crash the server.	code_logic	hard	2026-04-22 14:05:34.238755	618d2ab824490f929b0e6cd562be16456daccd2b3ccc3acf88c703ddb1691cd3	1776855934204-17-57	backend_routes	3
61	17	57	Fill in the blank to correctly validate a request body in an Express.js route.	app.post('/submit', (req, res) => {\n    if (____) {\n        return res.status(400).send('Invalid data');\n    }\n    res.send('Data submitted');\n});	typeof req.body.data !== 'string'	req.body.data === undefined	req.body.data.length < 5	req.body.data === null	B	Checking if req.body.data is undefined ensures that the required data is present before proceeding. This is a basic validation step.	fill_the_blank	hard	2026-04-22 14:05:34.241043	1a7435b856c5934b1f33aac0b9d8e89373875189319bc612ff5cbd9690af5eb1	1776855934204-17-57	functions	3
62	17	57	Which of the following practices best enhances the security of an Express application?	app.use(express.json());\napp.use((req, res, next) => {\n    // Security measures here\n});	Limiting request size to prevent DoS attacks	Using only GET requests to handle data	Disabling CORS entirely for public access	Avoiding the use of middleware in routes	A	Limiting request size is a common security measure to prevent Denial of Service (DoS) attacks, making it a best practice.	code_logic	hard	2026-04-22 14:05:34.243927	0f8f7cbbb997d7ecb1ca7f58e6e501aca761730d53c5c3377acc4c9e719d9754	1776855934204-17-57	backend_routes	3
\.


--
-- TOC entry 3185 (class 0 OID 24969)
-- Dependencies: 225
-- Data for Name: placement_questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.placement_questions (id, question, option_a, option_b, option_c, option_d, correct_option, difficulty, is_active, created_at) FROM stdin;
1	What does CPU stand for?	Central Process Unit	Central Processing Unit	Computer Personal Unit	Central Power Unit	B	easy	t	2026-04-20 14:49:02.254055
2	What is HTML mainly used for?	Designing databases	Structuring web pages	Managing servers	Creating operating systems	B	easy	t	2026-04-20 14:49:02.254055
3	Which of the following is a programming language?	Python	HTTP	MySQL Server	RAM	A	easy	t	2026-04-20 14:49:02.254055
4	What does RAM stand for?	Read Access Memory	Random Access Memory	Run Access Memory	Remote Access Module	B	easy	t	2026-04-20 14:49:02.254055
5	Which device is used to point and click on a computer screen?	Keyboard	Monitor	Mouse	Printer	C	easy	t	2026-04-20 14:49:02.254055
6	Which of the following is an output device?	Scanner	Keyboard	Mouse	Monitor	D	easy	t	2026-04-20 14:49:02.254055
7	What does URL stand for?	Uniform Resource Locator	Universal Resource Link	Unified Routing Locator	User Resource Level	A	easy	t	2026-04-20 14:49:02.254055
8	Which company developed the Windows operating system?	Apple	Google	Microsoft	IBM	C	easy	t	2026-04-20 14:49:02.254055
9	What is the binary value of decimal 1?	0	1	10	11	B	easy	t	2026-04-20 14:49:02.254055
10	Which symbol is commonly used in email addresses?	#	@	&	%	B	easy	t	2026-04-20 14:49:02.254055
11	What is the main purpose of an operating system?	To design websites	To manage computer hardware and software	To create databases only	To print documents	B	easy	t	2026-04-20 14:49:02.254055
12	Which one is a web browser?	Chrome	Linux	Oracle	Excel	A	easy	t	2026-04-20 14:49:02.254055
13	What does IT stand for?	Internet Tools	Information Technology	Integrated Technology	Internal Technique	B	easy	t	2026-04-20 14:49:02.254055
14	Which of the following is used to store data permanently?	RAM	Cache	Hard Drive	Register	C	easy	t	2026-04-20 14:49:02.254055
15	What is the main function of a keyboard?	Display images	Input text and commands	Store files	Connect networks	B	easy	t	2026-04-20 14:49:02.254055
16	What is the primary key in a database?	A key used for encryption	A unique identifier for each row	A duplicated field	A backup column	B	medium	t	2026-04-20 14:49:02.254055
17	What does API stand for?	Application Programming Interface	Applied Program Internet	Advanced Processing Input	Automated Program Integration	A	medium	t	2026-04-20 14:49:02.254055
18	Which SQL command is used to retrieve data?	INSERT	UPDATE	SELECT	DELETE	C	medium	t	2026-04-20 14:49:02.254055
19	Which of the following best describes OOP?	A way to connect to the internet	A programming paradigm based on objects and classes	A database language	A hardware optimization method	B	medium	t	2026-04-20 14:49:02.254055
20	What is a variable in programming?	A fixed value	A storage location for data	A type of loop	A network address	B	medium	t	2026-04-20 14:49:02.254055
21	What does CSS mainly control?	Server-side logic	Page structure	Database relations	Page styling and layout	D	medium	t	2026-04-20 14:49:02.254055
22	What is Git mainly used for?	Image editing	Version control	Database hosting	Compiling code only	B	medium	t	2026-04-20 14:49:02.254055
23	Which HTTP method is commonly used to create new data?	GET	POST	DELETE	PATCH	B	medium	t	2026-04-20 14:49:02.254055
24	What is the purpose of a firewall?	To speed up code execution	To protect a network by filtering traffic	To design user interfaces	To store passwords	B	medium	t	2026-04-20 14:49:02.254055
25	Which data structure follows FIFO?	Stack	Queue	Tree	Graph	B	medium	t	2026-04-20 14:49:02.254055
26	What does JSON commonly represent?	A compiled programming language	A lightweight data exchange format	A database engine	A hardware protocol	B	medium	t	2026-04-20 14:49:02.254055
27	Which of the following is a relational database?	MongoDB	PostgreSQL	Redis	Firebase Storage	B	medium	t	2026-04-20 14:49:02.254055
28	What is the purpose of authentication?	Checking if a user has permission after login only	Verifying the identity of a user	Encrypting the database	Improving UI design	B	medium	t	2026-04-20 14:49:02.254055
29	What is recursion?	A loop that never ends	A function calling itself	A way to store images	A type of database relation	B	medium	t	2026-04-20 14:49:02.254055
30	Which layer is mainly responsible for user interaction in a web app?	Database layer	Presentation layer	Network cable layer	Storage layer	B	medium	t	2026-04-20 14:49:02.254055
31	What is the time complexity of binary search on a sorted array?	O(n)	O(log n)	O(n log n)	O(1)	B	hard	t	2026-04-20 14:49:02.254055
32	Which normalization form removes partial dependency?	1NF	2NF	3NF	BCNF	B	hard	t	2026-04-20 14:49:02.254055
33	What is the main purpose of indexing in databases?	To encrypt tables	To speed up query performance	To duplicate data	To validate passwords	B	hard	t	2026-04-20 14:49:02.254055
34	Which protocol provides secure communication over the web?	HTTP	FTP	HTTPS	SMTP	C	hard	t	2026-04-20 14:49:02.254055
35	In networking, what does DNS do?	Encrypts traffic	Translates domain names to IP addresses	Compresses files	Stores website images	B	hard	t	2026-04-20 14:49:02.254055
36	Which join returns only matching rows from both tables?	LEFT JOIN	RIGHT JOIN	FULL JOIN	INNER JOIN	D	hard	t	2026-04-20 14:49:02.254055
37	What is the main difference between stack and heap memory?	Stack is for databases, heap is for networks	Stack stores function call data, heap stores dynamic allocations	Heap is always faster in every case	There is no difference	B	hard	t	2026-04-20 14:49:02.254055
38	What is the purpose of hashing in password storage?	To make passwords readable later exactly as entered	To store passwords securely in transformed form	To compress passwords for faster login only	To send passwords over email	B	hard	t	2026-04-20 14:49:02.254055
39	Which of the following best describes polymorphism in OOP?	Using one interface with different underlying forms	Storing data in tables	Running multiple operating systems	Converting HTML to CSS	A	hard	t	2026-04-20 14:49:02.254055
40	What is the role of middleware in backend applications?	To replace the database	To handle requests and responses between client and server logic	To design frontend pages	To create hardware drivers	B	hard	t	2026-04-20 14:49:02.254055
\.


--
-- TOC entry 3163 (class 0 OID 16474)
-- Dependencies: 203
-- Data for Name: questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.questions (id, question, option_a, option_b, option_c, option_d, correct_option, category, difficulty, field_id, type, topic_id, level, quiz_type) FROM stdin;
1325	What does UI stand for?	User Interface	User Internet	User Input	Unified Interface	A	\N	easy	\N	general	112	\N	topic
1326	What does UX stand for?	User Experience	User Example	Unified Experience	User Execution	A	\N	easy	\N	general	112	\N	topic
1327	What is UI mainly about?	Visual design of screens	Database design	Server setup	Network routing	A	\N	easy	\N	general	112	\N	topic
1328	What is UX mainly about?	How users feel using a product	Only colors	Only fonts	Only code	A	\N	easy	\N	general	112	\N	topic
1329	Which focuses on usability?	UX	CSS	Database	API	A	\N	medium	\N	general	112	\N	topic
1330	Which focuses on look and layout?	UI	SQL	Backend	Security	A	\N	medium	\N	general	112	\N	topic
1331	Good UI/UX helps to?	Improve user satisfaction	Slow the app	Increase bugs	Remove features	A	\N	medium	\N	general	112	\N	topic
1332	Which is part of UX?	User journey	Server logs	Indexes	Encryption	A	\N	medium	\N	general	112	\N	topic
1333	Which is a UI element?	Button	API endpoint	Table join	Firewall	A	\N	hard	\N	general	112	\N	topic
1334	Which is a UX goal?	Easy and efficient interaction	More code lines	Bigger database	Longer loading time	A	\N	hard	\N	general	112	\N	topic
1335	What is alignment in design?	Placing elements in order	Deleting elements	Encrypting data	Routing pages	A	\N	easy	\N	general	113	\N	topic
1336	What is contrast used for?	Making elements stand out	Storing data	Speeding server	Writing SQL	A	\N	easy	\N	general	113	\N	topic
95	What is programming?	Writing instructions for a computer	Using a browser	Installing apps	Designing UI	A	\N	easy	\N	general	1	\N	topic
96	Which of the following is a programming language?	HTML	Python	HTTP	CPU	B	\N	easy	\N	general	1	\N	topic
97	What is a variable?	A constant value	A storage for data	A loop	A function	B	\N	easy	\N	general	1	\N	topic
98	Which data type stores text?	Integer	Boolean	String	Float	C	\N	easy	\N	general	1	\N	topic
99	Which data type stores true/false?	Integer	Boolean	String	Char	B	\N	medium	\N	general	1	\N	topic
100	What is output?	Receiving data	Displaying data	Deleting data	Saving data	B	\N	medium	\N	general	1	\N	topic
101	Which symbol is used for assignment?	=	==	!=	>=	A	\N	medium	\N	general	1	\N	topic
102	Which one is NOT a programming language?	Java	C++	Python	WiFi	D	\N	medium	\N	general	1	\N	topic
103	What happens when you divide a number by zero in most programming languages?	Returns 0	An error occurs	Returns 1	Nothing happens	B	\N	hard	\N	general	1	\N	topic
104	What is the purpose of a compiler?	Execute code directly	Translate code into machine language	Store data	Debug code	B	\N	hard	\N	general	1	\N	topic
117	What is a control structure?	A data type	A way to control program flow	A variable	A compiler	B	\N	easy	\N	general	2	\N	topic
118	Which statement is used for decision making?	for	if	while	function	B	\N	easy	\N	general	2	\N	topic
119	Which keyword is used for alternative conditions?	loop	switch	else	break	C	\N	easy	\N	general	2	\N	topic
120	What does an if statement do?	Repeats code	Makes decisions	Stores data	Prints output	B	\N	easy	\N	general	2	\N	topic
121	Which loop runs while a condition is true?	for	if	while	switch	C	\N	medium	\N	general	2	\N	topic
122	What does break do?	Repeats loop	Ends loop	Skips iteration	Starts loop	B	\N	medium	\N	general	2	\N	topic
123	What does continue do?	Stops program	Ends loop	Skips current iteration	Restarts loop	C	\N	medium	\N	general	2	\N	topic
124	Which structure checks multiple conditions?	if-else if	for	while	variable	A	\N	medium	\N	general	2	\N	topic
125	What is the difference between if and if-else?	No difference	if handles one condition, else handles alternative	if is loop	else is variable	B	\N	hard	\N	general	2	\N	topic
139	What is a loop?	A data type	A structure that repeats code	A variable	A compiler	B	\N	easy	\N	general	3	\N	topic
161	What is a function?	A loop	A reusable block of code	A variable	A compiler	B	\N	easy	\N	general	4	\N	topic
162	Why are functions used?	To slow down code	To reuse code	To delete variables	To stop execution	B	\N	easy	\N	general	4	\N	topic
163	What is a parameter?	A value passed into a function	A return value	A loop condition	A variable type	A	\N	easy	\N	general	4	\N	topic
164	What is a return value?	A printed value	A value sent back from a function	A loop result	A variable	B	\N	easy	\N	general	4	\N	topic
165	Which keyword is commonly used to return a value?	send	return	output	exit	B	\N	medium	\N	general	4	\N	topic
205	What is problem solving in programming?	Designing logos	Breaking a problem into steps to create a solution	Installing software	Writing only comments	B	\N	easy	\N	general	10	\N	topic
206	What is the first step in solving a programming problem?	Start coding immediately	Understand the problem	Deploy the app	Create a database	B	\N	easy	\N	general	10	\N	topic
207	Why is it important to identify inputs and outputs?	To change the programming language	To know what data is needed and what result is expected	To remove loops	To speed up the compiler only	B	\N	easy	\N	general	10	\N	topic
208	What is an algorithm?	A type of error	A step-by-step solution to a problem	A variable name	A hardware device	B	\N	easy	\N	general	10	\N	topic
209	What is pseudocode?	Real code that runs directly	A simple way to describe logic before coding	A database query	A debugging tool	B	\N	medium	\N	general	10	\N	topic
210	Why do programmers use flowcharts?	To replace programming languages	To visualize the steps of a solution	To store data permanently	To install compilers	B	\N	medium	\N	general	10	\N	topic
211	What helps reduce mistakes before coding?	Skipping analysis	Planning the solution first	Using random variables	Avoiding functions	B	\N	medium	\N	general	10	\N	topic
212	Why should a large problem be divided into smaller parts?	To make it harder	To make it easier to solve and manage	To avoid inputs	To remove conditions	B	\N	medium	\N	general	10	\N	topic
213	What does algorithmic thinking mean?	Thinking only about hardware	Thinking logically in ordered steps	Writing longer code	Avoiding testing	B	\N	hard	\N	general	10	\N	topic
214	What is decomposition?	Deleting code	Breaking a complex problem into smaller subproblems	Combining all functions	Running code repeatedly	B	\N	hard	\N	general	10	\N	topic
227	What is recursion?	A loop statement	A function calling itself	A variable type	A data structure	B	\N	easy	\N	general	11	\N	topic
228	What is required for recursion to stop?	Loop	Base case	Variable	Compiler	B	\N	easy	\N	general	11	\N	topic
229	What happens if there is no base case?	Program ends normally	Infinite recursion occurs	Code runs once	Nothing happens	B	\N	easy	\N	general	11	\N	topic
230	Where is recursion commonly used?	Only in UI design	In problems that can be divided into smaller subproblems	Only in databases	Only in loops	B	\N	easy	\N	general	11	\N	topic
231	Which of these describes recursion best?	Repeating code with loops	Solving a problem by solving smaller versions of it	Storing data in arrays	Printing output	B	\N	medium	\N	general	11	\N	topic
232	What does each recursive call use?	Same memory space always	New stack frame	Same variable only	Global memory only	B	\N	medium	\N	general	11	\N	topic
233	Which structure is used internally to manage recursion calls?	Queue	Stack	Array	Loop	B	\N	medium	\N	general	11	\N	topic
234	What is a recursive function?	A function that never runs	A function that calls itself	A loop inside a function	A variable	B	\N	medium	\N	general	11	\N	topic
235	What is the role of the base case in recursion?	To repeat the function	To stop recursive calls	To increase performance	To store data	B	\N	hard	\N	general	11	\N	topic
249	What is object-oriented programming?	A way to design programs using objects	A type of database	A network protocol	A browser feature	A	\N	easy	\N	general	12	\N	topic
250	What is an object in OOP?	A comment	An instance of a class	A loop	A compiler	B	\N	easy	\N	general	12	\N	topic
251	What is a class?	A blueprint for creating objects	A variable	A function call	A data type only	A	\N	easy	\N	general	12	\N	topic
252	What does an object contain?	Only loops	Data and behavior	Only comments	Only errors	B	\N	easy	\N	general	12	\N	topic
253	What are attributes in a class?	Operations only	Properties or data of an object	Compiler messages	Conditions	B	\N	medium	\N	general	12	\N	topic
254	What are methods in a class?	Variables	Functions that belong to a class	Errors	Indexes	B	\N	medium	\N	general	12	\N	topic
255	Why are classes useful?	They make code random	They help organize related data and behavior	They remove debugging	They replace arrays only	B	\N	medium	\N	general	12	\N	topic
256	What is an example of a class?	Car	drive()	if	for	A	\N	medium	\N	general	12	\N	topic
272	Why do programs use files?	To store data permanently	To replace variables	To avoid functions	To remove output	A	\N	easy	\N	general	13	\N	topic
279	What is append mode used for?	Reading only	Adding data to the end of a file	Deleting the file	Renaming the file	B	\N	hard	\N	general	13	\N	topic
280	Why is error handling important in file operations?	To avoid all variables	To handle missing files or permission issues safely	To replace arrays	To speed up comments	B	\N	hard	\N	general	13	\N	topic
293	What is debugging?	Writing new features only	Finding and fixing errors in code	Designing databases	Creating classes	B	\N	easy	\N	general	14	\N	topic
294	What is code tracing?	Deleting code line by line	Following code execution step by step	Compiling code faster	Writing comments only	B	\N	easy	\N	general	14	\N	topic
295	Why do programmers debug programs?	To add random code	To identify and fix problems	To remove variables	To avoid functions	B	\N	easy	\N	general	14	\N	topic
296	What is a bug in programming?	A hardware device	An error or flaw in the program	A loop type	A file format	B	\N	easy	\N	general	14	\N	topic
297	What is a syntax error?	An error in program format or structure	A logical mistake in the algorithm	A server issue	A file permission issue	A	\N	medium	\N	general	14	\N	topic
298	What is a runtime error?	An error that happens while the program is running	An error in comments	An error before writing code	An error in naming only	A	\N	medium	\N	general	14	\N	topic
299	What is a logical error?	An error that crashes the compiler always	An error where the program runs but gives wrong results	An error in file permissions	An error in formatting only	B	\N	medium	\N	general	14	\N	topic
300	Why are print statements useful in debugging?	They help track variable values and execution flow	They always fix bugs automatically	They replace testing	They speed up the compiler	A	\N	medium	\N	general	14	\N	topic
301	What does a debugger tool help you do?	Edit images	Inspect variables and step through code	Replace all loops	Create databases	B	\N	hard	\N	general	14	\N	topic
302	What is a breakpoint?	A syntax rule	A point where execution pauses for inspection	A variable type	A file path	B	\N	hard	\N	general	14	\N	topic
315	What does HTML stand for?	Hyper Text Markup Language	High Tech Machine Language	Hyper Transfer Markup Language	Home Tool Markup Language	A	\N	easy	\N	general	22	\N	topic
316	Which HTML tag is used to create the largest heading?	<h6>	<heading>	<h1>	<head>	C	\N	easy	\N	general	22	\N	topic
317	Which tag is used to create a hyperlink in HTML?	<link>	<a>	<href>	<url>	B	\N	easy	\N	general	22	\N	topic
318	Which HTML tag is used to insert an image?	<image>	<img>	<src>	<picture>	B	\N	easy	\N	general	22	\N	topic
319	Which attribute is used with <img> to specify the image path?	href	alt	src	link	C	\N	medium	\N	general	22	\N	topic
345	What does HTML stand for?	Hyper Text Markup Language	High Text Machine Language	Home Tool Markup Language	Hyperlink Transfer Mark Language	A	\N	medium	\N	general	22	\N	topic
346	Which tag is used to create a paragraph?	<p>	<h1>	<br>	<a>	A	\N	medium	\N	general	22	\N	topic
347	Which tag is used to insert an image?	<img>	<image>	<pic>	<src>	A	\N	medium	\N	general	22	\N	topic
348	Which tag is used to create a link?	<a>	<link>	<href>	<url>	A	\N	hard	\N	general	22	\N	topic
349	Which attribute is used to define the destination of a link?	src	href	alt	title	B	\N	hard	\N	general	22	\N	topic
365	What is the main goal of responsive web design?	Make websites colorful	Make websites work on all screen sizes	Make websites faster only	Add animations	B	\N	medium	\N	general	24	\N	topic
366	Which device is considered in responsive design?	Mobile phones	Desktops	Tablets	All of the above	D	\N	medium	\N	general	24	\N	topic
367	Which CSS layout system helps in responsive design?	Flexbox	Console	Compiler	Debugger	A	\N	medium	\N	general	24	\N	topic
368	Which unit is flexible for responsive layouts?	px	%	cm	mm	B	\N	hard	\N	general	24	\N	topic
369	What is a media query used for?	Adding colors	Applying styles based on screen size	Running JavaScript	Creating animations	B	\N	hard	\N	general	24	\N	topic
375	Which language is used to add interactivity to web pages?	HTML	CSS	JavaScript	SQL	C	\N	medium	\N	general	25	\N	topic
376	Which keyword is used to declare a variable in modern JavaScript?	var	let	define	int	B	\N	medium	\N	general	25	\N	topic
377	Which symbol is used to assign a value to a variable?	=	==	===	!=	A	\N	medium	\N	general	25	\N	topic
378	Which data type represents true or false?	String	Boolean	Number	Object	B	\N	hard	\N	general	25	\N	topic
379	Which method is used to print to the browser console?	print()	console.log()	echo()	write()	B	\N	hard	\N	general	25	\N	topic
385	What does DOM stand for?	Document Object Model	Data Object Management	Digital Object Method	Desktop Oriented Model	A	\N	medium	\N	general	26	\N	topic
386	Which object represents the DOM in JavaScript?	window	document	console	screen	B	\N	medium	\N	general	26	\N	topic
387	Which method selects an element by id?	getElementById()	querySelectorAll()	getElementsByClassName()	selectById()	A	\N	medium	\N	general	26	\N	topic
388	Which property is used to change text content?	innerText	textValue	valueText	contentText	A	\N	hard	\N	general	26	\N	topic
389	Which method selects the first matching CSS selector?	getElementById()	querySelector()	querySelectorAll()	getElements()	B	\N	hard	\N	general	26	\N	topic
395	What is React mainly used for?	Building user interfaces	Managing databases	Writing server code	Operating systems	A	\N	medium	\N	general	27	\N	topic
396	What is a React component?	A CSS file	A reusable piece of UI	A database table	A browser plugin	B	\N	medium	\N	general	27	\N	topic
397	Which syntax extension is commonly used in React?	XML	JSX	SQL	JSON	B	\N	medium	\N	general	27	\N	topic
398	React is mainly written using which language?	Python	JavaScript	C++	Java	B	\N	hard	\N	general	27	\N	topic
399	How do you pass data from parent to child in React?	State	Props	Hooks	Events	B	\N	hard	\N	general	27	\N	topic
405	What is Flexbox mainly used for?	Styling text	Layout design	Database queries	Animations only	B	\N	easy	\N	general	28	\N	topic
525	What is a data structure?	A way to store and organize data	A programming language	A database only	A UI design	A	\N	easy	\N	general	15	\N	topic
526	Which data structure stores elements in order?	Array	Tree	Graph	Heap	A	\N	easy	\N	general	15	\N	topic
527	Which data structure follows FIFO?	Stack	Queue	Array	Tree	B	\N	easy	\N	general	15	\N	topic
528	Which data structure follows LIFO?	Queue	Stack	Array	Graph	B	\N	easy	\N	general	15	\N	topic
529	What is the main advantage of arrays?	Dynamic size	Fast access by index	Low memory usage always	No duplicates	B	\N	medium	\N	general	15	\N	topic
530	Which data structure is used for hierarchical data?	Array	Queue	Tree	Stack	C	\N	medium	\N	general	15	\N	topic
531	What is a linked list?	A collection of nodes connected by pointers	An array of fixed size	A database table	A UI component	A	\N	medium	\N	general	15	\N	topic
532	Which structure uses nodes with next references?	Array	Linked List	Queue	Heap	B	\N	medium	\N	general	15	\N	topic
533	What is the time complexity of accessing an element in an array by index?	O(n)	O(log n)	O(1)	O(n log n)	C	\N	hard	\N	general	15	\N	topic
534	Which structure is best for implementing recursion?	Queue	Stack	Tree	Graph	B	\N	hard	\N	general	15	\N	topic
709	What is rate limiting?	Limiting CSS	Controlling number of requests	Deleting requests	Styling APIs	B	\N	medium	\N	general	51	\N	topic
710	What does authentication verify?	Permissions	Identity	UI	Database	B	\N	medium	\N	general	51	\N	topic
711	What does authorization control?	Identity	Access rights	UI styling	Routing	B	\N	medium	\N	general	51	\N	topic
712	Which header is used for authentication tokens?	Content-Type	Authorization	Accept	Host	B	\N	medium	\N	general	51	\N	topic
713	Which attack involves inserting malicious SQL queries?	XSS	CSRF	SQL Injection	DDoS	C	\N	hard	\N	general	51	\N	topic
714	What is the purpose of encryption in APIs?	Improve UI	Secure sensitive data	Speed requests	Delete data	B	\N	hard	\N	general	51	\N	topic
715	What is system design?	Styling UI	Designing software architecture	Writing CSS	Creating animations	B	\N	easy	\N	general	52	\N	topic
716	Which component handles user requests?	Client	Server	Database	CSS	B	\N	easy	\N	general	52	\N	topic
717	What is scalability?	Making UI bigger	Handling more users efficiently	Adding CSS	Reducing code	B	\N	easy	\N	general	52	\N	topic
718	Which part stores data?	Frontend	Server	Database	Browser	C	\N	easy	\N	general	52	\N	topic
738	Microservices communicate using?	CSS	APIs	HTML	Images	B	\N	easy	\N	general	54	\N	topic
1254	Best practice?	Relevant msgs	Spam	None	CSS	A	\N	hard	\N	general	104	\N	topic
837	Which language does PostgreSQL use?	HTML	CSS	SQL	JSX	C	\N	easy	\N	general	63	\N	topic
1147	Which device runs mobile apps?	Server	Smartphone	Router	Printer	B	\N	easy	\N	general	94	\N	topic
126	When is a switch statement preferred?	When checking many conditions	For loops only	For variables	For debugging	A	\N	hard	\N	general	2	\N	topic
140	Which loop is commonly used when the number of iterations is known?	while	for	if	switch	B	\N	easy	\N	general	3	\N	topic
141	Which loop continues as long as a condition is true?	for	while	if	case	B	\N	easy	\N	general	3	\N	topic
142	What does a loop help reduce?	Variables	Repeated code	Functions	Errors only	B	\N	easy	\N	general	3	\N	topic
143	Which keyword stops a loop completely?	continue	break	skip	end	B	\N	medium	\N	general	3	\N	topic
144	Which keyword skips the current iteration and moves to the next one?	break	continue	return	exit	B	\N	medium	\N	general	3	\N	topic
145	What is the starting value in a loop called?	Condition	Initialization	Iteration	Termination	B	\N	medium	\N	general	3	\N	topic
146	What must be updated inside many loops to avoid running forever?	The output text	The loop variable	The function name	The compiler	B	\N	medium	\N	general	3	\N	topic
147	What is an infinite loop?	A loop that runs once	A loop that never ends	A loop without variables	A loop in a function	B	\N	hard	\N	general	3	\N	topic
148	What are nested loops?	Two variables in one loop	A loop inside another loop	A loop with comments	Two functions together	B	\N	hard	\N	general	3	\N	topic
166	What happens if a function has no return?	Error occurs always	Returns nothing (void)	Stops program	Repeats code	B	\N	medium	\N	general	4	\N	topic
167	What is calling a function?	Defining it	Executing it	Deleting it	Looping it	B	\N	medium	\N	general	4	\N	topic
168	Where should functions be defined?	Anywhere randomly	Before or after main depending on language	Only inside loops	Only inside conditions	B	\N	medium	\N	general	4	\N	topic
169	What is the difference between parameter and argument?	No difference	Parameter is in definition, argument is actual value	Argument is in definition	Parameter is output	B	\N	hard	\N	general	4	\N	topic
170	What is recursion in functions?	Calling multiple functions	Function calling itself	Looping forever	Returning values	B	\N	hard	\N	general	4	\N	topic
183	What is an array?	A single variable that stores one value	A collection of elements stored under one name	A function	A loop	B	\N	easy	\N	general	9	\N	topic
184	What does a string store?	Only numbers	A sequence of characters	Only true or false	A list of arrays	B	\N	easy	\N	general	9	\N	topic
185	How are array elements usually accessed?	By color	By index	By password	By function name	B	\N	easy	\N	general	9	\N	topic
186	What is the first index in most programming languages?	0	1	-1	2	A	\N	easy	\N	general	9	\N	topic
187	Which of these is an example of a string?	25	true	"Hello"	3.14	C	\N	medium	\N	general	9	\N	topic
188	What happens if you store multiple numbers in one array?	They become a string	They are grouped together in one structure	They turn into functions	They are deleted	B	\N	medium	\N	general	9	\N	topic
189	What is the length of a string?	Its memory address	The number of characters in it	Its data type	Its first index	B	\N	medium	\N	general	9	\N	topic
190	Which operation joins two strings together?	Division	Concatenation	Indexing	Casting	B	\N	medium	\N	general	9	\N	topic
191	What is out-of-bounds access in arrays?	Accessing a valid index	Accessing an index that does not exist	Sorting an array	Printing an array	B	\N	hard	\N	general	9	\N	topic
192	Why are arrays useful?	They replace functions	They store multiple values efficiently	They avoid all errors	They only store text	B	\N	hard	\N	general	9	\N	topic
236	What happens during each recursive call?	Program restarts	Function executes with new parameters	Variables are deleted	Loops are created	B	\N	hard	\N	general	11	\N	topic
257	What is encapsulation?	Combining data and methods while controlling access	Repeating loops	Deleting objects	Running code faster	A	\N	hard	\N	general	12	\N	topic
258	What is inheritance?	Creating multiple variables	Allowing one class to acquire features of another	Stopping execution	Changing string length	B	\N	hard	\N	general	12	\N	topic
271	What is file handling?	Designing interfaces	Reading from and writing to files	Creating loops	Building classes only	B	\N	easy	\N	general	13	\N	topic
273	What does reading a file mean?	Deleting the file	Getting data from the file	Renaming the file	Compiling the file	B	\N	easy	\N	general	13	\N	topic
274	What does writing to a file mean?	Displaying file size	Saving data into the file	Closing the file	Opening a browser	B	\N	easy	\N	general	13	\N	topic
275	What should usually be done after finishing with a file?	Restart the program	Close the file	Delete all variables	Run a loop	B	\N	medium	\N	general	13	\N	topic
276	Which mode is commonly used to read a file?	read mode	delete mode	loop mode	class mode	A	\N	medium	\N	general	13	\N	topic
277	Which mode is commonly used to write to a file?	write mode	index mode	debug mode	return mode	A	\N	medium	\N	general	13	\N	topic
278	What may happen if a file does not exist when trying to open it?	Nothing ever happens	An error may occur	The program becomes a loop	The file is always created automatically	B	\N	medium	\N	general	13	\N	topic
535	What is searching in programming?	Sorting data	Finding a specific element	Deleting data	Creating arrays	B	\N	easy	\N	general	16	\N	topic
536	What is sorting?	Arranging data in a specific order	Finding data	Deleting data	Creating loops	A	\N	easy	\N	general	16	\N	topic
537	Which algorithm checks each element one by one?	Binary Search	Linear Search	Quick Sort	Merge Sort	B	\N	easy	\N	general	16	\N	topic
538	Which search algorithm requires sorted data?	Linear Search	Binary Search	Bubble Sort	Selection Sort	B	\N	easy	\N	general	16	\N	topic
539	What is the time complexity of linear search?	O(1)	O(log n)	O(n)	O(n log n)	C	\N	medium	\N	general	16	\N	topic
540	What is the time complexity of binary search?	O(n)	O(log n)	O(n^2)	O(1)	B	\N	medium	\N	general	16	\N	topic
541	Which sorting algorithm repeatedly swaps adjacent elements?	Selection Sort	Bubble Sort	Merge Sort	Quick Sort	B	\N	medium	\N	general	16	\N	topic
542	Which algorithm divides the array into halves?	Bubble Sort	Merge Sort	Selection Sort	Insertion Sort	B	\N	medium	\N	general	16	\N	topic
543	Which sorting algorithm has average time complexity O(n log n)?	Bubble Sort	Merge Sort	Selection Sort	Insertion Sort	B	\N	hard	\N	general	16	\N	topic
544	Which search algorithm is fastest on sorted data?	Linear Search	Binary Search	Depth First Search	Breadth First Search	B	\N	hard	\N	general	16	\N	topic
555	What is time complexity?	Memory usage	Measure of algorithm speed	Code length	Number of variables	B	\N	easy	\N	general	17	\N	topic
556	Which notation is used for time complexity?	O-notation	T-notation	S-notation	C-notation	A	\N	easy	\N	general	17	\N	topic
557	What does O(1) mean?	Linear time	Constant time	Logarithmic time	Quadratic time	B	\N	easy	\N	general	17	\N	topic
558	What does O(n) represent?	Constant time	Logarithmic time	Linear time	Quadratic time	C	\N	easy	\N	general	17	\N	topic
559	Which complexity is faster?	O(n)	O(log n)	O(n^2)	O(n log n)	B	\N	medium	\N	general	17	\N	topic
560	What does O(n^2) mean?	Constant time	Quadratic time	Linear time	Logarithmic time	B	\N	medium	\N	general	17	\N	topic
561	Which complexity is best for large data?	O(n^2)	O(n)	O(log n)	O(n log n)	C	\N	medium	\N	general	17	\N	topic
562	What happens when input size increases in O(n)?	Time decreases	Time stays constant	Time increases linearly	Time becomes zero	C	\N	medium	\N	general	17	\N	topic
563	Which algorithm has O(log n) complexity?	Binary Search	Linear Search	Bubble Sort	Selection Sort	A	\N	hard	\N	general	17	\N	topic
564	Which complexity grows fastest?	O(n)	O(log n)	O(n^2)	O(1)	C	\N	hard	\N	general	17	\N	topic
565	What is problem solving in programming?	Writing CSS	Finding solutions using code	Designing UI	Managing servers	B	\N	easy	\N	general	18	\N	topic
566	What is the first step in solving a problem?	Write code	Understand the problem	Test solution	Optimize code	B	\N	easy	\N	general	18	\N	topic
567	What is an algorithm?	A database	A step-by-step solution	A programming language	A UI design	B	\N	easy	\N	general	18	\N	topic
568	What helps break a problem into smaller parts?	Loops	Functions	Decomposition	Variables	C	\N	easy	\N	general	18	\N	topic
569	What is debugging?	Writing code	Fixing errors in code	Running programs	Compiling code	B	\N	medium	\N	general	18	\N	topic
570	Which approach solves problems step by step logically?	Random approach	Algorithmic thinking	Trial and error only	Copy-paste method	B	\N	medium	\N	general	18	\N	topic
571	What is pseudocode?	Real code	Informal description of algorithm	Database schema	Binary code	B	\N	medium	\N	general	18	\N	topic
572	What is optimization?	Making code longer	Improving efficiency	Adding UI	Removing functions	B	\N	medium	\N	general	18	\N	topic
573	Which technique avoids recalculating results?	Recursion	Memoization	Looping	Sorting	B	\N	hard	\N	general	18	\N	topic
574	Which approach divides problems into smaller subproblems?	Brute force	Divide and conquer	Random search	Linear scan	B	\N	hard	\N	general	18	\N	topic
575	What is memory in programming?	A UI component	Storage used to hold data	A network protocol	A CSS property	B	\N	easy	\N	general	19	\N	topic
576	What does performance refer to?	Design quality	Speed and efficiency of code	Color scheme	Database size	B	\N	easy	\N	general	19	\N	topic
577	Which memory type is temporary?	Hard disk	RAM	ROM	SSD	B	\N	easy	\N	general	19	\N	topic
578	Which factor affects performance?	Code efficiency	Font style	Image color	HTML tags	A	\N	easy	\N	general	19	\N	topic
579	What is memory allocation?	Freeing memory	Assigning memory to variables	Deleting data	Sorting data	B	\N	medium	\N	general	19	\N	topic
580	What is memory leak?	Extra memory usage without release	Low memory usage	Fast execution	Data backup	A	\N	medium	\N	general	19	\N	topic
581	What improves performance?	Efficient algorithms	More CSS	More images	Long code	A	\N	medium	\N	general	19	\N	topic
582	What is garbage collection?	Deleting files manually	Automatic memory cleanup	Sorting memory	Allocating memory	B	\N	medium	\N	general	19	\N	topic
583	Which structure can consume more memory?	Array	Linked List	Queue	Stack	B	\N	hard	\N	general	19	\N	topic
584	Which improves performance in repeated computations?	Loops only	Caching	More variables	Nested loops	B	\N	hard	\N	general	19	\N	topic
585	What is the output of 2 + 3 in programming?	5	23	6	Error	A	\N	easy	\N	general	20	\N	topic
586	Which loop repeats code multiple times?	if	for	switch	case	B	\N	easy	\N	general	20	\N	topic
587	Which structure is used for decision making?	loop	if statement	array	function	B	\N	easy	\N	general	20	\N	topic
588	What does a function do?	Stores data	Executes a block of code	Styles UI	Handles database	B	\N	easy	\N	general	20	\N	topic
589	What will be the result of 10 % 3?	1	3	0	10	A	\N	medium	\N	general	20	\N	topic
590	Which loop runs at least once?	for loop	while loop	do-while loop	if loop	C	\N	medium	\N	general	20	\N	topic
591	What is recursion?	A loop only	A function calling itself	Sorting data	Memory allocation	B	\N	medium	\N	general	20	\N	topic
592	What does break do in loops?	Continues loop	Exits loop	Repeats loop	Skips code	B	\N	medium	\N	general	20	\N	topic
593	Which problem-solving approach tries all possibilities?	Divide and conquer	Dynamic programming	Brute force	Greedy	C	\N	hard	\N	general	20	\N	topic
594	Which structure is best for tracking function calls?	Queue	Stack	Array	Tree	B	\N	hard	\N	general	20	\N	topic
320	What does CSS stand for?	Creative Style Sheets	Cascading Style Sheets	Computer Style System	Colorful Style Syntax	B	\N	easy	\N	general	23	\N	topic
321	Which CSS property is used to change text color?	font-color	text-color	color	foreground	C	\N	easy	\N	general	23	\N	topic
322	Which symbol is used to target a class in CSS?	#	.	*	@	B	\N	easy	\N	general	23	\N	topic
323	Which symbol is used to target an id in CSS?	.	#	:	&	B	\N	easy	\N	general	23	\N	topic
324	Which CSS property controls the size of text?	font-size	text-style	font-weight	size	A	\N	medium	\N	general	23	\N	topic
355	What does CSS stand for?	Creative Style Sheets	Cascading Style Sheets	Computer Style System	Colorful Style Syntax	B	\N	medium	\N	general	23	\N	topic
356	Which property is used to change text color?	font-color	text-color	color	background-color	C	\N	medium	\N	general	23	\N	topic
357	Which symbol is used to select a class in CSS?	#	.	*	@	B	\N	medium	\N	general	23	\N	topic
358	Which symbol is used to select an id in CSS?	.	#	*	:	B	\N	hard	\N	general	23	\N	topic
359	Which property is used to change the background color?	color	bgcolor	background-color	background-style	C	\N	hard	\N	general	23	\N	topic
325	What is the main goal of responsive web design?	Make websites colorful	Make websites work well on different screen sizes	Make websites load only on desktop	Add animations to pages	B	\N	easy	\N	general	24	\N	topic
326	Which CSS feature is commonly used to apply styles based on screen size?	Transitions	Media Queries	Variables	Gradients	B	\N	easy	\N	general	24	\N	topic
327	Which unit is often useful in responsive layouts?	px only	% and rem	cm	mm	B	\N	easy	\N	general	24	\N	topic
328	What does viewport refer to in web design?	The browser visible area	A CSS file	A JavaScript function	A database record	A	\N	easy	\N	general	24	\N	topic
329	Which layout tool is commonly used to build responsive page structures?	Flexbox	Console	Compiler	Terminal	A	\N	medium	\N	general	24	\N	topic
330	Which keyword is used to declare a variable in modern JavaScript?	int	var	let	define	C	\N	easy	\N	general	25	\N	topic
331	Which JavaScript data type is used for true or false values?	String	Boolean	Number	Object	B	\N	easy	\N	general	25	\N	topic
332	How do you write a single-line comment in JavaScript?	<!-- comment -->	// comment	# comment	/* comment */	B	\N	easy	\N	general	25	\N	topic
333	Which operator is used for strict equality in JavaScript?	==	=	===	!=	C	\N	easy	\N	general	25	\N	topic
334	Which function is commonly used to print something in the browser console?	print()	echo()	console.log()	write()	C	\N	medium	\N	general	25	\N	topic
335	What does DOM stand for?	Document Object Model	Data Object Management	Digital Ordinance Model	Desktop Object Method	A	\N	easy	\N	general	26	\N	topic
336	Which method is used to select an element by its id?	document.getElementById()	document.queryElements()	document.getClass()	document.selectId()	A	\N	easy	\N	general	26	\N	topic
337	Which property is used to change the text inside an element?	innerText	styleText	valueText	contentValue	A	\N	easy	\N	general	26	\N	topic
338	Which method is used to add an event listener to an element?	appendEvent()	listen()	addEventListener()	onClickAdd()	C	\N	easy	\N	general	26	\N	topic
339	Which method can select the first element matching a CSS selector?	getElementById()	querySelector()	getElementsByClassName()	matchSelector()	B	\N	medium	\N	general	26	\N	topic
340	What is React mainly used for?	Designing databases	Building user interfaces	Managing servers	Writing operating systems	B	\N	easy	\N	general	27	\N	topic
341	What is a React component?	A CSS property	A reusable piece of UI	A database table	A browser extension	B	\N	easy	\N	general	27	\N	topic
342	Which syntax extension is commonly used with React?	XML	JSX	SQL	YAML	B	\N	easy	\N	general	27	\N	topic
343	How is data passed from a parent component to a child component in React?	Hooks	Props	State only	Events	B	\N	easy	\N	general	27	\N	topic
344	Which hook is used to manage state in a functional React component?	useFetch	useState	useRoute	useClass	B	\N	medium	\N	general	27	\N	topic
406	Which property enables Flexbox on a container?	display: flex	flex: on	layout: flex	enable-flex	A	\N	easy	\N	general	28	\N	topic
407	Which direction is default in Flexbox?	column	row	grid	inline	B	\N	easy	\N	general	28	\N	topic
408	What does CSS Grid primarily control?	Text color	Layout structure	Fonts	Images	B	\N	easy	\N	general	28	\N	topic
409	Which property changes the direction of flex items?	flex-direction	flex-flow	direction	align-items	A	\N	medium	\N	general	28	\N	topic
410	Which property aligns items horizontally in Flexbox?	align-items	justify-content	text-align	flex-align	B	\N	medium	\N	general	28	\N	topic
411	Which property defines rows and columns in Grid?	grid-layout	grid-template	grid-template-columns	grid-structure	C	\N	medium	\N	general	28	\N	topic
412	Which unit is commonly used in Grid layouts?	fr	px	cm	deg	A	\N	medium	\N	general	28	\N	topic
413	Which property controls spacing between grid items?	gap	margin	padding	space	A	\N	hard	\N	general	28	\N	topic
414	Which Flexbox property aligns items vertically?	justify-content	align-items	flex-direction	flex-align	B	\N	hard	\N	general	28	\N	topic
415	Which keyword is used to declare a constant in JavaScript?	var	let	const	define	C	\N	easy	\N	general	29	\N	topic
416	Which keyword allows block-scoped variables?	var	let	const	Both let and const	D	\N	easy	\N	general	29	\N	topic
417	What does ES6 stand for?	ECMAScript 6	Easy Script 6	Extended Script 6	Engine Script 6	A	\N	easy	\N	general	29	\N	topic
418	Which symbol is used for arrow functions?	=>	->	==>	>>	A	\N	easy	\N	general	29	\N	topic
419	What does async keyword do in JavaScript?	Stops execution	Makes a function return a promise	Runs code faster	Declares a variable	B	\N	medium	\N	general	29	\N	topic
420	Which keyword is used to wait for a promise?	wait	async	await	hold	C	\N	medium	\N	general	29	\N	topic
421	Which method is used to handle resolved promises?	.catch()	.then()	.finally()	.resolve()	B	\N	medium	\N	general	29	\N	topic
422	What is destructuring used for?	Creating loops	Extracting values from arrays/objects	Declaring functions	Handling errors	B	\N	medium	\N	general	29	\N	topic
423	What will async function always return?	A number	A string	A promise	Undefined	C	\N	hard	\N	general	29	\N	topic
424	Which statement handles errors in async/await?	if/else	switch	try/catch	for loop	C	\N	hard	\N	general	29	\N	topic
425	What does API stand for?	Application Programming Interface	Advanced Program Interaction	Application Process Integration	Applied Programming Internet	A	\N	easy	\N	general	30	\N	topic
426	Which function is used to make HTTP requests in JavaScript?	request()	fetch()	get()	http()	B	\N	easy	\N	general	30	\N	topic
427	Which method is used to retrieve data from a server?	POST	PUT	GET	DELETE	C	\N	easy	\N	general	30	\N	topic
428	What format is commonly used when working with APIs?	XML only	JSON	HTML	CSV	B	\N	easy	\N	general	30	\N	topic
429	What does fetch() return?	Data directly	A promise	An object	A string	B	\N	medium	\N	general	30	\N	topic
430	Which method converts a response to JSON?	response.text()	response.parse()	response.json()	response.data()	C	\N	medium	\N	general	30	\N	topic
431	Which method is used to send data to a server?	GET	POST	READ	FETCH	B	\N	medium	\N	general	30	\N	topic
432	Which status code means success?	404	500	200	301	C	\N	medium	\N	general	30	\N	topic
433	Which block is used to handle fetch errors?	.then()	.catch()	.map()	.filter()	B	\N	hard	\N	general	30	\N	topic
434	What does CORS stand for?	Cross-Origin Resource Sharing	Cross Object Response System	Client-Origin Request Server	Common Object Resource Sharing	A	\N	hard	\N	general	30	\N	topic
435	What is a React component?	A CSS file	A reusable UI element	A database table	A browser plugin	B	\N	easy	\N	general	31	\N	topic
436	What are props in React?	Functions	Styles	Data passed to components	Events only	C	\N	easy	\N	general	31	\N	topic
437	Which type of component uses functions?	Class component	Functional component	Static component	Dynamic component	B	\N	easy	\N	general	31	\N	topic
438	Which keyword is used to define a function component?	class	function	define	component	B	\N	easy	\N	general	31	\N	topic
439	How are props accessed in a functional component?	this.props	props	state.props	component.props	B	\N	medium	\N	general	31	\N	topic
440	Which keyword is used to access props in class components?	this.props	props	self.props	component.props	A	\N	medium	\N	general	31	\N	topic
441	What happens if props change?	Component does not update	Component re-renders	App crashes	Nothing happens	B	\N	medium	\N	general	31	\N	topic
442	Props in React are:	Mutable	Read-only	Global	Private	B	\N	medium	\N	general	31	\N	topic
443	Which of the following is true about props?	They can be modified inside the component	They are immutable	They store state	They are functions only	B	\N	hard	\N	general	31	\N	topic
444	What is the main purpose of props?	Manage state	Style components	Pass data between components	Handle events	C	\N	hard	\N	general	31	\N	topic
445	What is state in React?	A CSS property	A built-in object that stores data	A database	A server response	B	\N	easy	\N	general	32	\N	topic
446	Which hook is used to manage state in functional components?	useEffect	useState	useFetch	useData	B	\N	easy	\N	general	32	\N	topic
447	Where is state usually used?	Inside components	In CSS files	In HTML only	In database	A	\N	easy	\N	general	32	\N	topic
448	State is mainly used to:	Store data that changes over time	Style components	Write HTML	Handle routing	A	\N	easy	\N	general	32	\N	topic
449	What happens when state changes?	Nothing happens	Component re-renders	App crashes	Data is deleted	B	\N	medium	\N	general	32	\N	topic
450	Which function is used to update state in useState?	setState	updateState	changeState	modifyState	A	\N	medium	\N	general	32	\N	topic
451	What is the initial value in useState?	Final value	Starting value	Random value	Null always	B	\N	medium	\N	general	32	\N	topic
452	State in React is:	Mutable directly	Immutable directly	Editable from anywhere	Global by default	B	\N	medium	\N	general	32	\N	topic
453	Why should state not be modified directly?	It causes errors in UI updates	It makes code faster	It improves performance	It simplifies code	A	\N	hard	\N	general	32	\N	topic
454	Which hook is used for side effects along with state?	useState	useEffect	useData	useRender	B	\N	hard	\N	general	32	\N	topic
455	What is React Router used for?	Managing state	Navigation between pages	Styling components	Handling APIs	B	\N	easy	\N	general	33	\N	topic
456	Which component is used to define routes?	<Router>	<Route>	<Switch>	<Nav>	B	\N	easy	\N	general	33	\N	topic
457	Which component is used for navigation links?	<Link>	<Navigate>	<Anchor>	<Href>	A	\N	easy	\N	general	33	\N	topic
458	React Router helps create:	Multiple databases	Single Page Applications	CSS files	APIs	B	\N	easy	\N	general	33	\N	topic
459	Which hook is used to navigate programmatically?	useRoute	useNavigate	useLink	usePath	B	\N	medium	\N	general	33	\N	topic
460	Which hook is used to access URL parameters?	useParams	useQuery	useURL	useLocationOnly	A	\N	medium	\N	general	33	\N	topic
461	Which component redirects to another route?	<Link>	<Redirect>	<Navigate>	<Route>	C	\N	medium	\N	general	33	\N	topic
462	Which prop defines the path of a route?	url	link	path	route	C	\N	medium	\N	general	33	\N	topic
463	Which hook provides information about the current URL?	useParams	useLocation	usePath	useHistoryOnly	B	\N	hard	\N	general	33	\N	topic
464	Which component wraps all routes in React Router v6?	<Switch>	<Routes>	<RouterSwitch>	<RouteWrapper>	B	\N	hard	\N	general	33	\N	topic
465	What is TypeScript?	A database language	A superset of JavaScript	A CSS framework	A browser	B	\N	easy	\N	general	34	\N	topic
466	What does TypeScript add to JavaScript?	Animations	Types	HTML elements	Database support	B	\N	easy	\N	general	34	\N	topic
467	Which file extension is used for TypeScript?	.js	.ts	.jsx	.json	B	\N	easy	\N	general	34	\N	topic
468	TypeScript code is converted to which language?	Python	Java	JavaScript	C++	C	\N	easy	\N	general	34	\N	topic
469	What keyword is used to define a type in TypeScript?	type	define	var	class	A	\N	medium	\N	general	34	\N	topic
470	Which keyword defines an interface?	interface	type	struct	object	A	\N	medium	\N	general	34	\N	topic
471	Which symbol is used to define type annotations?	:	=	->	=>	A	\N	medium	\N	general	34	\N	topic
472	What is the purpose of interfaces?	Styling	Defining structure of objects	Creating loops	Handling events	B	\N	medium	\N	general	34	\N	topic
473	What does the "any" type allow?	Strict typing	No type checking	Only numbers	Only strings	B	\N	hard	\N	general	34	\N	topic
474	Which feature ensures safer code in TypeScript?	Loose typing	Type checking	Dynamic variables	Inline CSS	B	\N	hard	\N	general	34	\N	topic
475	What is Next.js mainly used for?	Database management	Building React applications	Designing UI only	Writing CSS	B	\N	easy	\N	general	35	\N	topic
476	Next.js is built on top of which library?	Vue	Angular	React	Svelte	C	\N	easy	\N	general	35	\N	topic
477	Which feature does Next.js provide out of the box?	Routing	Manual linking only	No navigation	Static CSS only	A	\N	easy	\N	general	35	\N	topic
478	Which folder is commonly used for pages in Next.js?	components	pages	styles	public	B	\N	easy	\N	general	35	\N	topic
479	What is Server-Side Rendering (SSR)?	Rendering on the client	Rendering on the server before sending to client	Rendering using CSS	Rendering images only	B	\N	medium	\N	general	35	\N	topic
480	What is Static Site Generation (SSG)?	Dynamic pages	Pre-rendering pages at build time	Runtime rendering	Server-only rendering	B	\N	medium	\N	general	35	\N	topic
481	Which function is used for SSR in Next.js?	getStaticProps	getServerSideProps	fetchData	useEffect	B	\N	medium	\N	general	35	\N	topic
482	Which function is used for SSG in Next.js?	getStaticProps	getServerSideProps	useState	renderPage	A	\N	medium	\N	general	35	\N	topic
483	Which feature allows dynamic routing in Next.js?	Dynamic folders with []	Static paths only	Manual routing	No routing	A	\N	hard	\N	general	35	\N	topic
484	Which hook is used for client-side navigation in Next.js?	useState	useRouter	useEffect	useFetch	B	\N	hard	\N	general	35	\N	topic
485	What is the goal of performance optimization?	Make code longer	Improve speed and efficiency	Add more features	Remove UI	B	\N	easy	\N	general	36	\N	topic
486	Which tool helps measure website performance?	Chrome DevTools	Photoshop	Excel	Notepad	A	\N	easy	\N	general	36	\N	topic
487	What does lazy loading do?	Loads everything at once	Loads content when needed	Deletes data	Speeds database	B	\N	easy	\N	general	36	\N	topic
488	Which file type is usually smaller for images?	PNG	JPEG	BMP	TIFF	B	\N	easy	\N	general	36	\N	topic
489	What is code splitting?	Breaking code into smaller bundles	Deleting code	Writing CSS	Combining files	A	\N	medium	\N	general	36	\N	topic
490	Which technique reduces file size?	Minification	Expansion	Compilation only	Debugging	A	\N	medium	\N	general	36	\N	topic
491	What does caching do?	Deletes files	Stores data for faster access	Slows loading	Blocks requests	B	\N	medium	\N	general	36	\N	topic
492	Which tag helps defer JavaScript loading?	<script defer>	<script slow>	<script async-only>	<script delay>	A	\N	medium	\N	general	36	\N	topic
493	What is the purpose of using CDN?	Store database	Deliver content faster globally	Write code	Host backend	B	\N	hard	\N	general	36	\N	topic
494	Which metric measures time until content is visible?	FPS	FCP (First Contentful Paint)	CPU usage	RAM size	B	\N	hard	\N	general	36	\N	topic
495	What is web accessibility?	Making websites colorful	Making websites usable by everyone	Making websites faster only	Adding animations	B	\N	easy	\N	general	37	\N	topic
496	Who benefits from accessibility features?	Developers only	Users with disabilities	Designers only	Servers	B	\N	easy	\N	general	37	\N	topic
497	Which attribute provides alternative text for images?	src	href	alt	title	C	\N	easy	\N	general	37	\N	topic
498	Which HTML element improves navigation accessibility?	<div>	<nav>	<span>	<style>	B	\N	easy	\N	general	37	\N	topic
499	What does ARIA stand for?	Accessible Rich Internet Applications	Advanced Responsive Internet Apps	Automatic Rendering Interface API	Accessible Resource Integration Area	A	\N	medium	\N	general	37	\N	topic
500	Why is color contrast important?	For decoration	For readability	For animations	For layout only	B	\N	medium	\N	general	37	\N	topic
501	Which element is best for buttons?	<div>	<span>	<button>	<section>	C	\N	medium	\N	general	37	\N	topic
502	What is the purpose of labels in forms?	Styling	Accessibility and usability	Performance	Animations	B	\N	medium	\N	general	37	\N	topic
503	Which tool is commonly used to test accessibility?	Lighthouse	Photoshop	Excel	VS Code only	A	\N	hard	\N	general	37	\N	topic
504	What is the role of screen readers?	Improve design	Read content aloud for users	Write code	Manage databases	B	\N	hard	\N	general	37	\N	topic
505	What is testing in frontend development?	Writing UI only	Checking if code works correctly	Styling components	Deploying apps	B	\N	easy	\N	general	38	\N	topic
506	What is Vitest?	A CSS library	A testing framework	A database tool	A browser	B	\N	easy	\N	general	38	\N	topic
507	Which function is used to define a test?	test()	check()	verify()	run()	A	\N	easy	\N	general	38	\N	topic
508	What is the purpose of assertions?	Styling UI	Checking expected results	Creating components	Routing pages	B	\N	easy	\N	general	38	\N	topic
509	Which method checks equality in tests?	assert()	expect().toBe()	checkEqual()	verify()	B	\N	medium	\N	general	38	\N	topic
510	What does a unit test focus on?	Entire application	Single function or component	Database only	Server only	B	\N	medium	\N	general	38	\N	topic
511	Which command runs tests in most setups?	npm run test	npm start	node run	start test	A	\N	medium	\N	general	38	\N	topic
512	What is mocking in testing?	Deleting data	Simulating dependencies	Styling components	Rendering UI	B	\N	medium	\N	general	38	\N	topic
513	Which type of test checks interaction between components?	Unit test	Integration test	UI test	Manual test	B	\N	hard	\N	general	38	\N	topic
514	Why is testing important?	To increase code size	To ensure code reliability	To slow down apps	To remove features	B	\N	hard	\N	general	38	\N	topic
515	What are React patterns used for?	Writing SQL queries	Solving common UI design problems	Managing databases	Styling with CSS only	B	\N	easy	\N	general	39	\N	topic
516	Which pattern helps reuse component logic?	Loop pattern	Custom Hooks	Grid pattern	Fetch pattern	B	\N	easy	\N	general	39	\N	topic
517	What is a custom hook in React?	A CSS class	A reusable JavaScript function using hooks	A database model	A routing file	B	\N	easy	\N	general	39	\N	topic
518	Which pattern allows one component to pass content into another?	Props Children	Local Storage	Redux Store	Event Loop	A	\N	easy	\N	general	39	\N	topic
519	What is the purpose of the Render Props pattern?	Styling elements	Sharing code using a function prop	Fetching CSS	Managing files	B	\N	medium	\N	general	39	\N	topic
520	What does Higher-Order Component (HOC) mean?	A component that returns another component	A hook inside CSS	A routing feature	A state variable	A	\N	medium	\N	general	39	\N	topic
521	What is component composition in React?	Writing multiple CSS files	Combining components to build complex UIs	Using many databases	Creating loops	B	\N	medium	\N	general	39	\N	topic
522	Which prop is commonly used to pass nested content?	value	children	contentType	nested	B	\N	medium	\N	general	39	\N	topic
523	Why are custom hooks useful?	They replace JSX	They allow reuse of stateful logic	They style components automatically	They remove props	B	\N	hard	\N	general	39	\N	topic
524	Which pattern can make components harder to debug if overused?	HOC	Simple props	Plain HTML	Inline text	A	\N	hard	\N	general	39	\N	topic
595	What is backend development?	Designing UI	Working on server-side logic	Styling web pages	Creating animations	B	\N	easy	\N	general	40	\N	topic
596	Which part of the app handles data processing?	Frontend	Backend	CSS	HTML	B	\N	easy	\N	general	40	\N	topic
597	Where does backend code usually run?	Browser	Server	Mobile app	CSS file	B	\N	easy	\N	general	40	\N	topic
598	Which language can be used for backend?	HTML	CSS	JavaScript	Figma	C	\N	easy	\N	general	40	\N	topic
599	What is a server?	A design tool	A computer that provides services to clients	A CSS framework	A browser	B	\N	medium	\N	general	40	\N	topic
600	What does backend handle?	User interface only	Data, logic, and APIs	Fonts and colors	Images only	B	\N	medium	\N	general	40	\N	topic
601	Which component stores data in backend systems?	Frontend	Database	Browser	CSS	B	\N	medium	\N	general	40	\N	topic
602	What is an API?	A UI component	A way for systems to communicate	A database	A CSS file	B	\N	medium	\N	general	40	\N	topic
603	Which architecture separates frontend and backend?	Monolithic only	Client-server	Inline design	Static HTML	B	\N	hard	\N	general	40	\N	topic
604	What is scalability in backend?	Making UI bigger	Handling more users efficiently	Adding more CSS	Reducing code	B	\N	hard	\N	general	40	\N	topic
605	What is Node.js?	A database	A JavaScript runtime	A CSS framework	A browser	B	\N	easy	\N	general	41	\N	topic
606	Where does Node.js run?	Browser	Server	Database	Mobile app	B	\N	easy	\N	general	41	\N	topic
607	Which language is used in Node.js?	Python	JavaScript	Java	C++	B	\N	easy	\N	general	41	\N	topic
608	What is npm?	A programming language	Node package manager	A database tool	A browser	B	\N	easy	\N	general	41	\N	topic
609	Which method is used to import modules in Node.js (ES modules)?	require()	import	include()	use()	B	\N	medium	\N	general	41	\N	topic
610	What is the purpose of package.json?	Styling	Managing project dependencies	Database connection	UI rendering	B	\N	medium	\N	general	41	\N	topic
611	Which module is used to create a server in Node.js?	http	fs	path	url	A	\N	medium	\N	general	41	\N	topic
612	What is asynchronous code?	Code that runs line by line only	Code that runs without blocking execution	Code that deletes data	Code that styles UI	B	\N	medium	\N	general	41	\N	topic
613	Which concept allows Node.js to handle many requests efficiently?	Thread blocking	Event loop	Synchronous execution	CSS rendering	B	\N	hard	\N	general	41	\N	topic
614	Which module is used for file operations in Node.js?	http	fs	url	net	B	\N	hard	\N	general	41	\N	topic
615	What is Express.js?	A database	A Node.js framework	A CSS library	A browser	B	\N	easy	\N	general	42	\N	topic
616	Express.js is mainly used for?	Styling UI	Building web servers and APIs	Managing databases only	Creating animations	B	\N	easy	\N	general	42	\N	topic
617	Which method is used to handle GET requests?	app.post()	app.get()	app.put()	app.delete()	B	\N	easy	\N	general	42	\N	topic
618	Which object represents the request in Express?	req	res	app	server	A	\N	easy	\N	general	42	\N	topic
619	Which object is used to send responses?	req	res	app	router	B	\N	medium	\N	general	42	\N	topic
620	What does app.listen() do?	Stops server	Starts server	Deletes routes	Handles CSS	B	\N	medium	\N	general	42	\N	topic
621	Which middleware parses JSON data?	express.json()	app.json()	parse.json()	req.json()	A	\N	medium	\N	general	42	\N	topic
622	What is middleware in Express?	Database tool	Function that runs between request and response	UI component	Routing method	B	\N	medium	\N	general	42	\N	topic
623	Which method is used to define routes in Express?	app.route()	app.get()/post()	defineRoute()	createRoute()	B	\N	hard	\N	general	42	\N	topic
624	Which middleware is used for error handling?	next()	errorHandler()	app.use((err,...))	handleError()	C	\N	hard	\N	general	42	\N	topic
625	What does REST stand for?	Remote Execution State Transfer	Representational State Transfer	Rapid Server Transfer	Resource Execution Style Transfer	B	\N	easy	\N	general	43	\N	topic
626	What is a REST API?	A UI component	A way to communicate between client and server	A database	A CSS file	B	\N	easy	\N	general	43	\N	topic
627	Which HTTP method is used to get data?	POST	GET	PUT	DELETE	B	\N	easy	\N	general	43	\N	topic
628	Which HTTP method is used to create data?	GET	POST	DELETE	PATCH	B	\N	easy	\N	general	43	\N	topic
629	Which HTTP method is used to update data?	GET	POST	PUT	READ	C	\N	medium	\N	general	43	\N	topic
630	Which HTTP method is used to delete data?	POST	PUT	DELETE	GET	C	\N	medium	\N	general	43	\N	topic
631	What does stateless mean in REST?	Server stores client data	Each request is independent	Data is permanent	Only GET requests allowed	B	\N	medium	\N	general	43	\N	topic
632	Which format is commonly used in REST APIs?	XML only	JSON	HTML	TXT	B	\N	medium	\N	general	43	\N	topic
633	Which status code indicates resource created?	200	201	400	404	B	\N	hard	\N	general	43	\N	topic
634	Which principle ensures no session is stored on server?	Caching	Statelessness	Layering	Code reuse	B	\N	hard	\N	general	43	\N	topic
635	What is a database?	A UI component	A system to store and manage data	A CSS file	A browser tool	B	\N	easy	\N	general	44	\N	topic
636	Which type of database uses tables?	NoSQL	Relational database	Graph database	File system	B	\N	easy	\N	general	44	\N	topic
637	Which language is used to interact with databases?	HTML	CSS	SQL	JSX	C	\N	easy	\N	general	44	\N	topic
638	What is a table in a database?	A UI layout	A collection of rows and columns	A function	A server	B	\N	easy	\N	general	44	\N	topic
639	What is a primary key?	A duplicate value	A unique identifier for each record	A foreign value	A UI element	B	\N	medium	\N	general	44	\N	topic
640	What is a row in a table?	A column	A record	A function	A database	B	\N	medium	\N	general	44	\N	topic
641	What is a column in a table?	A record	A field/attribute	A loop	A query	B	\N	medium	\N	general	44	\N	topic
642	What does SQL stand for?	Structured Query Language	Simple Query Language	Standard Quick Language	System Query Logic	A	\N	medium	\N	general	44	\N	topic
643	What is normalization?	Adding duplicate data	Organizing data to reduce redundancy	Deleting tables	Formatting UI	B	\N	hard	\N	general	44	\N	topic
644	What is a foreign key?	A unique identifier	A link between two tables	A UI element	A loop	B	\N	hard	\N	general	44	\N	topic
645	What does CRUD stand for?	Create, Read, Update, Delete	Copy, Run, Upload, Download	Create, Remove, Use, Delete	Code, Read, Update, Debug	A	\N	easy	\N	general	45	\N	topic
646	Which operation is used to add new data?	Read	Update	Create	Delete	C	\N	easy	\N	general	45	\N	topic
647	Which operation retrieves data?	Create	Read	Delete	Update	B	\N	easy	\N	general	45	\N	topic
648	Which operation removes data?	Create	Read	Delete	Update	C	\N	easy	\N	general	45	\N	topic
649	Which SQL command is used to insert data?	SELECT	INSERT	UPDATE	DELETE	B	\N	medium	\N	general	45	\N	topic
650	Which SQL command retrieves data?	INSERT	SELECT	DELETE	UPDATE	B	\N	medium	\N	general	45	\N	topic
651	Which SQL command updates data?	SELECT	INSERT	UPDATE	DROP	C	\N	medium	\N	general	45	\N	topic
652	Which SQL command deletes data?	REMOVE	DELETE	DROP	CLEAR	B	\N	medium	\N	general	45	\N	topic
653	Which operation modifies existing data?	Create	Read	Update	Delete	C	\N	hard	\N	general	45	\N	topic
654	Which SQL command removes a table completely?	DELETE	DROP	REMOVE	CLEAR	B	\N	hard	\N	general	45	\N	topic
655	What is authentication?	Checking user identity	Styling UI	Managing database	Sending emails	A	\N	easy	\N	general	46	\N	topic
656	What is authorization?	Verifying identity	Granting access permissions	Creating UI	Deleting data	B	\N	easy	\N	general	46	\N	topic
657	Which is used to log in users?	Login form	CSS file	Database schema	API only	A	\N	easy	\N	general	46	\N	topic
658	Which data is commonly used for authentication?	Color	Username and password	Font size	Image URL	B	\N	easy	\N	general	46	\N	topic
659	What is a token in authentication?	A UI element	A secure key for user sessions	A database row	A CSS class	B	\N	medium	\N	general	46	\N	topic
660	Which method is commonly used for secure passwords?	Plain text	Hashing	Encoding only	Copying	B	\N	medium	\N	general	46	\N	topic
661	What is JWT?	Java Web Token	JSON Web Token	JavaScript Web Tool	JSON With Token	B	\N	medium	\N	general	46	\N	topic
662	Which process checks user permissions?	Authentication	Authorization	Rendering	Routing	B	\N	medium	\N	general	46	\N	topic
663	Why is hashing important for passwords?	To speed up login	To securely store passwords	To style UI	To delete data	B	\N	hard	\N	general	46	\N	topic
664	Which method ensures data is not easily reversible?	Encryption	Hashing	Encoding	Parsing	B	\N	hard	\N	general	46	\N	topic
665	What is middleware in backend?	A database	A function between request and response	A UI element	A CSS tool	B	\N	easy	\N	general	47	\N	topic
666	What is routing?	Styling pages	Handling different URLs	Managing database	Writing HTML	B	\N	easy	\N	general	47	\N	topic
667	Which method defines a route in Express?	app.route()	app.get()	route.create()	defineRoute()	B	\N	easy	\N	general	47	\N	topic
668	Middleware functions receive which parameters?	req only	res only	req, res, next	next only	C	\N	easy	\N	general	47	\N	topic
669	What does next() do in middleware?	Stops execution	Passes control to next middleware	Deletes data	Restarts server	B	\N	medium	\N	general	47	\N	topic
670	Which middleware handles JSON parsing?	express.json()	app.parse()	json.parse()	req.json()	A	\N	medium	\N	general	47	\N	topic
671	Which route handles POST requests?	app.get()	app.post()	app.delete()	app.put()	B	\N	medium	\N	general	47	\N	topic
672	Routing helps in:	Styling UI	Handling requests based on URL	Managing CSS	Rendering HTML only	B	\N	medium	\N	general	47	\N	topic
673	What happens if next() is not called in middleware?	Request continues	Request hangs or stops	Server crashes always	Nothing happens	B	\N	hard	\N	general	47	\N	topic
674	Which type of middleware handles errors?	Normal middleware	Error-handling middleware	Routing middleware	Static middleware	B	\N	hard	\N	general	47	\N	topic
675	What is database integration?	Styling UI	Connecting backend with database	Creating animations	Writing HTML	B	\N	easy	\N	general	48	\N	topic
676	Which tool is commonly used to connect Node.js with PostgreSQL?	pg	react	express	vite	A	\N	easy	\N	general	48	\N	topic
677	What is a query?	A UI element	A command to interact with database	A CSS rule	A function only	B	\N	easy	\N	general	48	\N	topic
678	Which operation retrieves data from database?	INSERT	SELECT	DELETE	UPDATE	B	\N	easy	\N	general	48	\N	topic
679	What does a database connection do?	Deletes data	Links app to database	Styles UI	Creates routes	B	\N	medium	\N	general	48	\N	topic
680	Which command inserts data into a table?	SELECT	INSERT	UPDATE	DELETE	B	\N	medium	\N	general	48	\N	topic
681	Which command updates existing data?	SELECT	UPDATE	DELETE	INSERT	B	\N	medium	\N	general	48	\N	topic
682	Which command deletes data?	REMOVE	DELETE	CLEAR	DROP	B	\N	medium	\N	general	48	\N	topic
683	What is connection pooling?	Deleting connections	Managing multiple database connections efficiently	Creating UI	Running queries once	B	\N	hard	\N	general	48	\N	topic
684	Why use prepared statements?	To style queries	To prevent SQL injection	To slow down queries	To store data	B	\N	hard	\N	general	48	\N	topic
685	What is error handling?	Styling UI	Managing and responding to errors	Creating database	Routing requests	B	\N	easy	\N	general	49	\N	topic
686	What is validation?	Checking input data	Deleting data	Styling forms	Creating APIs	A	\N	easy	\N	general	49	\N	topic
687	Which keyword is used for error handling in JavaScript?	if	try	loop	case	B	\N	easy	\N	general	49	\N	topic
688	Which block catches errors?	try	catch	finally	error	B	\N	easy	\N	general	49	\N	topic
689	What is input validation?	Formatting text	Ensuring user input is correct	Creating database	Handling CSS	B	\N	medium	\N	general	49	\N	topic
690	Which block always runs after try/catch?	catch	finally	throw	error	B	\N	medium	\N	general	49	\N	topic
691	What does throw do?	Ignore errors	Create custom error	Delete data	Restart app	B	\N	medium	\N	general	49	\N	topic
692	Which validation checks required fields?	Optional validation	Required validation	CSS validation	UI validation	B	\N	medium	\N	general	49	\N	topic
693	Why is validation important?	To slow app	To ensure correct data and security	To style UI	To create routes	B	\N	hard	\N	general	49	\N	topic
694	What happens if errors are not handled?	App becomes faster	App may crash	UI improves	Data increases	B	\N	hard	\N	general	49	\N	topic
695	What is file upload in web applications?	Styling UI	Sending files from client to server	Deleting files	Creating database	B	\N	easy	\N	general	50	\N	topic
696	Which type of files can be uploaded?	Images only	Text only	Any supported file type	Videos only	C	\N	easy	\N	general	50	\N	topic
697	Where are uploaded files stored?	Browser only	Server or cloud storage	CSS file	Database only	B	\N	easy	\N	general	50	\N	topic
698	Which library is commonly used for file uploads in Node.js?	multer	react	vite	axios	A	\N	easy	\N	general	50	\N	topic
699	What is file validation?	Deleting files	Checking file type and size	Styling files	Compressing files	B	\N	medium	\N	general	50	\N	topic
700	Why limit file size?	To slow server	To improve performance and security	To style UI	To store more data	B	\N	medium	\N	general	50	\N	topic
701	Which storage is used for scalable file storage?	Local disk only	Cloud storage	CSS files	HTML files	B	\N	medium	\N	general	50	\N	topic
702	Which format is common for image uploads?	.exe	.jpg	.bat	.sys	B	\N	medium	\N	general	50	\N	topic
703	Why is file upload security important?	To improve UI	To prevent malicious files	To speed code	To store CSS	B	\N	hard	\N	general	50	\N	topic
704	Which technique helps secure file uploads?	Skipping validation	File type checking	Deleting all files	Ignoring size limits	B	\N	hard	\N	general	50	\N	topic
705	What is API security?	Styling APIs	Protecting APIs from attacks	Creating UI	Managing database	B	\N	easy	\N	general	51	\N	topic
706	Which method is used to secure APIs?	Authentication	Animation	Styling	Routing	A	\N	easy	\N	general	51	\N	topic
707	What does HTTPS provide?	Speed only	Secure communication	Database access	UI design	B	\N	easy	\N	general	51	\N	topic
708	Which attack targets user input fields?	SQL Injection	CSS attack	UI bug	Animation bug	A	\N	easy	\N	general	51	\N	topic
719	What is load balancing?	Styling pages	Distributing traffic across servers	Deleting data	Handling CSS	B	\N	medium	\N	general	52	\N	topic
720	What is a microservice?	Small UI component	Independent service in a system	Database table	CSS file	B	\N	medium	\N	general	52	\N	topic
721	Which architecture uses one large system?	Microservices	Monolithic	Client-server	Layered	B	\N	medium	\N	general	52	\N	topic
722	What improves system availability?	More CSS	Redundancy	Long code	Inline styles	B	\N	medium	\N	general	52	\N	topic
723	What is horizontal scaling?	Adding more servers	Adding more CPU to one server	Deleting servers	Reducing load	A	\N	hard	\N	general	52	\N	topic
724	Which concept ensures system remains operational during failure?	Caching	Fault tolerance	Styling	Routing	B	\N	hard	\N	general	52	\N	topic
725	What is caching?	Deleting data	Storing data for faster access	Styling UI	Creating routes	B	\N	easy	\N	general	53	\N	topic
726	Why is caching used?	To slow system	To improve performance	To add CSS	To delete data	B	\N	easy	\N	general	53	\N	topic
727	Where can caching be used?	Server only	Client only	Both client and server	Database only	C	\N	easy	\N	general	53	\N	topic
728	Which type of cache is in browser?	Server cache	Client cache	Database cache	API cache	B	\N	easy	\N	general	53	\N	topic
729	What is a cache hit?	Cache failure	Data found in cache	Data deleted	New request	B	\N	medium	\N	general	53	\N	topic
730	What is a cache miss?	Data found in cache	Data not found in cache	Data deleted	Server crash	B	\N	medium	\N	general	53	\N	topic
731	Which tool is used for caching in backend?	Redis	React	CSS	HTML	A	\N	medium	\N	general	53	\N	topic
732	What improves performance in repeated requests?	More CSS	Caching	Long code	Deleting data	B	\N	medium	\N	general	53	\N	topic
733	What is cache invalidation?	Deleting unused cache	Adding new cache	Styling cache	Saving UI	A	\N	hard	\N	general	53	\N	topic
734	Which caching strategy stores data before it is requested?	Cache aside	Write-through	Lazy loading	Manual cache	B	\N	hard	\N	general	53	\N	topic
735	What is a microservice?	A UI component	A small independent service	A database table	A CSS file	B	\N	easy	\N	general	54	\N	topic
736	Microservices architecture consists of?	One large system	Multiple small services	Only frontend	Only database	B	\N	easy	\N	general	54	\N	topic
737	Each microservice is usually?	Dependent on all others	Independent	UI-only	Static	B	\N	easy	\N	general	54	\N	topic
739	What is the main advantage of microservices?	Hard to scale	Scalability and flexibility	Slower performance	More bugs	B	\N	medium	\N	general	54	\N	topic
740	Which architecture is opposite of microservices?	Client-server	Monolithic	Layered	Cloud	B	\N	medium	\N	general	54	\N	topic
741	What is service isolation?	Sharing all data	Independent execution of services	UI rendering	CSS styling	B	\N	medium	\N	general	54	\N	topic
742	Which tool is often used with microservices?	Docker	Photoshop	Excel	Figma	A	\N	medium	\N	general	54	\N	topic
743	What is a challenge of microservices?	Simple deployment	Complex communication	Easy debugging always	No scaling needed	B	\N	hard	\N	general	54	\N	topic
744	Which concept helps manage microservices communication?	Orchestration	Styling	Animation	Routing only	A	\N	hard	\N	general	54	\N	topic
755	What are real-time applications?	Apps that work offline only	Apps that update instantly	Apps for design only	Apps without server	B	\N	easy	\N	general	55	\N	topic
756	Which example is a real-time app?	Calculator	Chat application	Text editor	Image viewer	B	\N	easy	\N	general	55	\N	topic
757	Which technology enables real-time communication?	HTTP only	WebSockets	CSS	HTML	B	\N	easy	\N	general	55	\N	topic
758	Real-time apps require?	Slow updates	Instant data exchange	No server	Static pages	B	\N	easy	\N	general	55	\N	topic
759	What is WebSocket?	A database	Protocol for real-time communication	A CSS tool	A UI library	B	\N	medium	\N	general	55	\N	topic
760	Which library is used for real-time apps in Node.js?	socket.io	react	vite	axios	A	\N	medium	\N	general	55	\N	topic
761	What is bidirectional communication?	One-way data flow	Two-way data flow	No data flow	Static flow	B	\N	medium	\N	general	55	\N	topic
762	Which protocol is used in WebSockets?	ws:// or wss://	http://	ftp://	file://	A	\N	medium	\N	general	55	\N	topic
763	What is the advantage of WebSockets over HTTP?	Slower communication	Persistent connection	More CSS	No server needed	B	\N	hard	\N	general	55	\N	topic
764	Which feature ensures continuous connection in real-time apps?	Polling	Persistent connection	Static loading	CSS rendering	B	\N	hard	\N	general	55	\N	topic
765	What is API testing?	Styling UI	Testing API functionality	Creating database	Writing HTML	B	\N	easy	\N	general	56	\N	topic
766	Which tool is used for API testing?	Postman	Photoshop	Figma	Excel	A	\N	easy	\N	general	56	\N	topic
767	What does testing ensure?	More CSS	Correct functionality	More UI	More bugs	B	\N	easy	\N	general	56	\N	topic
768	Which method tests retrieving data?	POST	GET	DELETE	PUT	B	\N	easy	\N	general	56	\N	topic
769	What is a test case?	A CSS rule	A scenario to test functionality	A UI component	A database table	B	\N	medium	\N	general	56	\N	topic
770	Which status code means success?	404	500	200	301	C	\N	medium	\N	general	56	\N	topic
771	Which method tests data creation?	GET	POST	DELETE	READ	B	\N	medium	\N	general	56	\N	topic
772	What is automated testing?	Manual testing	Testing using scripts/tools	UI testing only	CSS testing	B	\N	medium	\N	general	56	\N	topic
773	Which type of testing checks API endpoints together?	Unit testing	Integration testing	UI testing	Manual testing	B	\N	hard	\N	general	56	\N	topic
774	Why is API testing important?	To slow system	To ensure reliability and correctness	To add CSS	To create UI	B	\N	hard	\N	general	56	\N	topic
775	What is deployment?	Writing code	Making app available to users	Styling UI	Creating database	B	\N	easy	\N	general	57	\N	topic
776	What is DevOps?	Designing UI	Combining development and operations	Writing CSS	Creating animations	B	\N	easy	\N	general	57	\N	topic
777	Where are apps deployed?	Local machine only	Servers or cloud	CSS files	Browser only	B	\N	easy	\N	general	57	\N	topic
778	Which platform can host apps?	Heroku	Photoshop	Figma	Excel	A	\N	easy	\N	general	57	\N	topic
779	What is CI/CD?	Continuous Integration and Continuous Deployment	Code Improvement Cycle	Client Interface Control	Continuous Internet Connection	A	\N	medium	\N	general	57	\N	topic
780	What is version control used for?	Styling UI	Tracking code changes	Creating database	Handling CSS	B	\N	medium	\N	general	57	\N	topic
781	Which tool is used for version control?	Git	Photoshop	Excel	Figma	A	\N	medium	\N	general	57	\N	topic
782	What is a build process?	Deleting code	Preparing app for deployment	Styling UI	Handling routes	B	\N	medium	\N	general	57	\N	topic
783	What is containerization?	Styling UI	Packaging app with dependencies	Deleting data	Creating routes	B	\N	hard	\N	general	57	\N	topic
784	Which tool is used for containerization?	Docker	React	CSS	HTML	A	\N	hard	\N	general	57	\N	topic
785	What is a database?	A UI component	A system to store and manage data	A CSS file	A browser tool	B	\N	easy	\N	general	58	\N	topic
786	Why are databases used?	To style UI	To organize and store data	To create animations	To write HTML	B	\N	easy	\N	general	58	\N	topic
787	Which type of database uses tables?	NoSQL	Relational database	Graph database	File system	B	\N	easy	\N	general	58	\N	topic
788	Which language is used to interact with databases?	HTML	CSS	SQL	JSX	C	\N	easy	\N	general	58	\N	topic
789	What is a record in a database?	A column	A row	A table	A query	B	\N	medium	\N	general	58	\N	topic
790	What is a field in a database?	A row	A column	A table	A database	B	\N	medium	\N	general	58	\N	topic
791	Which database stores data in documents?	Relational DB	NoSQL DB	Table DB	Column DB	B	\N	medium	\N	general	58	\N	topic
792	Which system manages databases?	DBMS	HTML	CSS	React	A	\N	medium	\N	general	58	\N	topic
793	What is ACID in databases?	A UI design method	Properties for reliable transactions	A CSS feature	A query type	B	\N	hard	\N	general	58	\N	topic
794	Which type of database is best for structured data?	NoSQL	Relational database	File system	Graph database	B	\N	hard	\N	general	58	\N	topic
795	What is a table in a database?	A UI layout	A collection of rows and columns	A function	A server	B	\N	easy	\N	general	59	\N	topic
796	What is a row in a table?	A column	A record	A query	A database	B	\N	easy	\N	general	59	\N	topic
797	What is a column in a table?	A record	A field	A database	A function	B	\N	easy	\N	general	59	\N	topic
798	What does a table store?	Functions	Data	CSS	Images	B	\N	easy	\N	general	59	\N	topic
799	What is a primary key?	Duplicate value	Unique identifier for a record	A column name	A query	B	\N	medium	\N	general	59	\N	topic
800	Can a table have multiple rows?	No	Yes	Only one	Depends on UI	B	\N	medium	\N	general	59	\N	topic
801	Which part defines the structure of a table?	Rows	Columns	Records	Queries	B	\N	medium	\N	general	59	\N	topic
802	Which constraint ensures uniqueness?	NULL	PRIMARY KEY	FOREIGN KEY	DEFAULT	B	\N	medium	\N	general	59	\N	topic
803	What happens if two rows have same primary key?	Allowed	Error occurs	Data is merged	Nothing happens	B	\N	hard	\N	general	59	\N	topic
804	Which constraint links tables together?	PRIMARY KEY	FOREIGN KEY	UNIQUE	NOT NULL	B	\N	hard	\N	general	59	\N	topic
805	Which SQL command is used to retrieve data?	INSERT	SELECT	UPDATE	DELETE	B	\N	easy	\N	general	60	\N	topic
806	Which SQL command is used to add data?	SELECT	INSERT	UPDATE	DELETE	B	\N	easy	\N	general	60	\N	topic
807	Which SQL command updates data?	INSERT	SELECT	UPDATE	DROP	C	\N	easy	\N	general	60	\N	topic
808	Which SQL command deletes data?	REMOVE	DELETE	DROP	CLEAR	B	\N	easy	\N	general	60	\N	topic
809	Which clause is used to filter data?	ORDER BY	WHERE	GROUP BY	SELECT	B	\N	medium	\N	general	60	\N	topic
810	Which clause sorts results?	WHERE	ORDER BY	GROUP BY	FILTER	B	\N	medium	\N	general	60	\N	topic
811	Which clause groups data?	ORDER BY	GROUP BY	WHERE	JOIN	B	\N	medium	\N	general	60	\N	topic
812	Which keyword selects all columns?	*	ALL	COLUMNS	SELECT ALL	A	\N	medium	\N	general	60	\N	topic
813	Which clause is used after GROUP BY to filter groups?	WHERE	HAVING	ORDER BY	LIMIT	B	\N	hard	\N	general	60	\N	topic
814	What does LIMIT do in SQL?	Sort data	Restrict number of results	Delete data	Update rows	B	\N	hard	\N	general	60	\N	topic
815	Which clause filters rows in SQL?	ORDER BY	WHERE	GROUP BY	JOIN	B	\N	easy	\N	general	61	\N	topic
816	Which clause sorts results?	WHERE	ORDER BY	GROUP BY	FILTER	B	\N	easy	\N	general	61	\N	topic
817	Which keyword selects all rows?	*	ALL	SELECT ALL	COLUMNS	A	\N	easy	\N	general	61	\N	topic
818	Which operator checks equality?	=	==	!=	>=	A	\N	easy	\N	general	61	\N	topic
819	Which operator selects values within a range?	LIKE	IN	BETWEEN	IS	C	\N	medium	\N	general	61	\N	topic
820	Which keyword searches for patterns?	BETWEEN	LIKE	IN	WHERE	B	\N	medium	\N	general	61	\N	topic
821	Which keyword checks multiple values?	BETWEEN	IN	LIKE	ORDER	B	\N	medium	\N	general	61	\N	topic
822	Which keyword checks for NULL values?	IS NULL	NULL =	== NULL	CHECK NULL	A	\N	medium	\N	general	61	\N	topic
823	Which clause sorts data in descending order?	ORDER BY DESC	ORDER BY ASC	SORT DESC	DESC ONLY	A	\N	hard	\N	general	61	\N	topic
824	Which clause is used to limit results after sorting?	WHERE	LIMIT	GROUP BY	HAVING	B	\N	hard	\N	general	61	\N	topic
825	What is a primary key?	Duplicate value	Unique identifier for a record	A UI element	A query	B	\N	easy	\N	general	62	\N	topic
826	Can a primary key be NULL?	Yes	No	Sometimes	Depends on UI	B	\N	easy	\N	general	62	\N	topic
827	What is a foreign key?	Unique identifier	Link between tables	A UI component	A function	B	\N	easy	\N	general	62	\N	topic
828	What does a foreign key reference?	Same table always	Another table primary key	CSS file	HTML page	B	\N	easy	\N	general	62	\N	topic
829	What is a relationship in databases?	Styling tables	Connection between tables	Deleting data	Sorting data	B	\N	medium	\N	general	62	\N	topic
830	Which relationship is one-to-many?	One row to one row	One row to many rows	Many rows to one row	No relation	B	\N	medium	\N	general	62	\N	topic
831	Which relationship is many-to-many?	One row to one row	One row to many rows	Multiple rows linked together	No relation	C	\N	medium	\N	general	62	\N	topic
832	What ensures referential integrity?	Primary key only	Foreign key constraints	UI validation	CSS rules	B	\N	medium	\N	general	62	\N	topic
833	What happens if foreign key constraint is violated?	Data is inserted	Error occurs	Data is ignored	Nothing happens	B	\N	hard	\N	general	62	\N	topic
834	Which action deletes related rows automatically?	ON DELETE CASCADE	ON DELETE IGNORE	ON DELETE SKIP	ON DELETE NONE	A	\N	hard	\N	general	62	\N	topic
835	What is PostgreSQL?	A programming language	A relational database system	A CSS framework	A browser	B	\N	easy	\N	general	63	\N	topic
836	PostgreSQL stores data in?	Files only	Tables	Images	Functions only	B	\N	easy	\N	general	63	\N	topic
838	PostgreSQL is an example of?	NoSQL database	Relational database	Graph database	File system	B	\N	easy	\N	general	63	\N	topic
839	Which command creates a table in PostgreSQL?	MAKE TABLE	CREATE TABLE	NEW TABLE	ADD TABLE	B	\N	medium	\N	general	63	\N	topic
840	Which command removes a table?	DELETE TABLE	DROP TABLE	REMOVE TABLE	CLEAR TABLE	B	\N	medium	\N	general	63	\N	topic
841	Which command modifies a table structure?	UPDATE TABLE	ALTER TABLE	CHANGE TABLE	MODIFY TABLE	B	\N	medium	\N	general	63	\N	topic
842	Which command inserts data?	ADD	INSERT	PUT	CREATE	B	\N	medium	\N	general	63	\N	topic
843	Which feature makes PostgreSQL reliable?	No constraints	ACID compliance	No transactions	Static tables	B	\N	hard	\N	general	63	\N	topic
844	Which command retrieves data?	GET	SELECT	FETCH	READ	B	\N	hard	\N	general	63	\N	topic
845	What is a JOIN in SQL?	Deleting tables	Combining data from multiple tables	Creating UI	Sorting data	B	\N	easy	\N	general	64	\N	topic
846	Which JOIN returns matching records from both tables?	LEFT JOIN	RIGHT JOIN	INNER JOIN	FULL JOIN	C	\N	easy	\N	general	64	\N	topic
847	Which JOIN returns all records from left table?	INNER JOIN	LEFT JOIN	RIGHT JOIN	FULL JOIN	B	\N	easy	\N	general	64	\N	topic
848	Which JOIN returns all records from right table?	INNER JOIN	LEFT JOIN	RIGHT JOIN	FULL JOIN	C	\N	easy	\N	general	64	\N	topic
849	Which JOIN returns all records from both tables?	INNER JOIN	LEFT JOIN	RIGHT JOIN	FULL JOIN	D	\N	medium	\N	general	64	\N	topic
850	Which clause is used with JOIN?	WHERE only	ON	ORDER BY	GROUP BY	B	\N	medium	\N	general	64	\N	topic
851	What does INNER JOIN do?	Returns unmatched rows	Returns matching rows only	Deletes data	Creates tables	B	\N	medium	\N	general	64	\N	topic
852	Which JOIN keeps unmatched rows as NULL?	INNER JOIN	LEFT JOIN	CROSS JOIN	SELF JOIN	B	\N	medium	\N	general	64	\N	topic
853	What is a CROSS JOIN?	Join with condition	Cartesian product of tables	Join on keys only	Filtering join	B	\N	hard	\N	general	64	\N	topic
854	Which JOIN combines a table with itself?	INNER JOIN	SELF JOIN	LEFT JOIN	FULL JOIN	B	\N	hard	\N	general	64	\N	topic
855	What is an aggregate function?	A UI function	Function that performs calculation on multiple rows	A CSS rule	A routing method	B	\N	easy	\N	general	65	\N	topic
856	Which function counts rows?	SUM()	COUNT()	AVG()	MAX()	B	\N	easy	\N	general	65	\N	topic
857	Which function calculates total?	COUNT()	SUM()	AVG()	MIN()	B	\N	easy	\N	general	65	\N	topic
858	Which function finds average?	AVG()	SUM()	COUNT()	MAX()	A	\N	easy	\N	general	65	\N	topic
859	Which function finds maximum value?	MIN()	MAX()	SUM()	AVG()	B	\N	medium	\N	general	65	\N	topic
860	Which function finds minimum value?	MIN()	MAX()	COUNT()	SUM()	A	\N	medium	\N	general	65	\N	topic
861	Which clause groups rows?	ORDER BY	GROUP BY	WHERE	JOIN	B	\N	medium	\N	general	65	\N	topic
862	Which clause filters grouped results?	WHERE	HAVING	ORDER BY	LIMIT	B	\N	medium	\N	general	65	\N	topic
863	Which clause is used before GROUP BY?	ORDER BY	WHERE	HAVING	LIMIT	B	\N	hard	\N	general	65	\N	topic
864	What does COUNT(*) count?	Columns only	All rows	Only numbers	Only NULLs	B	\N	hard	\N	general	65	\N	topic
865	What is database design?	Styling UI	Planning structure of database	Writing CSS	Creating animations	B	\N	easy	\N	general	66	\N	topic
866	What is a schema?	A CSS file	Structure of database	A function	A query	B	\N	easy	\N	general	66	\N	topic
867	What is normalization used for?	Adding duplicates	Reducing redundancy	Styling tables	Deleting data	B	\N	easy	\N	general	66	\N	topic
868	Which component defines relationships?	CSS	Tables	Keys	Images	C	\N	easy	\N	general	66	\N	topic
869	What is redundancy?	Unique data	Duplicate data	Sorted data	Deleted data	B	\N	medium	\N	general	66	\N	topic
870	Which normal form removes repeating groups?	1NF	2NF	3NF	BCNF	A	\N	medium	\N	general	66	\N	topic
871	Which design improves data consistency?	Denormalization	Normalization	Duplication	Caching	B	\N	medium	\N	general	66	\N	topic
872	What is entity in database?	A UI component	An object/table	A function	A route	B	\N	medium	\N	general	66	\N	topic
873	Which normal form removes partial dependency?	1NF	2NF	3NF	4NF	B	\N	hard	\N	general	66	\N	topic
874	Which normal form removes transitive dependency?	1NF	2NF	3NF	BCNF	C	\N	hard	\N	general	66	\N	topic
875	What is a constraint in a database?	A UI element	A rule applied to data	A CSS style	A function	B	\N	easy	\N	general	67	\N	topic
876	Which constraint ensures unique values?	NOT NULL	UNIQUE	DEFAULT	CHECK	B	\N	easy	\N	general	67	\N	topic
877	Which constraint prevents NULL values?	UNIQUE	NOT NULL	PRIMARY KEY	CHECK	B	\N	easy	\N	general	67	\N	topic
878	Which constraint defines a unique identifier?	FOREIGN KEY	PRIMARY KEY	CHECK	DEFAULT	B	\N	easy	\N	general	67	\N	topic
879	Which constraint links tables together?	PRIMARY KEY	FOREIGN KEY	UNIQUE	CHECK	B	\N	medium	\N	general	67	\N	topic
880	What does DEFAULT constraint do?	Deletes data	Sets default value	Creates table	Sorts data	B	\N	medium	\N	general	67	\N	topic
881	What does CHECK constraint do?	Validates data condition	Deletes rows	Sorts data	Joins tables	A	\N	medium	\N	general	67	\N	topic
882	What ensures data integrity?	Constraints	CSS	UI design	Routing	A	\N	medium	\N	general	67	\N	topic
883	What happens if constraint is violated?	Data is inserted	Error occurs	Data is ignored	Nothing happens	B	\N	hard	\N	general	67	\N	topic
884	Which constraint enforces referential integrity?	PRIMARY KEY	FOREIGN KEY	UNIQUE	CHECK	B	\N	hard	\N	general	67	\N	topic
885	What is an index in a database?	A UI component	A structure to speed up queries	A CSS file	A table row	B	\N	easy	\N	general	68	\N	topic
886	Why are indexes used?	To slow down queries	To improve query performance	To delete data	To style UI	B	\N	easy	\N	general	68	\N	topic
887	Indexes help in?	Faster data retrieval	Slower queries	UI design	CSS styling	A	\N	easy	\N	general	68	\N	topic
888	Which operation benefits most from indexes?	Searching	Deleting UI	Styling	Rendering HTML	A	\N	easy	\N	general	68	\N	topic
889	What is the downside of indexes?	Faster queries always	Extra storage usage	Better UI	No effect	B	\N	medium	\N	general	68	\N	topic
890	Which queries use indexes effectively?	SELECT	INSERT only	DELETE only	CSS queries	A	\N	medium	\N	general	68	\N	topic
891	What is query performance?	UI speed	Efficiency of database queries	CSS rendering	Image loading	B	\N	medium	\N	general	68	\N	topic
892	Which structure helps in indexing?	B-tree	Array only	Stack	Queue	A	\N	medium	\N	general	68	\N	topic
893	What happens if too many indexes are created?	Faster inserts	Slower writes	No effect	Better UI	B	\N	hard	\N	general	68	\N	topic
894	Which operation is slowed by indexes?	SELECT	INSERT	READ	SEARCH	B	\N	hard	\N	general	68	\N	topic
895	What is a transaction in a database?	A UI action	A group of operations executed together	A CSS rule	A query only	B	\N	easy	\N	general	69	\N	topic
896	What does ACID stand for?	Access, Control, Input, Data	Atomicity, Consistency, Isolation, Durability	Application, Code, Integration, Data	Async, Code, Input, Data	B	\N	easy	\N	general	69	\N	topic
897	Which ACID property ensures all or nothing?	Consistency	Isolation	Atomicity	Durability	C	\N	easy	\N	general	69	\N	topic
898	Which ACID property ensures data is saved permanently?	Atomicity	Durability	Consistency	Isolation	B	\N	easy	\N	general	69	\N	topic
899	What is COMMIT?	Cancel transaction	Save changes permanently	Rollback changes	Delete data	B	\N	medium	\N	general	69	\N	topic
900	What is ROLLBACK?	Save changes	Undo changes	Delete tables	Insert data	B	\N	medium	\N	general	69	\N	topic
901	Which ACID property ensures valid state?	Consistency	Isolation	Atomicity	Durability	A	\N	medium	\N	general	69	\N	topic
902	Which ACID property prevents interference between transactions?	Atomicity	Isolation	Durability	Consistency	B	\N	medium	\N	general	69	\N	topic
903	What happens if a transaction fails?	Partial changes saved	All changes rolled back	Data ignored	Nothing happens	B	\N	hard	\N	general	69	\N	topic
904	Which operation finalizes a transaction?	ROLLBACK	COMMIT	DELETE	UPDATE	B	\N	hard	\N	general	69	\N	topic
905	What is a subquery?	A UI component	A query inside another query	A CSS rule	A table	B	\N	easy	\N	general	70	\N	topic
906	Which clause is used to filter data?	GROUP BY	WHERE	ORDER BY	JOIN	B	\N	easy	\N	general	70	\N	topic
907	Which keyword combines results from two queries?	JOIN	UNION	GROUP	SELECT	B	\N	easy	\N	general	70	\N	topic
908	Which clause sorts results?	WHERE	ORDER BY	GROUP BY	JOIN	B	\N	easy	\N	general	70	\N	topic
909	What does UNION do?	Deletes data	Combines results of queries	Sorts data	Groups data	B	\N	medium	\N	general	70	\N	topic
910	What does DISTINCT do?	Removes duplicates	Adds duplicates	Deletes rows	Sorts columns	A	\N	medium	\N	general	70	\N	topic
911	Which clause groups rows?	ORDER BY	GROUP BY	WHERE	JOIN	B	\N	medium	\N	general	70	\N	topic
912	Which clause filters grouped results?	WHERE	HAVING	ORDER BY	LIMIT	B	\N	medium	\N	general	70	\N	topic
913	Which query runs first in nested queries?	Outer query	Inner subquery	Both together	Random	B	\N	hard	\N	general	70	\N	topic
914	Which keyword removes duplicate rows in UNION?	UNION ALL	UNION	JOIN	GROUP	B	\N	hard	\N	general	70	\N	topic
915	What is query optimization?	Styling UI	Improving query performance	Deleting data	Creating tables	B	\N	easy	\N	general	71	\N	topic
916	Why optimize queries?	To slow system	To improve performance	To add CSS	To delete tables	B	\N	easy	\N	general	71	\N	topic
917	Which tool helps optimize queries?	Index	CSS	HTML	React	A	\N	easy	\N	general	71	\N	topic
918	Which operation benefits from optimization?	SELECT	CSS styling	UI rendering	Animation	A	\N	easy	\N	general	71	\N	topic
919	What is a slow query?	Fast query	Query that takes long time	UI issue	CSS error	B	\N	medium	\N	general	71	\N	topic
920	Which clause should be used carefully for performance?	SELECT	WHERE	ORDER BY	LIMIT	C	\N	medium	\N	general	71	\N	topic
921	Which technique reduces data scanned?	SELECT *	Filtering with WHERE	Sorting only	Grouping only	B	\N	medium	\N	general	71	\N	topic
922	Which improves performance in joins?	Indexes	CSS	HTML	Images	A	\N	medium	\N	general	71	\N	topic
923	Which practice improves query speed?	Selecting all columns	Using indexes	Ignoring filters	Adding CSS	B	\N	hard	\N	general	71	\N	topic
924	Which operation can slow queries if overused?	Indexing	JOIN	WHERE	LIMIT	B	\N	hard	\N	general	71	\N	topic
925	What is a stored procedure?	A UI component	A pre-written SQL code block	A CSS file	A table	B	\N	easy	\N	general	72	\N	topic
926	Where are stored procedures stored?	Frontend	Database	Browser	CSS file	B	\N	easy	\N	general	72	\N	topic
927	What is a function in SQL?	A UI element	Reusable code that returns a value	A CSS rule	A table row	B	\N	easy	\N	general	72	\N	topic
928	Which one returns a value?	Stored procedure	Function	Table	View	B	\N	easy	\N	general	72	\N	topic
929	What is the benefit of stored procedures?	Faster execution and reuse	More CSS	UI design	Slower queries	A	\N	medium	\N	general	72	\N	topic
930	Which statement executes a stored procedure?	RUN	CALL	EXECUTE	Both CALL and EXECUTE	D	\N	medium	\N	general	72	\N	topic
931	What can stored procedures accept?	CSS	Parameters	Images	HTML	B	\N	medium	\N	general	72	\N	topic
932	Functions are mainly used for?	Returning values	Styling UI	Routing	Creating tables	A	\N	medium	\N	general	72	\N	topic
933	Which improves performance by reducing repeated queries?	Stored procedures	CSS	HTML	UI design	A	\N	hard	\N	general	72	\N	topic
934	Which is more flexible for returning data?	Procedure	Function	Table	Index	B	\N	hard	\N	general	72	\N	topic
935	What is database security?	Styling UI	Protecting database from threats	Creating tables	Writing CSS	B	\N	easy	\N	general	73	\N	topic
936	Why is database security important?	To slow system	To protect data	To style UI	To create animations	B	\N	easy	\N	general	73	\N	topic
937	Which method secures user access?	Authentication	Styling	Routing	Animation	A	\N	easy	\N	general	73	\N	topic
938	Which attack targets databases?	SQL Injection	CSS bug	UI bug	Animation error	A	\N	easy	\N	general	73	\N	topic
939	What is encryption?	Deleting data	Converting data into secure form	Styling UI	Sorting data	B	\N	medium	\N	general	73	\N	topic
940	What does authorization control?	Identity	Access rights	UI styling	Routing	B	\N	medium	\N	general	73	\N	topic
941	Which principle limits user access?	Least privilege	Full access	No access	Unlimited access	A	\N	medium	\N	general	73	\N	topic
942	What protects data during transmission?	HTTP	HTTPS	CSS	HTML	B	\N	medium	\N	general	73	\N	topic
943	Which attack injects malicious SQL code?	XSS	CSRF	SQL Injection	DDoS	C	\N	hard	\N	general	73	\N	topic
944	What is the purpose of hashing passwords?	Styling UI	Secure storage	Deleting data	Routing	B	\N	hard	\N	general	73	\N	topic
945	What is a database backup?	Deleting data	Copying data for safety	Styling UI	Creating tables	B	\N	easy	\N	general	74	\N	topic
946	Why are backups important?	To slow system	To recover lost data	To style UI	To create animations	B	\N	easy	\N	general	74	\N	topic
947	Where can backups be stored?	Server only	Local or cloud storage	CSS file	Browser only	B	\N	easy	\N	general	74	\N	topic
948	Which backup type copies all data?	Incremental	Full backup	Partial	Delta	B	\N	easy	\N	general	74	\N	topic
949	What is incremental backup?	Copy all data	Copy only changed data	Delete data	Sort data	B	\N	medium	\N	general	74	\N	topic
950	What is recovery?	Deleting data	Restoring data from backup	Styling UI	Creating tables	B	\N	medium	\N	general	74	\N	topic
951	Which backup is fastest to create?	Full backup	Incremental backup	Manual backup	Cloud backup	B	\N	medium	\N	general	74	\N	topic
952	What is restore point?	Backup location	Specific point to recover data	CSS file	Database schema	B	\N	medium	\N	general	74	\N	topic
953	Which backup takes the most storage?	Incremental	Full backup	Partial	Delta	B	\N	hard	\N	general	74	\N	topic
954	Which strategy improves data safety?	No backups	Regular backups	Deleting data	Ignoring errors	B	\N	hard	\N	general	74	\N	topic
955	What is database scaling?	Styling UI	Handling more data and users	Deleting tables	Writing CSS	B	\N	easy	\N	general	75	\N	topic
956	Why is scaling needed?	To slow system	To support growth	To add CSS	To reduce data	B	\N	easy	\N	general	75	\N	topic
957	Which scaling adds more servers?	Vertical scaling	Horizontal scaling	Static scaling	Manual scaling	B	\N	easy	\N	general	75	\N	topic
958	Which scaling upgrades one server?	Horizontal scaling	Vertical scaling	Cloud scaling	Dynamic scaling	B	\N	easy	\N	general	75	\N	topic
959	What is sharding?	Deleting data	Splitting database into parts	Styling UI	Joining tables	B	\N	medium	\N	general	75	\N	topic
960	What is replication?	Deleting tables	Copying data across servers	Sorting data	Creating UI	B	\N	medium	\N	general	75	\N	topic
961	Which improves read performance?	Replication	Deletion	CSS	UI design	A	\N	medium	\N	general	75	\N	topic
962	Which distributes data across nodes?	Sharding	Caching	Indexing	Sorting	A	\N	medium	\N	general	75	\N	topic
963	Which scaling is easier but limited?	Horizontal	Vertical	Sharding	Replication	B	\N	hard	\N	general	75	\N	topic
964	Which scaling is more complex but scalable?	Vertical	Horizontal	Static	Manual	B	\N	hard	\N	general	75	\N	topic
965	What is cyber security?	Styling UI	Protecting systems and data from attacks	Creating databases	Writing CSS	B	\N	easy	\N	general	76	\N	topic
966	Why is cyber security important?	To slow systems	To protect data and systems	To create UI	To write code	B	\N	easy	\N	general	76	\N	topic
967	Which asset is protected in cyber security?	CSS files	Data and systems	Images only	Fonts	B	\N	easy	\N	general	76	\N	topic
968	Which is an example of cyber threat?	CSS bug	Malware	UI error	Animation	B	\N	easy	\N	general	76	\N	topic
969	What is malware?	Safe software	Malicious software	UI component	Database tool	B	\N	medium	\N	general	76	\N	topic
970	What is a firewall?	UI tool	Security system that monitors traffic	Database table	CSS file	B	\N	medium	\N	general	76	\N	topic
971	What is encryption?	Deleting data	Converting data into secure form	Styling UI	Sorting data	B	\N	medium	\N	general	76	\N	topic
972	What is phishing?	Secure login	Fake attempt to steal information	Database error	UI bug	B	\N	medium	\N	general	76	\N	topic
973	Which principle ensures data confidentiality?	Encryption	Caching	Styling	Routing	A	\N	hard	\N	general	76	\N	topic
974	Which security layer protects network traffic?	Firewall	CSS	HTML	React	A	\N	hard	\N	general	76	\N	topic
975	What is a network?	A UI component	A group of connected devices	A CSS file	A database	B	\N	easy	\N	general	77	\N	topic
976	What is the internet?	A single computer	A global network of networks	A CSS framework	A database only	B	\N	easy	\N	general	77	\N	topic
977	Which device connects networks?	Mouse	Router	Keyboard	Monitor	B	\N	easy	\N	general	77	\N	topic
978	Which protocol is used for web browsing?	FTP	HTTP	SMTP	SSH	B	\N	easy	\N	general	77	\N	topic
979	What is an IP address?	A UI element	Unique identifier for a device	A CSS file	A database key	B	\N	medium	\N	general	77	\N	topic
980	What does DNS do?	Stores CSS	Translates domain names to IP addresses	Handles UI	Creates databases	B	\N	medium	\N	general	77	\N	topic
981	What is a LAN?	Large network worldwide	Local area network	Cloud storage	Database system	B	\N	medium	\N	general	77	\N	topic
982	What is a WAN?	Local network	Wide area network	UI component	Database	B	\N	medium	\N	general	77	\N	topic
983	Which protocol is secure version of HTTP?	FTP	HTTPS	SMTP	TCP	B	\N	hard	\N	general	77	\N	topic
984	Which model divides networking into layers?	MVC	OSI model	REST	CRUD	B	\N	hard	\N	general	77	\N	topic
985	What is a cyber threat?	UI bug	Potential harm to systems or data	CSS error	Database query	B	\N	easy	\N	general	78	\N	topic
986	Which is an example of malware?	Antivirus	Virus	Firewall	Router	B	\N	easy	\N	general	78	\N	topic
987	What is phishing?	Secure login	Fake attempt to steal data	Database error	UI issue	B	\N	easy	\N	general	78	\N	topic
988	Which attack overloads servers?	SQL Injection	DDoS	Phishing	XSS	B	\N	easy	\N	general	78	\N	topic
989	What is a virus?	Safe program	Self-replicating malicious code	Database tool	UI element	B	\N	medium	\N	general	78	\N	topic
990	What is ransomware?	Free software	Malware that demands payment	UI framework	Database query	B	\N	medium	\N	general	78	\N	topic
991	What is spyware?	Security tool	Software that steals data secretly	UI component	Database system	B	\N	medium	\N	general	78	\N	topic
992	What is social engineering?	Coding method	Manipulating people to gain access	UI design	Database query	B	\N	medium	\N	general	78	\N	topic
993	Which attack injects malicious SQL code?	XSS	CSRF	SQL Injection	DDoS	C	\N	hard	\N	general	78	\N	topic
994	Which attack executes scripts in browser?	SQL Injection	XSS	DDoS	Phishing	B	\N	hard	\N	general	78	\N	topic
995	What is cryptography?	Styling UI	Securing data using encryption	Creating database	Writing CSS	B	\N	easy	\N	general	79	\N	topic
996	What is encryption?	Deleting data	Converting data into unreadable form	Sorting data	Styling UI	B	\N	easy	\N	general	79	\N	topic
997	What is decryption?	Deleting data	Converting data back to readable form	Sorting data	Styling UI	B	\N	easy	\N	general	79	\N	topic
998	What is a key in cryptography?	A UI element	Value used to encrypt/decrypt data	A database field	A CSS file	B	\N	easy	\N	general	79	\N	topic
999	What is symmetric encryption?	One key used	Two keys used	No keys	Random keys	A	\N	medium	\N	general	79	\N	topic
1000	What is asymmetric encryption?	One key used	Two keys (public and private)	No encryption	Only hashing	B	\N	medium	\N	general	79	\N	topic
1001	Which algorithm is used for hashing?	AES	RSA	SHA	HTTP	C	\N	medium	\N	general	79	\N	topic
1002	What is hashing?	Reversible encryption	One-way transformation	UI styling	Database sorting	B	\N	medium	\N	general	79	\N	topic
1003	Which encryption uses public/private keys?	Symmetric	Asymmetric	Hashing	Encoding	B	\N	hard	\N	general	79	\N	topic
1004	Which property ensures data integrity?	Encryption	Hashing	Styling	Routing	B	\N	hard	\N	general	79	\N	topic
1005	What is operating system security?	Styling UI	Protecting OS from threats	Creating database	Writing CSS	B	\N	easy	\N	general	80	\N	topic
1006	Which OS feature controls access?	Themes	User accounts	Fonts	Icons	B	\N	easy	\N	general	80	\N	topic
1007	What is a password used for?	Styling UI	Authenticating users	Deleting files	Creating apps	B	\N	easy	\N	general	80	\N	topic
1008	Which OS update improves security?	Software updates	UI updates	CSS updates	Font updates	A	\N	easy	\N	general	80	\N	topic
1009	What is antivirus software?	UI tool	Software that detects malware	Database tool	CSS framework	B	\N	medium	\N	general	80	\N	topic
1010	What is access control?	Styling	Restricting user permissions	Sorting data	Deleting files	B	\N	medium	\N	general	80	\N	topic
1011	What is a vulnerability?	Security strength	Weakness in system	UI bug	CSS issue	B	\N	medium	\N	general	80	\N	topic
1012	What does patching do?	Adds UI	Fixes security issues	Deletes data	Creates database	B	\N	medium	\N	general	80	\N	topic
1013	Which model enforces strict access control?	DAC	MAC	UI model	CSS model	B	\N	hard	\N	general	80	\N	topic
1014	What is least privilege principle?	Full access	Minimal necessary access	No access	Unlimited access	B	\N	hard	\N	general	80	\N	topic
1015	What is a strong password?	123456	Password123	A complex unique password	User	C	\N	easy	\N	general	81	\N	topic
1016	Why update software regularly?	To add UI	To fix security vulnerabilities	To delete data	To style apps	B	\N	easy	\N	general	81	\N	topic
1017	What is two-factor authentication?	One password	Two-step verification	No login	UI feature	B	\N	easy	\N	general	81	\N	topic
1018	What should you avoid clicking?	Trusted links	Suspicious links	UI buttons	Menus	B	\N	easy	\N	general	81	\N	topic
1019	What is password hashing?	Storing plain passwords	Securely storing passwords	Deleting passwords	Styling UI	B	\N	medium	\N	general	81	\N	topic
1020	What is a secure connection?	HTTP	HTTPS	FTP	CSS	B	\N	medium	\N	general	81	\N	topic
1021	Why use firewalls?	Styling UI	Blocking unauthorized access	Deleting data	Creating routes	B	\N	medium	\N	general	81	\N	topic
1022	What is data backup?	Deleting data	Saving copies of data	Styling UI	Creating database	B	\N	medium	\N	general	81	\N	topic
1023	Which practice reduces attack surface?	Using weak passwords	Limiting access and services	Ignoring updates	Sharing credentials	B	\N	hard	\N	general	81	\N	topic
1024	What is the safest way to store passwords?	Plain text	Encrypted or hashed	In CSS files	In UI	B	\N	hard	\N	general	81	\N	topic
1025	What is web security?	Styling websites	Protecting web applications from attacks	Creating databases	Writing CSS	B	\N	easy	\N	general	82	\N	topic
1026	Which protocol secures web traffic?	HTTP	HTTPS	FTP	SMTP	B	\N	easy	\N	general	82	\N	topic
1027	Which attack targets user sessions?	DDoS	Session hijacking	Sorting	Styling	B	\N	easy	\N	general	82	\N	topic
1028	What is XSS?	Database error	Cross-Site Scripting attack	CSS bug	UI issue	B	\N	easy	\N	general	82	\N	topic
1029	What is CSRF?	Database query	Cross-Site Request Forgery	UI bug	CSS issue	B	\N	medium	\N	general	82	\N	topic
1030	Which header helps protect against XSS?	Content-Type	X-XSS-Protection	Authorization	Accept	B	\N	medium	\N	general	82	\N	topic
1031	What is input sanitization?	Deleting data	Cleaning user input	Styling UI	Creating routes	B	\N	medium	\N	general	82	\N	topic
1032	Which method prevents SQL injection?	No validation	Prepared statements	Plain queries	Ignoring input	B	\N	medium	\N	general	82	\N	topic
1033	Which attack tricks users into unwanted actions?	XSS	CSRF	DDoS	SQL Injection	B	\N	hard	\N	general	82	\N	topic
1034	Which protection limits script execution sources?	CORS	CSP	HTTPS	JWT	B	\N	hard	\N	general	82	\N	topic
1035	What is authentication?	Granting access	Verifying user identity	Styling UI	Creating database	B	\N	easy	\N	general	83	\N	topic
1036	What is authorization?	Verifying identity	Granting access permissions	Deleting data	Styling UI	B	\N	easy	\N	general	83	\N	topic
1037	Which is used to log in users?	Login form	CSS file	Database table	UI animation	A	\N	easy	\N	general	83	\N	topic
1038	Which factor improves security?	Weak password	Two-factor authentication	No login	Open access	B	\N	easy	\N	general	83	\N	topic
1039	What is a JWT used for?	Styling UI	Secure authentication tokens	Database query	CSS animation	B	\N	medium	\N	general	83	\N	topic
1040	What does OAuth allow?	Deleting data	Secure third-party login	Styling UI	Creating tables	B	\N	medium	\N	general	83	\N	topic
1041	What is session management?	UI rendering	Managing user sessions	CSS handling	Database creation	B	\N	medium	\N	general	83	\N	topic
1042	Which stores session data securely?	Cookies	Plain text	CSS files	HTML files	A	\N	medium	\N	general	83	\N	topic
1043	Which attack targets authentication systems?	SQL Injection	Brute force attack	CSS bug	UI issue	B	\N	hard	\N	general	83	\N	topic
1044	Which method protects against brute force?	Unlimited attempts	Rate limiting	Weak passwords	No login	B	\N	hard	\N	general	83	\N	topic
1045	What is network security?	Styling UI	Protecting network systems from attacks	Creating database	Writing CSS	B	\N	easy	\N	general	84	\N	topic
1046	Which device filters network traffic?	Router	Firewall	Keyboard	Monitor	B	\N	easy	\N	general	84	\N	topic
1047	Which protocol secures communication?	HTTP	HTTPS	FTP	SMTP	B	\N	easy	\N	general	84	\N	topic
1048	Which attack floods a network?	SQL Injection	DDoS	XSS	Phishing	B	\N	easy	\N	general	84	\N	topic
1049	What is intrusion detection system (IDS)?	UI tool	System that detects attacks	Database tool	CSS framework	B	\N	medium	\N	general	84	\N	topic
1050	What is VPN?	UI component	Secure private network over internet	Database	CSS file	B	\N	medium	\N	general	84	\N	topic
1051	What is port scanning?	Styling UI	Scanning open ports on a network	Deleting data	Creating database	B	\N	medium	\N	general	84	\N	topic
1052	What does encryption do in networks?	Deletes data	Secures data transmission	Styles UI	Creates routes	B	\N	medium	\N	general	84	\N	topic
1053	Which system prevents unauthorized access?	Firewall	CSS	HTML	React	A	\N	hard	\N	general	84	\N	topic
1054	Which attack intercepts communication?	MITM attack	DDoS	SQL Injection	XSS	A	\N	hard	\N	general	84	\N	topic
1055	What is vulnerability assessment?	Styling UI	Identifying system weaknesses	Creating database	Writing CSS	B	\N	easy	\N	general	85	\N	topic
1056	Why perform vulnerability assessment?	To slow system	To find security issues	To style UI	To delete data	B	\N	easy	\N	general	85	\N	topic
1057	What is a vulnerability?	Security strength	Weakness in system	UI feature	CSS file	B	\N	easy	\N	general	85	\N	topic
1058	Which tool scans for vulnerabilities?	Antivirus	Scanner tools	CSS tools	UI tools	B	\N	easy	\N	general	85	\N	topic
1059	What is penetration testing?	Styling UI	Simulating attacks to find vulnerabilities	Creating database	Sorting data	B	\N	medium	\N	general	85	\N	topic
1060	What is risk assessment?	Deleting data	Evaluating impact of threats	Styling UI	Creating routes	B	\N	medium	\N	general	85	\N	topic
1061	What is exploit?	Safe code	Code that takes advantage of vulnerability	UI component	CSS file	B	\N	medium	\N	general	85	\N	topic
1062	Which phase identifies vulnerabilities?	Scanning	Styling	Routing	Rendering	A	\N	medium	\N	general	85	\N	topic
1063	Which test actively exploits vulnerabilities?	Vulnerability scan	Penetration test	UI test	CSS test	B	\N	hard	\N	general	85	\N	topic
1064	Which process ranks vulnerabilities by risk?	Sorting	Risk assessment	UI testing	CSS rendering	B	\N	hard	\N	general	85	\N	topic
1065	What is secure coding?	Styling UI	Writing code free from vulnerabilities	Creating database	Writing CSS	B	\N	easy	\N	general	86	\N	topic
1066	Why is secure coding important?	To slow system	To prevent security issues	To style UI	To delete data	B	\N	easy	\N	general	86	\N	topic
1067	Which input should be validated?	Trusted only	All user input	No input	CSS only	B	\N	easy	\N	general	86	\N	topic
1068	What is input validation?	Deleting data	Checking user input	Styling UI	Creating routes	B	\N	easy	\N	general	86	\N	topic
1069	What prevents SQL injection?	Plain queries	Prepared statements	No validation	CSS	B	\N	medium	\N	general	86	\N	topic
1070	What prevents XSS?	Ignoring input	Output encoding	Deleting data	CSS styling	B	\N	medium	\N	general	86	\N	topic
1071	What is least privilege?	Full access	Minimum required access	No access	Unlimited access	B	\N	medium	\N	general	86	\N	topic
1072	What should be avoided in code?	Hardcoded secrets	Validation	Security checks	Encryption	A	\N	medium	\N	general	86	\N	topic
1073	Which practice improves code security?	Ignoring errors	Input validation and sanitization	Weak passwords	No authentication	B	\N	hard	\N	general	86	\N	topic
1074	Which issue arises from unvalidated input?	Better performance	Security vulnerabilities	UI improvement	CSS rendering	B	\N	hard	\N	general	86	\N	topic
1075	What is penetration testing?	Styling UI	Simulating attacks to test security	Creating database	Writing CSS	B	\N	easy	\N	general	87	\N	topic
1076	Why is penetration testing done?	To slow system	To find vulnerabilities	To style UI	To delete data	B	\N	easy	\N	general	87	\N	topic
1077	Who performs penetration testing?	Designers	Security testers	UI developers	Database admins	B	\N	easy	\N	general	87	\N	topic
1078	Which phase gathers information?	Scanning	Reconnaissance	Exploitation	Reporting	B	\N	easy	\N	general	87	\N	topic
1079	What is scanning phase?	Styling UI	Identifying vulnerabilities	Deleting data	Creating routes	B	\N	medium	\N	general	87	\N	topic
1080	What is exploitation?	Fixing issues	Using vulnerabilities to gain access	Sorting data	Creating UI	B	\N	medium	\N	general	87	\N	topic
1081	What is reporting?	Deleting data	Documenting findings	Styling UI	Creating routes	B	\N	medium	\N	general	87	\N	topic
1082	Which tool is used in penetration testing?	Nmap	Photoshop	Figma	Excel	A	\N	medium	\N	general	87	\N	topic
1083	Which phase attempts to gain access?	Reconnaissance	Scanning	Exploitation	Reporting	C	\N	hard	\N	general	87	\N	topic
1084	Which testing type is done without prior knowledge?	White box	Black box	Grey box	UI test	B	\N	hard	\N	general	87	\N	topic
1085	What is advanced web security?	Styling UI	Protecting complex web systems	Creating database	Writing CSS	B	\N	easy	\N	general	88	\N	topic
1086	Which attack targets user sessions?	DDoS	Session hijacking	Sorting	Styling	B	\N	easy	\N	general	88	\N	topic
1087	Which header improves security?	Content-Type	Content-Security-Policy	Accept	Host	B	\N	easy	\N	general	88	\N	topic
1088	What is XSS?	Database error	Cross-Site Scripting attack	CSS bug	UI issue	B	\N	easy	\N	general	88	\N	topic
1089	What is CSRF?	Database query	Cross-Site Request Forgery	UI bug	CSS issue	B	\N	medium	\N	general	88	\N	topic
1090	What is input sanitization?	Deleting data	Cleaning user input	Styling UI	Creating routes	B	\N	medium	\N	general	88	\N	topic
1091	Which prevents SQL injection?	Plain queries	Prepared statements	Ignoring input	CSS	B	\N	medium	\N	general	88	\N	topic
1092	Which improves authentication security?	Weak passwords	Multi-factor authentication	No login	Open access	B	\N	medium	\N	general	88	\N	topic
1093	Which policy restricts resource loading?	CORS	CSP	JWT	HTTPS	B	\N	hard	\N	general	88	\N	topic
1094	Which attack executes scripts in user browser?	SQL Injection	XSS	DDoS	Phishing	B	\N	hard	\N	general	88	\N	topic
1095	What is an exploit?	Safe code	Code that uses a vulnerability	UI component	CSS file	B	\N	easy	\N	general	89	\N	topic
1148	Which language used in mobile?	Java	HTML only	CSS only	Excel	A	\N	easy	\N	general	94	\N	topic
1096	Why are exploits dangerous?	They improve performance	They allow unauthorized access	They style UI	They delete CSS	B	\N	easy	\N	general	89	\N	topic
1097	What is a vulnerability?	Security strength	Weakness in system	UI feature	CSS file	B	\N	easy	\N	general	89	\N	topic
1098	Who uses exploits?	Designers	Attackers	UI developers	Database admins	B	\N	easy	\N	general	89	\N	topic
1099	What is buffer overflow?	UI overflow	Writing beyond memory limits	CSS bug	Database issue	B	\N	medium	\N	general	89	\N	topic
1100	What is payload?	UI component	Code delivered by exploit	CSS file	Database row	B	\N	medium	\N	general	89	\N	topic
1101	What is reverse engineering?	Creating UI	Analyzing system behavior	Styling CSS	Deleting data	B	\N	medium	\N	general	89	\N	topic
1102	What is shellcode?	UI script	Code executed after exploit	CSS style	Database query	B	\N	medium	\N	general	89	\N	topic
1103	Which vulnerability allows memory overwrite?	SQL Injection	Buffer overflow	XSS	CSRF	B	\N	hard	\N	general	89	\N	topic
1104	Which step sends malicious code to target?	Scanning	Payload delivery	Reporting	Reconnaissance	B	\N	hard	\N	general	89	\N	topic
1105	What is digital forensics?	Styling UI	Investigating digital evidence	Creating database	Writing CSS	B	\N	easy	\N	general	90	\N	topic
1106	Why is digital forensics used?	To slow system	To analyze cyber incidents	To style UI	To delete data	B	\N	easy	\N	general	90	\N	topic
1107	What is digital evidence?	UI component	Data used in investigations	CSS file	HTML page	B	\N	easy	\N	general	90	\N	topic
1108	Which device can contain evidence?	Only computers	Any digital device	CSS files	UI tools	B	\N	easy	\N	general	90	\N	topic
1109	What is data recovery?	Deleting data	Restoring lost data	Styling UI	Creating routes	B	\N	medium	\N	general	90	\N	topic
1110	What is log analysis?	UI analysis	Reviewing system logs	CSS analysis	Database design	B	\N	medium	\N	general	90	\N	topic
1111	What is chain of custody?	Data deletion	Tracking evidence handling	Styling UI	Creating database	B	\N	medium	\N	general	90	\N	topic
1112	Which tool is used in forensics?	Wireshark	Photoshop	Figma	Excel	A	\N	medium	\N	general	90	\N	topic
1113	Which step ensures evidence integrity?	Ignoring logs	Chain of custody	Deleting data	Styling UI	B	\N	hard	\N	general	90	\N	topic
1114	Which process analyzes network traffic?	UI testing	Packet analysis	CSS rendering	Database query	B	\N	hard	\N	general	90	\N	topic
1115	What is security architecture?	Styling UI	Designing secure systems	Creating database	Writing CSS	B	\N	easy	\N	general	91	\N	topic
1116	What is a security layer?	UI component	Level of protection in system	CSS file	Database table	B	\N	easy	\N	general	91	\N	topic
1117	Which concept uses multiple layers of defense?	Single protection	Defense in depth	No security	Open access	B	\N	easy	\N	general	91	\N	topic
1118	What protects system boundaries?	CSS	Firewalls	HTML	React	B	\N	easy	\N	general	91	\N	topic
1119	What is least privilege?	Full access	Minimum required access	No access	Unlimited access	B	\N	medium	\N	general	91	\N	topic
1120	What is threat modeling?	Styling UI	Identifying potential threats	Creating database	Sorting data	B	\N	medium	\N	general	91	\N	topic
1121	What is secure design?	Ignoring security	Designing with security in mind	Styling UI	Creating routes	B	\N	medium	\N	general	91	\N	topic
1122	Which protects data at rest?	HTTP	Encryption	CSS	HTML	B	\N	medium	\N	general	91	\N	topic
1123	Which principle reduces attack surface?	More services	Minimal exposure	No security	Unlimited access	B	\N	hard	\N	general	91	\N	topic
1124	Which model enforces strict access rules?	DAC	MAC	UI model	CSS model	B	\N	hard	\N	general	91	\N	topic
1125	What is cloud security?	Styling UI	Protecting cloud systems and data	Creating database	Writing CSS	B	\N	easy	\N	general	92	\N	topic
1126	Which service stores data in cloud?	Compute	Storage	UI	CSS	B	\N	easy	\N	general	92	\N	topic
1127	What is cloud provider?	UI tool	Company offering cloud services	Database table	CSS file	B	\N	easy	\N	general	92	\N	topic
1128	Which model provides full infrastructure?	SaaS	PaaS	IaaS	CSS	C	\N	easy	\N	general	92	\N	topic
1129	What is shared responsibility model?	Only user responsible	Both provider and user share security	Only provider responsible	No responsibility	B	\N	medium	\N	general	92	\N	topic
1130	What protects cloud data?	CSS	Encryption	HTML	UI	B	\N	medium	\N	general	92	\N	topic
1131	What is IAM?	UI tool	Identity and Access Management	Database query	CSS file	B	\N	medium	\N	general	92	\N	topic
1132	Which prevents unauthorized access?	Open access	Access control	No login	Weak password	B	\N	medium	\N	general	92	\N	topic
1133	Which attack targets cloud misconfigurations?	XSS	Cloud breach	SQL Injection	DDoS	B	\N	hard	\N	general	92	\N	topic
1134	Which practice secures cloud storage?	Public access	Private access and encryption	No security	Weak passwords	B	\N	hard	\N	general	92	\N	topic
1135	What is advanced penetration testing?	Styling UI	In-depth security testing	Creating database	Writing CSS	B	\N	easy	\N	general	93	\N	topic
1136	What is the goal of penetration testing?	Slow system	Find and exploit vulnerabilities	Style UI	Delete data	B	\N	easy	\N	general	93	\N	topic
1137	Who performs penetration testing?	Designers	Security experts	UI developers	Database admins	B	\N	easy	\N	general	93	\N	topic
1138	Which phase gathers detailed info?	Scanning	Reconnaissance	Exploitation	Reporting	B	\N	easy	\N	general	93	\N	topic
1139	What is privilege escalation?	Reducing access	Gaining higher access rights	Styling UI	Creating database	B	\N	medium	\N	general	93	\N	topic
1140	What is lateral movement?	Moving UI elements	Moving across systems after access	Styling CSS	Deleting data	B	\N	medium	\N	general	93	\N	topic
1141	What is post-exploitation?	Fixing system	Actions after gaining access	Creating UI	Sorting data	B	\N	medium	\N	general	93	\N	topic
1142	Which tool is used for advanced testing?	Metasploit	Photoshop	Figma	Excel	A	\N	medium	\N	general	93	\N	topic
1143	Which step escalates privileges?	Reconnaissance	Privilege escalation	Reporting	Scanning	B	\N	hard	\N	general	93	\N	topic
1144	Which step maintains access after exploit?	Scanning	Persistence	Reporting	Reconnaissance	B	\N	hard	\N	general	93	\N	topic
1145	What is mobile development?	UI design	Building mobile apps	CSS styling	Database only	B	\N	easy	\N	general	94	\N	topic
1146	Which platform is mobile?	Windows	Android	Linux server	Database	B	\N	easy	\N	general	94	\N	topic
1149	What is SDK?	UI tool	Software dev kit	Database	CSS file	B	\N	medium	\N	general	94	\N	topic
1150	What is APK?	Image file	Android app package	CSS file	Database	B	\N	medium	\N	general	94	\N	topic
1151	What is mobile UI?	Server logic	User interface	Database	API	B	\N	medium	\N	general	94	\N	topic
1152	Which OS for iPhone?	Android	iOS	Linux	Windows	B	\N	medium	\N	general	94	\N	topic
1153	Which platform is cross-platform?	Flutter	HTML	CSS	SQL	A	\N	hard	\N	general	94	\N	topic
1154	Which improves UX?	Bad design	Responsive UI	No UI	Static layout	B	\N	hard	\N	general	94	\N	topic
1155	What is variable?	Loop	Data storage	Function	UI	B	\N	easy	\N	general	95	\N	topic
1156	Which stores numbers?	String	Integer	Boolean	Char	B	\N	easy	\N	general	95	\N	topic
1157	Which stores text?	Integer	String	Boolean	Float	B	\N	easy	\N	general	95	\N	topic
1158	What is function?	UI	Reusable code	Database	CSS	B	\N	easy	\N	general	95	\N	topic
1159	What is loop?	Repeat code	Stop code	Delete code	UI	A	\N	medium	\N	general	95	\N	topic
1160	What is condition?	Loop	Decision making	CSS	DB	B	\N	medium	\N	general	95	\N	topic
1161	What is array?	Single value	Collection of data	CSS	HTML	B	\N	medium	\N	general	95	\N	topic
1162	What is object?	UI	Data structure	Loop	Function	B	\N	medium	\N	general	95	\N	topic
1163	Which is OOP concept?	Loop	Encapsulation	CSS	HTML	B	\N	hard	\N	general	95	\N	topic
1164	Which improves logic?	Copy code	Practice problems	Ignore errors	Random code	B	\N	hard	\N	general	95	\N	topic
1165	What is Flutter?	DB	UI toolkit	CSS	HTML	B	\N	easy	\N	general	96	\N	topic
1166	Which language Flutter uses?	Java	Dart	Python	C++	B	\N	easy	\N	general	96	\N	topic
1167	What is widget?	UI element	Database	API	Loop	A	\N	easy	\N	general	96	\N	topic
1168	What builds UI?	Widgets	Tables	API	Routes	A	\N	easy	\N	general	96	\N	topic
1169	What is StatelessWidget?	Dynamic	Static UI	DB	CSS	B	\N	medium	\N	general	96	\N	topic
1170	What is StatefulWidget?	Static	Dynamic UI	CSS	HTML	B	\N	medium	\N	general	96	\N	topic
1171	What is build() method?	API	UI rendering	DB	CSS	B	\N	medium	\N	general	96	\N	topic
1172	What is scaffold?	UI structure	DB	API	Loop	A	\N	medium	\N	general	96	\N	topic
1173	Which handles state?	setState	CSS	HTML	SQL	A	\N	hard	\N	general	96	\N	topic
1174	Which improves UI reuse?	Widgets	Tables	DB	API	A	\N	hard	\N	general	96	\N	topic
1175	What is UI?	Server	User interface	DB	CSS	B	\N	easy	\N	general	97	\N	topic
1176	What improves UI?	Good design	Bad colors	No layout	Random	A	\N	easy	\N	general	97	\N	topic
1177	What is layout?	Structure	Code	DB	API	A	\N	easy	\N	general	97	\N	topic
1178	What is color scheme?	Colors used	DB	CSS file	API	A	\N	easy	\N	general	97	\N	topic
1179	What improves UX?	Good navigation	No design	Random UI	Slow app	A	\N	medium	\N	general	97	\N	topic
1180	What is typography?	Fonts	Images	DB	API	A	\N	medium	\N	general	97	\N	topic
1181	What is spacing?	UI gap	DB	Loop	CSS	A	\N	medium	\N	general	97	\N	topic
1182	What is alignment?	Positioning	DB	API	Loop	A	\N	medium	\N	general	97	\N	topic
1183	Which improves design consistency?	Design system	Random UI	No UI	CSS only	A	\N	hard	\N	general	97	\N	topic
1184	Which improves usability?	Clear UI	Complex UI	Hidden buttons	No nav	A	\N	hard	\N	general	97	\N	topic
1185	What is navigation?	Moving between screens	DB	CSS	HTML	A	\N	easy	\N	general	98	\N	topic
1186	What is route?	Path	DB	API	Loop	A	\N	easy	\N	general	98	\N	topic
1187	What is screen?	Page	DB	API	CSS	A	\N	easy	\N	general	98	\N	topic
1188	What is layout?	Structure	Code	DB	API	A	\N	easy	\N	general	98	\N	topic
1189	What is stack navigation?	Layered screens	DB	CSS	API	A	\N	medium	\N	general	98	\N	topic
1190	What is drawer?	Side menu	DB	API	CSS	A	\N	medium	\N	general	98	\N	topic
1191	What is bottom nav?	Bottom menu	DB	API	Loop	A	\N	medium	\N	general	98	\N	topic
1192	What improves navigation?	Clear routes	Random UI	No nav	Slow UI	A	\N	medium	\N	general	98	\N	topic
1193	Which improves UX?	Simple nav	Complex nav	Hidden nav	No nav	A	\N	hard	\N	general	98	\N	topic
1194	Which handles routes?	Navigator	CSS	HTML	SQL	A	\N	hard	\N	general	98	\N	topic
1195	What is local storage?	UI tool	Store data on device	DB server	API	B	\N	easy	\N	general	99	\N	topic
1196	Where is data stored?	Server	Device	CSS	HTML	B	\N	easy	\N	general	99	\N	topic
1197	Is local storage offline?	No	Yes	Sometimes	Unknown	B	\N	easy	\N	general	99	\N	topic
1198	What type stored?	Temporary	Persistent	CSS	API	B	\N	easy	\N	general	99	\N	topic
1199	What is SharedPreferences?	DB	Local storage tool	API	CSS	B	\N	medium	\N	general	99	\N	topic
1200	What is caching data?	Delete	Store locally	Style	Render	B	\N	medium	\N	general	99	\N	topic
1201	Which data format common?	JSON	CSS	HTML	SQL	A	\N	medium	\N	general	99	\N	topic
1202	Local storage improves?	Speed	UI	CSS	Fonts	A	\N	medium	\N	general	99	\N	topic
1203	Which risk exists?	Data loss	Perfect safety	UI error	None	A	\N	hard	\N	general	99	\N	topic
1204	Which improves security?	Encryption	Plain text	No storage	CSS	A	\N	hard	\N	general	99	\N	topic
1205	What is state?	UI style	App data	DB	CSS	B	\N	easy	\N	general	100	\N	topic
1206	Why manage state?	Style UI	Control data	Delete data	Render CSS	B	\N	easy	\N	general	100	\N	topic
1207	State changes cause?	UI update	DB delete	CSS	API	A	\N	easy	\N	general	100	\N	topic
1208	Which manages state?	Provider	CSS	HTML	SQL	A	\N	easy	\N	general	100	\N	topic
1209	What is global state?	Shared data	UI	CSS	Loop	A	\N	medium	\N	general	100	\N	topic
1210	What is setState?	Update UI	Delete data	DB	CSS	A	\N	medium	\N	general	100	\N	topic
1211	Which improves state handling?	Redux	CSS	HTML	SQL	A	\N	medium	\N	general	100	\N	topic
1212	State used for?	Logic	Design	Fonts	Images	A	\N	medium	\N	general	100	\N	topic
1213	Which avoids prop drilling?	Global state	CSS	HTML	Loop	A	\N	hard	\N	general	100	\N	topic
1214	Which improves performance?	Efficient state	Random state	No state	CSS	A	\N	hard	\N	general	100	\N	topic
1215	What is API?	UI	Communication layer	DB	CSS	B	\N	easy	\N	general	101	\N	topic
1216	API used for?	Fetch data	Style UI	Delete CSS	Render HTML	A	\N	easy	\N	general	101	\N	topic
1217	Which method gets data?	GET	POST	PUT	DELETE	A	\N	easy	\N	general	101	\N	topic
1218	Which sends data?	POST	GET	CSS	HTML	A	\N	easy	\N	general	101	\N	topic
1219	What is JSON?	Data format	UI	CSS	DB	A	\N	medium	\N	general	101	\N	topic
1220	What is fetch?	API call	UI	CSS	Loop	A	\N	medium	\N	general	101	\N	topic
1221	What handles API errors?	Try/catch	CSS	HTML	SQL	A	\N	medium	\N	general	101	\N	topic
1222	API improves?	Dynamic data	Static UI	CSS	Fonts	A	\N	medium	\N	general	101	\N	topic
1223	Which improves API security?	Auth	No auth	CSS	HTML	A	\N	hard	\N	general	101	\N	topic
1224	Which handles async?	Promises	CSS	HTML	SQL	A	\N	hard	\N	general	101	\N	topic
1225	What is login?	UI	User auth	CSS	DB	B	\N	easy	\N	general	102	\N	topic
1226	What verifies user?	Auth	CSS	HTML	API	A	\N	easy	\N	general	102	\N	topic
1227	Which data used?	User/pass	Color	Font	CSS	A	\N	easy	\N	general	102	\N	topic
1228	What is logout?	Exit session	CSS	DB	API	A	\N	easy	\N	general	102	\N	topic
1229	What is token?	Key	CSS	UI	Loop	A	\N	medium	\N	general	102	\N	topic
1230	Where stored?	Local	CSS	HTML	SQL	A	\N	medium	\N	general	102	\N	topic
1231	What is session?	User state	CSS	HTML	DB	A	\N	medium	\N	general	102	\N	topic
1232	Auth improves?	Security	UI	CSS	Fonts	A	\N	medium	\N	general	102	\N	topic
1233	Which secures auth?	Encryption	Plain	CSS	HTML	A	\N	hard	\N	general	102	\N	topic
1234	Which prevents attacks?	Validation	None	CSS	HTML	A	\N	hard	\N	general	102	\N	topic
1235	What is animation?	UI motion	DB	CSS	API	A	\N	easy	\N	general	103	\N	topic
1236	Why animations?	UX	CSS	DB	API	A	\N	easy	\N	general	103	\N	topic
1237	Which improves UX?	Smooth UI	Static UI	No UI	CSS	A	\N	easy	\N	general	103	\N	topic
1238	What is transition?	UI change	DB	CSS	API	A	\N	easy	\N	general	103	\N	topic
1239	What is duration?	Time	CSS	HTML	DB	A	\N	medium	\N	general	103	\N	topic
1240	What is easing?	Animation style	CSS	DB	API	A	\N	medium	\N	general	103	\N	topic
1241	Animations affect?	Performance	CSS	HTML	DB	A	\N	medium	\N	general	103	\N	topic
1242	Which tool?	Flutter anim	CSS	HTML	SQL	A	\N	medium	\N	general	103	\N	topic
1243	Too many animations cause?	Slow app	Fast app	No change	CSS	A	\N	hard	\N	general	103	\N	topic
1244	Best practice?	Optimize	Ignore	Overuse	CSS	A	\N	hard	\N	general	103	\N	topic
1245	What is notification?	Alert	DB	CSS	API	A	\N	easy	\N	general	104	\N	topic
1246	Used for?	User updates	CSS	HTML	DB	A	\N	easy	\N	general	104	\N	topic
1247	Which service?	Firebase	CSS	HTML	SQL	A	\N	easy	\N	general	104	\N	topic
1248	Push sent by?	Server	CSS	HTML	UI	A	\N	easy	\N	general	104	\N	topic
1249	What triggers?	Event	CSS	HTML	DB	A	\N	medium	\N	general	104	\N	topic
1250	Notifications improve?	Engagement	CSS	UI	Fonts	A	\N	medium	\N	general	104	\N	topic
1251	What is token?	Device ID	CSS	HTML	DB	A	\N	medium	\N	general	104	\N	topic
1252	Permission needed?	Yes	No	Maybe	CSS	A	\N	medium	\N	general	104	\N	topic
1253	Spam causes?	User loss	Growth	UI	CSS	A	\N	hard	\N	general	104	\N	topic
1255	What is app performance optimization?	Styling UI	Improving app speed and efficiency	Creating database	Writing CSS	B	\N	easy	\N	general	105	\N	topic
1256	Why optimize performance?	To slow app	To improve user experience	To delete data	To reduce UI	B	\N	easy	\N	general	105	\N	topic
1257	Which affects app performance?	Efficient code	Font color only	CSS only	Images only	A	\N	easy	\N	general	105	\N	topic
1258	What does optimization reduce?	Speed	Lag	Security	Navigation	B	\N	easy	\N	general	105	\N	topic
1259	What is lazy loading?	Load all at once	Load data when needed	Delete data	Style UI	B	\N	medium	\N	general	105	\N	topic
1260	What is caching used for?	Slow app	Faster access to data	Delete storage	Add animations	B	\N	medium	\N	general	105	\N	topic
1261	Which improves performance in lists?	Rendering everything always	Efficient rendering	Ignoring updates	More images	B	\N	medium	\N	general	105	\N	topic
1262	What helps reduce memory usage?	Unused objects	Efficient state management	More CSS	Large files	B	\N	medium	\N	general	105	\N	topic
1263	What can cause slow performance?	Optimized code	Heavy unnecessary rendering	Good caching	Small assets	B	\N	hard	\N	general	105	\N	topic
1264	Which practice improves mobile performance?	Compress assets and optimize state	Use larger files	Ignore profiling	Add extra animations	A	\N	hard	\N	general	105	\N	topic
1265	What is advanced state management?	Basic styling	Managing complex app data flow	Creating database	Writing CSS	B	\N	easy	\N	general	106	\N	topic
1266	Why use advanced state management?	For colors only	To manage shared and complex state	To delete data	To style fonts	B	\N	easy	\N	general	106	\N	topic
1267	Which library is commonly used for advanced state management?	Redux	Photoshop	HTML	CSS	A	\N	easy	\N	general	106	\N	topic
1268	What kind of state is usually shared globally?	Local temporary style only	App-wide data	Image size	Font family	B	\N	easy	\N	general	106	\N	topic
1269	What is a store in state management?	A CSS file	Central place for app state	A database table	A route	B	\N	medium	\N	general	106	\N	topic
1270	What is an action in Redux-like systems?	A design pattern only	An object describing state change	A UI color	A database row	B	\N	medium	\N	general	106	\N	topic
1271	What is a reducer?	A function that updates state based on action	A styling tool	A database query	A navigation method	A	\N	medium	\N	general	106	\N	topic
1272	Why avoid unnecessary global state?	It makes app faster always	It can increase complexity	It improves styling	It replaces APIs	B	\N	medium	\N	general	106	\N	topic
1273	Which pattern helps predict state changes?	Unidirectional data flow	Random updates	Inline CSS	Direct mutation everywhere	A	\N	hard	\N	general	106	\N	topic
1274	What should be avoided in advanced state management?	Clear structure	Direct state mutation	Reusable logic	Normalized state	B	\N	hard	\N	general	106	\N	topic
1275	What is an offline-first app?	An app that works only online	An app designed to work without internet first	A CSS tool	A database only	B	\N	easy	\N	general	107	\N	topic
1276	Why build offline-first apps?	To block users	To improve reliability without internet	To remove storage	To slow performance	B	\N	easy	\N	general	107	\N	topic
1277	What is synced later in offline-first apps?	Only colors	Local changes when connection returns	CSS files	Fonts	B	\N	easy	\N	general	107	\N	topic
1278	Which storage is useful for offline-first apps?	Local database	Remote CSS	HTML page	Image editor	A	\N	easy	\N	general	107	\N	topic
1279	What is synchronization?	Deleting local data	Updating local and remote data consistently	Styling UI	Reducing fonts	B	\N	medium	\N	general	107	\N	topic
1280	Why is local persistence important?	For animations only	To keep data available offline	To remove APIs	To style layout	B	\N	medium	\N	general	107	\N	topic
1281	What is conflict resolution?	Choosing how to handle different updates	Deleting all changes	Styling errors	Hiding UI	A	\N	medium	\N	general	107	\N	topic
1282	Which feature improves offline UX?	Clear sync status	No feedback	Forced reloads	Large assets only	A	\N	medium	\N	general	107	\N	topic
1283	What is a challenge in offline-first design?	Simple syncing always	Data conflicts between local and server	Too much CSS	No storage needed	B	\N	hard	\N	general	107	\N	topic
1284	Which approach is essential for offline-first apps?	Depend fully on internet	Queue and sync changes later	Disable local storage	Remove caching	B	\N	hard	\N	general	107	\N	topic
1285	What is app security?	Styling UI	Protecting app data and functionality	Creating database	Writing CSS	B	\N	easy	\N	general	108	\N	topic
1286	Why is app security important?	To slow app	To protect users and data	To remove features	To style screens	B	\N	easy	\N	general	108	\N	topic
1287	Which improves login security?	Weak password	Strong authentication	No validation	Open access	B	\N	easy	\N	general	108	\N	topic
1288	What should sensitive data use?	Plain text	Encryption	Large fonts	Extra images	B	\N	easy	\N	general	108	\N	topic
1289	What is secure storage?	Saving secrets safely on device	Putting tokens in UI	Saving passwords in plain text	Ignoring local security	A	\N	medium	\N	general	108	\N	topic
1290	What does authentication do?	Styles screens	Verifies user identity	Deletes data	Creates routes	B	\N	medium	\N	general	108	\N	topic
1291	What helps protect app communication?	HTTP only	HTTPS	Plain text	No validation	B	\N	medium	\N	general	108	\N	topic
1292	Why validate input?	To improve colors	To reduce security risks	To remove navigation	To style forms	B	\N	medium	\N	general	108	\N	topic
1293	What should never be hardcoded in app source?	Theme colors	Secrets and keys	Layout spacing	Icon names	B	\N	hard	\N	general	108	\N	topic
1294	Which practice improves app security most?	Input validation and secure storage	Ignoring errors	Weak auth	Open APIs	A	\N	hard	\N	general	108	\N	topic
1295	What is mobile app testing?	Styling UI	Checking app works correctly	Creating database	Writing CSS	B	\N	easy	\N	general	109	\N	topic
1296	Why test mobile apps?	To add bugs	To ensure quality	To remove features	To style screens	B	\N	easy	\N	general	109	\N	topic
1297	Which test checks one small unit?	Unit test	UI design test	CSS test	Manual drawing	A	\N	easy	\N	general	109	\N	topic
1298	Which test checks the interface?	UI test	SQL test	Font test	Color test	A	\N	easy	\N	general	109	\N	topic
1299	What is integration testing?	Testing combined components	Testing colors	Testing fonts	Testing icons	A	\N	medium	\N	general	109	\N	topic
1300	What is manual testing?	Testing by a person	Testing with CSS	Testing only database	Testing with no device	A	\N	medium	\N	general	109	\N	topic
1301	What is automated testing?	Testing using scripts/tools	Drawing mockups	Styling layouts	Deleting bugs manually	A	\N	medium	\N	general	109	\N	topic
1302	Which improves test quality?	Clear test cases	No planning	Random clicks	Ignoring errors	A	\N	medium	\N	general	109	\N	topic
1303	Why test on real devices?	For decoration	To catch real environment issues	To style UI	To remove APIs	B	\N	hard	\N	general	109	\N	topic
1304	Which is important in mobile testing?	Different screen sizes and OS versions	One device only	No internet only	Fonts only	A	\N	hard	\N	general	109	\N	topic
1305	What does publishing an app mean?	Deleting app	Releasing app to users	Styling app	Creating database	B	\N	easy	\N	general	110	\N	topic
1306	Where are mobile apps commonly published?	App stores	CSS files	Databases	Browsers only	A	\N	easy	\N	general	110	\N	topic
1307	Which store is for Android apps?	App Store	Play Store	Photoshop	Figma	B	\N	easy	\N	general	110	\N	topic
1308	Which store is for iOS apps?	Play Store	App Store	Chrome Store	Drive	B	\N	easy	\N	general	110	\N	topic
1309	What is app signing?	Styling app	Verifying app identity before release	Deleting assets	Changing UI	B	\N	medium	\N	general	110	\N	topic
1310	Why prepare screenshots and descriptions?	For styling only	To present app in store	To delete bugs	To create API	B	\N	medium	\N	general	110	\N	topic
1311	What should be tested before publishing?	Only colors	Functionality and stability	Fonts only	Nothing	B	\N	medium	\N	general	110	\N	topic
1312	Why follow store guidelines?	To avoid rejection	To slow release	To remove features	To change CSS	A	\N	medium	\N	general	110	\N	topic
1313	What can cause app rejection?	Meeting guidelines	Policy violations	Testing well	Stable performance	B	\N	hard	\N	general	110	\N	topic
1314	Which is important after publishing?	Ignore users	Monitor crashes and feedback	Delete updates	Remove analytics	B	\N	hard	\N	general	110	\N	topic
1315	What is CI/CD?	Continuous Integration and Continuous Deployment	Code and CSS	Cloud only	Database sync only	A	\N	easy	\N	general	111	\N	topic
1316	Why use CI/CD?	To slow development	To automate build and release steps	To style UI	To remove testing	B	\N	easy	\N	general	111	\N	topic
1317	What does CI mainly help with?	Automatic code integration and testing	Only colors	Only databases	Only icons	A	\N	easy	\N	general	111	\N	topic
1318	What does CD mainly help with?	Manual deployment only	Automated delivery/release	Deleting builds	Styling app	B	\N	easy	\N	general	111	\N	topic
1319	What is a pipeline?	A UI layout	A sequence of automated steps	A database row	A CSS class	B	\N	medium	\N	general	111	\N	topic
1320	Which task can CI run automatically?	Tests	Figma design	Manual clicks	Font selection	A	\N	medium	\N	general	111	\N	topic
1321	Why are automated builds useful?	They reduce reliability	They ensure consistent builds	They remove security	They slow releases	B	\N	medium	\N	general	111	\N	topic
1322	What is one benefit of CI/CD for teams?	More manual work	Faster and safer releases	No testing	No version control	B	\N	medium	\N	general	111	\N	topic
1323	Which practice improves CI/CD quality?	Run tests in pipeline	Skip validation	Deploy broken builds	Ignore logs	A	\N	hard	\N	general	111	\N	topic
1324	What is required for effective CI/CD?	Version control and automation	Only CSS	Only UI mockups	No testing	A	\N	hard	\N	general	111	\N	topic
1337	What is repetition in design?	Using consistent styles	Repeating bugs	Duplicating databases	Copying code	A	\N	easy	\N	general	113	\N	topic
1338	What is proximity in design?	Grouping related items	Spacing code lines	Connecting servers	Sorting records	A	\N	easy	\N	general	113	\N	topic
1339	Why is consistency important?	Creates a predictable interface	Makes UI random	Slows app	Breaks layout	A	\N	medium	\N	general	113	\N	topic
1340	What is hierarchy in design?	Showing importance of elements	Deleting layers	Saving files	Building APIs	A	\N	medium	\N	general	113	\N	topic
1341	What principle improves readability?	Whitespace	Overcrowding	Tiny fonts	Random colors	A	\N	medium	\N	general	113	\N	topic
1342	What is balance in design?	Even visual distribution	More buttons	Less testing	More code	A	\N	medium	\N	general	113	\N	topic
1343	Which principle guides user attention first?	Visual hierarchy	Database indexing	Authentication	Caching	A	\N	hard	\N	general	113	\N	topic
1344	Which harms design quality?	Inconsistent spacing	Clear hierarchy	Good contrast	Proper alignment	A	\N	hard	\N	general	113	\N	topic
1345	What does typography relate to?	Fonts and text styling	APIs	Databases	Animations only	A	\N	easy	\N	general	114	\N	topic
1346	Why is color important in UI?	Communicates meaning and mood	Stores data	Runs code	Builds routes	A	\N	easy	\N	general	114	\N	topic
1347	What improves text readability?	Good contrast	Low contrast	Tiny spacing	Random sizes	A	\N	easy	\N	general	114	\N	topic
1348	What is a font family?	Group of related fonts	Database table	Color palette	Animation set	A	\N	easy	\N	general	114	\N	topic
1349	What is line height used for?	Text spacing vertically	Server response	Image size	Button color	A	\N	medium	\N	general	114	\N	topic
1350	What is a color palette?	Set of chosen colors	Set of routes	Set of queries	Set of files	A	\N	medium	\N	general	114	\N	topic
1351	Why use limited fonts?	To keep design consistent	To slow app	To add bugs	To remove branding	A	\N	medium	\N	general	114	\N	topic
1352	Which color choice improves accessibility?	High contrast colors	Very similar colors	Random gradients only	Invisible text	A	\N	medium	\N	general	114	\N	topic
1353	What is hierarchy in typography?	Using sizes/weights to show importance	Deleting fonts	Saving files	Styling backend	A	\N	hard	\N	general	114	\N	topic
1354	Which harms typography most?	Too many font styles	Consistent font scale	Clear spacing	Readable sizes	A	\N	hard	\N	general	114	\N	topic
1355	What is a wireframe?	Basic layout of a screen	Final coded app	Database model	Server config	A	\N	easy	\N	general	115	\N	topic
1356	Why use wireframes?	Plan structure before detailed design	Encrypt data	Write API	Deploy app	A	\N	easy	\N	general	115	\N	topic
1357	Wireframes usually focus on?	Layout and content placement	Colors only	Animations only	Backend logic	A	\N	easy	\N	general	115	\N	topic
1358	A low-fidelity wireframe is?	Simple and rough	Fully coded	Production-ready	Animated only	A	\N	easy	\N	general	115	\N	topic
1359	What comes after wireframing often?	High-fidelity design	Database migration	Server scaling	Testing APIs	A	\N	medium	\N	general	115	\N	topic
1360	What is a placeholder in wireframes?	Temporary content block	Security feature	SQL query	App store asset	A	\N	medium	\N	general	115	\N	topic
1361	Why avoid too much detail in early wireframes?	Focus on structure first	Because colors are forbidden	Because code is faster	To delete screens	A	\N	medium	\N	general	115	\N	topic
1362	Which tool is commonly used for wireframes?	Figma	Postman	pgAdmin	Node.js	A	\N	medium	\N	general	115	\N	topic
1363	What is the goal of low-fidelity wireframes?	Quickly explore ideas	Finalize branding	Write backend	Publish app	A	\N	hard	\N	general	115	\N	topic
1364	Which is most important in a wireframe?	Screen structure	Exact final colors	Production assets	Database schema	A	\N	hard	\N	general	115	\N	topic
1365	What is user research?	Studying users and their needs	Styling UI	Writing backend	Managing database	A	\N	easy	\N	general	116	\N	topic
1366	Why do user research?	Understand users better	Slow design	Remove testing	Skip planning	A	\N	easy	\N	general	116	\N	topic
1367	Which is a research method?	Interview	SQL query	Deployment	Caching	A	\N	easy	\N	general	116	\N	topic
1368	Who is the focus of user research?	Users	Servers	Databases	Compilers	A	\N	easy	\N	general	116	\N	topic
1369	What can interviews reveal?	User goals and pain points	Font size	Server uptime	SQL errors	A	\N	medium	\N	general	116	\N	topic
1370	What is a survey used for?	Collect feedback from many users	Style screens	Build APIs	Store files	A	\N	medium	\N	general	116	\N	topic
1371	What is a persona?	A fictional user profile	A database row	A CSS component	A route	A	\N	medium	\N	general	116	\N	topic
1372	What is a pain point?	A user problem or frustration	A UI button	A code function	A test case	A	\N	medium	\N	general	116	\N	topic
1373	Which improves product decisions?	Research findings	Random guesses	Ignoring feedback	Copying blindly	A	\N	hard	\N	general	116	\N	topic
1374	What should research be based on?	Real user data	Assumptions only	Colors only	Developer opinion only	A	\N	hard	\N	general	116	\N	topic
1375	What is Figma?	A design and prototyping tool	A database	A backend framework	A browser	A	\N	easy	\N	general	117	\N	topic
1376	What is Figma commonly used for?	UI/UX design	SQL queries	Server hosting	API testing	A	\N	easy	\N	general	117	\N	topic
1377	Can Figma be used collaboratively?	Yes	No	Only offline	Only on mobile	A	\N	easy	\N	general	117	\N	topic
1378	Which feature in Figma organizes design elements?	Frames	Indexes	Routes	Queries	A	\N	easy	\N	general	117	\N	topic
1379	What are components in Figma?	Reusable design elements	Database tables	Security layers	Code files	A	\N	medium	\N	general	117	\N	topic
1380	Why use auto layout in Figma?	To create flexible layouts	To delete layers	To write SQL	To encrypt data	A	\N	medium	\N	general	117	\N	topic
1381	What is prototyping in Figma?	Connecting screens for interaction	Creating tables	Testing APIs	Deploying apps	A	\N	medium	\N	general	117	\N	topic
1382	What does a style in Figma help with?	Consistency in colors/text	Database speed	Network security	Routing	A	\N	medium	\N	general	117	\N	topic
1383	What is a variant in Figma?	Different states of a component	A SQL join	A server log	A backup type	A	\N	hard	\N	general	117	\N	topic
1384	Why are components powerful?	They speed reuse and consistency	They replace research	They store user data	They deploy apps	A	\N	hard	\N	general	117	\N	topic
1385	What is a user flow?	Path a user takes through a product	A CSS animation	A database query	A server route only	A	\N	easy	\N	general	118	\N	topic
1386	What is information architecture?	Organizing content and structure	Encrypting data	Deploying apps	Styling buttons	A	\N	easy	\N	general	118	\N	topic
1387	Why are user flows important?	They show how users complete tasks	They replace UI design	They increase bugs	They style screens	A	\N	easy	\N	general	118	\N	topic
1388	What does IA help with?	Navigation and content organization	Database indexing	Authentication only	Caching only	A	\N	easy	\N	general	118	\N	topic
1389	What is a sitemap?	A map of pages/content	A server log	A query result	A color palette	A	\N	medium	\N	general	118	\N	topic
1390	Why should navigation be clear?	To help users find content easily	To hide screens	To slow usage	To increase confusion	A	\N	medium	\N	general	118	\N	topic
1391	What is a task flow?	Steps for one user goal	All database steps	Deployment steps	Animation order	A	\N	medium	\N	general	118	\N	topic
1392	Which improves IA?	Logical grouping of content	Random menus	Too many layers	Hidden labels	A	\N	medium	\N	general	118	\N	topic
1393	What is the main goal of user flows?	Reduce friction in task completion	Add more pages	Increase clicks	Hide actions	A	\N	hard	\N	general	118	\N	topic
1394	Which harms information architecture?	Confusing labels	Clear categories	Simple hierarchy	Consistent navigation	A	\N	hard	\N	general	118	\N	topic
1395	What is a prototype?	Interactive model of a design	Database backup	API endpoint	CSS framework	A	\N	easy	\N	general	119	\N	topic
1396	Why create prototypes?	Test interactions before development	Delete features	Skip design	Write backend faster	A	\N	easy	\N	general	119	\N	topic
1397	A prototype helps show?	How screens connect and behave	Database joins	Server logs	Security rules	A	\N	easy	\N	general	119	\N	topic
1398	What can be tested with a prototype?	User flow	SQL syntax	Docker setup	Indexes	A	\N	easy	\N	general	119	\N	topic
1399	What is high-fidelity prototype?	Detailed and close to final product	Rough sketch only	Backend code	Database schema	A	\N	medium	\N	general	119	\N	topic
1400	What is low-fidelity prototype?	Simple and basic version	Fully developed app	Security diagram	SQL script	A	\N	medium	\N	general	119	\N	topic
1401	Why use clickable prototypes?	To simulate navigation	To deploy app	To store files	To hash passwords	A	\N	medium	\N	general	119	\N	topic
1402	Which tool is often used for prototyping?	Figma	pgAdmin	Postman	Node	A	\N	medium	\N	general	119	\N	topic
1403	What is a main benefit of prototyping?	Catching usability issues early	Increasing server cost	Replacing coding completely	Removing design feedback	A	\N	hard	\N	general	119	\N	topic
1404	What should prototype interactions reflect?	Expected user behavior	Database normalization	Firewall settings	Cloud scaling	A	\N	hard	\N	general	119	\N	topic
1405	What is usability testing?	Testing how easy a product is to use	Testing databases	Testing CSS only	Deploying app	A	\N	easy	\N	general	120	\N	topic
1406	Who participates in usability testing?	Real or representative users	Only developers	Only servers	Only designers	A	\N	easy	\N	general	120	\N	topic
1407	Why do usability tests?	Find usability problems	Increase bugs	Slow the app	Avoid feedback	A	\N	easy	\N	general	120	\N	topic
1408	What do users perform in usability tests?	Tasks	SQL queries	Deployments	Backups	A	\N	easy	\N	general	120	\N	topic
1409	What is an observation in usability testing?	Watching how users interact	Deleting data	Changing CSS	Routing screens	A	\N	medium	\N	general	120	\N	topic
1410	What is a moderator?	Person guiding the test	Database admin	API server	Security scanner	A	\N	medium	\N	general	120	\N	topic
1411	Which result is valuable from testing?	Pain points and confusion	Font list only	Only colors	Only logs	A	\N	medium	\N	general	120	\N	topic
1412	What should tasks in testing be?	Realistic	Impossible	Unclear	Very technical only	A	\N	medium	\N	general	120	\N	topic
1413	What is the goal of usability testing?	Improve product usability	Replace design	Delete screens	Skip research	A	\N	hard	\N	general	120	\N	topic
1414	Which harms a usability test?	Leading the user too much	Neutral observation	Clear tasks	Recording findings	A	\N	hard	\N	general	120	\N	topic
1415	What is responsive design?	Design that adapts to screen sizes	A database feature	A backend service	A testing method	A	\N	easy	\N	general	121	\N	topic
1416	Why is responsive design important?	Users use different devices	To remove layouts	To avoid testing	To slow websites	A	\N	easy	\N	general	121	\N	topic
1417	Which devices benefit from responsive design?	Mobile, tablet, and desktop	Servers only	Printers only	Keyboards only	A	\N	easy	\N	general	121	\N	topic
1418	What should responsive UI maintain?	Usability across sizes	Same bug count	Only desktop layout	Only mobile layout	A	\N	easy	\N	general	121	\N	topic
1419	What helps build responsive layouts?	Grids and flexible spacing	Hardcoded fixed sizes only	Random positioning	No structure	A	\N	medium	\N	general	121	\N	topic
1420	Why test designs on multiple screens?	To ensure consistency and usability	To delete components	To avoid wireframes	To increase confusion	A	\N	medium	\N	general	121	\N	topic
1421	What is a breakpoint?	Screen width where layout changes	Database limit	API timeout	Security level	A	\N	medium	\N	general	121	\N	topic
1422	Which is better for responsive text?	Scalable sizing	One tiny size	Random sizes	Only uppercase text	A	\N	medium	\N	general	121	\N	topic
1423	What is a risk of poor responsive design?	Broken layout and bad UX	Better performance	Simpler navigation	More accessibility	A	\N	hard	\N	general	121	\N	topic
1424	Which principle is key in responsive UI/UX?	Adapt content and hierarchy by screen	Use identical spacing always	Ignore device context	Hide important actions	A	\N	hard	\N	general	121	\N	topic
1425	What is a design system?	Collection of reusable design standards/components	A database model	A server architecture	A testing report	A	\N	easy	\N	general	122	\N	topic
1426	Why use a design system?	Consistency and speed	Random styling	More bugs	Slower work	A	\N	easy	\N	general	122	\N	topic
1427	What do design systems include?	Components, styles, and guidelines	Only SQL queries	Only backend code	Only animations	A	\N	easy	\N	general	122	\N	topic
1428	What is a reusable component?	Element used in many places	A deleted layer	A route	A log file	A	\N	easy	\N	general	122	\N	topic
1429	What is a design token?	Named value like color/spacing	A database key	An API secret	A build tool	A	\N	medium	\N	general	122	\N	topic
1430	Why are component libraries useful?	They reduce repeated work	They remove UX research	They replace testing	They delete layouts	A	\N	medium	\N	general	122	\N	topic
1431	What does consistency improve?	User understanding	Confusion	Bug count	Loading time only	A	\N	medium	\N	general	122	\N	topic
1432	Who benefits from design systems?	Designers and developers	Only databases	Only servers	Only testers	A	\N	medium	\N	general	122	\N	topic
1433	What happens without a design system?	Inconsistency grows	Everything becomes faster always	Testing is not needed	Security improves automatically	A	\N	hard	\N	general	122	\N	topic
1434	Which is a core goal of design systems?	Scalable, maintainable product design	More random styles	Fewer components	No guidelines	A	\N	hard	\N	general	122	\N	topic
1435	What is accessibility in design?	Making products usable for more people	Making designs colorful	Creating SQL queries	Deploying apps	A	\N	easy	\N	general	123	\N	topic
1436	Who benefits from accessible design?	Everyone, especially users with disabilities	Only developers	Only designers	Only admins	A	\N	easy	\N	general	123	\N	topic
1437	Why is text contrast important?	Readability	Database speed	API security	Animation timing	A	\N	easy	\N	general	123	\N	topic
1438	Why label form fields clearly?	To improve usability and accessibility	To slow forms	To hide content	To style backend	A	\N	easy	\N	general	123	\N	topic
1439	What is an accessible button?	Clearly labeled and easy to use	Hidden without text	Very tiny only	Image without purpose	A	\N	medium	\N	general	123	\N	topic
1440	Why avoid relying on color alone?	Some users may not distinguish it	Colors break servers	It slows apps	It removes UX	A	\N	medium	\N	general	123	\N	topic
1441	What helps keyboard users?	Logical focus order	Random focus jumps	No focus states	Hidden navigation	A	\N	medium	\N	general	123	\N	topic
1442	What should icons often include?	Labels or context	Only decoration	Random colors	Database tags	A	\N	medium	\N	general	123	\N	topic
1443	What is inclusive design aiming for?	Broader usability	More complexity	Fewer users	Harder tasks	A	\N	hard	\N	general	123	\N	topic
1444	Which harms accessibility most?	Low contrast and unclear labels	Readable text	Clear buttons	Consistent navigation	A	\N	hard	\N	general	123	\N	topic
1445	What is interaction design?	Designing how users interact with interfaces	Database design	Server setup	SQL formatting	A	\N	easy	\N	general	124	\N	topic
1446	Why are interactions important?	They shape user experience	They replace UI	They delete bugs	They remove navigation	A	\N	easy	\N	general	124	\N	topic
1447	What is feedback in interaction design?	System response to user actions	A database row	A SQL error	A server log	A	\N	easy	\N	general	124	\N	topic
1448	What is a microinteraction?	Small focused interaction	Database backup	API request only	Design token	A	\N	easy	\N	general	124	\N	topic
1449	Why use transitions carefully?	To support clarity and flow	To slow everything	To replace structure	To hide errors	A	\N	medium	\N	general	124	\N	topic
1450	What is affordance?	Clue about how to use an element	A backend method	A query optimization	A cloud model	A	\N	medium	\N	general	124	\N	topic
1451	Why is feedback timing important?	Users need immediate response	Servers require colors	It replaces research	It changes SQL	A	\N	medium	\N	general	124	\N	topic
1452	What is interaction consistency?	Similar behavior across product	Random behavior	No patterns	Different buttons everywhere	A	\N	medium	\N	general	124	\N	topic
1453	What makes advanced interactions effective?	They help tasks without adding confusion	They are flashy only	They replace usability	They remove hierarchy	A	\N	hard	\N	general	124	\N	topic
1454	Which is a risk of poor interaction design?	User confusion and mistakes	Better performance	Less friction	Simpler flow	A	\N	hard	\N	general	124	\N	topic
1455	What is an advanced design system?	A mature scalable system with rules and governance	A single color file	A server tool	A query library	A	\N	easy	\N	general	125	\N	topic
1456	Why evolve a design system?	Support larger products and teams	Delete components	Reduce consistency	Avoid documentation	A	\N	easy	\N	general	125	\N	topic
1457	What is governance in design systems?	Managing how the system is maintained	Deleting UI	Storing passwords	Deploying backend	A	\N	easy	\N	general	125	\N	topic
1458	What is documentation for in design systems?	Explain usage and standards	Hide decisions	Replace design	Store SQL	A	\N	easy	\N	general	125	\N	topic
1459	Why use component variants?	Support different states consistently	Increase randomness	Remove reuse	Hide styles	A	\N	medium	\N	general	125	\N	topic
1460	What is contribution model?	How teams add/update system parts	A server model	A DB schema	A cloud model	A	\N	medium	\N	general	125	\N	topic
1461	What should advanced systems support?	Scalability and consistency	Only one page	No reuse	No testing	A	\N	medium	\N	general	125	\N	topic
1462	Why sync design and code components?	Reduce mismatch between design and implementation	Increase bugs	Remove documentation	Avoid collaboration	A	\N	medium	\N	general	125	\N	topic
1463	What is a key challenge in advanced systems?	Keeping adoption and consistency across teams	Choosing a font once	Adding one button	Changing one color	A	\N	hard	\N	general	125	\N	topic
1464	What strengthens a design system long-term?	Clear governance and documentation	Random updates	No ownership	No standards	A	\N	hard	\N	general	125	\N	topic
1465	What is UX strategy?	Plan for delivering user-centered experience	A CSS style	A database strategy	A server configuration	A	\N	easy	\N	general	126	\N	topic
1466	Why use UX strategy?	Align product goals with user needs	Slow the process	Skip research	Remove testing	A	\N	easy	\N	general	126	\N	topic
1467	What should UX strategy consider?	Users, business goals, and product vision	Only colors	Only APIs	Only servers	A	\N	easy	\N	general	126	\N	topic
1468	What helps shape UX strategy?	Research insights	Random guesses	Only typography	Only branding	A	\N	easy	\N	general	126	\N	topic
1469	Why connect UX to business goals?	To create valuable outcomes	To ignore users	To remove features	To style pages	A	\N	medium	\N	general	126	\N	topic
1470	What is a product vision?	High-level direction for the product	A SQL command	A CSS token	A server log	A	\N	medium	\N	general	126	\N	topic
1471	What is prioritization in UX?	Choosing most valuable improvements first	Adding everything	Deleting all features	Ignoring feedback	A	\N	medium	\N	general	126	\N	topic
1472	What does UX strategy help teams do?	Make intentional product decisions	Only create wireframes	Only test APIs	Only style screens	A	\N	medium	\N	general	126	\N	topic
1473	What weakens UX strategy?	No research or alignment	Clear goals	Evidence-based choices	Cross-team collaboration	A	\N	hard	\N	general	126	\N	topic
1474	What is a sign of strong UX strategy?	Consistent decisions tied to user and business value	Random features	No direction	Only visual polish	A	\N	hard	\N	general	126	\N	topic
1475	What are data-driven design decisions?	Using evidence to guide design choices	Using only guesses	Using CSS rules	Using backend logs only	A	\N	easy	\N	general	127	\N	topic
1476	Why use data in design?	To understand what works	To avoid users	To skip testing	To remove strategy	A	\N	easy	\N	general	127	\N	topic
1477	Which can provide design data?	Analytics	Only colors	Only fonts	Only HTML	A	\N	easy	\N	general	127	\N	topic
1478	What can metrics show?	User behavior	Server styling	Database colors	API themes	A	\N	easy	\N	general	127	\N	topic
1479	What is A/B testing?	Comparing two versions	Deleting two screens	Two databases	Two servers	A	\N	medium	\N	general	127	\N	topic
1480	Why combine data with research?	Numbers need context	To remove insights	To avoid users	To skip analysis	A	\N	medium	\N	general	127	\N	topic
1481	What is a KPI?	Key performance indicator	Key page icon	Known product image	Keyboard process input	A	\N	medium	\N	general	127	\N	topic
1482	What can analytics reveal?	Drop-off points and engagement	Only font names	Only passwords	Only backups	A	\N	medium	\N	general	127	\N	topic
1483	What is a risk of using data poorly?	Optimizing wrong metric	Better usability automatically	No bias	No mistakes	A	\N	hard	\N	general	127	\N	topic
1484	Best design decisions use?	Data plus user understanding	Only random ideas	Only visual taste	Only technical constraints	A	\N	hard	\N	general	127	\N	topic
1485	What is advanced user research?	Deeper methods for understanding users	CSS optimization	Server hardening	Database scaling	A	\N	easy	\N	general	128	\N	topic
1486	Why do advanced research?	Get richer insights for better decisions	Remove research	Skip testing	Only style UI	A	\N	easy	\N	general	128	\N	topic
1487	Which is an advanced research activity?	Usability study with detailed analysis	Deleting rows	Deploying app	Creating routes	A	\N	easy	\N	general	128	\N	topic
1488	What can advanced research uncover?	Hidden motivations and patterns	Only colors	Only fonts	Only code syntax	A	\N	easy	\N	general	128	\N	topic
1489	What is qualitative research?	Research about opinions/behaviors	Only numeric reports	Only server logs	Only SQL data	A	\N	medium	\N	general	128	\N	topic
1490	What is quantitative research?	Research using measurable numbers	Only interviews	Only sketches	Only prototypes	A	\N	medium	\N	general	128	\N	topic
1491	Why triangulate research?	Validate insights using multiple methods	Delete duplicate users	Avoid analysis	Replace design	A	\N	medium	\N	general	128	\N	topic
1492	What is diary study used for?	Understanding behavior over time	Styling pages	Deploying builds	Creating indexes	A	\N	medium	\N	general	128	\N	topic
1493	What makes advanced research strong?	Clear methodology and synthesis	Random notes	No participants	Only screenshots	A	\N	hard	\N	general	128	\N	topic
1494	Which weakens research quality?	Biased questions	Neutral prompts	Representative users	Clear goals	A	\N	hard	\N	general	128	\N	topic
1495	What is a design portfolio?	Collection of your design work	A database backup	A server monitor	A CSS file	A	\N	easy	\N	general	129	\N	topic
1496	Why make case studies?	Explain process and decisions	Hide your work	Skip research	Avoid feedback	A	\N	easy	\N	general	129	\N	topic
1497	What should a case study show?	Problem, process, and outcome	Only final colors	Only code	Only screenshots	A	\N	easy	\N	general	129	\N	topic
1498	Who is the audience of a portfolio?	Recruiters, clients, and teams	Only databases	Only servers	Only APIs	A	\N	easy	\N	general	129	\N	topic
1499	Why include process in a case study?	Shows how you think and solve problems	Makes it longer only	Replaces visuals	Removes outcomes	A	\N	medium	\N	general	129	\N	topic
1500	What improves a portfolio most?	Clear storytelling	Random layout	Too much text without structure	No context	A	\N	medium	\N	general	129	\N	topic
1501	What should case study results mention?	Impact and learnings	Only colors	Only icons	Only fonts	A	\N	medium	\N	general	129	\N	topic
1502	Why keep portfolio organized?	Helps viewers scan and understand quickly	To hide weak work	To avoid readability	To remove hierarchy	A	\N	medium	\N	general	129	\N	topic
1503	What makes a strong case study?	Clear problem, evidence, solution, and outcome	Only final mockup	Only backend details	Only animation	A	\N	hard	\N	general	129	\N	topic
1504	Which hurts a portfolio most?	Lack of context and cluttered presentation	Clear structure	Relevant examples	Readable layout	A	\N	hard	\N	general	129	\N	topic
1505	What is cloud computing?	Using remote computing resources over the internet	A UI framework	A database language	A CSS library	A	\N	easy	\N	general	130	\N	topic
1506	What is a main benefit of cloud computing?	On-demand resources	Hardcoded infrastructure only	No internet access	No scalability	A	\N	easy	\N	general	130	\N	topic
1507	Cloud services are accessed through?	Internet	Printer cable	BIOS only	CSS files	A	\N	easy	\N	general	130	\N	topic
1508	Which is an example of cloud provider?	AWS	HTML	Figma	Postman	A	\N	easy	\N	general	130	\N	topic
1509	Why do companies use cloud computing?	Flexibility and scalability	To remove servers completely from reality	To avoid all security	To stop backups	A	\N	medium	\N	general	130	\N	topic
1510	What does on-demand mean in cloud?	Resources available when needed	Resources only once a month	Resources without billing	Resources without internet	A	\N	medium	\N	general	130	\N	topic
1511	Which cloud feature helps reduce upfront hardware cost?	Pay-as-you-go	Manual deployment only	Physical-only storage	Static servers only	A	\N	medium	\N	general	130	\N	topic
1512	What is elasticity in cloud?	Ability to scale resources up or down	Deleting all resources	Changing UI color	Encrypting CSS	A	\N	medium	\N	general	130	\N	topic
1513	Which cloud characteristic helps handle varying traffic?	Elastic scaling	Fixed hardware only	No automation	Manual coding only	A	\N	hard	\N	general	130	\N	topic
1514	What is a trade-off of cloud computing?	Need to manage cost and configuration carefully	No internet is ever needed	No maintenance exists	No security concerns exist	A	\N	hard	\N	general	130	\N	topic
1515	What does IaaS stand for?	Infrastructure as a Service	Interface as a Service	Internet as a Service	Integration as a Service	A	\N	easy	\N	general	131	\N	topic
1516	What does PaaS stand for?	Platform as a Service	Programming as a Service	Project as a Service	Process as a Service	A	\N	easy	\N	general	131	\N	topic
1517	What does SaaS stand for?	Software as a Service	Storage as a Service	Security as a Service	System as a Service	A	\N	easy	\N	general	131	\N	topic
1518	Which model gives users finished software over the internet?	SaaS	IaaS	PaaS	LAN	A	\N	easy	\N	general	131	\N	topic
1519	Which service model provides virtual machines and storage?	IaaS	SaaS	PaaS	UIaaS	A	\N	medium	\N	general	131	\N	topic
1520	Which model is best when developers only want to deploy code?	PaaS	IaaS	SaaS	FTP	A	\N	medium	\N	general	131	\N	topic
1521	Which service model includes apps like Gmail or Google Docs?	SaaS	IaaS	PaaS	Bare metal	A	\N	medium	\N	general	131	\N	topic
1522	Which model gives the most infrastructure control?	IaaS	SaaS	PaaS	Shared hosting only	A	\N	medium	\N	general	131	\N	topic
1523	Which model abstracts most infrastructure from developers?	PaaS	IaaS	Bare metal	Self-hosted only	A	\N	hard	\N	general	131	\N	topic
1524	Which is the correct order from most control to least?	IaaS → PaaS → SaaS	SaaS → PaaS → IaaS	PaaS → SaaS → IaaS	IaaS → SaaS → PaaS	A	\N	hard	\N	general	131	\N	topic
1525	Which deployment model is available to the public?	Public cloud	Private cloud	Hybrid cloud	Local-only cloud	A	\N	easy	\N	general	132	\N	topic
1526	Which deployment model is dedicated to one organization?	Private cloud	Public cloud	Shared cloud	Open cloud	A	\N	easy	\N	general	132	\N	topic
1527	What is hybrid cloud?	Combination of public and private cloud	Only public internet	Only local storage	Only mobile cloud	A	\N	easy	\N	general	132	\N	topic
1528	Which model offers the most organizational control?	Private cloud	Public cloud	Community cloud	Hybrid cloud	A	\N	easy	\N	general	132	\N	topic
1529	Why use hybrid cloud?	Balance flexibility and control	To remove networking	To avoid scaling	To avoid all security rules	A	\N	medium	\N	general	132	\N	topic
1530	Which deployment model is usually fastest to start with?	Public cloud	Private cloud	On-prem only	Hybrid always	A	\N	medium	\N	general	132	\N	topic
1531	What is a common reason to choose private cloud?	Compliance and control needs	No users	No network	Only CSS hosting	A	\N	medium	\N	general	132	\N	topic
1532	What does community cloud mean?	Cloud shared by organizations with similar needs	Cloud for gaming only	Cloud without security	Cloud for one laptop	A	\N	medium	\N	general	132	\N	topic
1533	Which model often requires integration planning between environments?	Hybrid cloud	Public cloud	Local CSS	Single VM only	A	\N	hard	\N	general	132	\N	topic
1534	Which deployment model may cost more due to dedicated resources?	Private cloud	Public cloud	Shared SaaS only	Static website hosting	A	\N	hard	\N	general	132	\N	topic
1535	What is a virtual machine?	Software-based computer running its own OS	A CSS framework	A database index	A UI component	A	\N	easy	\N	general	133	\N	topic
1536	What is a container?	Lightweight packaged application with dependencies	A printed box	A database row	A router protocol	A	\N	easy	\N	general	133	\N	topic
1537	Which is usually lighter than a virtual machine?	Container	Physical server	Database	CSS file	A	\N	easy	\N	general	133	\N	topic
1538	What does a VM include that containers usually do not?	Full guest operating system	App code only	Only CSS	Only network logs	A	\N	easy	\N	general	133	\N	topic
1539	Why are containers popular?	Fast startup and portability	They replace all databases	They remove networking	They only run on phones	A	\N	medium	\N	general	133	\N	topic
1540	What is hypervisor used for?	Running virtual machines	Styling UI	Managing fonts	Writing SQL	A	\N	medium	\N	general	133	\N	topic
1541	Which tool is common for containers?	Docker	Photoshop	Excel	pgAdmin	A	\N	medium	\N	general	133	\N	topic
1542	Why use virtualization?	Better resource utilization and isolation	To remove operating systems	To avoid backups	To disable security	A	\N	medium	\N	general	133	\N	topic
1543	Which is usually better for microservice packaging?	Containers	Monitors	CSS files	Spreadsheets	A	\N	hard	\N	general	133	\N	topic
1544	Which option generally has higher overhead?	Virtual machine	Container	Static file	API key	A	\N	hard	\N	general	133	\N	topic
1545	What is cloud storage?	Storing data on remote cloud servers	A design system	A coding language	A CSS property	A	\N	easy	\N	general	134	\N	topic
1546	Why use cloud storage?	Accessible and scalable data storage	To remove all backups	To avoid internet	To replace code	A	\N	easy	\N	general	134	\N	topic
1547	Which is a type of cloud storage?	Object storage	UI storage	CSS storage	Route storage	A	\N	easy	\N	general	134	\N	topic
1548	What can be stored in cloud storage?	Files and data	Only colors	Only code comments	Only fonts	A	\N	easy	\N	general	134	\N	topic
1549	What is object storage good for?	Files, media, and backups	Only SQL joins	Only CSS	Only runtime memory	A	\N	medium	\N	general	134	\N	topic
1550	What is block storage often used for?	Virtual machine disks	Typography	Wireframes	Icons only	A	\N	medium	\N	general	134	\N	topic
1551	What is file storage used for?	Shared file systems	Firewall rules	API tokens	Color palettes	A	\N	medium	\N	general	134	\N	topic
1552	Why is redundancy important in storage?	Improves data durability	Removes scaling	Deletes backups	Improves font rendering	A	\N	medium	\N	general	134	\N	topic
1553	What helps protect stored cloud data?	Encryption and access control	Public write access	Weak passwords	No backups	A	\N	hard	\N	general	134	\N	topic
1554	Which storage choice best fits large media assets?	Object storage	Local CSS variable	SQL function	Browser history	A	\N	hard	\N	general	134	\N	topic
1555	What is AWS?	A cloud provider	A CSS framework	A database language	A browser engine	A	\N	easy	\N	general	135	\N	topic
1556	What is Azure?	A cloud provider	A UI library	A testing tool	A font pack	A	\N	easy	\N	general	135	\N	topic
1557	AWS and Azure provide?	Cloud services	Only web colors	Only local files	Only mobile widgets	A	\N	easy	\N	general	135	\N	topic
1558	Which provider offers virtual machines and storage?	AWS and Azure	HTML and CSS	Figma and Postman	Only browsers	A	\N	easy	\N	general	135	\N	topic
1559	Why learn cloud providers?	To deploy and manage applications	To replace UX	To avoid infrastructure	To remove testing	A	\N	medium	\N	general	135	\N	topic
1560	What is a cloud console?	Web interface for managing services	Database schema	Code editor only	Image viewer	A	\N	medium	\N	general	135	\N	topic
1561	Which service category is common in AWS/Azure?	Compute	Typography	Wireframes	Animations only	A	\N	medium	\N	general	135	\N	topic
1562	What is a region in cloud providers?	Geographic location of data centers	A CSS rule	A route param	A query group	A	\N	medium	\N	general	135	\N	topic
1563	Why choose a nearby region?	Lower latency	Bigger fonts	Better colors	More SQL keywords	A	\N	hard	\N	general	135	\N	topic
1564	What should be considered when choosing a provider?	Services, cost, region, and skills	Only logo color	Only homepage design	Only icon style	A	\N	hard	\N	general	135	\N	topic
1565	What are compute services?	Cloud services that run applications/workloads	Design tools	Database schemas	CSS assets	A	\N	easy	\N	general	136	\N	topic
1566	Which cloud resource runs virtual servers?	Compute instance	Color token	Typography scale	Wireframe	A	\N	easy	\N	general	136	\N	topic
1567	Why use compute services?	Run backend apps and jobs	Store only fonts	Create only icons	Replace all storage	A	\N	easy	\N	general	136	\N	topic
1568	Which is an example of compute usage?	Hosting a web app	Changing button color	Writing Figma comments	Sorting images manually	A	\N	easy	\N	general	136	\N	topic
1569	What is auto scaling?	Automatically adjusting compute resources	Deleting resources	Styling layouts	Encrypting CSS	A	\N	medium	\N	general	136	\N	topic
1570	Why use load balancing with compute?	Distribute traffic across instances	Store backups only	Improve typography	Reduce colors	A	\N	medium	\N	general	136	\N	topic
1571	What is serverless compute?	Run code without managing servers directly	No servers exist anywhere	Only local execution	Only CSS rendering	A	\N	medium	\N	general	136	\N	topic
1572	What affects compute cost?	Usage time and resource size	Only icon count	Only font choice	Only CSS classes	A	\N	medium	\N	general	136	\N	topic
1573	Which option is best for unpredictable traffic?	Auto scaling compute	One tiny fixed server only	No monitoring	Manual deployment only	A	\N	hard	\N	general	136	\N	topic
1574	What is a key advantage of serverless?	Less infrastructure management	No need for code	No billing	No security responsibilities	A	\N	hard	\N	general	136	\N	topic
1575	What is cloud networking?	Connecting cloud resources securely	A font system	A database index	A UI pattern	A	\N	easy	\N	general	137	\N	topic
1576	What is a VPC/VNet used for?	Private cloud network space	Image storage	Typography settings	API styling	A	\N	easy	\N	general	137	\N	topic
1577	What controls allowed traffic in cloud networks?	Security rules/groups	Color tokens	Wireframes	Mockups	A	\N	easy	\N	general	137	\N	topic
1578	What is a subnet?	Smaller network segment	A UI component	A storage bucket	A SQL subquery	A	\N	easy	\N	general	137	\N	topic
1579	Why use subnets?	Organize and isolate resources	Delete traffic	Speed up fonts	Replace servers	A	\N	medium	\N	general	137	\N	topic
1580	What is an IP address used for?	Identifying devices/resources on network	Styling forms	Naming components	Sorting tables	A	\N	medium	\N	general	137	\N	topic
1581	What is a public subnet?	Subnet reachable from internet	Subnet with no addresses	A database table	A CSS block	A	\N	medium	\N	general	137	\N	topic
1582	What is a private subnet?	Subnet not directly exposed to internet	A public website only	A font set	An icon pack	A	\N	medium	\N	general	137	\N	topic
1583	Which improves network security?	Least-access network rules	Allow all traffic	No segmentation	Public everything	A	\N	hard	\N	general	137	\N	topic
1584	What is a common network design principle?	Separate public and private resources	Put everything in one open subnet	Remove all rules	Ignore IP planning	A	\N	hard	\N	general	137	\N	topic
1585	What is a cloud database?	Database hosted in cloud infrastructure	A CSS variable	A UI component	A browser cache only	A	\N	easy	\N	general	138	\N	topic
1586	Why use databases in the cloud?	Managed scaling, backup, and availability	To remove all data models	To avoid storage	To replace APIs	A	\N	easy	\N	general	138	\N	topic
1587	Which type can be hosted in cloud?	Relational and NoSQL databases	Only spreadsheets	Only CSS	Only images	A	\N	easy	\N	general	138	\N	topic
1588	What is a managed database service?	Cloud provider manages many admin tasks	Database without users	A design system	A routing library	A	\N	easy	\N	general	138	\N	topic
1589	What is a benefit of managed cloud DB?	Automated backups and patching	No cost ever	No internet required	No security work at all	A	\N	medium	\N	general	138	\N	topic
1590	Why consider database region?	Latency and compliance	Font loading	Button styles	Animation timing	A	\N	medium	\N	general	138	\N	topic
1591	What is replication in databases?	Copying data for availability/read scaling	Deleting duplicates only	Styling backups	Rendering UI	A	\N	medium	\N	general	138	\N	topic
1592	What helps protect cloud database access?	Network rules and authentication	Public anonymous access	Weak passwords	No encryption	A	\N	medium	\N	general	138	\N	topic
1593	What is a major risk with cloud databases?	Misconfiguration and exposed access	Too much typography	Too many icons	Too many wireframes	A	\N	hard	\N	general	138	\N	topic
1594	What improves reliability of a cloud database?	Backups, monitoring, and replication	One local screenshot	Only CSS cleanup	Removing indexes always	A	\N	hard	\N	general	138	\N	topic
1595	What does IAM stand for?	Identity and Access Management	Interface Access Model	Internet Admin Method	Indexed Access Matrix	A	\N	easy	\N	general	139	\N	topic
1596	What is IAM used for?	Managing identities and permissions	Styling UI	Drawing wireframes	Writing SQL only	A	\N	easy	\N	general	139	\N	topic
1597	What is a role in IAM?	Set of permissions	Color palette	Route file	Storage disk	A	\N	easy	\N	general	139	\N	topic
1598	What is least privilege?	Grant only necessary permissions	Give everyone admin	No permissions ever	Open public access	A	\N	easy	\N	general	139	\N	topic
1599	Why avoid shared accounts?	Harder auditing and security risks	Better collaboration always	More colors	Faster CSS	A	\N	medium	\N	general	139	\N	topic
1600	What is MFA?	Multi-factor authentication	Managed file access	Main function app	Manual firewall action	A	\N	medium	\N	general	139	\N	topic
1601	Why use IAM policies?	Control who can do what	Style pages	Sort data	Compress images	A	\N	medium	\N	general	139	\N	topic
1602	What helps track access activity?	Audit logs	Typography scale	Component variants	Wireframes	A	\N	medium	\N	general	139	\N	topic
1603	Which is safest?	Specific scoped permissions	Administrator for everyone	Public write access	Single shared password	A	\N	hard	\N	general	139	\N	topic
1604	What is a common IAM mistake?	Overly broad permissions	Using least privilege	Using MFA	Reviewing access	A	\N	hard	\N	general	139	\N	topic
1605	Why monitor cloud systems?	Track health and performance	Change font size	Design icons	Remove APIs	A	\N	easy	\N	general	140	\N	topic
1606	What are logs?	Recorded system/application events	UI mockups	CSS themes	Database tables only	A	\N	easy	\N	general	140	\N	topic
1607	Why are logs useful?	Troubleshooting and auditing	Choosing colors	Drawing wireframes	Replacing testing	A	\N	easy	\N	general	140	\N	topic
1608	What can monitoring show?	CPU, memory, errors, traffic	Only typography	Only screen size	Only icon count	A	\N	easy	\N	general	140	\N	topic
1609	What is an alert?	Notification when metric/event crosses threshold	A design token	A SQL join	A CSS class	A	\N	medium	\N	general	140	\N	topic
1610	Why centralize logs?	Easier searching and analysis	More random output	Less security	More duplicate data	A	\N	medium	\N	general	140	\N	topic
1611	What is an uptime metric?	Availability of a system	Color consistency	Layout spacing	Font readability	A	\N	medium	\N	general	140	\N	topic
1612	Why monitor latency?	Measure responsiveness	Measure only colors	Delete slow queries	Replace backups	A	\N	medium	\N	general	140	\N	topic
1613	What helps detect incidents faster?	Alerts and dashboards	More screenshots	Longer CSS	No logging	A	\N	hard	\N	general	140	\N	topic
1614	What is a risk of poor logging?	Harder debugging and auditing	Faster troubleshooting	Better security automatically	Simpler costs	A	\N	hard	\N	general	140	\N	topic
1615	What is cloud deployment?	Releasing an app to cloud infrastructure	Changing button styles	Creating icons	Writing only SQL	A	\N	easy	\N	general	141	\N	topic
1616	Why deploy to cloud?	Scalability and accessibility	To remove internet	To avoid users	To replace design	A	\N	easy	\N	general	141	\N	topic
1617	What is a deployment pipeline?	Automated steps to build and release	A color system	A storage bucket	A font list	A	\N	easy	\N	general	141	\N	topic
1618	What usually happens before deployment?	Build and test	Only choose colors	Only make wireframes	Only rename files	A	\N	easy	\N	general	141	\N	topic
1619	What is an environment?	Separate setup like dev/test/prod	A CSS class	A SQL alias	An icon set	A	\N	medium	\N	general	141	\N	topic
1620	Why use staging?	Test before production release	Hide code forever	Delete backups	Avoid monitoring	A	\N	medium	\N	general	141	\N	topic
1621	What is rollback?	Revert to previous version	Delete all code	Reset colors	Move to another font	A	\N	medium	\N	general	141	\N	topic
1622	Why automate deployment?	Consistency and speed	More manual work	Less reliability	No testing	A	\N	medium	\N	general	141	\N	topic
1623	What reduces release risk?	Testing and staged rollout	Deploying untested code	Ignoring logs	No backup plan	A	\N	hard	\N	general	141	\N	topic
1624	What is production environment?	Live environment used by real users	Design file only	Local sketch only	Temporary CSS lab	A	\N	hard	\N	general	141	\N	topic
1625	What is cloud architecture?	Structure of cloud resources and services	A font pack	A wireframe	A CSS reset	A	\N	easy	\N	general	142	\N	topic
1626	Why design cloud architecture carefully?	Performance, security, and scalability	Only aesthetics	Only typography	Only colors	A	\N	easy	\N	general	142	\N	topic
1627	What is a common architecture goal?	High availability	Random layouts	More manual work	No monitoring	A	\N	easy	\N	general	142	\N	topic
1628	What does high availability mean?	System stays accessible even during failures	More icons	No backups	Only one server	A	\N	easy	\N	general	142	\N	topic
1629	Why use multiple availability zones/regions?	Improve resilience	Delete redundancy	Reduce all costs automatically	Avoid monitoring	A	\N	medium	\N	general	142	\N	topic
1630	What is fault tolerance?	System keeps working during failures	No errors ever	Only UI fallback	Color consistency	A	\N	medium	\N	general	142	\N	topic
1631	Why separate app tiers?	Better isolation and scalability	To remove security	To hide code	To avoid databases	A	\N	medium	\N	general	142	\N	topic
1632	What is a reference architecture?	Reusable recommended design pattern	A SQL dump	A font file	A log line	A	\N	medium	\N	general	142	\N	topic
1633	What is a key architecture trade-off?	Cost vs resilience/performance	Buttons vs icons	Fonts vs colors	CSS vs HTML	A	\N	hard	\N	general	142	\N	topic
1634	Which principle strengthens cloud architecture?	Design for failure	Assume nothing breaks	Use one zone only	Ignore scaling	A	\N	hard	\N	general	142	\N	topic
1635	What is Kubernetes?	Container orchestration platform	A database	A design tool	A CSS library	A	\N	easy	\N	general	143	\N	topic
1636	Why use Kubernetes?	Manage containers at scale	Create color palettes	Write SQL queries	Replace UX research	A	\N	easy	\N	general	143	\N	topic
1637	What is orchestration?	Automated management of containers/services	Manual drawing	Database normalization	Icon grouping	A	\N	easy	\N	general	143	\N	topic
1638	What is a pod in Kubernetes?	Smallest deployable unit	A font style	A storage class only	A server region	A	\N	easy	\N	general	143	\N	topic
1639	What does Kubernetes help with?	Scaling, deployment, and self-healing	Typography	Wireframing	Only backups	A	\N	medium	\N	general	143	\N	topic
1640	What is a deployment in Kubernetes?	Way to manage app replicas/updates	A CSS token	A route param	A query cache	A	\N	medium	\N	general	143	\N	topic
1641	What is a service in Kubernetes?	Stable networking access to pods	A design system	A SQL view	A Figma component	A	\N	medium	\N	general	143	\N	topic
1642	What is autoscaling in Kubernetes?	Adjusting replicas based on demand	Changing colors automatically	Deleting logs	Compressing images	A	\N	medium	\N	general	143	\N	topic
1643	What is self-healing in Kubernetes?	Restarting failed containers automatically	Fixing UI spacing	Repairing SQL syntax	Changing typography	A	\N	hard	\N	general	143	\N	topic
1644	What is a challenge of Kubernetes?	Operational complexity	No scalability	No automation	No networking support	A	\N	hard	\N	general	143	\N	topic
1645	What is Infrastructure as Code (IaC)?	Managing infrastructure through code	Styling infrastructure	Drawing server diagrams only	Saving passwords in CSS	A	\N	easy	\N	general	144	\N	topic
1646	Why use IaC?	Automation and consistency	Random manual setup	No version control	More drift	A	\N	easy	\N	general	144	\N	topic
1647	What can IaC define?	Servers, networks, storage, and rules	Only fonts	Only colors	Only images	A	\N	easy	\N	general	144	\N	topic
1648	What is a benefit of IaC?	Repeatable infrastructure setup	No documentation	No testing	No security	A	\N	easy	\N	general	144	\N	topic
1649	Why store IaC in version control?	Track changes and collaborate	Hide infrastructure	Remove history	Avoid reviews	A	\N	medium	\N	general	144	\N	topic
1650	What is infrastructure drift?	Real setup differs from intended code/config	Better design consistency	A UI bug	A font mismatch	A	\N	medium	\N	general	144	\N	topic
1651	What is declarative IaC?	Describe desired final state	Write only UI code	Manually click through console	Store screenshots	A	\N	medium	\N	general	144	\N	topic
1652	What is a common IaC advantage?	Faster provisioning	Weaker security	Manual repetition	Random environments	A	\N	medium	\N	general	144	\N	topic
1653	Which practice improves IaC safety?	Review and test infrastructure changes	Apply unreviewed changes in production	Hardcode secrets	Ignore state	A	\N	hard	\N	general	144	\N	topic
1654	What does IaC reduce?	Manual configuration errors	Need for any planning	Monitoring needs	Security controls	A	\N	hard	\N	general	144	\N	topic
1655	What is cloud security?	Protecting cloud resources, identities, and data	A database color scheme	A UI pattern	A CSS reset	A	\N	easy	\N	general	145	\N	topic
1656	What helps secure cloud access?	IAM and MFA	Public admin account	Shared passwords	Open storage	A	\N	easy	\N	general	145	\N	topic
1657	Why encrypt cloud data?	Protect confidentiality	Increase font size	Delete backups	Improve icons	A	\N	easy	\N	general	145	\N	topic
1658	What is a security group/rule used for?	Controlling network access	Choosing colors	Writing SQL	Drawing wireframes	A	\N	easy	\N	general	145	\N	topic
1659	What is a common cloud security risk?	Misconfiguration	Typography inconsistency	Button spacing	Image size	A	\N	medium	\N	general	145	\N	topic
1660	Why audit logs matter in cloud security?	Track actions and investigate incidents	Style dashboards	Replace backups	Hide users	A	\N	medium	\N	general	145	\N	topic
1661	What is the shared responsibility model?	Provider and customer split security duties	Provider does everything	Customer does everything	Nobody is responsible	A	\N	medium	\N	general	145	\N	topic
1662	What improves cloud security posture?	Least privilege and continuous monitoring	Public resources by default	No patching	No encryption	A	\N	medium	\N	general	145	\N	topic
1663	What is a dangerous storage mistake?	Publicly exposed buckets or disks	Encrypted storage	Access logging	Private networks	A	\N	hard	\N	general	145	\N	topic
1664	Which practice best reduces cloud attack surface?	Tight permissions and secure defaults	Allow all inbound traffic	Reuse shared admin account	Disable logging	A	\N	hard	\N	general	145	\N	topic
1665	What is serverless computing?	Running code without managing servers directly	Computing without internet	UI without screens	Databases without storage	A	\N	easy	\N	general	146	\N	topic
1666	What is a key serverless benefit?	Less infrastructure management	No billing ever	No limits	No security needs	A	\N	easy	\N	general	146	\N	topic
1667	What usually triggers serverless functions?	Events/requests	Color changes	Wireframes	Fonts	A	\N	easy	\N	general	146	\N	topic
1668	What do serverless functions typically do?	Run small units of backend logic	Replace all design work	Store all images locally	Draw mockups	A	\N	easy	\N	general	146	\N	topic
1669	Why is serverless good for variable workloads?	Scales automatically	Needs fixed hardware	Requires manual scaling only	Does not handle traffic spikes	A	\N	medium	\N	general	146	\N	topic
1670	What is pay-per-use in serverless?	Billing based on executions/usage	One-time lifetime payment	No cost model	Billing by font count	A	\N	medium	\N	general	146	\N	topic
1671	What is a common serverless challenge?	Cold starts and architecture limits	No scaling	No events	No logging support	A	\N	medium	\N	general	146	\N	topic
1672	Which apps often fit serverless well?	Event-driven APIs and background tasks	Desktop wallpapers	Typography systems only	Static paper forms	A	\N	medium	\N	general	146	\N	topic
1673	What should still be managed in serverless?	Security, permissions, and observability	Nothing at all	Only color tokens	Only page titles	A	\N	hard	\N	general	146	\N	topic
1674	Which is a trade-off of serverless?	Convenience vs execution/runtime constraints	More fonts vs fewer fonts	CSS vs HTML	Icons vs images	A	\N	hard	\N	general	146	\N	topic
1675	What is cloud cost optimization?	Reducing waste while meeting needs	Making everything free	Removing security	Deleting all logs	A	\N	easy	\N	general	147	\N	topic
1676	Why optimize cloud cost?	Avoid unnecessary spending	Slow systems	Reduce usability	Remove scaling	A	\N	easy	\N	general	147	\N	topic
1677	What causes wasted cloud cost?	Unused resources	Good monitoring	Right sizing	Shutting idle systems down	A	\N	easy	\N	general	147	\N	topic
1678	What is rightsizing?	Choosing appropriate resource sizes	Making buttons bigger	Increasing all servers always	Removing storage	A	\N	easy	\N	general	147	\N	topic
1679	Why monitor cost regularly?	Find waste and unexpected usage	Style dashboards	Replace backups	Reduce UX work	A	\N	medium	\N	general	147	\N	topic
1680	What is a budget alert?	Notification when spending approaches threshold	A SQL trigger only	A font warning	A layout rule	A	\N	medium	\N	general	147	\N	topic
1681	How can idle resources be optimized?	Stop/delete when not needed	Keep all running forever	Duplicate them	Expose them publicly	A	\N	medium	\N	general	147	\N	topic
1682	Why use storage lifecycle policies?	Move/delete old data automatically to save cost	Increase icon count	Avoid backups	Change typography	A	\N	medium	\N	general	147	\N	topic
1683	What is a common cloud cost mistake?	Forgetting unused resources	Using budgets	Monitoring usage	Right sizing instances	A	\N	hard	\N	general	147	\N	topic
1684	What balances cost optimization best?	Efficiency without hurting reliability/performance	Cheapest option no matter what	Disable logging and backups	Undersize everything	A	\N	hard	\N	general	147	\N	topic
\.


--
-- TOC entry 3173 (class 0 OID 24748)
-- Dependencies: 213
-- Data for Name: resources; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.resources (id, topic_id, title, url, type) FROM stdin;
1	1	Programming Basics - English (freeCodeCamp)	https://www.youtube.com/watch?v=zOjov-2OZ0E	video
2	1	مقدمة في البرمجة - عربي	https://www.youtube.com/watch?v=ovx1HIKbQZk	video
3	2	If Statements - English (Mosh)	https://www.youtube.com/watch?v=IsG4Xd6LlsM	video
4	2	الجمل الشرطية if - عربي	https://www.youtube.com/watch?v=6v2L2UGZJAM	video
5	3	Loops in Programming - English	https://www.youtube.com/watch?v=Kn06785pkJg	video
6	3	الحلقات التكرارية - عربي	https://www.youtube.com/watch?v=4r6WdaY3SOA	video
7	4	Functions Explained - English	https://www.youtube.com/watch?v=N8ap4k_1QEQ	video
8	4	الدوال Functions - عربي	https://www.youtube.com/watch?v=5b1d9G3n0xA	video
9	4	Functions Explained - English	https://www.youtube.com/watch?v=N8ap4k_1QEQ	video
10	4	الدوال Functions - عربي	https://www.youtube.com/watch?v=5b1d9G3n0xA	video
28	22	HTML Full Course - FreeCodeCamp	https://www.youtube.com/watch?v=pQN-pnXPaVg	VIDEO
29	22	MDN HTML Introduction	https://developer.mozilla.org/en-US/docs/Learn/HTML/Introduction_to_HTML	ARTICLE
30	22	W3Schools HTML Tutorial	https://www.w3schools.com/html/	ARTICLE
31	23	CSS Full Course - FreeCodeCamp	https://www.youtube.com/watch?v=OXGznpKZ_sA	VIDEO
32	23	MDN CSS First Steps	https://developer.mozilla.org/en-US/docs/Learn/CSS/First_steps	ARTICLE
33	23	W3Schools CSS Tutorial	https://www.w3schools.com/css/	ARTICLE
34	24	Responsive Web Design Full Course - FreeCodeCamp	https://www.youtube.com/watch?v=srvUrASNj0s	VIDEO
35	24	MDN Responsive Design	https://developer.mozilla.org/en-US/docs/Learn/CSS/CSS_layout/Responsive_Design	ARTICLE
36	24	W3Schools Responsive Web Design	https://www.w3schools.com/css/css_rwd_intro.asp	ARTICLE
37	25	JavaScript Full Course - FreeCodeCamp	https://www.youtube.com/watch?v=PkZNo7MFNFg	VIDEO
38	25	MDN JavaScript Guide	https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide	ARTICLE
39	25	W3Schools JavaScript Tutorial	https://www.w3schools.com/js/	ARTICLE
40	26	JavaScript DOM Crash Course	https://www.youtube.com/watch?v=0ik6X4DJKCc	VIDEO
41	26	MDN DOM Introduction	https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model/Introduction	ARTICLE
42	26	JavaScript DOM Tutorial	https://www.javascripttutorial.net/javascript-dom/	ARTICLE
43	27	React Course for Beginners - FreeCodeCamp	https://www.youtube.com/watch?v=bMknfKXIFA8	VIDEO
44	27	React Official Learn	https://react.dev/learn	ARTICLE
45	27	React Official Installation	https://react.dev/learn/installation	ARTICLE
46	40	MDN - Express/Node Introduction	https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Server-side/Express_Nodejs/Introduction	ARTICLE
47	40	Node.js Official Website	https://nodejs.org/en	ARTICLE
48	40	Node.js and Express.js - Full Course	https://www.youtube.com/watch?v=Oe421EPjeBE	VIDEO
49	41	Node.js Official Website	https://nodejs.org/en	ARTICLE
50	41	Node.js and Express.js - Full Course	https://www.youtube.com/watch?v=Oe421EPjeBE	VIDEO
51	42	MDN - Express/Node Introduction	https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Server-side/Express_Nodejs/Introduction	ARTICLE
52	42	Node.js and Express.js - Full Course	https://www.youtube.com/watch?v=Oe421EPjeBE	VIDEO
53	43	REST API Tutorial	https://restfulapi.net/	ARTICLE
54	43	Build a REST API with Node and Express	https://www.youtube.com/watch?v=l8WPWK9mS5M	VIDEO
55	44	PostgreSQL Documentation	https://www.postgresql.org/docs/	ARTICLE
56	44	PERN Stack Course - Postgres, Express, React, Node	https://www.youtube.com/watch?v=ldYcgPKEZC8	VIDEO
57	45	Build a REST API with Node and Express	https://www.youtube.com/watch?v=l8WPWK9mS5M	VIDEO
58	45	REST API Tutorial	https://restfulapi.net/	ARTICLE
59	46	RFC 7519 - JSON Web Token (JWT)	https://datatracker.ietf.org/doc/rfc7519/	ARTICLE
60	46	OWASP - JWT Cheat Sheet	https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html	ARTICLE
61	47	MDN - Express/Node Introduction	https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Server-side/Express_Nodejs/Introduction	ARTICLE
62	47	Express.js Full Course	https://www.youtube.com/watch?v=nH9E25nkk3I	VIDEO
63	48	PostgreSQL Documentation	https://www.postgresql.org/docs/	ARTICLE
64	48	PERN Stack Course - Postgres, Express, React, Node	https://www.youtube.com/watch?v=ldYcgPKEZC8	VIDEO
65	49	MDN - Express/Node Introduction	https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Server-side/Express_Nodejs/Introduction	ARTICLE
66	50	Multer Documentation	https://www.npmjs.com/package/multer	ARTICLE
67	51	OWASP - JWT Testing Guide	https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/06-Session_Management_Testing/10-Testing_JSON_Web_Tokens	ARTICLE
68	51	OWASP - OAuth 2.0 Cheat Sheet	https://cheatsheetseries.owasp.org/cheatsheets/OAuth2_Cheat_Sheet.html	ARTICLE
69	52	MDN - Express Deployment	https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Server-side/Express_Nodejs/deployment	ARTICLE
70	53	Node.js Official Website	https://nodejs.org/en	ARTICLE
71	54	Backend Complete Course | NodeJS, ExpressJS, JWT	https://www.youtube.com/watch?v=g09PoiCob4Y	VIDEO
72	55	MDN - WebSocket API	https://developer.mozilla.org/en-US/docs/Web/API/WebSocket	ARTICLE
73	56	Jest Documentation	https://jestjs.io/	ARTICLE
74	56	Testing Node.js Server with Jest and Supertest	https://www.youtube.com/watch?v=7r4xVDI2vho	VIDEO
75	57	MDN - Express Deploying to Production	https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Server-side/Express_Nodejs/deployment	ARTICLE
76	58	Introduction to Databases - Full Course	https://www.youtube.com/watch?v=pPqazMTzNOM	VIDEO
77	58	IBM - What is a Relational Database?	https://www.ibm.com/think/topics/relational-databases	ARTICLE
78	58	Oracle - What is a Database?	https://www.oracle.com/database/what-is-database/	ARTICLE
79	59	IBM - What is a Relational Database?	https://www.ibm.com/think/topics/relational-databases	ARTICLE
80	59	Oracle - What is a Database?	https://www.oracle.com/database/what-is-database/	ARTICLE
81	60	PostgreSQL Tutorial for Beginners	https://www.youtube.com/watch?v=SpfIwlAYaKk	VIDEO
82	60	IBM - What Is Structured Query Language (SQL)?	https://www.ibm.com/think/topics/structured-query-language	ARTICLE
83	60	PostgreSQL Documentation	https://www.postgresql.org/docs/	ARTICLE
84	61	PostgreSQL Tutorial for Beginners	https://www.youtube.com/watch?v=SpfIwlAYaKk	VIDEO
85	61	IBM - What Is Structured Query Language (SQL)?	https://www.ibm.com/think/topics/structured-query-language	ARTICLE
86	61	PostgreSQL Documentation	https://www.postgresql.org/docs/	ARTICLE
87	62	IBM - What is a Relational Database?	https://www.ibm.com/think/topics/relational-databases	ARTICLE
88	62	PostgreSQL Documentation	https://www.postgresql.org/docs/	ARTICLE
89	63	PostgreSQL Official Documentation	https://www.postgresql.org/docs/	ARTICLE
90	63	PostgreSQL Tutorial for Beginners	https://www.youtube.com/watch?v=SpfIwlAYaKk	VIDEO
91	63	PostgreSQL Official Website	https://www.postgresql.org/	ARTICLE
92	64	IBM - What Is Structured Query Language (SQL)?	https://www.ibm.com/think/topics/structured-query-language	ARTICLE
93	64	PostgreSQL Tutorial for Beginners	https://www.youtube.com/watch?v=SpfIwlAYaKk	VIDEO
94	64	PostgreSQL Documentation	https://www.postgresql.org/docs/	ARTICLE
95	65	PostgreSQL Documentation	https://www.postgresql.org/docs/	ARTICLE
96	65	IBM - What Is Structured Query Language (SQL)?	https://www.ibm.com/think/topics/structured-query-language	ARTICLE
97	66	IBM - What is a Relational Database?	https://www.ibm.com/think/topics/relational-databases	ARTICLE
98	66	Oracle - What is a Database?	https://www.oracle.com/database/what-is-database/	ARTICLE
99	67	PostgreSQL Documentation	https://www.postgresql.org/docs/	ARTICLE
100	67	IBM - What is a Relational Database?	https://www.ibm.com/think/topics/relational-databases	ARTICLE
101	68	PostgreSQL Documentation	https://www.postgresql.org/docs/	ARTICLE
102	68	PostgreSQL Wiki - Operations Cheat Sheet	https://wiki.postgresql.org/wiki/Operations_cheat_sheet	ARTICLE
103	69	PostgreSQL Documentation	https://www.postgresql.org/docs/	ARTICLE
104	69	IBM - What is a Relational Database?	https://www.ibm.com/think/topics/relational-databases	ARTICLE
105	70	Advanced SQL Full Course	https://www.youtube.com/watch?v=uPhRSCPfcc0	VIDEO
106	70	PostgreSQL Documentation	https://www.postgresql.org/docs/	ARTICLE
107	70	IBM - What Is Structured Query Language (SQL)?	https://www.ibm.com/think/topics/structured-query-language	ARTICLE
108	71	PostgreSQL Documentation	https://www.postgresql.org/docs/	ARTICLE
109	71	PostgreSQL Wiki - Operations Cheat Sheet	https://wiki.postgresql.org/wiki/Operations_cheat_sheet	ARTICLE
110	72	PostgreSQL Documentation	https://www.postgresql.org/docs/	ARTICLE
111	72	Advanced SQL Full Course	https://www.youtube.com/watch?v=uPhRSCPfcc0	VIDEO
112	73	PostgreSQL Documentation	https://www.postgresql.org/docs/	ARTICLE
113	73	IBM - What is a Relational Database?	https://www.ibm.com/think/topics/relational-databases	ARTICLE
114	74	PostgreSQL Documentation	https://www.postgresql.org/docs/	ARTICLE
115	74	Oracle - What is a Database?	https://www.oracle.com/database/what-is-database/	ARTICLE
116	75	PostgreSQL Documentation	https://www.postgresql.org/docs/	ARTICLE
117	75	Introduction to Databases - Full Course	https://www.youtube.com/watch?v=pPqazMTzNOM	VIDEO
122	76	Cyber Security Full Course for Beginner	https://www.youtube.com/watch?v=U_P23SqJaDc	VIDEO
123	76	IBM - What is Cybersecurity?	https://www.ibm.com/topics/cybersecurity	ARTICLE
124	77	Networking Fundamentals Playlist	https://www.youtube.com/playlist?list=PLIFyRwBY_4bRLmKfP1KnZA6rZbRHtxmXi	VIDEO
125	77	Practical Networking Channel	https://www.youtube.com/practicalnetworking	ARTICLE
126	78	OWASP Top 10 Official	https://owasp.org/www-project-top-ten/	ARTICLE
127	78	OWASP Top 10 2025	https://owasp.org/Top10/2025/	ARTICLE
128	79	Cryptography Basics Intro to Cybersecurity	https://www.youtube.com/watch?v=2oXKjPwBSUk	VIDEO
129	79	Cryptography 101 - The Basics	https://www.youtube.com/watch?v=fNC3jCCGJ0o	VIDEO
130	80	Linux Essentials for Ethical Hackers	https://www.youtube.com/watch?v=1hvVcEhcbLM	VIDEO
131	80	OWASP Foundation	https://owasp.org/	ARTICLE
132	81	Harvard CS50 Intro to Cybersecurity	https://www.youtube.com/watch?v=9HOpanT0GRs	VIDEO
133	81	IBM - What is Cybersecurity?	https://www.ibm.com/topics/cybersecurity	ARTICLE
134	82	OWASP Top 10 Official	https://owasp.org/www-project-top-ten/	ARTICLE
135	82	OWASP Top 10 2025 Introduction	https://owasp.org/Top10/2025/0x00_2025-Introduction/	ARTICLE
136	83	RFC 7519 - JSON Web Token	https://datatracker.ietf.org/doc/rfc7519/	ARTICLE
137	83	OWASP - OAuth 2.0 Cheat Sheet	https://cheatsheetseries.owasp.org/cheatsheets/OAuth2_Cheat_Sheet.html	ARTICLE
138	84	Computer Networking Fundamentals	https://www.youtube.com/watch?v=k9ZigsW9il0	VIDEO
139	84	Computer Networking Full Course	https://www.youtube.com/watch?v=IPvYjXCsTg8	VIDEO
140	85	Ethical Hacking in 12 Hours	https://www.youtube.com/watch?v=fNzpcB7ODxQ	VIDEO
141	85	OWASP Foundation	https://owasp.org/	ARTICLE
142	86	OWASP Top 10 Official	https://owasp.org/www-project-top-ten/	ARTICLE
143	86	OWASP Foundation	https://owasp.org/	ARTICLE
144	87	Hands-On Cybersecurity and Ethical Hacking	https://www.youtube.com/watch?v=ug8W0sFiVJo	VIDEO
145	87	Ethical Hacking Playlist	https://www.youtube.com/playlist?list=PLWKjhJtqVAbnklGh3FNRLECx_2D_vK3mu	ARTICLE
146	88	OWASP Top 10 2025	https://owasp.org/Top10/2025/	ARTICLE
147	88	OWASP Top 10 Official	https://owasp.org/www-project-top-ten/	ARTICLE
148	89	Ethical Hacking in 12 Hours	https://www.youtube.com/watch?v=fNzpcB7ODxQ	VIDEO
149	89	OWASP Foundation	https://owasp.org/	ARTICLE
150	90	Harvard CS50 Intro to Cybersecurity	https://www.youtube.com/watch?v=9HOpanT0GRs	VIDEO
151	90	OWASP Foundation	https://owasp.org/	ARTICLE
152	91	IBM - What is Cybersecurity?	https://www.ibm.com/topics/cybersecurity	ARTICLE
153	91	OWASP Foundation	https://owasp.org/	ARTICLE
154	92	OWASP Foundation	https://owasp.org/	ARTICLE
155	92	IBM - What is Cybersecurity?	https://www.ibm.com/topics/cybersecurity	ARTICLE
156	93	Hands-On Cybersecurity and Ethical Hacking	https://www.youtube.com/watch?v=ug8W0sFiVJo	VIDEO
157	93	Ethical Hacking in 12 Hours	https://www.youtube.com/watch?v=fNzpcB7ODxQ	VIDEO
158	94	Flutter Official Documentation	https://docs.flutter.dev/	ARTICLE
159	94	The Ultimate Flutter Tutorial for Beginners - 2025 Full Course	https://www.youtube.com/watch?v=3kaGC_DrUnw	VIDEO
160	95	Learn Flutter	https://docs.flutter.dev/learn	ARTICLE
161	95	First steps with Flutter	https://www.youtube.com/watch?v=sE1M2EayFes	VIDEO
162	96	Install Flutter	https://docs.flutter.dev/install	ARTICLE
163	96	Learn Flutter	https://docs.flutter.dev/learn	ARTICLE
164	96	The Ultimate Flutter Tutorial for Beginners - 2025 Full Course	https://www.youtube.com/watch?v=3kaGC_DrUnw	VIDEO
165	97	Flutter documentation	https://docs.flutter.dev/	ARTICLE
166	97	Flutter Tutorial for Beginners #1 - Intro & Setup	https://www.youtube.com/watch?v=1ukSR1GRtMU	VIDEO
167	98	Learn Flutter	https://docs.flutter.dev/learn	ARTICLE
168	98	FULL Flutter Tutorial Beginner Course | Widgets / Navigation	https://www.youtube.com/watch?v=5lDJNFSWUD8	VIDEO
169	99	Flutter documentation	https://docs.flutter.dev/	ARTICLE
170	100	Flutter State Management Tutorials	https://www.youtube.com/playlist?list=PL1WkZqhlAdC-GNyxQbfn8Db9pR6bRcQuw	VIDEO
171	100	Learn Flutter	https://docs.flutter.dev/learn	ARTICLE
172	101	Learn Flutter	https://docs.flutter.dev/learn	ARTICLE
173	102	Get Started with React Native	https://reactnative.dev/docs/getting-started	ARTICLE
174	102	Set Up Your Environment	https://reactnative.dev/docs/set-up-your-environment	ARTICLE
175	103	Flutter documentation	https://docs.flutter.dev/	ARTICLE
176	104	Firebase Cloud Messaging	https://firebase.google.com/docs/cloud-messaging	ARTICLE
177	104	Get started with Firebase Cloud Messaging in Flutter apps	https://firebase.google.com/docs/cloud-messaging/flutter/get-started	ARTICLE
178	104	Flutter Firebase Cloud Messaging (FCM)	https://www.youtube.com/watch?v=OHFyGRLfKxo	VIDEO
179	105	Guide to app architecture	https://developer.android.com/topic/architecture	ARTICLE
180	106	Flutter State Management Tutorials	https://www.youtube.com/playlist?list=PL1WkZqhlAdC-GNyxQbfn8Db9pR6bRcQuw	VIDEO
181	106	#1 Master Riverpod | Flutter Riverpod State Management 2025	https://www.youtube.com/watch?v=t2QL-AMJViE	VIDEO
182	107	Guide to app architecture	https://developer.android.com/topic/architecture	ARTICLE
183	108	App architecture	https://developer.android.com/topic/architecture/intro	ARTICLE
184	109	Running On Device	https://reactnative.dev/docs/running-on-device	ARTICLE
185	110	Set Up Your Environment	https://reactnative.dev/docs/set-up-your-environment	ARTICLE
186	111	Guide to app architecture	https://developer.android.com/topic/architecture	ARTICLE
187	112	Figma - What is the difference between UI and UX?	https://www.figma.com/resource-library/design-basics/	ARTICLE
188	112	Free Figma UX Design UI Essentials Course | 2025	https://www.youtube.com/watch?v=QJBP2uy8LcU	VIDEO
189	113	Figma - Design Basics	https://www.figma.com/resource-library/design-basics/	ARTICLE
190	113	Material Design Foundations	https://m3.material.io/foundations	ARTICLE
191	114	Figma - Ultimate Guide to Typography in Design	https://www.figma.com/resource-library/typography-in-design/	ARTICLE
192	114	Figma Design for beginners 2025	https://www.youtube.com/playlist?list=PLXDU_eVOJTx5IuSrbtanZHnDuPB3Hx0hq	VIDEO
193	115	Figma - Design Basics	https://www.figma.com/resource-library/design-basics/	ARTICLE
194	115	Figma Tutorial for Beginners - Complete Course 2025	https://www.youtube.com/watch?v=HoKD1qIcchQ	VIDEO
195	116	NN/g - When to Use Which User-Experience Research Methods	https://www.nngroup.com/articles/which-ux-research-methods/	ARTICLE
196	116	NN/g - UX & Usability Articles	https://www.nngroup.com/articles/	ARTICLE
197	117	Figma Design for beginners 2025 - Course Overview	https://help.figma.com/hc/en-us/articles/30848209492887-Course-overview-Figma-Design-for-beginners-2025	ARTICLE
198	117	Figma Design for beginners 2025	https://www.youtube.com/playlist?list=PLXDU_eVOJTx5IuSrbtanZHnDuPB3Hx0hq	VIDEO
199	118	NN/g - Information Architecture Study Guide	https://www.nngroup.com/articles/ia-study-guide/	ARTICLE
200	118	NN/g - Information Architecture Topic	https://www.nngroup.com/topic/information-architecture/	ARTICLE
201	119	Figma Design	https://www.figma.com/design/	ARTICLE
202	119	Free Figma Crash Course for Beginners 2026 | UI/UX Design	https://www.youtube.com/watch?v=1SNZRCVNizg	VIDEO
203	120	NN/g - Usability Testing 101	https://www.nngroup.com/articles/usability-testing-101/	ARTICLE
204	120	NN/g - UX & Usability Articles	https://www.nngroup.com/articles/	ARTICLE
205	121	Figma - Guide to Auto Layout	https://help.figma.com/hc/en-us/articles/360040451373-Guide-to-auto-layout	ARTICLE
206	121	Material Design Foundations	https://m3.material.io/foundations	ARTICLE
207	122	Figma - Introduction to Design Systems	https://help.figma.com/hc/en-us/articles/14552901442839-Overview-Introduction-to-design-systems	ARTICLE
208	122	Figma - Design System Examples	https://www.figma.com/resource-library/design-system-examples/	ARTICLE
209	123	Material Design - Accessibility	https://m2.material.io/design/usability/accessibility.html	ARTICLE
210	123	Material Design 3 - Foundations	https://m3.material.io/foundations	ARTICLE
211	124	NN/g - UX & Usability Articles	https://www.nngroup.com/articles/	ARTICLE
212	124	Figma Design	https://www.figma.com/design/	ARTICLE
213	125	Figma - Introduction to Design Systems	https://help.figma.com/hc/en-us/articles/14552901442839-Overview-Introduction-to-design-systems	ARTICLE
214	125	Figma - Design System Examples	https://www.figma.com/resource-library/design-system-examples/	ARTICLE
215	126	NN/g - UX & Usability Articles	https://www.nngroup.com/articles/	ARTICLE
216	126	NN/g Research Reports	https://www.nngroup.com/reports/	ARTICLE
217	127	NN/g - When to Use Which UX Research Methods	https://www.nngroup.com/articles/which-ux-research-methods/	ARTICLE
218	128	NN/g - UX & Usability Articles	https://www.nngroup.com/articles/	ARTICLE
219	128	NN/g Research Reports	https://www.nngroup.com/reports/	ARTICLE
220	129	Figma Design	https://www.figma.com/design/	ARTICLE
221	129	Free Figma UX Design UI Essentials Course | 2025	https://www.youtube.com/watch?v=QJBP2uy8LcU	VIDEO
222	112	Figma - What is the difference between UI and UX?	https://www.figma.com/resource-library/design-basics/	ARTICLE
223	112	Free Figma UX Design UI Essentials Course | 2025	https://www.youtube.com/watch?v=QJBP2uy8LcU	VIDEO
224	113	Figma - Design Basics	https://www.figma.com/resource-library/design-basics/	ARTICLE
225	113	Material Design Foundations	https://m3.material.io/foundations	ARTICLE
226	114	Figma - Ultimate Guide to Typography in Design	https://www.figma.com/resource-library/typography-in-design/	ARTICLE
227	114	Figma Design for beginners 2025	https://www.youtube.com/playlist?list=PLXDU_eVOJTx5IuSrbtanZHnDuPB3Hx0hq	VIDEO
228	115	Figma - Design Basics	https://www.figma.com/resource-library/design-basics/	ARTICLE
229	115	Figma Tutorial for Beginners - Complete Course 2025	https://www.youtube.com/watch?v=HoKD1qIcchQ	VIDEO
230	116	NN/g - When to Use Which User-Experience Research Methods	https://www.nngroup.com/articles/which-ux-research-methods/	ARTICLE
231	116	NN/g - UX & Usability Articles	https://www.nngroup.com/articles/	ARTICLE
232	117	Figma Design for beginners 2025 - Course Overview	https://help.figma.com/hc/en-us/articles/30848209492887-Course-overview-Figma-Design-for-beginners-2025	ARTICLE
233	117	Figma Design for beginners 2025	https://www.youtube.com/playlist?list=PLXDU_eVOJTx5IuSrbtanZHnDuPB3Hx0hq	VIDEO
234	118	NN/g - Information Architecture Study Guide	https://www.nngroup.com/articles/ia-study-guide/	ARTICLE
235	118	NN/g - Information Architecture Topic	https://www.nngroup.com/topic/information-architecture/	ARTICLE
236	119	Figma Design	https://www.figma.com/design/	ARTICLE
237	119	Free Figma Crash Course for Beginners 2026 | UI/UX Design	https://www.youtube.com/watch?v=1SNZRCVNizg	VIDEO
238	120	NN/g - Usability Testing 101	https://www.nngroup.com/articles/usability-testing-101/	ARTICLE
239	120	NN/g - UX & Usability Articles	https://www.nngroup.com/articles/	ARTICLE
240	121	Figma - Guide to Auto Layout	https://help.figma.com/hc/en-us/articles/360040451373-Guide-to-auto-layout	ARTICLE
241	121	Material Design Foundations	https://m3.material.io/foundations	ARTICLE
242	122	Figma - Introduction to Design Systems	https://help.figma.com/hc/en-us/articles/14552901442839-Overview-Introduction-to-design-systems	ARTICLE
243	122	Figma - Design System Examples	https://www.figma.com/resource-library/design-system-examples/	ARTICLE
244	123	Material Design - Accessibility	https://m2.material.io/design/usability/accessibility.html	ARTICLE
245	123	Material Design 3 - Foundations	https://m3.material.io/foundations	ARTICLE
246	124	NN/g - UX & Usability Articles	https://www.nngroup.com/articles/	ARTICLE
247	124	Figma Design	https://www.figma.com/design/	ARTICLE
248	125	Figma - Introduction to Design Systems	https://help.figma.com/hc/en-us/articles/14552901442839-Overview-Introduction-to-design-systems	ARTICLE
249	125	Figma - Design System Examples	https://www.figma.com/resource-library/design-system-examples/	ARTICLE
250	126	NN/g - UX & Usability Articles	https://www.nngroup.com/articles/	ARTICLE
251	126	NN/g Research Reports	https://www.nngroup.com/reports/	ARTICLE
252	127	NN/g - When to Use Which UX Research Methods	https://www.nngroup.com/articles/which-ux-research-methods/	ARTICLE
253	128	NN/g - UX & Usability Articles	https://www.nngroup.com/articles/	ARTICLE
254	128	NN/g Research Reports	https://www.nngroup.com/reports/	ARTICLE
255	129	Figma Design	https://www.figma.com/design/	ARTICLE
256	129	Free Figma UX Design UI Essentials Course | 2025	https://www.youtube.com/watch?v=QJBP2uy8LcU	VIDEO
257	130	AWS - Getting Started with Cloud Essentials	https://aws.amazon.com/getting-started/cloud-essentials/	ARTICLE
258	130	Google Cloud Overview	https://docs.cloud.google.com/docs/overview	ARTICLE
259	131	AWS - Cloud Essentials	https://aws.amazon.com/getting-started/cloud-essentials/	ARTICLE
260	131	Azure Fundamentals Learning Paths	https://learn.microsoft.com/en-us/training/azure/	ARTICLE
261	132	Azure Documentation	https://learn.microsoft.com/en-us/azure/	ARTICLE
262	132	Google Cloud Get Started	https://docs.cloud.google.com/docs/get-started	ARTICLE
263	133	Azure Documentation	https://learn.microsoft.com/en-us/azure/	ARTICLE
264	133	Kubernetes Overview	https://kubernetes.io/docs/concepts/overview/	ARTICLE
265	134	Google Cloud Storage Documentation	https://docs.cloud.google.com/storage/docs	ARTICLE
266	134	Google Cloud Get Started	https://docs.cloud.google.com/docs/get-started	ARTICLE
267	135	AWS Getting Started	https://aws.amazon.com/getting-started/	ARTICLE
268	135	Azure Documentation	https://learn.microsoft.com/en-us/azure/	ARTICLE
269	136	AWS Getting Started	https://aws.amazon.com/getting-started/	ARTICLE
270	136	Azure Documentation	https://learn.microsoft.com/en-us/azure/	ARTICLE
271	137	Azure Documentation	https://learn.microsoft.com/en-us/azure/	ARTICLE
272	137	Google Cloud Overview	https://docs.cloud.google.com/docs/overview	ARTICLE
273	138	Google Cloud Documentation	https://docs.cloud.google.com/docs	ARTICLE
274	138	Azure Documentation	https://learn.microsoft.com/en-us/azure/	ARTICLE
275	139	AWS Getting Started	https://aws.amazon.com/getting-started/	ARTICLE
276	139	Azure Security Fundamentals	https://learn.microsoft.com/en-us/azure/security/fundamentals/	ARTICLE
277	140	Azure Documentation	https://learn.microsoft.com/en-us/azure/	ARTICLE
278	140	Google Cloud Documentation	https://docs.cloud.google.com/docs	ARTICLE
279	141	AWS Getting Started	https://aws.amazon.com/getting-started/	ARTICLE
280	141	Google Cloud Get Started	https://docs.cloud.google.com/docs/get-started	ARTICLE
281	142	Google Cloud Architecture Fundamentals	https://docs.cloud.google.com/architecture/fundamentals	ARTICLE
282	142	Azure Architecture Center / Docs	https://learn.microsoft.com/en-us/azure/	ARTICLE
283	143	Kubernetes Documentation	https://kubernetes.io/docs/home/	ARTICLE
284	143	Kubernetes Cluster Architecture	https://kubernetes.io/docs/concepts/architecture/	ARTICLE
285	144	AWS CloudFormation Getting Started	https://aws.amazon.com/cloudformation/getting-started/	ARTICLE
286	144	Google Cloud Overview	https://docs.cloud.google.com/docs/overview	ARTICLE
287	145	Azure Security Fundamentals	https://learn.microsoft.com/en-us/azure/security/fundamentals/	ARTICLE
288	145	AWS Training and Certification	https://aws.amazon.com/training/	ARTICLE
289	146	AWS Getting Started	https://aws.amazon.com/getting-started/	ARTICLE
290	146	Google Cloud Get Started	https://docs.cloud.google.com/docs/get-started	ARTICLE
291	147	Google Cloud Overview	https://docs.cloud.google.com/docs/overview	ARTICLE
292	147	AWS Training and Certification	https://aws.amazon.com/training/	ARTICLE
293	9	Arrays Tutorial - English	https://www.youtube.com/watch?v=RBSGKlAvoiM	video
294	9	Strings in Programming - English	https://www.youtube.com/watch?v=8ext9G7xspg	video
295	9	Arrays and Strings Explained - عربي	https://www.youtube.com/watch?v=7I4r6Yz1Yx8	video
296	10	Problem Solving for Beginners - English	https://www.youtube.com/watch?v=6hfOvs8pY1k	video
297	10	Algorithmic Thinking Basics	https://www.youtube.com/watch?v=azcrPFhaY9k	video
298	10	حل المشاكل البرمجية - عربي	https://www.youtube.com/watch?v=VQx0rYkY1fA	video
299	11	Recursion Explained - English	https://www.youtube.com/watch?v=ngCos392W4w	video
300	11	Recursion in Programming	https://www.youtube.com/watch?v=IJDJ0kBx2LM	video
301	11	الريكيرجن Recursion - عربي	https://www.youtube.com/watch?v=rf60MejMz3E	video
302	12	Object Oriented Programming - English	https://www.youtube.com/watch?v=Ej_02ICOIgs	video
303	12	OOP Concepts Explained	https://www.youtube.com/watch?v=pTB0EiLXUC8	video
304	12	البرمجة كائنية التوجه - عربي	https://www.youtube.com/watch?v=SiBw7os-_zI	video
305	13	File Handling in Programming - English	https://www.youtube.com/watch?v=Uh2ebFW8OYM	video
306	13	Read and Write Files	https://www.youtube.com/watch?v=8cFJ7jU8hXg	video
307	13	التعامل مع الملفات - عربي	https://www.youtube.com/watch?v=Zl4x8w0gY0Q	video
308	14	Debugging for Beginners	https://www.youtube.com/watch?v=H0XScE08hy8	video
309	14	How to Trace Code	https://www.youtube.com/watch?v=Q0Xk2Uu7q9E	video
310	14	تصحيح الأخطاء Debugging - عربي	https://www.youtube.com/watch?v=H7o6mwP0z7I	video
311	15	Data Structures Full Course - freeCodeCamp	https://www.youtube.com/watch?v=RBSGKlAvoiM	VIDEO
312	15	شرح هياكل البيانات - عربي	https://www.youtube.com/watch?v=bum_19loj9A	VIDEO
313	16	Searching and Sorting Algorithms - Full Course	https://www.youtube.com/watch?v=kgBjXUE_Nwc	VIDEO
314	16	شرح خوارزميات البحث والترتيب - عربي	https://www.youtube.com/watch?v=TW0n1n1r2fM	VIDEO
315	17	Big O Notation - Full Course	https://www.youtube.com/watch?v=__vX2sjlpXU	VIDEO
316	17	شرح Time Complexity - عربي	https://www.youtube.com/watch?v=Mo4vesaut8g	VIDEO
317	18	Problem Solving Techniques for Coding Interviews	https://www.youtube.com/watch?v=8hly31xKli0	VIDEO
318	18	حل مسائل متقدمة - عربي	https://www.youtube.com/watch?v=6hfOvs8pY1k	VIDEO
319	19	Memory Management and Performance Optimization	https://www.youtube.com/watch?v=HcLz3s6k9eA	VIDEO
320	19	شرح الذاكرة والأداء - عربي	https://www.youtube.com/watch?v=G1bRiZJ6c8Q	VIDEO
321	20	Coding Challenges Practice - freeCodeCamp	https://www.youtube.com/watch?v=8ext9G7xspg	VIDEO
322	20	تمارين برمجية للمبتدئين والمتقدمين - عربي	https://www.youtube.com/watch?v=VQx0rYkY1fA	VIDEO
323	28	CSS Flexbox and Grid Full Course	https://www.youtube.com/watch?v=JJSoEo8JSnc	VIDEO
324	28	شرح Flexbox و Grid - عربي	https://www.youtube.com/watch?v=JJSoEo8JSnc	VIDEO
325	29	JavaScript ES6 Crash Course	https://www.youtube.com/watch?v=NCwa_xi0Uuc	VIDEO
326	29	شرح ES6 و Async JavaScript - عربي	https://www.youtube.com/watch?v=PoRJizFvM7s	VIDEO
327	30	JavaScript Fetch API Tutorial	https://www.youtube.com/watch?v=Oive66jrwBs	VIDEO
328	30	شرح Fetch API - عربي	https://www.youtube.com/watch?v=cuEtnrL9-H0	VIDEO
329	31	React Components and Props Explained	https://www.youtube.com/watch?v=Ke90Tje7VS0	VIDEO
330	31	شرح React Components و Props - عربي	https://www.youtube.com/watch?v=SqcY0GlETPk	VIDEO
331	32	React useState and State Management	https://www.youtube.com/watch?v=O6P86uwfdR0	VIDEO
332	32	شرح React State Management - عربي	https://www.youtube.com/watch?v=4UZrsTqkcW4	VIDEO
333	33	React Router Tutorial	https://www.youtube.com/watch?v=Law7wfdg_ls	VIDEO
334	33	شرح React Router - عربي	https://www.youtube.com/watch?v=Ul3y1LXxzdU	VIDEO
335	34	TypeScript Full Course for Beginners	https://www.youtube.com/watch?v=30LWjhZzg50	VIDEO
336	34	شرح TypeScript - عربي	https://www.youtube.com/watch?v=BwuLxPH8IDs	VIDEO
337	35	Next.js Crash Course	https://www.youtube.com/watch?v=1WmNXEVia8I	VIDEO
338	35	شرح Next.js - عربي	https://www.youtube.com/watch?v=MFuwkrseXVE	VIDEO
339	36	Frontend Performance Optimization Guide	https://www.youtube.com/watch?v=5fLW5Q5ODiE	VIDEO
340	36	تحسين أداء الواجهة الأمامية - عربي	https://www.youtube.com/watch?v=7Z1p4K9xVxA	VIDEO
341	37	Web Accessibility Crash Course	https://www.youtube.com/watch?v=20SHvU2PKsM	VIDEO
342	37	شرح Accessibility - عربي	https://www.youtube.com/watch?v=3f31oufqFSM	VIDEO
343	38	Frontend Testing with Vitest	https://www.youtube.com/watch?v=7r4xVDI2vho	VIDEO
344	38	شرح اختبار الواجهة الأمامية - عربي	https://www.youtube.com/watch?v=ML5egqL3YFE	VIDEO
345	39	Advanced React Patterns	https://www.youtube.com/watch?v=FJDVKeh7RJI	VIDEO
346	39	شرح Advanced React Patterns - عربي	https://www.youtube.com/watch?v=GZz0cK9q2Y8	VIDEO
\.


--
-- TOC entry 3175 (class 0 OID 24772)
-- Dependencies: 215
-- Data for Name: roadmap_questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roadmap_questions (id, topic_id, question, option_a, option_b, option_c, option_d, correct_option) FROM stdin;
\.


--
-- TOC entry 3171 (class 0 OID 24731)
-- Dependencies: 211
-- Data for Name: roadmap_topics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roadmap_topics (id, roadmap_id, title, description, topic_order, is_locked, is_active) FROM stdin;
1	1	Introduction to Programming	Learn what programming is, understand variables, data types, input and output.	1	t	t
2	1	Control Structures	Learn how decisions are made in programs using if, else, and switch.	2	t	t
3	1	Loops	Understand repetition using for loops, while loops, and nested loops.	3	t	t
4	1	Functions	Learn how to write reusable code using functions, parameters, and return values.	4	t	t
9	3	Arrays and Strings	Learn how to store and manipulate collections of data efficiently.	1	t	t
10	3	Problem Solving Basics	Practice breaking problems into steps and building algorithmic thinking.	2	t	t
11	3	Recursion Basics	Understand recursive thinking and how functions can call themselves safely.	3	t	t
12	3	Object-Oriented Programming Basics	Learn classes, objects, encapsulation, and basic OOP concepts.	4	t	t
13	3	File Handling	Learn how programs read from and write to files.	5	t	t
14	3	Debugging and Code Tracing	Develop the ability to trace logic and find common programming mistakes.	6	t	t
15	4	Data Structures Foundations	Explore stacks, queues, linked lists, and their practical uses.	1	t	t
16	4	Searching and Sorting Algorithms	Learn core algorithms and compare their behavior and efficiency.	2	t	t
17	4	Time Complexity Basics	Understand Big-O notation and evaluate algorithm performance.	3	t	t
18	4	Advanced Problem Solving	Solve more structured coding challenges using efficient approaches.	4	t	t
19	4	Memory and Performance Concepts	Learn how code structure affects speed and memory usage.	5	t	t
20	4	Mini Programming Challenges	Apply your knowledge through integrated coding exercises.	6	t	t
22	5	HTML Basics	Learn structure of web pages using HTML.	1	t	t
23	5	CSS Basics	Learn styling and layout using CSS.	2	t	t
24	5	Responsive Design Basics	Learn how to make websites responsive.	3	t	t
25	5	JavaScript Basics	Learn programming basics with JavaScript.	4	t	t
26	5	DOM Manipulation Basics	Interact with web pages dynamically.	5	t	t
27	5	React Basics	Introduction to React framework.	6	t	t
28	6	Flexbox and Grid	Advanced layout techniques.	1	t	t
29	6	JavaScript ES6+ and Async	Modern JavaScript features.	2	t	t
30	6	APIs and Fetch	Working with APIs and data.	3	t	t
31	6	React Components and Props	Component-based architecture.	4	t	t
32	6	React State Management	Managing state in apps.	5	t	t
33	6	React Router Basics	Routing in React apps.	6	t	t
34	7	TypeScript for Frontend	Strong typing in JavaScript.	1	t	t
35	7	Next.js Foundations	SSR and modern frameworks.	2	t	t
36	7	Frontend Performance Optimization	Improve speed and performance.	3	t	t
37	7	Web Accessibility	Make websites accessible.	4	t	t
38	7	Frontend Testing with Vitest	Testing frontend apps using Vitest.	5	t	t
39	7	Advanced React Patterns	Advanced React techniques.	6	t	t
40	8	Introduction to Backend	Understand what backend development is and how servers work.	1	t	t
41	8	Node.js Basics	Learn how to run JavaScript on the server.	2	t	t
42	8	Express.js Basics	Build simple APIs using Express framework.	3	t	t
43	8	REST APIs Fundamentals	Understand how APIs work and how to design them.	4	t	t
44	8	Databases Basics	Learn SQL basics and how databases work.	5	t	t
45	8	CRUD Operations	Create, read, update, delete data in backend.	6	t	t
46	9	Authentication and Authorization	Implement login, JWT, and user roles.	1	t	t
47	9	Middleware and Routing	Understand Express middleware and route handling.	2	t	t
48	9	Database Integration	Connect backend with PostgreSQL or other databases.	3	t	t
49	9	Error Handling and Validation	Handle errors and validate user input.	4	t	t
50	9	File Uploads and Storage	Handle file uploads and storage systems.	5	t	t
51	9	API Security Basics	Protect APIs from common attacks.	6	t	t
52	10	System Design Basics	Design scalable backend systems.	1	t	t
53	10	Caching and Performance	Improve performance using caching strategies.	2	t	t
54	10	Microservices Architecture	Build and manage microservices systems.	3	t	t
55	10	Real-time Applications	Use WebSockets and real-time communication.	4	t	t
56	10	Testing Backend APIs	Write unit and integration tests.	5	t	t
57	10	Deployment and DevOps Basics	Deploy backend systems and manage environments.	6	t	t
58	11	Introduction to Databases	Understand what databases are and why they are used.	1	t	t
59	11	Tables and Records	Learn how data is stored in tables, rows, and columns.	2	t	t
60	11	Basic SQL Queries	Write simple SELECT, INSERT, UPDATE, and DELETE queries.	3	t	t
61	11	Filtering and Sorting Data	Use WHERE, ORDER BY, and LIMIT to filter and sort results.	4	t	t
62	11	Primary Keys and Relationships	Learn how tables are connected using keys and relationships.	5	t	t
63	11	Introduction to PostgreSQL	Get started with PostgreSQL and basic database operations.	6	t	t
64	12	Joins in SQL	Combine data from multiple tables using different types of joins.	1	t	t
65	12	Aggregate Functions and Grouping	Use COUNT, SUM, AVG, GROUP BY, and HAVING in queries.	2	t	t
66	12	Database Design Basics	Design well-structured databases using normalization principles.	3	t	t
67	12	Constraints and Data Integrity	Use constraints to keep data valid and consistent.	4	t	t
68	12	Indexes and Query Performance	Learn how indexes improve query speed and performance.	5	t	t
69	12	Transactions and ACID	Understand transactions and the ACID properties in databases.	6	t	t
70	13	Advanced SQL Queries	Write complex queries using subqueries, CTEs, and window functions.	1	t	t
71	13	Query Optimization	Analyze and optimize SQL queries for better performance.	2	t	t
72	13	Stored Procedures and Functions	Create reusable database logic using procedures and functions.	3	t	t
73	13	Database Security	Protect databases using permissions, roles, and secure practices.	4	t	t
74	13	Backup and Recovery	Learn strategies for backup, restore, and disaster recovery.	5	t	t
75	13	Scaling Databases	Understand replication, partitioning, and scaling techniques.	6	t	t
76	14	Introduction to Cyber Security	Understand basic cybersecurity concepts and threats.	1	t	t
77	14	Networking Basics	Learn how networks work and basic protocols.	2	t	t
78	14	Common Cyber Threats	Explore malware, phishing, and common attacks.	3	t	t
79	14	Basic Cryptography	Understand encryption, hashing, and secure communication.	4	t	t
80	14	Operating System Security	Learn basic OS security concepts.	5	t	t
81	14	Security Best Practices	Apply basic security practices in real life.	6	t	t
82	15	Web Security Basics	Understand common web vulnerabilities.	1	t	t
83	15	Authentication and Authorization Security	Secure login systems and access control.	2	t	t
84	15	Network Security	Protect networks using firewalls and protocols.	3	t	t
85	15	Vulnerability Assessment	Identify and analyze system vulnerabilities.	4	t	t
86	15	Secure Coding Practices	Write secure backend and frontend code.	5	t	t
87	15	Penetration Testing Basics	Learn basic ethical hacking techniques.	6	t	t
88	16	Advanced Web Security	Deep dive into complex web vulnerabilities.	1	t	t
89	16	Exploit Development Basics	Understand how exploits are created.	2	t	t
90	16	Digital Forensics	Investigate cyber incidents and collect evidence.	3	t	t
91	16	Security Architecture Design	Design secure systems and infrastructures.	4	t	t
92	16	Cloud Security	Secure cloud-based applications and systems.	5	t	t
93	16	Advanced Penetration Testing	Perform advanced ethical hacking techniques.	6	t	t
94	17	Introduction to Mobile Development	Understand mobile platforms and app architecture.	1	t	t
95	17	Programming Basics for Mobile	Learn programming concepts used in mobile apps.	2	t	t
96	17	Flutter Basics	Build simple apps using Flutter framework.	3	t	t
97	17	UI Design Basics	Design user interfaces for mobile apps.	4	t	t
98	17	Navigation and Layouts	Handle screens and navigation in apps.	5	t	t
99	17	Local Storage Basics	Store data locally on device.	6	t	t
100	18	State Management	Manage app state efficiently.	1	t	t
101	18	API Integration	Connect mobile apps with backend services.	2	t	t
102	18	Authentication in Mobile Apps	Implement login and user authentication.	3	t	t
103	18	Animations and UI Enhancements	Improve user experience with animations.	4	t	t
104	18	Push Notifications	Send notifications to users.	5	t	t
105	18	App Performance Optimization	Improve app performance and responsiveness.	6	t	t
106	19	Advanced State Management	Use advanced patterns for managing state.	1	t	t
107	19	Offline-first Apps	Build apps that work without internet.	2	t	t
108	19	App Security	Secure mobile applications and data.	3	t	t
109	19	Testing Mobile Apps	Write unit and UI tests.	4	t	t
110	19	Publishing Apps	Deploy apps to App Store and Play Store.	5	t	t
111	19	CI/CD for Mobile Apps	Automate build and deployment.	6	t	t
112	20	Introduction to UI/UX	Understand the difference between UI and UX and why both matter.	1	t	t
113	20	Design Principles Basics	Learn balance, contrast, alignment, hierarchy, and consistency.	2	t	t
114	20	Color and Typography	Explore color theory, font pairing, and readable interfaces.	3	t	t
115	20	Wireframing Basics	Create low-fidelity layouts to plan interface structure.	4	t	t
116	20	User Research Basics	Learn how to understand users, needs, and simple personas.	5	t	t
117	20	Introduction to Figma	Use Figma to design simple screens and components.	6	t	t
118	21	User Flows and Information Architecture	Organize content and design clear navigation paths.	1	t	t
119	21	Prototyping	Build interactive prototypes to simulate user experience.	2	t	t
120	21	Usability Testing	Test interfaces with users and identify friction points.	3	t	t
121	21	Responsive Design for UI/UX	Adapt interfaces for desktop, tablet, and mobile screens.	4	t	t
122	21	Design Systems Basics	Create reusable components, styles, and patterns.	5	t	t
123	21	Accessibility in Design	Design products that are usable by a wider range of people.	6	t	t
124	22	Advanced Interaction Design	Design microinteractions and advanced user interface behavior.	1	t	t
125	22	Advanced Design Systems	Scale design systems across larger products and teams.	2	t	t
126	22	UX Strategy	Connect business goals with user needs and design decisions.	3	t	t
127	22	Data-Driven Design Decisions	Use analytics and feedback to improve product experience.	4	t	t
128	22	Advanced User Research	Apply deeper research methods such as interviews and journey mapping.	5	t	t
129	22	Portfolio and Case Study Design	Present design work professionally through case studies and portfolios.	6	t	t
130	23	Introduction to Cloud Computing	Understand what cloud computing is and why it is used.	1	t	t
131	23	Cloud Service Models	Learn the basics of IaaS, PaaS, and SaaS.	2	t	t
132	23	Cloud Deployment Models	Understand public, private, and hybrid cloud models.	3	t	t
133	23	Virtual Machines and Containers Basics	Compare virtual machines and containers in cloud environments.	4	t	t
134	23	Cloud Storage Basics	Learn how cloud storage and object storage work.	5	t	t
135	23	Introduction to AWS or Azure	Explore the basics of a major cloud platform.	6	t	t
136	24	Compute Services	Work with cloud compute services such as EC2 or virtual machines.	1	t	t
137	24	Cloud Networking Basics	Understand VPCs, subnets, IPs, and routing in the cloud.	2	t	t
138	24	Databases in the Cloud	Learn managed databases and cloud data services.	3	t	t
139	24	IAM and Access Control	Control access to cloud resources securely.	4	t	t
140	24	Monitoring and Logging	Track cloud resources and troubleshoot systems.	5	t	t
141	24	Deploying Applications to the Cloud	Deploy and manage applications in cloud environments.	6	t	t
142	25	Cloud Architecture Design	Design scalable and reliable cloud architectures.	1	t	t
143	25	Kubernetes and Container Orchestration	Manage containers at scale using orchestration tools.	2	t	t
144	25	Infrastructure as Code	Automate infrastructure provisioning using code.	3	t	t
145	25	Cloud Security	Secure cloud systems, data, and access controls.	4	t	t
146	25	Serverless Computing	Build applications using serverless services and functions.	5	t	t
147	25	Cloud Cost Optimization	Monitor and optimize cloud usage and spending.	6	t	t
\.


--
-- TOC entry 3169 (class 0 OID 24720)
-- Dependencies: 209
-- Data for Name: roadmaps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roadmaps (id, field_name, level, title, description) FROM stdin;
1	Programming Fundamentals	Beginner	Programming Fundamentals - Beginner Roadmap	Learn the essential programming concepts to build a strong foundation before moving to advanced development fields.
3	Programming Fundamentals	Intermediate	Programming Fundamentals Roadmap - Intermediate	Intermediate roadmap for programming fundamentals learners
4	Programming Fundamentals	Advanced	Programming Fundamentals Roadmap - Advanced	Advanced roadmap for programming fundamentals learners
5	Frontend Development	Beginner	Frontend Development Roadmap - Beginner	Beginner roadmap for frontend development learners
6	Frontend Development	Intermediate	Frontend Development Roadmap - Intermediate	Intermediate roadmap for frontend development learners
7	Frontend Development	Advanced	Frontend Development Roadmap - Advanced	Advanced roadmap for frontend development learners
8	Backend Development	Beginner	Backend Development Roadmap - Beginner	Beginner roadmap for backend development learners
9	Backend Development	Intermediate	Backend Development Roadmap - Intermediate	Intermediate roadmap for backend development learners
10	Backend Development	Advanced	Backend Development Roadmap - Advanced	Advanced roadmap for backend development learners
11	Databases	Beginner	Databases Roadmap - Beginner	Beginner roadmap for database learners
12	Databases	Intermediate	Databases Roadmap - Intermediate	Intermediate roadmap for database learners
13	Databases	Advanced	Databases Roadmap - Advanced	Advanced roadmap for database learners
14	Cyber Security	Beginner	Cyber Security Roadmap - Beginner	Beginner roadmap for cybersecurity learners
15	Cyber Security	Intermediate	Cyber Security Roadmap - Intermediate	Intermediate roadmap for cybersecurity learners
16	Cyber Security	Advanced	Cyber Security Roadmap - Advanced	Advanced roadmap for cybersecurity learners
17	Mobile Development	Beginner	Mobile Development Roadmap - Beginner	Beginner roadmap for mobile app development learners
18	Mobile Development	Intermediate	Mobile Development Roadmap - Intermediate	Intermediate roadmap for mobile app development learners
19	Mobile Development	Advanced	Mobile Development Roadmap - Advanced	Advanced roadmap for mobile app development learners
20	UI/UX Design	Beginner	UI/UX Design Roadmap - Beginner	Beginner roadmap for UI/UX design learners
21	UI/UX Design	Intermediate	UI/UX Design Roadmap - Intermediate	Intermediate roadmap for UI/UX design learners
22	UI/UX Design	Advanced	UI/UX Design Roadmap - Advanced	Advanced roadmap for UI/UX design learners
23	Cloud Computing	Beginner	Cloud Computing Roadmap - Beginner	Beginner roadmap for cloud computing learners
24	Cloud Computing	Intermediate	Cloud Computing Roadmap - Intermediate	Intermediate roadmap for cloud computing learners
25	Cloud Computing	Advanced	Cloud Computing Roadmap - Advanced	Advanced roadmap for cloud computing learners
26	Databases	Beginner	Databases Roadmap - Beginner	Beginner roadmap for learning database fundamentals, SQL basics, and data modeling
27	Databases	Intermediate	Databases Roadmap - Intermediate	Intermediate roadmap for mastering advanced SQL, normalization, indexing, and database design
28	Databases	Advanced	Databases Roadmap - Advanced	Advanced roadmap for database optimization, distributed systems, performance tuning, and big data concepts
29	Cyber Security	Beginner	Cyber Security Roadmap - Beginner	Beginner roadmap for learning cybersecurity fundamentals, threats, and basic protection techniques
30	Cyber Security	Intermediate	Cyber Security Roadmap - Intermediate	Intermediate roadmap for mastering network security, ethical hacking, and security tools
31	Cyber Security	Advanced	Cyber Security Roadmap - Advanced	Advanced roadmap for penetration testing, advanced threats, cryptography, and security architecture
\.


--
-- TOC entry 3179 (class 0 OID 24814)
-- Dependencies: 219
-- Data for Name: user_fields; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_fields (id, user_id, field_id, created_at) FROM stdin;
\.


--
-- TOC entry 3167 (class 0 OID 24701)
-- Dependencies: 207
-- Data for Name: user_paths; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_paths (id, user_id, path_name, selected_at) FROM stdin;
62	17	Backend Development	2026-04-11 09:46:38.692291
9	24	Software Engineering	2026-04-05 14:34:00.879454
68	28	Frontend Development	2026-04-11 09:58:11.35082
69	28	Backend Development	2026-04-11 09:58:11.3765
70	28	Databases	2026-04-11 09:58:11.389439
71	28	Programming Fundamentals	2026-04-11 09:58:11.401806
72	28	Cloud Computing	2026-04-11 09:58:11.409418
73	28	Mobile Development	2026-04-11 09:58:11.422572
74	28	UI/UX Design	2026-04-11 09:58:11.434426
75	28	Cyber Security	2026-04-11 09:58:11.44221
76	25	Frontend Development	2026-04-16 16:28:05.965593
77	25	Backend Development	2026-04-16 16:28:06.070295
78	25	Cloud Computing	2026-04-16 16:28:06.110032
86	31	Programming Fundamentals	2026-04-20 14:22:27.300662
87	31	Cyber Security	2026-04-20 14:29:41.607149
88	31	Frontend Development	2026-04-20 15:16:03.751441
89	17	Mobile Development	2026-04-22 14:58:29.075473
90	2	UI/UX Design	2026-04-22 16:54:55.485292
47	27	Programming Fundamentals	2026-04-06 14:28:11.43041
48	27	Frontend Development	2026-04-06 14:57:55.71659
49	27	Backend Development	2026-04-06 14:57:55.746308
50	27	UI/UX Design	2026-04-06 14:57:55.779709
51	27	Cloud Computing	2026-04-06 14:57:55.795909
\.


--
-- TOC entry 3183 (class 0 OID 24937)
-- Dependencies: 223
-- Data for Name: user_question_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_question_history (id, user_id, topic_id, generated_question_id, question_hash, question_text, question_type, weakness_tag, difficulty, difficulty_step, user_answer, correct_answer, was_correct, created_at) FROM stdin;
1	17	53	38	c7933b4bf185c9a6f7b9625e189611bcccc6b8df80470c08d9fdaa1a2ccebf97	What will be the output of the following code snippet when the endpoint '/data' is accessed?\n\nconst express = require('express');\nconst app = express();\napp.get('/data', async (req, res) => {\n    const cachedData = await getFromCache('data');\n    if (cachedData) {\n        return res.json(cachedData);\n    }\n    const data = await fetchDataFromDB();\n    res.json(data);\n});\n\napp.listen(3000);	output_prediction	loops	hard	3	A	A	t	2026-04-22 12:30:15.415478
2	17	53	39	b5bf596b4e7ab9fc6e53048c71c9e52aad83b1d19ced57fcd2e78394e49f5c67	Identify the error in the following middleware implementation.\n\nconst express = require('express');\nconst app = express();\n\napp.use((req, res, next) => {\n    console.log('Request URL:', req.url);\n    next;\n});\n\napp.get('/', (req, res) => res.send('Hello World!'));\n\napp.listen(3000);	find_the_error	loops	hard	3	B	B	t	2026-04-22 12:30:15.415478
3	17	53	40	abdd106ac81741fc52818094051593105207bf9ded1d023c7031064b627e5c9b	Fill in the blank: To implement caching in the following function, you can use __________ to store the fetched result temporarily.\n\nasync function getUserData(userId) {\n    const userData = await fetchUserFromDB(userId);\n    // Store user data in cache here\n    return userData;\n}	fill_the_blank	loops	hard	3	B	B	t	2026-04-22 12:30:15.415478
4	17	53	41	08db4f428998c3ebe4d601ff7b6f250d54fbadfaee75f498f33768495a88fd7b	What will happen if the following code is executed and an error occurs while fetching data?\n\napp.get('/user', async (req, res) => {\n    try {\n        const user = await getUserFromDB(req.params.id);\n        res.json(user);\n    } catch (error) {\n        res.status(500).send('Error fetching user data');\n    }\n});	code_logic	loops	hard	3	C	C	t	2026-04-22 12:30:15.415478
5	17	53	42	858bb3d16430c7c1f11aa839d9d42422ef8d6d1711ae85c43424da36e7d397cb	Which of the following best describes the purpose of middleware in an Express application?\n\napp.use(express.json());\napp.use((req, res, next) => {\n    console.log('Incoming request');\n    next();\n});	code_logic	loops	hard	3	B	B	t	2026-04-22 12:30:15.415478
6	17	54	43	219acf5daeb13c37de2dd129d827d016f8fc138cee6585801aa5fcf210cd9872	What will be the output of the following code snippet when a GET request is made to '/api/data'?\n\nconst express = require('express');\nconst app = express();\napp.get('/api/data', async (req, res) => {\n    const data = await fetchData();\n    res.json(data);\n});\nfunction fetchData() {\n    return Promise.resolve({ message: 'Hello, World!' });\n}\napp.listen(3000);	output_prediction	functions	hard	3	A	A	t	2026-04-22 12:46:17.708523
7	17	54	44	f7177cf1e8c63f873c007c017084a46fb4f9f12fcf54559d42f46fc40b6b778d	Identify the error in the following middleware function that is intended to validate request data.\n\nconst validateData = (req, res, next) => {\n    if (!req.body.name) {\n        return res.status(400).send('Name is required');\n    }\n    next();\n};\napp.use(validateData);\napp.post('/api/user', (req, res) => {\n    res.send('User created');\n});	find_the_error	functions	hard	3	B	B	t	2026-04-22 12:46:17.708523
8	17	54	45	d7a11a36f212da7636eafd8ef9258e78e527dec5492c6fdca673c9ad6680db32	What will happen if the following route handler is called with an invalid JSON body?\n\napp.post('/api/data', (req, res) => {\n    const data = req.body;\n    if (!data || !data.field) {\n        throw new Error('Invalid data');\n    }\n    res.send('Data received');\n});	code_logic	backend_routes	hard	3	B	B	t	2026-04-22 12:46:17.708523
9	17	54	46	521d51c15674fcd3ea815f25be9f449baf4213bbe60fe07246225dc67845e60b	Fill in the blank: In an Express application, to handle errors globally, you should use __________.\n\napp.use((err, req, res, next) => {\n    res.status(500).send('Something broke!');\n});	fill_the_blank	backend_routes	hard	3	A	A	t	2026-04-22 12:46:17.708523
10	17	54	47	45928f04f51644cfb8715fb16b1006297c2d50b0c8a9d24106ae4a20968eabcd	What is the expected behavior of the following code snippet if the API endpoint is accessed with an unsupported method?\n\napp.route('/api/items')\n    .get((req, res) => res.send('GET method'))\n    .post((req, res) => res.send('POST method'));\napp.all('/api/items', (req, res) => {\n    res.status(405).send('Method Not Allowed');\n});	code_logic	backend_routes	hard	3	B	B	t	2026-04-22 12:46:17.708523
11	17	55	48	c929a9bc5abfcb1da381b478f55b50025bb523a1b68860d177d3c91736bb50bb	What will the following code output when a GET request is made to '/api/data'?\n\nconst express = require('express');\nconst app = express();\n\napp.get('/api/data', async (req, res) => {\n    const data = await fetchData();\n    res.json(data);\n});\n\napp.listen(3000);\n	output_prediction	backend_routes	hard	3	A	A	t	2026-04-22 13:43:38.762975
12	17	55	49	f3b74d715d865b4a64fd53c11caf418c6768a1177e053ac5394b3c479e6ce005	Identify the error in the following middleware function.\n\napp.use((req, res, next) => {\n    if (!req.body.name) {\n        return res.status(400).send('Name is required');\n    }\n    next();\n});	find_the_error	functions	hard	3	A	A	t	2026-04-22 13:43:38.762975
13	17	55	50	1274e4aa42e72875080d8c300ee2e8fc581a49eb6d82cc271d23318bdebd47dc	Fill in the blank to properly handle a promise rejection in the following async route handler.\n\napp.get('/api/item', async (req, res) => {\n    try {\n        const item = await getItem();\n    } catch (error) {\n        _______\n    }\n});	fill_the_blank	backend_routes	hard	3	A	A	t	2026-04-22 13:43:38.762975
14	17	55	51	1813e3fcdebde24363983102c1846b4fc5c736c4c43b9675e917e3198efac00b	What is the purpose of this code block in a route handler?\n\napp.post('/api/user', (req, res) => {\n    const user = req.body;\n    if (!user.email || !user.password) {\n        return res.status(400).json({ error: 'Email and password are required' });\n    }\n    // Logic to create user\n});	code_logic	functions	hard	3	A	A	t	2026-04-22 13:43:38.762975
15	17	55	52	eddfcb36723bb2c2f0f7c82fffe23b932f35bfe75a9483b2faf1b867a1607bf6	What will happen if an error occurs in the following route without a proper error handler?\n\napp.get('/api/products', (req, res) => {\n    const products = getProducts(); // Assume this function may throw an error\n    res.json(products);\n});	output_prediction	functions	hard	3	B	B	t	2026-04-22 13:43:38.762975
16	17	56	53	c739202c3635450f25fefb1a440ec5980164fa768c2a86fd3bb975c003dc51e7	What will be the output of the following Express route if the URL contains a valid user ID?\n\napp.get('/user/:id', async (req, res) => { const user = await getUser(req.params.id); res.json(user); });	output_prediction	backend_routes	hard	3	A	A	t	2026-04-22 14:02:47.719398
17	17	56	54	8f39dd2c0c898a3d0f4c61af6ddc770c1292d6e343d912e9feca521c31006486	Identify the error in the following middleware function for error handling.\n\napp.use((err, req, res, next) => { res.status(500).send('Something broke!'); next(); });	find_the_error	loops	hard	3	A	A	t	2026-04-22 14:02:47.719398
18	17	56	55	65e561f84156b6e6c3be22a340e0e4b380171e67bfee8f7a96b6cf44d428b446	Fill in the blank to ensure the API validates incoming JSON data correctly.\n\napp.post('/data', (req, res) => { const { value } = req.body; if (value) { res.send('Valid data'); } else { _______ } });	fill_the_blank	general	hard	3	A	A	t	2026-04-22 14:02:47.719398
19	17	56	56	9a9dc8097214ace785334d79f76d833b87ed6be1584f00b0cb91fb64a79bfd0b	What is the purpose of the following line in an Express route for handling a request?\n\nconst user = await User.findById(req.params.id);	code_logic	loops	hard	3	A	A	t	2026-04-22 14:02:47.719398
20	17	56	57	72ae15c0099ae45d9807ef7328f73e94f620d95a8beecd72601461427fa55616	Given the following Express route, what will happen if an invalid JSON is sent to it?\n\napp.post('/submit', express.json(), (req, res) => { res.send(req.body); });	output_prediction	backend_routes	hard	3	B	B	t	2026-04-22 14:02:47.719398
21	17	57	58	39524ac109d8005381cd7c462ee85dd182021ee83a17021aeb3010308d5a9a6a	What will be the output of the following Node.js code snippet?\n\nconst express = require('express');\nconst app = express();\n\napp.get('/data', async (req, res) => {\n    const data = await fetchData();\n    res.json(data);\n});\n\napp.listen(3000);\n\nasync function fetchData() {\n    return { name: 'Cognito', type: 'Learning Platform' };\n}	output_prediction	loops	hard	3	A	A	t	2026-04-22 14:06:47.108657
22	17	57	59	b2a48eefb6b71a1f8efd3806858da8c5b7c2423a93735ac4aa3e72d38f1e6008	Identify the error in the following Express.js middleware implementation.\n\napp.use((req, res, next) => {\n    if (!req.body.name) {\n        return res.status(400).send('Name is required');\n    }\n    next();\n});	find_the_error	functions	hard	3	C	C	t	2026-04-22 14:06:47.108657
23	17	57	60	618d2ab824490f929b0e6cd562be16456daccd2b3ccc3acf88c703ddb1691cd3	What will happen if the following code is executed in an Express route without proper error handling?\n\napp.get('/user', async (req, res) => {\n    const user = await getUserById(req.params.id);\n    res.send(user);\n});	code_logic	backend_routes	hard	3	C	C	t	2026-04-22 14:06:47.108657
24	17	57	61	1a7435b856c5934b1f33aac0b9d8e89373875189319bc612ff5cbd9690af5eb1	Fill in the blank to correctly validate a request body in an Express.js route.\n\napp.post('/submit', (req, res) => {\n    if (____) {\n        return res.status(400).send('Invalid data');\n    }\n    res.send('Data submitted');\n});	fill_the_blank	functions	hard	3	B	B	t	2026-04-22 14:06:47.108657
25	17	57	62	0f8f7cbbb997d7ecb1ca7f58e6e501aca761730d53c5c3377acc4c9e719d9754	Which of the following practices best enhances the security of an Express application?\n\napp.use(express.json());\napp.use((req, res, next) => {\n    // Security measures here\n});	code_logic	backend_routes	hard	3	A	A	t	2026-04-22 14:06:47.108657
\.


--
-- TOC entry 3177 (class 0 OID 24789)
-- Dependencies: 217
-- Data for Name: user_topic_progress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_topic_progress (id, user_id, topic_id, status, score, completed_at) FROM stdin;
473780	31	76	unlocked	0	\N
473781	31	22	unlocked	0	\N
325966	17	53	completed	100	2026-04-22 12:30:15.424
39	27	9	unlocked	0	\N
40	27	28	unlocked	0	\N
41	27	46	unlocked	0	\N
43	27	118	unlocked	0	\N
44	27	136	unlocked	0	\N
475217	17	54	completed	100	2026-04-22 12:46:17.712
492114	17	55	completed	100	2026-04-22 13:43:38.77
500429	17	106	unlocked	0	\N
22391	28	100	unlocked	0	\N
473779	31	1	unlocked	0	\N
22392	28	118	unlocked	0	\N
22386	28	28	unlocked	0	\N
8	17	52	completed	100	2026-04-22 12:06:12.758
500154	17	57	completed	100	2026-04-22 14:06:47.135
22393	28	82	unlocked	0	\N
520856	2	112	unlocked	0	\N
492198	17	56	completed	100	2026-04-22 14:02:47.728
22387	28	46	unlocked	0	\N
22390	28	136	unlocked	0	\N
22389	28	9	unlocked	0	\N
22388	28	64	unlocked	0	\N
\.


--
-- TOC entry 3161 (class 0 OID 16461)
-- Dependencies: 201
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, email, password, created_at, field, level, placement_score, phone, university_major, google_id, auth_provider, avatar_url, role) FROM stdin;
29	admin gp	gb-14@gmail.com	123456	2026-04-18 13:57:57.409297	\N	\N	\N	0785152900	se	\N	local	\N	learner
30	admin 1	gb-15@gmail.com	123456	2026-04-18 14:11:47.352757	\N	\N	\N	0785152900	se	\N	local	\N	learner
3	ali	alitst@gmail.com	157972	2025-12-21 23:05:28.960525	Backend Development	\N	\N	\N	\N	\N	local	\N	learner
22	JustForJUST	jfj.hr.members@gmail.com	GOOGLE_AUTH	2026-04-04 17:15:26.093404	\N	\N	\N	0785152900	software eng	111049265728100287830	google	https://lh3.googleusercontent.com/a/ACg8ocIj2aau5bR0wyOIPxXOUGb8ciS9074KvvZNPQgpWohUEv993Cc=s96-c	learner
32	admin 3	admin2@gmail.com	123456	2026-04-18 14:55:08.992798	\N	\N	\N	0785152900	se	\N	local	\N	admin
23	kamel ahmad	kamel22@gmail.com	123456	2026-04-05 14:15:10.625873	\N	Intermediate	50	0785152900	cis	\N	local	\N	learner
33	احمد محمد	ahamd22@gmail.com	123456	2026-04-20 14:31:21.620957	\N	\N	\N	0785152900	هندسة البرمجيات	\N	local	\N	user
31	admin  2	admin1@gmail.com	123456	2026-04-18 14:12:30.480394	Programming Fundamentals	Beginner	33	0785152900	se	\N	local	\N	learner
27	mohanad sawaie	mohali@gmail.com	123456	2026-04-06 14:26:58.832204	Programming Fundamentals	Intermediate	45	0785152900	se	\N	local	\N	learner
26	ali mohammad	ali@gmail.com	123456	2026-04-05 15:17:10.297841	\N	Advanced	100	0785152900	cis	\N	local	\N	learner
2	Mohanad Ali	mohanadsawaie3@gmail.com	157972	2025-12-21 22:56:47.993159	UI/UX Design	Beginner	45	\N	\N	105012572188023772179	google	https://lh3.googleusercontent.com/a/ACg8ocLKg4ROR7WYMhvYImZ9c4CAYMeRYZh2yAPlv_0z09dm7ZzCKJo=s96-c	learner
24	ahmad moh	ahmad@gmail.com	123456	2026-04-05 14:20:13.33987	\N	Beginner	0	0785152900	cs	\N	local	\N	learner
5	moh	mohtst@gmail.com	2003	2025-12-29 19:50:35.396821	\N	\N	\N	\N	\N	\N	local	\N	learner
4	omar	omar@tst.com	157972	2025-12-29 15:41:06.351024	\N	\N	\N	\N	\N	\N	local	\N	learner
1	mohanad	mohanadtst@gmail.com	2003	2025-12-21 21:52:33.790916	Programming Fundamentals	Beginner	\N	\N	\N	\N	local	\N	learner
34	admin 19	admin19@gmail.com	HASH_HERE	2026-04-22 17:04:05.450344	\N	\N	\N	0785152900	se	\N	local	\N	admin
6	mohanad sawei	sawaie22tst@gmail.com	123456	2025-12-29 21:01:13.315725	\N	Advanced	94	\N	\N	\N	local	\N	learner
7	omar	omarkhaledtst@gmail.com	123456	2025-12-29 21:48:09.946671	Frontend Development	Beginner	33	\N	\N	\N	local	\N	learner
28	moh sawaie	sawie21@gmail.com	123456	2026-04-11 09:56:28.335004	Frontend Development	Intermediate	53	078552900	se	\N	local	\N	learner
17	Mohanad Sawaie	maalsawie21@cit.just.edu.jo	0785152900	2026-03-27 19:12:55.271426	Backend Development	Advanced	80	\N	\N	\N	local	\N	learner
8	ali	ali66tst@gmail.com	123456	2026-01-01 13:01:54.909582	Frontend Development	Advanced	80	\N	\N	\N	local	\N	learner
9	Automation User	auto1767369633255@test.com	123456	2026-01-02 19:00:35.231748	\N	\N	\N	\N	\N	\N	local	\N	learner
10	Automation User	auto1767369641640@test.com	123456	2026-01-02 19:00:43.21012	\N	\N	\N	\N	\N	\N	local	\N	learner
11	Automation User	auto1767369657896@test.com	123456	2026-01-02 19:00:59.737603	\N	\N	\N	\N	\N	\N	local	\N	learner
12	Mohanad Sawaie	sawaie04tst@gmail.com	157972	2026-01-04 19:25:44.449933	\N	\N	\N	\N	\N	\N	local	\N	learner
13	Mohanad SAWAIE	sawaie19tst@gmail.com	157972	2026-01-04 19:26:33.015316	Backend Development	Advanced	84	\N	\N	\N	local	\N	learner
14	Khaled ali	khaledtst22@gmail.com	157972	2026-01-12 19:43:41.410297	\N	Advanced	100	\N	\N	\N	local	\N	learner
15	ali	ali22tst@gmail.com	123456	2026-01-13 22:37:38.995718	\N	\N	\N	\N	\N	\N	local	\N	learner
25	Mohanad Sawaie	sawaiemohanad@gmail.com	GOOGLE_AUTH	2026-04-05 15:10:15.825636	Frontend Development	\N	\N	0785152900	SE	116251263297694354451	google	https://lh3.googleusercontent.com/a/ACg8ocKPxhc19ObsvWJj_efC3IWn995NYpuIWlPMeX4ChRd4Tz3m0A=s96-c	learner
16	mousa	mousatst10@gmail.com	123	2026-01-19 16:57:41.959943	Backend Development	Beginner	30	\N	\N	\N	local	\N	learner
18	مهند علي	Mohanad66@gmail.com	123456	2026-04-04 13:15:33.631432	\N	\N	\N	\N	\N	\N	local	\N	learner
19	Ali Sawaie	ali33@gmail.com	123456	2026-04-04 13:51:26.674964	\N	\N	\N	0785152900	Software eng	\N	local	\N	learner
20	omar khaled	omar44@gmail.com	123456	2026-04-04 13:57:55.330435	\N	\N	\N	0785152900	software eng	\N	local	\N	learner
21	Mohanad Sawaie	mohanadsawaie5@gmail.com	GOOGLE_AUTH	2026-04-04 14:38:49.639369	\N	\N	\N	\N	\N	104613385029838094352	google	https://lh3.googleusercontent.com/a/ACg8ocLvXRIMiGEntx18PAly2RPcsxfZRkkVXEFZ-FMWShhJ00IKiQ=s96-c	learner
\.


--
-- TOC entry 3205 (class 0 OID 0)
-- Dependencies: 204
-- Name: fields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fields_id_seq', 7, true);


--
-- TOC entry 3206 (class 0 OID 0)
-- Dependencies: 220
-- Name: generated_questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.generated_questions_id_seq', 62, true);


--
-- TOC entry 3207 (class 0 OID 0)
-- Dependencies: 224
-- Name: placement_questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.placement_questions_id_seq', 40, true);


--
-- TOC entry 3208 (class 0 OID 0)
-- Dependencies: 202
-- Name: questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.questions_id_seq', 1684, true);


--
-- TOC entry 3209 (class 0 OID 0)
-- Dependencies: 212
-- Name: resources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.resources_id_seq', 346, true);


--
-- TOC entry 3210 (class 0 OID 0)
-- Dependencies: 214
-- Name: roadmap_questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roadmap_questions_id_seq', 1, false);


--
-- TOC entry 3211 (class 0 OID 0)
-- Dependencies: 210
-- Name: roadmap_topics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roadmap_topics_id_seq', 147, true);


--
-- TOC entry 3212 (class 0 OID 0)
-- Dependencies: 208
-- Name: roadmaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roadmaps_id_seq', 31, true);


--
-- TOC entry 3213 (class 0 OID 0)
-- Dependencies: 218
-- Name: user_fields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_fields_id_seq', 1, false);


--
-- TOC entry 3214 (class 0 OID 0)
-- Dependencies: 206
-- Name: user_paths_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_paths_id_seq', 90, true);


--
-- TOC entry 3215 (class 0 OID 0)
-- Dependencies: 222
-- Name: user_question_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_question_history_id_seq', 25, true);


--
-- TOC entry 3216 (class 0 OID 0)
-- Dependencies: 216
-- Name: user_topic_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_topic_progress_id_seq', 534897, true);


--
-- TOC entry 3217 (class 0 OID 0)
-- Dependencies: 200
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 35, true);


--
-- TOC entry 2982 (class 2606 OID 16496)
-- Name: fields fields_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fields_name_key UNIQUE (name);


--
-- TOC entry 2984 (class 2606 OID 16494)
-- Name: fields fields_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fields_pkey PRIMARY KEY (id);


--
-- TOC entry 3006 (class 2606 OID 24921)
-- Name: generated_questions generated_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.generated_questions
    ADD CONSTRAINT generated_questions_pkey PRIMARY KEY (id);


--
-- TOC entry 3014 (class 2606 OID 24981)
-- Name: placement_questions placement_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.placement_questions
    ADD CONSTRAINT placement_questions_pkey PRIMARY KEY (id);


--
-- TOC entry 2980 (class 2606 OID 16483)
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- TOC entry 2992 (class 2606 OID 24757)
-- Name: resources resources_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resources
    ADD CONSTRAINT resources_pkey PRIMARY KEY (id);


--
-- TOC entry 2994 (class 2606 OID 24781)
-- Name: roadmap_questions roadmap_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roadmap_questions
    ADD CONSTRAINT roadmap_questions_pkey PRIMARY KEY (id);


--
-- TOC entry 2990 (class 2606 OID 24740)
-- Name: roadmap_topics roadmap_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roadmap_topics
    ADD CONSTRAINT roadmap_topics_pkey PRIMARY KEY (id);


--
-- TOC entry 2988 (class 2606 OID 24728)
-- Name: roadmaps roadmaps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roadmaps
    ADD CONSTRAINT roadmaps_pkey PRIMARY KEY (id);


--
-- TOC entry 3002 (class 2606 OID 24820)
-- Name: user_fields user_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_fields
    ADD CONSTRAINT user_fields_pkey PRIMARY KEY (id);


--
-- TOC entry 3004 (class 2606 OID 24822)
-- Name: user_fields user_fields_user_id_field_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_fields
    ADD CONSTRAINT user_fields_user_id_field_id_key UNIQUE (user_id, field_id);


--
-- TOC entry 2986 (class 2606 OID 24707)
-- Name: user_paths user_paths_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_paths
    ADD CONSTRAINT user_paths_pkey PRIMARY KEY (id);


--
-- TOC entry 3012 (class 2606 OID 24947)
-- Name: user_question_history user_question_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_question_history
    ADD CONSTRAINT user_question_history_pkey PRIMARY KEY (id);


--
-- TOC entry 2996 (class 2606 OID 24797)
-- Name: user_topic_progress user_topic_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_topic_progress
    ADD CONSTRAINT user_topic_progress_pkey PRIMARY KEY (id);


--
-- TOC entry 2998 (class 2606 OID 24799)
-- Name: user_topic_progress user_topic_progress_user_id_topic_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_topic_progress
    ADD CONSTRAINT user_topic_progress_user_id_topic_id_key UNIQUE (user_id, topic_id);


--
-- TOC entry 3000 (class 2606 OID 24846)
-- Name: user_topic_progress user_topic_progress_user_topic_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_topic_progress
    ADD CONSTRAINT user_topic_progress_user_topic_unique UNIQUE (user_id, topic_id);


--
-- TOC entry 2974 (class 2606 OID 16469)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 2976 (class 2606 OID 24715)
-- Name: users users_google_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_google_id_unique UNIQUE (google_id);


--
-- TOC entry 2978 (class 2606 OID 16467)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3007 (class 1259 OID 24934)
-- Name: idx_generated_questions_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_generated_questions_hash ON public.generated_questions USING btree (question_hash);


--
-- TOC entry 3008 (class 1259 OID 24933)
-- Name: idx_generated_questions_user_topic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_generated_questions_user_topic ON public.generated_questions USING btree (user_id, topic_id);


--
-- TOC entry 3009 (class 1259 OID 24964)
-- Name: idx_user_question_history_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_question_history_hash ON public.user_question_history USING btree (user_id, topic_id, question_hash);


--
-- TOC entry 3010 (class 1259 OID 24963)
-- Name: idx_user_question_history_user_topic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_question_history_user_topic ON public.user_question_history USING btree (user_id, topic_id, created_at DESC);


--
-- TOC entry 3015 (class 2606 OID 16497)
-- Name: questions fk_questions_field; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT fk_questions_field FOREIGN KEY (field_id) REFERENCES public.fields(id) ON DELETE SET NULL;


--
-- TOC entry 3016 (class 2606 OID 24765)
-- Name: questions fk_topic; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT fk_topic FOREIGN KEY (topic_id) REFERENCES public.roadmap_topics(id) ON DELETE CASCADE;


--
-- TOC entry 3025 (class 2606 OID 24927)
-- Name: generated_questions generated_questions_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.generated_questions
    ADD CONSTRAINT generated_questions_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.roadmap_topics(id) ON DELETE CASCADE;


--
-- TOC entry 3026 (class 2606 OID 24922)
-- Name: generated_questions generated_questions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.generated_questions
    ADD CONSTRAINT generated_questions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3019 (class 2606 OID 24758)
-- Name: resources resources_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resources
    ADD CONSTRAINT resources_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.roadmap_topics(id) ON DELETE CASCADE;


--
-- TOC entry 3020 (class 2606 OID 24782)
-- Name: roadmap_questions roadmap_questions_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roadmap_questions
    ADD CONSTRAINT roadmap_questions_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.roadmap_topics(id) ON DELETE CASCADE;


--
-- TOC entry 3018 (class 2606 OID 24741)
-- Name: roadmap_topics roadmap_topics_roadmap_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roadmap_topics
    ADD CONSTRAINT roadmap_topics_roadmap_id_fkey FOREIGN KEY (roadmap_id) REFERENCES public.roadmaps(id) ON DELETE CASCADE;


--
-- TOC entry 3023 (class 2606 OID 24828)
-- Name: user_fields user_fields_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_fields
    ADD CONSTRAINT user_fields_field_id_fkey FOREIGN KEY (field_id) REFERENCES public.fields(id) ON DELETE CASCADE;


--
-- TOC entry 3024 (class 2606 OID 24823)
-- Name: user_fields user_fields_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_fields
    ADD CONSTRAINT user_fields_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3017 (class 2606 OID 24708)
-- Name: user_paths user_paths_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_paths
    ADD CONSTRAINT user_paths_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3027 (class 2606 OID 24958)
-- Name: user_question_history user_question_history_generated_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_question_history
    ADD CONSTRAINT user_question_history_generated_question_id_fkey FOREIGN KEY (generated_question_id) REFERENCES public.generated_questions(id) ON DELETE SET NULL;


--
-- TOC entry 3028 (class 2606 OID 24953)
-- Name: user_question_history user_question_history_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_question_history
    ADD CONSTRAINT user_question_history_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.roadmap_topics(id) ON DELETE CASCADE;


--
-- TOC entry 3029 (class 2606 OID 24948)
-- Name: user_question_history user_question_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_question_history
    ADD CONSTRAINT user_question_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3021 (class 2606 OID 24805)
-- Name: user_topic_progress user_topic_progress_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_topic_progress
    ADD CONSTRAINT user_topic_progress_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.roadmap_topics(id) ON DELETE CASCADE;


--
-- TOC entry 3022 (class 2606 OID 24800)
-- Name: user_topic_progress user_topic_progress_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_topic_progress
    ADD CONSTRAINT user_topic_progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3191 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2026-04-22 18:35:29

--
-- PostgreSQL database dump complete
--

\unrestrict JN95htiKYHqGRf6e9C70AArPFhgRb7MVmhxgHzUrxjfOmDVasvTAXrXrteZxmyE

