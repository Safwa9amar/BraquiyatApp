-- BraquiyatApp — Access schema export (generated with mdbtools)
-- Source: Braquiyat.accdb

-- ----------------------------------------------------------
-- MDB Tools - A library for reading MS Access database files
-- Copyright (C) 2000-2011 Brian Bruns and others.
-- Files in libmdb are licensed under LGPL and the utilities under
-- the GPL, see COPYING.LIB and COPYING files respectively.
-- Check out http://mdbtools.sourceforge.net
-- ----------------------------------------------------------

-- That file uses encoding UTF-8

CREATE TABLE [BRAQUIYA]
 (
	[NUM_BRQ]			Long Integer, 
	[DATE_REC]			DateTime NOT NULL, 
	[DATE_ENV]			DateTime, 
	[OBJET]			Text (200) NOT NULL, 
	[TYPE_BRQ]			Text (10) NOT NULL, 
	[URGENCE]			Text (10), 
	[ETAT]			Text (20), 
	[CONTENU]			Memo/Hyperlink (255), 
	[REMARQUES]			Text (250), 
	[ID_JIHA]			Long Integer, 
	[ID_EMP_ENREG]			Long Integer
);

CREATE TABLE [EMPLOYE]
 (
	[ID_EMP]			Long Integer, 
	[NOM]			Text (50) NOT NULL, 
	[PRENOM]			Text (50) NOT NULL, 
	[POSTE]			Text (50), 
	[USERNAME]			Text (30) NOT NULL, 
	[PASSWORD]			Text (64) NOT NULL, 
	[ROLE]			Text (10), 
	[ACTIF]			Boolean NOT NULL
);

CREATE TABLE [JIHA]
 (
	[ID_JIHA]			Long Integer, 
	[NOM_JIHA]			Text (100) NOT NULL, 
	[TYPE_JIHA]			Text (20), 
	[TELEPHONE]			Text (20), 
	[ADRESSE]			Text (200)
);

CREATE TABLE [ORIENTATION]
 (
	[ID_ORI]			Long Integer, 
	[NUM_BRQ]			Long Integer NOT NULL, 
	[ID_EMP]			Long Integer NOT NULL, 
	[DATE_ORI]			DateTime NOT NULL, 
	[ETAT_ORI]			Text (20), 
	[REMARQUES]			Text (250)
);



-- ===== DATA =====

-- Table: BRAQUIYA
INSERT INTO "braquiya" ("num_brq", "date_rec", "date_env", "objet", "type_brq", "urgence", "etat", "contenu", "remarques", "id_jiha", "id_emp_enreg") VALUES (1,'2026-04-27 23:20:52',NULL,'qweqwe','WARED','ADI','WAREDAH','qweqweqwqweq','qweqwe',1,1), (2,'2026-06-11 23:20:52',NULL,'asdasd','SADER','SIRRI','WAREDAH','asdasd',NULL,1,1);

-- Table: EMPLOYE
INSERT INTO "employe" ("id_emp", "nom", "prenom", "poste", "username", "password", "role", "actif") VALUES (1,'hamza','hassani',NULL,'admin','admin123','USER',1);

-- Table: JIHA
INSERT INTO "jiha" ("id_jiha", "nom_jiha", "type_jiha", "telephone", "adresse") VALUES (1,'test','test','0674020244','qweqweqwe');

-- Table: ORIENTATION
