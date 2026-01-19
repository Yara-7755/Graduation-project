--
-- PostgreSQL database dump
--

\restrict sRk2dPPfLbeOiEWuSTRL7Bw9qRMkEnwwD0fOEg6hLfoB4ViRD6b1K7gQAemZ9xN

-- Dumped from database version 13.23
-- Dumped by pg_dump version 18.1

-- Started on 2026-01-07 21:20:27

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

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 3023 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 205 (class 1259 OID 16489)
-- Name: fields; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fields (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    description text
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
-- TOC entry 3025 (class 0 OID 0)
-- Dependencies: 204
-- Name: fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fields_id_seq OWNED BY public.fields.id;


--
-- TOC entry 203 (class 1259 OID 16474)
-- Name: questions; Type: TABLE; Schema: public; Owner: postgres
--
CREATE TABLE public.user_paths (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  path_name VARCHAR NOT NULL,
  selected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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
    CONSTRAINT questions_correct_option_check CHECK ((correct_option = ANY (ARRAY['A'::bpchar, 'B'::bpchar, 'C'::bpchar, 'D'::bpchar])))
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
-- TOC entry 3026 (class 0 OID 0)
-- Dependencies: 202
-- Name: questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.questions_id_seq OWNED BY public.questions.id;


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
    placement_score integer
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
-- TOC entry 3027 (class 0 OID 0)
-- Dependencies: 200
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 2869 (class 2604 OID 16492)
-- Name: fields id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fields ALTER COLUMN id SET DEFAULT nextval('public.fields_id_seq'::regclass);


--
-- TOC entry 2867 (class 2604 OID 16477)
-- Name: questions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions ALTER COLUMN id SET DEFAULT nextval('public.questions_id_seq'::regclass);


--
-- TOC entry 2865 (class 2604 OID 16464)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 3017 (class 0 OID 16489)
-- Dependencies: 205
-- Data for Name: fields; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fields (id, name, description) FROM stdin;
1	Frontend Development	Focuses on building user interfaces using HTML, CSS, JavaScript, and frameworks like React.
2	Backend Development	Focuses on server-side logic, APIs, databases, and system architecture.
5	Software Engineering	Covers software design, problem solving, algorithms, and development methodologies.
4	Databases	Focuses on data modeling, SQL, database management systems, and optimization.
3	Programming Fundamentals	Start your journey by learning the basic programming concepts, coding techniques and fundamental Algorithms.
\.


--
-- TOC entry 3015 (class 0 OID 16474)
-- Dependencies: 203
-- Data for Name: questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.questions (id, question, option_a, option_b, option_c, option_d, correct_option, category, difficulty, field_id, type) FROM stdin;
48	What does HTML stand for?	HyperText Markup Language	HighText Machine Language	Hyper Tool Markup Language	None of the above	A	\N	\N	1	general
49	What does HTML stand for?	HyperText Markup Language	HighText Machine Language	Hyper Tool Markup Language	None of the above	A	\N	\N	\N	general
50	What does CSS control?	Database queries	Page styling	Server logic	Operating system	B	\N	\N	\N	general
51	Which device executes instructions?	RAM	CPU	Hard Disk	GPU	B	\N	\N	\N	general
52	What does RAM stand for?	Read Access Memory	Random Access Memory	Run All Memory	Rapid Action Memory	B	\N	\N	\N	general
53	Which component stores data permanently?	RAM	Cache	Hard Disk	CPU	C	\N	\N	\N	general
54	What is an operating system?	A hardware device	System software	Programming language	Database	B	\N	\N	\N	general
55	Which of these is an input device?	Monitor	Printer	Keyboard	Speaker	C	\N	\N	\N	general
56	Which of these is NOT an operating system?	Windows	Linux	MySQL	macOS	C	\N	\N	\N	general
57	What does HTTP stand for?	HyperText Transfer Protocol	High Transfer Text Process	Hyper Transfer Text Program	None	A	\N	\N	\N	general
58	What does LAN stand for?	Large Area Network	Local Area Network	Logical Access Network	Low Area Network	B	\N	\N	\N	general
59	Which one is a programming language?	HTML	CSS	Python	HTTP	C	\N	\N	\N	general
60	Which storage is the fastest?	HDD	SSD	RAM	USB	C	\N	\N	\N	general
61	What is a database?	A collection of files	A collection of data	A hardware device	An operating system	B	\N	\N	\N	general
62	Which of these is an output device?	Mouse	Keyboard	Monitor	Scanner	C	\N	\N	\N	general
63	What does CPU stand for?	Central Processing Unit	Computer Personal Unit	Central Performance Utility	Control Processing Unit	A	\N	\N	\N	general
64	Which one is used to browse the internet?	Browser	Compiler	Editor	Database	A	\N	\N	\N	general
65	What is software?	Physical components	Programs and applications	Network cables	Input devices	B	\N	\N	\N	general
66	Which one is system software?	MS Word	Windows	Chrome	Photoshop	B	\N	\N	\N	general
67	What is hardware?	Programs	Physical components	Data	Internet	B	\N	\N	\N	general
68	What does URL stand for?	Uniform Resource Locator	Universal Resource Link	User Reference Link	Uniform Reference Link	A	\N	\N	\N	general
69	Which of these stores the OS?	RAM	CPU	Hard Disk	Cache	C	\N	\N	\N	general
70	What is the brain of the computer?	RAM	Hard Disk	CPU	Motherboard	C	\N	\N	\N	general
71	Which one is a web browser?	Linux	Google Chrome	Windows	Android	B	\N	\N	\N	general
72	What does IT stand for?	Information Technology	Internet Tools	Integrated Tech	Intelligent Technology	A	\N	\N	\N	general
73	Which one is volatile memory?	Hard Disk	SSD	RAM	ROM	C	\N	\N	\N	general
74	What is the main function of RAM?	Store permanent data	Execute programs	Temporary storage	Control hardware	C	\N	\N	\N	general
75	Which is an example of an OS?	Python	Linux	HTML	SQL	B	\N	\N	\N	general
76	What does GUI stand for?	Graphical User Interface	General User Interaction	Global User Internet	Graph Utility Interface	A	\N	\N	\N	general
77	Which one is NOT hardware?	Keyboard	Monitor	CPU	Windows	D	\N	\N	\N	general
78	What is a network?	Single computer	Connected computers	Storage device	Operating system	B	\N	\N	\N	general
79	Which protocol is used for emails?	HTTP	FTP	SMTP	TCP	C	\N	\N	\N	general
80	Which one is an example of cloud storage?	Google Drive	USB	Hard Disk	RAM	A	\N	\N	\N	general
81	What does IP stand for?	Internet Protocol	Internal Program	Input Process	Internet Process	A	\N	\N	\N	general
82	Which device connects networks?	Switch	Router	Keyboard	Monitor	B	\N	\N	\N	general
83	What is malware?	Useful software	Hardware component	Malicious software	Operating system	C	\N	\N	\N	general
84	Which one is used to type text?	Mouse	Keyboard	Monitor	Printer	B	\N	\N	\N	general
85	Which file extension is an image?	.txt	.jpg	.exe	.sql	B	\N	\N	\N	general
86	What does SSD stand for?	Solid State Drive	Super Speed Disk	System Storage Device	Secure Storage Drive	A	\N	\N	\N	general
87	Which one is used for video calls?	Zoom	Notepad	Calculator	CMD	A	\N	\N	\N	general
88	What is the internet?	Local computer	Global network	Operating system	Database	B	\N	\N	\N	general
89	Which one is a mobile OS?	Windows	Linux	Android	Ubuntu	C	\N	\N	\N	general
90	What is phishing?	Secure login	Fake messages	Encryption	Firewall	B	\N	\N	\N	general
91	Which one is used to store data?	RAM	Hard Disk	CPU	GPU	B	\N	\N	\N	general
92	What is a file?	A folder	A collection of data	A program	An OS	B	\N	\N	\N	general
93	Which one is an example of software?	Mouse	Keyboard	MS Word	Monitor	C	\N	\N	\N	general
94	What does BIOS do?	Starts the OS	Stores files	Connects internet	Runs apps	A	\N	\N	\N	general
\.


--
-- TOC entry 3013 (class 0 OID 16461)
-- Dependencies: 201
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, email, password, created_at, field, level, placement_score) FROM stdin;
1	yamin@123     		2025-12-21 21:52:33.790916	\N	\N	\N
3	ali	alitst@gmail.com	157972	2025-12-21 23:05:28.960525	Backend Development	\N	\N
4	omar	omar@tst.com	157972	2025-12-29 15:41:06.351024	\N	\N	\N
5	moh	mohtst@gmail.com	2003	2025-12-29 19:50:35.396821	Software Engineering	\N	\N
6	mohanad sawei	sawaie22tst@gmail.com	123456	2025-12-29 21:01:13.315725	\N	Advanced	94
7	omar	omarkhaledtst@gmail.com	123456	2025-12-29 21:48:09.946671	Frontend Development	Beginner	33
2	Mohanad Ali	mohanadsawaie3@gmail.com	157972	2025-12-21 22:56:47.993159	Backend Development	Intermediate	45
8	ali	ali66tst@gmail.com	123456	2026-01-01 13:01:54.909582	Frontend Development	Advanced	80
9	Automation User	auto1767369633255@test.com	123456	2026-01-02 19:00:35.231748	\N	\N	\N
10	Automation User	auto1767369641640@test.com	123456	2026-01-02 19:00:43.21012	\N	\N	\N
11	Automation User	auto1767369657896@test.com	123456	2026-01-02 19:00:59.737603	\N	\N	\N
12	Mohanad Sawaie	sawaie04tst@gmail.com	157972	2026-01-04 19:25:44.449933	\N	\N	\N
13	Mohanad SAWAIE	sawaie19tst@gmail.com	157972	2026-01-04 19:26:33.015316	Backend Development	Advanced	84
\.


--
-- TOC entry 3028 (class 0 OID 0)
-- Dependencies: 204
-- Name: fields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fields_id_seq', 7, true);


--
-- TOC entry 3029 (class 0 OID 0)
-- Dependencies: 202
-- Name: questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.questions_id_seq', 94, true);


--
-- TOC entry 3030 (class 0 OID 0)
-- Dependencies: 200
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 13, true);


--
-- TOC entry 2878 (class 2606 OID 16496)
-- Name: fields fields_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fields_name_key UNIQUE (name);


--
-- TOC entry 2880 (class 2606 OID 16494)
-- Name: fields fields_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fields_pkey PRIMARY KEY (id);


--
-- TOC entry 2876 (class 2606 OID 16483)
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- TOC entry 2872 (class 2606 OID 16469)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 2874 (class 2606 OID 16467)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 2881 (class 2606 OID 16497)
-- Name: questions fk_questions_field; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT fk_questions_field FOREIGN KEY (field_id) REFERENCES public.fields(id) ON DELETE SET NULL;


--
-- TOC entry 3024 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2026-01-07 21:20:27

--
-- PostgreSQL database dump complete
--

\unrestrict sRk2dPPfLbeOiEWuSTRL7Bw9qRMkEnwwD0fOEg6hLfoB4ViRD6b1K7gQAemZ9xN

