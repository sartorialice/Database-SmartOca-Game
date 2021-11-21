
-------------------------------------------------------------------CREAZIONE DELLO SCHEMA:------------------------------------------------------------------

create schema "oca";
set search_path to "oca";
set datestyle to "MDY";


CREATE DOMAIN TipoCasella AS TEXT
CHECK(
   	VALUE ~ 'Scala'
	OR VALUE ~ 'Serpente'
	OR VALUE ~ 'Normale'
);

CREATE DOMAIN IsPodio AS TEXT
CHECK(
   	VALUE ~ 'Podio'
	OR VALUE ~ 'Non podio'
);


--Icone contiene 20 tuple e occupa 3 blocchi
CREATE TABLE Icone(
Nome varchar(20) PRIMARY KEY NOT NULL,
Tema varchar(30) NOT NULL,
Dimensione varchar(13) NOT NULL
);

--Dadi contiene 4020 tuple e occupa 44 blocchi
CREATE TABLE Dadi(
IdDado serial PRIMARY KEY,
ValoreMax decimal(1,0) NOT NULL , 
ValoreMin decimal(1,0) NOT NULL
	CHECK (ValoreMin>=1 AND ValoreMax > ValoreMin AND ValoreMax <=6)
);

--Gioco contiene 10020 tuple e occupa 370 blocchi
CREATE TABLE Gioco(
IdGioco varchar(20) PRIMARY KEY,
Plancia varchar(30) NOT NULL,
ImmSfondo varchar(30) NOT NULL,
NumCaselle decimal(3,0) NOT NULL,
MaxSquadre decimal(2,0) NOT NULL,
Dummy text,
UNIQUE (ImmSfondo,Plancia)
);

--Utente contiene 20 tuple e occupa 3 blocchi
CREATE TABLE Utente(
Email varchar(30) PRIMARY KEY,
Nickname varchar (30) NOT NULL,
Coach boolean NOT NULL DEFAULT FALSE,
Caposquadra boolean NOT NULL DEFAULT FALSE,
Nome varchar(30),
Cognome varchar(30),
DataN date CHECK (DataN BETWEEN '01/01/1900' AND CURRENT_DATE)
);

--Caselle contiene 20 tuple e occupa 6 blocchi
CREATE TABLE Caselle(
IdCaselle varchar(20) PRIMARY KEY,
X decimal(4,0) NOT NULL,
Y decimal(4,0) NOT NULL,
Tipo TipoCasella NOT NULL,
Tipologia IsPodio NOT NULL,
Classifica decimal(1,0) CHECK(Classifica IN (1,2,3)),
Video varchar(30),
NumOrdine serial, 
IdGioco varchar(20) NOT NULL,
	FOREIGN KEY (IdGioco) REFERENCES Gioco (IdGioco),
UNIQUE(X,Y,IdGioco)
);

--Task contiene 5 tuple e occupa 5 blocchi
CREATE TABLE Task(
TestoT varchar(200) PRIMARY KEY,
TempoMaxRisposta decimal(3,0) NOT NULL,
Punteggio decimal(2,0) NOT NULL,
IdCaselle varchar(20) NOT NULL UNIQUE,
	FOREIGN KEY (IdCaselle) REFERENCES Caselle (IdCaselle)
);

--Quiz contiene 5 tuple e occupa 3 blocchi
CREATE TABLE Quiz(
TestoQ varchar(200) PRIMARY KEY,
TempoMaxRisposta decimal(3,0) NOT NULL,
Immagine varchar(30),
IdCaselle varchar(20) NOT NULL,
	 FOREIGN KEY (IdCaselle) REFERENCES Caselle (IdCaselle) 
);

--Sfida contiene 10018 tuple e occupa 355 blocchi
CREATE TABLE Sfida(
IdSfida varchar(20) PRIMARY KEY,
Orario varchar(5) NOT NULL,
DurataMax time NOT NULL,
Moderata boolean NOT NULL DEFAULT FALSE,
Data date NOT NULL,
Terminata boolean NOT NULL,
IdGioco varchar(20) NOT NULL,
	FOREIGN KEY (IdGioco) REFERENCES Gioco (IdGioco), 
Dummy text,
UNIQUE(IdGioco, Orario, Data)
);

--RisposteQuiz contiene 10 tuple e occupa 4 blocchi
CREATE TABLE RisposteQuiz (
TestoR varchar(100) UNIQUE,
TestoQ varchar(200) NOT NULL,
Immagine varchar(30),
Punteggio smallint,
	FOREIGN KEY (TestoQ) REFERENCES Quiz (TestoQ), 
PRIMARY KEY(TestoR,TestoQ)
);

--Squadra contiene 20 tuple e occupa 3 blocchi
CREATE TABLE Squadra(
IdSquadra varchar(20) PRIMARY KEY,
NomeS varchar (30) NOT NULL,
NomeI varchar(20) NOT NULL, 
	 FOREIGN KEY (NomeI) REFERENCES Icone (Nome),
IdSfida varchar(20) NOT NULL,
	 FOREIGN KEY (IdSfida) REFERENCES Sfida (IdSfida) 
);

--RispostaData contiene 5 tuple e occupa 3 blocchi
CREATE TABLE RispostaData(
IdSquadra varchar(20) NOT NULL,
	FOREIGN KEY (IdSquadra) REFERENCES Squadra (IdSquadra),
Email varchar(30) NOT NULL,
	 FOREIGN KEY (Email) REFERENCES Utente (Email),
PunteggioOttenuto smallint,
PercorsoFile varchar(30),
PiuVotata boolean DEFAULT FALSE,
Convalida boolean DEFAULT FALSE,
TestoT varchar(200),
	 FOREIGN KEY (TestoT) REFERENCES Task (TestoT),
TestoR varchar(100),
TestoQ varchar(200),
	FOREIGN KEY (TestoQ, TestoR) REFERENCES RisposteQuiz (TestoQ,TestoR),
PRIMARY KEY(IdSquadra, Email)
);

--Turno contiene 53 tuple e occupa 4 blocchi
CREATE TABLE Turno(
NTurno serial,
IdSfida varchar(20) NOT NULL,
	 FOREIGN KEY (IdSfida) REFERENCES Sfida (IdSfida),
PRIMARY KEY(NTurno, IdSfida)
);

--Posizione contiene 20 tuple e occupa 4 blocchi
CREATE TABLE Posizione(
NTurno serial NOT NULL,
IdSfida varchar(20) NOT NULL,
	FOREIGN KEY (NTurno, IdSfida) REFERENCES Turno (NTurno, IdSfida),
IdSquadra varchar(20) NOT NULL,
	FOREIGN KEY (IdSquadra) REFERENCES Squadra (IdSquadra),
IdCaselle varchar(20) NOT NULL,
	 FOREIGN KEY (IdCaselle) REFERENCES Caselle (IdCaselle),
PunteggioOttenuto smallint NOT NULL,
PRIMARY KEY(NTurno,IdSfida,IdSquadra,IdCaselle)
);

--Composta contiene 20 tuple e occupa 3 blocchi
CREATE TABLE Composta (
IdSquadra varchar(20) NOT NULL,
	FOREIGN KEY (IdSquadra) REFERENCES Squadra (IdSquadra),
Email varchar(30) NOT NULL,
	FOREIGN KEY (Email) REFERENCES Utente (Email),
PRIMARY KEY(Email,IdSquadra)
);

--Lancio contiene 20 tuple e occupa 5 blocchi
CREATE TABLE Lancio(
IdDado serial NOT NULL,
	FOREIGN KEY (IdDado) REFERENCES Dadi(IdDado),
IdSquadra varchar(20) NOT NULL,
	FOREIGN KEY (IdSquadra) REFERENCES Squadra (IdSquadra),
NTurno serial NOT NULL,
IdSfida varchar(20) NOT NULL,
	FOREIGN KEY (NTurno, IdSfida) REFERENCES Turno (NTurno, IdSfida),
NumDadi decimal(1,0) NOT NULL,
ValoreOttenuto decimal(2,0) NOT NULL,
	CHECK(NumDadi>0 AND ValoreOttenuto>0),
PRIMARY KEY (IdDado,IdSquadra, IdSfida, NTurno)
);

--Presente contiene 2058 tuple e occupa 55 blocchi
CREATE TABLE Presente(
IdDado serial NOT NULL,
	FOREIGN KEY (IdDado) REFERENCES Dadi(IdDado),
IdGioco varchar(20) NOT NULL,
	 FOREIGN KEY (IdGioco) REFERENCES Gioco (IdGioco),
NumDadi decimal(1,0) NOT NULL,
Dummy text,
PRIMARY KEY (IdDado, IdGioco)
);

--Contiene contiene 20 tuple e occupa 3 blocchi
CREATE TABLE Contiene(
IdGioco varchar(20) NOT NULL,
	FOREIGN KEY (IdGioco) REFERENCES Gioco (IdGioco),
NomeI varchar(20) NOT NULL,
	FOREIGN KEY (NomeI) REFERENCES Icone (Nome),
PRIMARY KEY (IdGioco, NomeI)
);

/*
I comandi Utilizzati per calcolare il numero di tuple e blocchi occupati per ogni tabella sono:
ANALYZE; --Per verificare che tutto fosse aggiornato

SELECT nspname, oid
FROM pg_namespace
WHERE nspname = 'oca'; --Per ottenere l'identeficatore dello schema

SELECT relname, relfilenode, relpages, reltuples
FROM pg_class
WHERE relnamespace = 31203; --Per controllare le tuple e i blocchi

*/

----------------------------------------------------------------POPOLAMENTO SENZA DATANAMIC:----------------------------------------------------------------

INSERT INTO Gioco VALUES ('g1', 'plancia1', 'blu', 100, 5);
INSERT INTO Gioco VALUES ('g2', 'plancia2', 'verde', 90, 2);
INSERT INTO Gioco VALUES ('g3', 'plancia3', 'giallo', 150, 7);
INSERT INTO Gioco VALUES ('g4', 'plancia4', 'rosso', 200, 10);
INSERT INTO Gioco VALUES ('g5', 'plancia5', 'nero', 100, 5);
INSERT INTO Gioco VALUES ('g6', 'plancia6', 'bianco', 100, 5);
INSERT INTO Gioco VALUES ('g7', 'plancia7', 'marrone', 100, 5);
INSERT INTO Gioco VALUES ('g8', 'plancia8', 'rosa', 200, 10);
INSERT INTO Gioco VALUES ('g9', 'plancia9', 'blu scuro', 300, 15);
INSERT INTO Gioco VALUES ('g10', 'plancia10', 'verde scuro', 100, 5);
INSERT INTO Gioco VALUES ('g11', 'plancia11', 'magenta', 100, 5);
INSERT INTO Gioco VALUES ('g12', 'plancia12', 'cian', 80, 2);
INSERT INTO Gioco VALUES ('g13', 'plancia13', 'ocra', 130, 6);
INSERT INTO Gioco VALUES ('g14', 'plancia14', 'mattone', 100, 10);
INSERT INTO Gioco VALUES ('g15', 'plancia15', 'indaco', 100, 7);
INSERT INTO Gioco VALUES ('g16', 'plancia16', 'azzurro', 100, 5);
INSERT INTO Gioco VALUES ('g17', 'plancia17', 'lilla', 90, 4);
INSERT INTO Gioco VALUES ('g18', 'plancia18', 'viola', 100, 5);
INSERT INTO Gioco VALUES ('g19', 'plancia19', 'catrame', 200, 5);
INSERT INTO Gioco VALUES ('g20', 'plancia20', 'arancione', 400, 16);

insert into sfida values('sf1', '10:30', '03:00', false , '01/31/2002', TRUE,'g1');
insert into sfida values('sf2', '11:00', '2:30', false , '11/24/1968',TRUE, 'g2');
insert into sfida values('sf3', '12:21', '3:00', true, '07/21/2001', TRUE,'g1');
insert into sfida values('sf4', '14:23', '01:00', true, '03/03/2008',FALSE, 'g3');
insert into sfida values('sf5', '02:45', '12:34', false, '06/13/2009',TRUE, 'g4');
insert into sfida values('sf6', '05:34', '03:46', true, '07/12/2011', FALSE,'g2');
insert into sfida values('sf7', '17:34', '2:34', true, '06/05/2008', TRUE,'g2');
insert into sfida values('sf8', '19:32', '1:22', false, '02/04/2005',FALSE, 'g1');
insert into sfida values('sf9', '15:10', '1:34', true, '02/07/2004',FALSE, 'g7');
insert into sfida values('sf10', '12:21', '00:30',false , '02/08/2015',TRUE, 'g1');
insert into sfida values('sf11', '15:00', '00:12', false, '01/08/2020',TRUE, 'g7');
insert into sfida values('sf12', '12:45', '07:30', true, '05/03/2018',FALSE, 'g2');
insert into sfida values('sf13', '16:39', '08:46', false, '08/01/2021', FALSE,'g12');
insert into sfida values('sf14', '19:24', '2:32', true, '08/12/2020', TRUE,'g15');
insert into sfida values('sf15', '18:32', '2:56', false, '12/31/2020',TRUE, 'g2');
insert into sfida values('sf16', '12:32', '05:45', true, '02/23/2019',FALSE, 'g3');
insert into sfida values('sf17', '11:34', '02:32', true, '01/02/2017',TRUE, 'g8');
insert into sfida values('sf', '11:11', '04:03', false, '12/04/2017', FALSE,'g17');
	
INSERT INTO Caselle VALUES ('c1', 1, 1, 'Normale', 'Podio', 1, NULL, 1, 'g1');
INSERT INTO Caselle VALUES ('c2', 1, 2, 'Normale', 'Podio', 2, NULL, 2, 'g1');
INSERT INTO Caselle VALUES ('c3', 1, 3, 'Normale', 'Podio', 3, NULL, 3, 'g1');
INSERT INTO Caselle VALUES ('c4', 2, 1, 'Normale', 'Non podio', NULL, 'video1', 4, 'g1');
INSERT INTO Caselle VALUES ('c5', 2, 2, 'Normale', 'Non podio', NULL, 'video2', 5, 'g1');
INSERT INTO Caselle VALUES ('c6', 1, 1, 'Normale', 'Podio', 1, NULL, 6, 'g2');
INSERT INTO Caselle VALUES ('c7', 1, 2, 'Normale', 'Podio', 2, NULL, 7, 'g2');
INSERT INTO Caselle VALUES ('c8', 1, 3, 'Normale', 'Podio', 3, NULL, 8, 'g2');
INSERT INTO Caselle VALUES ('c9', 5, 5, 'Scala', 'Non podio', NULL, 'video4', 9, 'g2');
INSERT INTO Caselle VALUES ('c10', 5, 7, 'Normale', 'Non podio', NULL, 'video3', 10, 'g2');
INSERT INTO Caselle VALUES ('c11', 1, 1, 'Normale', 'Podio', 1, NULL, 11, 'g3');
INSERT INTO Caselle VALUES ('c12', 1, 2, 'Normale', 'Podio', 2, NULL, 12, 'g3');
INSERT INTO Caselle VALUES ('c13', 1, 3, 'Normale', 'Podio', 3, NULL, 13, 'g3');
INSERT INTO Caselle VALUES ('c14', 3, 7, 'Serpente', 'Non podio', NULL, 'video5', 14, 'g3');
INSERT INTO Caselle VALUES ('c15', 7, 8, 'Normale', 'Non podio', NULL, 'video6', 15, 'g3');
INSERT INTO Caselle VALUES ('c16', 1, 1, 'Normale', 'Podio', 1, NULL, 16, 'g4');
INSERT INTO Caselle VALUES ('c17', 1, 2, 'Normale', 'Podio', 2, NULL, 17, 'g4');
INSERT INTO Caselle VALUES ('c18', 1, 3, 'Normale', 'Podio', 3, NULL, 18, 'g4');
INSERT INTO Caselle VALUES ('c19', 8, 1, 'Serpente', 'Non podio', NULL, 'video7', 19, 'g4');
INSERT INTO Caselle VALUES ('c20', 4, 5, 'Normale', 'Non podio', NULL, 'video8', 20, 'g4');


INSERT INTO Icone VALUES ('A', 'primo', '100x100');
INSERT INTO Icone VALUES ('B', 'secondo', '100x100');
INSERT INTO Icone VALUES ('C', 'terzo', '100x100');
INSERT INTO Icone VALUES ('D', 'primo', '100x100');
INSERT INTO Icone VALUES ('E', 'secondo', '100x100');
INSERT INTO Icone VALUES ('F', 'terzo', '100x100');
INSERT INTO Icone VALUES ('G', 'primo', '100x100');
INSERT INTO Icone VALUES ('H', 'secondo', '100x100');
INSERT INTO Icone VALUES ('I', 'terzo', '100x100');
INSERT INTO Icone VALUES ('L', 'secondo', '100x100');
INSERT INTO Icone VALUES ('M', 'terzo', '100x100');
INSERT INTO Icone VALUES ('N', 'quarto', '100x100');
INSERT INTO Icone VALUES ('O', 'quinto', '100x100');
INSERT INTO Icone VALUES ('P', 'primo', '100x100');
INSERT INTO Icone VALUES ('Q', 'secondo', '100x100');
INSERT INTO Icone VALUES ('R', 'terzo', '100x100');
INSERT INTO Icone VALUES ('S', 'primo', '100x100');
INSERT INTO Icone VALUES ('T', 'quarto', '100x100');
INSERT INTO Icone VALUES ('U', 'primo', '100x100');
INSERT INTO Icone VALUES ('V', 'quinto', '100x100');


insert into squadra values('sq1', 'rosso', 'A', 'sf2');
insert into squadra values('sq2', 'verde', 'B', 'sf1');
insert into squadra values('sq3', 'blu', 'C', 'sf1');
insert into squadra values('sq4', 'azzurro', 'D', 'sf4');
insert into squadra values('sq5', 'arancione', 'E', 'sf2');
insert into squadra values('sq6', 'lilla', 'F', 'sf1');
insert into squadra values('sq7', 'viola', 'G', 'sf5');
insert into squadra values('sq8', 'bianco', 'H', 'sf1');
insert into squadra values('sq9', 'nero', 'I', 'sf1');
insert into squadra values('sq10', 'verdeacqua', 'L', 'sf7');
insert into squadra values('sq11', 'grigio', 'M', 'sf9');
insert into squadra values('sq12', 'giallo', 'N', 'sf8');
insert into squadra values('sq13', 'rosa', 'O', 'sf4');
insert into squadra values('sq14', 'verdescuro', 'P', 'sf1');
insert into squadra values('sq15', 'giallosenape', 'Q', 'sf5');
insert into squadra values('sq16', 'tamarindo', 'R', 'sf2');
insert into squadra values('sq17', 'rossofuoco', 'S', 'sf7');
insert into squadra values('sq18', 'blumare', 'T', 'sf5');
insert into squadra values('sq19', 'verdefiume', 'U', 'sf8');
insert into squadra values('sq20', 'arancionezucca', 'V', 'sf1');

INSERT INTO Utente VALUES ('a@mail', 'bella', TRUE, FALSE,'andrea','cognome', '01/01/1999');
INSERT INTO Utente VALUES ('b@mail', 'raga', FALSE, TRUE,'paolo','paoli', '01/02/1999');
INSERT INTO Utente VALUES ('c@mail', 'martin', TRUE, FALSE,'pippo','pippi', '01/03/1999');
INSERT INTO Utente VALUES ('d@mail', 'garrix', FALSE, TRUE,'pluto','pluti', '01/04/1999');
INSERT INTO Utente VALUES ('e@mail', 'frank00', TRUE, FALSE,'topolino','topolini','01/05/1999');
INSERT INTO Utente VALUES ('f@mail', 'si23', FALSE, TRUE,'pisolo','pisoli','01/06/1999');
INSERT INTO Utente VALUES ('g@mail', 'volando2', TRUE, FALSE,'nannolo','nannoli','01/07/1999');
INSERT INTO Utente VALUES ('h@mail', 'sonotop11', FALSE, TRUE,'brontolo','brontoli','01/08/1999');
INSERT INTO Utente VALUES ('i@mail', 'tornato4', TRUE, FALSE,'mugugnolo','mugugnoli','01/09/1999');
INSERT INTO Utente VALUES ('l@mail', 'oggi6', FALSE, TRUE,'memmolo','memmoli','01/10/1999');
INSERT INTO Utente VALUES ('m@mail', 'holly5', TRUE, FALSE,'bambi','bambo','01/11/1999');
INSERT INTO Utente VALUES ('n@mail', 'vinto00', FALSE, FALSE,'buzz','lightyear','01/12/1999');
INSERT INTO Utente VALUES ('o@mail', 'trenta30', FALSE, FALSE,'woody','cowboy','01/13/1999');
INSERT INTO Utente VALUES ('p@mail', 'pallaalpiede4', FALSE, FALSE,'honda','non', '01/14/1999');
INSERT INTO Utente VALUES ('q@mail', 'stobene55', FALSE, FALSE,'finito','solo', '01/15/1999');
INSERT INTO Utente VALUES ('r@mail', 'volando', FALSE, FALSE,'alice','cosa', '01/16/1999');
INSERT INTO Utente VALUES ('s@mail', 'decollo12', FALSE, FALSE,'camillo','metter', '01/17/1999');
INSERT INTO Utente VALUES ('t@mail', 'andrea5', FALSE, FALSE,'luca','innna', '01/18/1999');
INSERT INTO Utente VALUES ('u@mail', 'diciae66', TRUE, FALSE,'marco','peroni', '01/19/1999');
INSERT INTO Utente VALUES ('v@mail', 'perla1', FALSE, TRUE,'paolo','spazi', '01/20/1999');

INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (1,4,3);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (2,4,1);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (3,5,1);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (4,4,2);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (5,4,1);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (6,5,3);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (7,5,2);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (8,6,5);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (9,6,1);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (10,5,3);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (11,5,4);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (12,6,1);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (13,3,1);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (14,5,3);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (15,3,1);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (16,3,2);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (17,6,5);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (18,6,4);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (19,5,4);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (20,6,4);


INSERT INTO Quiz VALUES ('testoq1', 900, 'immagineq1', 'c4');
INSERT INTO Quiz VALUES ('testoq2', 120, NULL, 'c5');
INSERT INTO Quiz VALUES ('testoq3', 360, 'immagineq2', 'c20');
INSERT INTO Quiz VALUES ('testoq4', 500, NULL, 'c19');
INSERT INTO Quiz VALUES ('testoq5', 640, 'immagineq3', 'c10');

insert into task values('testoTask6', 30, 6,'c19');
insert into task values('testoTask5', 45 ,4 ,'c20');
insert into task values('testoTask3',67 , 4,'c14');
insert into task values('testoTask2', 23, 8 ,'c15');
insert into task values('testoTask1', 23, 16,'c10');

INSERT INTO Composta VALUES ('sq1', 'a@mail');
INSERT INTO Composta VALUES ('sq2', 'b@mail');
INSERT INTO Composta VALUES ('sq3', 'c@mail');
INSERT INTO Composta VALUES ('sq4', 'd@mail');
INSERT INTO Composta VALUES ('sq5', 'e@mail');
INSERT INTO Composta VALUES ('sq6', 'f@mail');
INSERT INTO Composta VALUES ('sq7', 'g@mail');
INSERT INTO Composta VALUES ('sq8', 'h@mail');
INSERT INTO Composta VALUES ('sq9', 'i@mail');
INSERT INTO Composta VALUES ('sq10', 'l@mail');
INSERT INTO Composta VALUES ('sq11', 'm@mail');
INSERT INTO Composta VALUES ('sq12', 'n@mail');
INSERT INTO Composta VALUES ('sq13', 'o@mail');
INSERT INTO Composta VALUES ('sq14', 'p@mail');
INSERT INTO Composta VALUES ('sq15', 'q@mail');
INSERT INTO Composta VALUES ('sq16', 'r@mail');
INSERT INTO Composta VALUES ('sq17', 's@mail');
INSERT INTO Composta VALUES ('sq18', 't@mail');
INSERT INTO Composta VALUES ('sq19', 'u@mail');
INSERT INTO Composta VALUES ('sq20', 'v@mail');

INSERT INTO Turno VALUES (1, 'sf1');
INSERT INTO Turno VALUES (2, 'sf1');
INSERT INTO Turno VALUES (3, 'sf1');
INSERT INTO Turno VALUES (4, 'sf1');
INSERT INTO Turno VALUES (5, 'sf1');
INSERT INTO Turno VALUES (6, 'sf1');
INSERT INTO Turno VALUES (7, 'sf1');
INSERT INTO Turno VALUES (8, 'sf1');
INSERT INTO Turno VALUES (9, 'sf1');
INSERT INTO Turno VALUES (10, 'sf1');
INSERT INTO Turno VALUES (1, 'sf2');
INSERT INTO Turno VALUES (2, 'sf2');
INSERT INTO Turno VALUES (3, 'sf2');
INSERT INTO Turno VALUES (4, 'sf2');
INSERT INTO Turno VALUES (5, 'sf2');
INSERT INTO Turno VALUES (6, 'sf2');
INSERT INTO Turno VALUES (7, 'sf2');
INSERT INTO Turno VALUES (8, 'sf2');
INSERT INTO Turno VALUES (9, 'sf2');
INSERT INTO Turno VALUES (10, 'sf2');

INSERT INTO Turno VALUES (1, 'sf3');
INSERT INTO Turno VALUES (2, 'sf3');
INSERT INTO Turno VALUES (3, 'sf3');
INSERT INTO Turno VALUES (4, 'sf3');
INSERT INTO Turno VALUES (5, 'sf3');
INSERT INTO Turno VALUES (6, 'sf3');
INSERT INTO Turno VALUES (7, 'sf3');
INSERT INTO Turno VALUES (8, 'sf3');
INSERT INTO Turno VALUES (9, 'sf3');
INSERT INTO Turno VALUES (10, 'sf3');
INSERT INTO Turno VALUES (1, 'sf4');
INSERT INTO Turno VALUES (2, 'sf4');
INSERT INTO Turno VALUES (3, 'sf4');
INSERT INTO Turno VALUES (4, 'sf4');
INSERT INTO Turno VALUES (5, 'sf4');
INSERT INTO Turno VALUES (6, 'sf4');
INSERT INTO Turno VALUES (7, 'sf4');
INSERT INTO Turno VALUES (8, 'sf4');
INSERT INTO Turno VALUES (9, 'sf4');
INSERT INTO Turno VALUES (10, 'sf4');
INSERT INTO Turno VALUES (3, 'sf5');
INSERT INTO Turno  VALUES (7, 'sf5');
INSERT INTO Turno  VALUES (10, 'sf7');
INSERT INTO Turno  VALUES (11, 'sf9');
INSERT INTO Turno  VALUES (12, 'sf8');
INSERT INTO Turno  VALUES (13, 'sf4');
INSERT INTO Turno  VALUES (14, 'sf1');
INSERT INTO Turno  VALUES (15, 'sf5');
INSERT INTO Turno  VALUES (16, 'sf2');
INSERT INTO Turno  VALUES (17, 'sf7');
INSERT INTO Turno  VALUES (18, 'sf5');
INSERT INTO Turno  VALUES (19, 'sf8');
INSERT INTO Turno VALUES (20, 'sf1');

INSERT INTO Contiene VALUES ('g1', 'A');
INSERT INTO Contiene VALUES ('g2', 'B');
INSERT INTO Contiene VALUES ('g3', 'C');
INSERT INTO Contiene VALUES ('g4', 'D');
INSERT INTO Contiene VALUES ('g5', 'E');
INSERT INTO Contiene VALUES ('g6', 'F');
INSERT INTO Contiene VALUES ('g7', 'G');
INSERT INTO Contiene VALUES ('g8', 'H');
INSERT INTO Contiene VALUES ('g9', 'I');
INSERT INTO Contiene VALUES ('g10', 'L');
INSERT INTO Contiene VALUES ('g11', 'M');
INSERT INTO Contiene VALUES ('g12', 'N');
INSERT INTO Contiene VALUES ('g13', 'O');
INSERT INTO Contiene VALUES ('g14', 'P');
INSERT INTO Contiene VALUES ('g15', 'Q');
INSERT INTO Contiene VALUES ('g16', 'R');
INSERT INTO Contiene VALUES ('g17', 'S');
INSERT INTO Contiene VALUES ('g18', 'T');
INSERT INTO Contiene VALUES ('g19', 'U');
INSERT INTO Contiene VALUES ('g20', 'V');

insert into rispostequiz values('rispostaq1', 'testoq1', 'delfino', 2 );
insert into rispostequiz values('rispostaq2', 'testoq1', 'tartaruga',5 );
insert into rispostequiz values('rispostaq3', 'testoq2', 'leone',7 );
insert into rispostequiz values('rispostaq4', 'testoq2', 'mare',8 );
insert into rispostequiz values('rispostaq5', 'testoq3', 'alga',9 );
insert into rispostequiz values('rispostaq6', 'testoq3', 'trattore',3 );
insert into rispostequiz values('rispostaq7', 'testoq4', 'maratona',6 );
insert into rispostequiz values('rispostaq8', 'testoq4', 'c++', 4);
insert into rispostequiz values('rispostaq9', 'testoq5', 'sql', 6);
insert into rispostequiz values('rispostaq10', 'testoq5', 'java', 2);

insert into presente values( 1, 'g1', 2, null);
insert into presente values( 2, 'g1', 3, null);
insert into presente values( 3, 'g1', 5, null);
insert into presente values( 4, 'g1', 6, null);
insert into presente values( 5, 'g1', 6, null);
insert into presente values( 1, 'g2', 3, null);
insert into presente values( 2, 'g2', 4, null);
insert into presente values( 3, 'g2', 3, null);
insert into presente values( 4, 'g2', 2, null);
insert into presente values( 5, 'g2', 1, null);
insert into presente values( 1, 'g3', 5, null);
insert into presente values( 2, 'g3', 3, null);
insert into presente values( 3, 'g3', 5, null);
insert into presente values( 4, 'g3', 3, null);
insert into presente values( 5, 'g3', 3, null);
insert into presente values( 1, 'g4', 1, null);
insert into presente values( 2, 'g4', 6, null);
insert into presente values( 1, 'g5', 8, null);
insert into presente values( 2, 'g5', 5, null);
insert into presente values( 3, 'g5', 3, null);
insert into presente values( 4, 'g5', 5, null);
insert into presente values( 5, 'g5', 4, null);
insert into presente values( 1, 'g6', 3, null);
insert into presente values( 2, 'g6', 4, null);
insert into presente values( 3, 'g6', 2, null);
insert into presente values( 4, 'g6', 4, null);
insert into presente values( 5, 'g6', 6,null);
insert into presente values( 6, 'g6', 7, null);
insert into presente values( 7, 'g6', 9, null);
insert into presente values( 8, 'g6', 4, null);
insert into presente values( 1, 'g7', 2, null);
insert into presente values( 1, 'g8', 4, null);
insert into presente values( 2, 'g8', 6, null);
insert into presente values( 3, 'g8', 4, null);
insert into presente values( 4, 'g8', 3, null);
insert into presente values( 5, 'g8', 2, null);
insert into presente values( 6, 'g8', 3, null);
insert into presente values( 7, 'g8', 2, null);
insert into presente values( 8, 'g8', 6, null);
insert into presente values( 9, 'g8', 7, null);
insert into presente values( 1, 'g9', 8, null);
insert into presente values( 2, 'g9', 5, null);
insert into presente values( 1, 'g10', 4, null);
insert into presente values( 2, 'g10', 5, null);
insert into presente values( 3, 'g10', 4, null);
insert into presente values( 4, 'g10', 5, null);
insert into presente values( 5, 'g10', 5, null);
insert into presente values( 1, 'g11', 2, null);
insert into presente values( 2, 'g11', 2, null);
insert into presente values( 3, 'g11', 6, null);
insert into presente values( 1, 'g12', 8, null);
insert into presente values( 2, 'g12', 9, null);
insert into presente values( 3, 'g12', 1, null);
insert into presente values( 4, 'g13', 2, null);
insert into presente values( 1, 'g13', 0, null);
insert into presente values( 2, 'g13', 5, null);
insert into presente values( 3, 'g13', 4, null);
insert into presente values( 4, 'g14', 2, null);

INSERT INTO Posizione VALUES (1, 'sf2', 'sq1', 'c9', 10);
INSERT INTO Posizione VALUES (1, 'sf2', 'sq1', 'c6', 10);
INSERT INTO Posizione VALUES (1, 'sf2', 'sq5', 'c9', 9);
INSERT INTO Posizione VALUES (1, 'sf2', 'sq5', 'c7', 9);
INSERT INTO Posizione VALUES (1, 'sf2', 'sq16', 'c8', 8);
INSERT INTO Posizione VALUES (1, 'sf2', 'sq16', 'c9', 8);
INSERT INTO Posizione VALUES (3, 'sf1', 'sq2', 'c1', 50);
INSERT INTO Posizione VALUES (3, 'sf1', 'sq2', 'c4', 50);
INSERT INTO Posizione VALUES (3, 'sf1', 'sq3', 'c2', 25);
INSERT INTO Posizione VALUES (3, 'sf1', 'sq3', 'c4', 25);
INSERT INTO Posizione VALUES (3, 'sf1', 'sq6', 'c3', 11);
INSERT INTO Posizione VALUES (3, 'sf1', 'sq6', 'c4', 11);
INSERT INTO Posizione VALUES (1, 'sf1', 'sq8', 'c4', 4);
INSERT INTO Posizione VALUES (1, 'sf1', 'sq14', 'c4', 7);
INSERT INTO Posizione VALUES (3, 'sf5', 'sq7', 'c16', 50);
INSERT INTO Posizione VALUES (3, 'sf5', 'sq7', 'c19', 50);
INSERT INTO Posizione VALUES (3, 'sf5', 'sq15', 'c17', 25);
INSERT INTO Posizione VALUES (3, 'sf5', 'sq15', 'c19', 25);
INSERT INTO Posizione VALUES (3, 'sf5', 'sq18', 'c18', 11);
INSERT INTO Posizione VALUES (3, 'sf5', 'sq18', 'c19', 11);

INSERT INTO Lancio VALUES (1, 'sq1', 1, 'sf2', 1, 6);
INSERT INTO Lancio VALUES (2, 'sq2',  2,'sf1', 2, 8);
INSERT INTO Lancio VALUES (3, 'sq3',  3,'sf1', 3, 6);
INSERT INTO Lancio VALUES (4, 'sq4',  4,'sf4', 2, 4);
INSERT INTO Lancio VALUES (5, 'sq5',  5, 'sf2',3, 5);
INSERT INTO Lancio VALUES (6, 'sq6',  6,'sf1', 1, 6);
INSERT INTO Lancio VALUES (7, 'sq7',  7,'sf5', 2, 3);
INSERT INTO Lancio VALUES (8, 'sq8',  8, 'sf1', 3, 5);
INSERT INTO Lancio VALUES (9, 'sq9',  9, 'sf1', 1, 6);
INSERT INTO Lancio VALUES (10, 'sq10',  10, 'sf7',2, 7);
INSERT INTO Lancio VALUES (11, 'sq11',  11, 'sf9',3, 3);
INSERT INTO Lancio VALUES (12, 'sq12',  12, 'sf8', 4, 4);
INSERT INTO Lancio VALUES (13, 'sq13',  2,'sf4', 1, 5);
INSERT INTO Lancio VALUES (14, 'sq14',  14,'sf1', 1, 4);
INSERT INTO Lancio VALUES (15, 'sq15',  15, 'sf5', 3, 3);
INSERT INTO Lancio VALUES (16, 'sq16',  16,'sf2', 2, 6);
INSERT INTO Lancio VALUES (17, 'sq17',  17,'sf7', 4, 5);
INSERT INTO Lancio VALUES (18, 'sq18', 18, 'sf5', 2, 5);
INSERT INTO Lancio VALUES (19, 'sq19',  19,'sf8', 3, 4);
INSERT INTO Lancio VALUES (20, 'sq20',  20,'sf1', 1, 1);

insert into rispostadata values ('sq1', 'a@mail', 1, 'aragosta/delfino', true, true, null, 'rispostaq4', 'testoq2');
insert into rispostadata values ('sq2', 'b@mail', 8, 'leone/tartaruga', false, false, null, 'rispostaq6', 'testoq3');
insert into rispostadata values ('sq3', 'c@mail', -6, '../tmp/d', false, true, 'testoTask2', null, null);
insert into rispostadata values ('sq4', 'd@mail', 7, '././../proc', true, true, 'testoTask5', null, null);
insert into rispostadata values ('sq5', 'e@mail', -4, 'home/images/montagna', true, false, null, 'rispostaq1', 'testoq1');



----------------------------------------------------------------POPOLAMENTO SENZA DATANAMIC:----------------------------------------------------------------

INSERT INTO Gioco VALUES ('g1', 'plancia1', 'blu', 100, 5);
INSERT INTO Gioco VALUES ('g2', 'plancia2', 'verde', 90, 2);
INSERT INTO Gioco VALUES ('g3', 'plancia3', 'giallo', 150, 7);
INSERT INTO Gioco VALUES ('g4', 'plancia4', 'rosso', 200, 10);
INSERT INTO Gioco VALUES ('g5', 'plancia5', 'nero', 100, 5);
INSERT INTO Gioco VALUES ('g6', 'plancia6', 'bianco', 100, 5);
INSERT INTO Gioco VALUES ('g7', 'plancia7', 'marrone', 100, 5);
INSERT INTO Gioco VALUES ('g8', 'plancia8', 'rosa', 200, 10);
INSERT INTO Gioco VALUES ('g9', 'plancia9', 'blu scuro', 300, 15);
INSERT INTO Gioco VALUES ('g10', 'plancia10', 'verde scuro', 100, 5);
INSERT INTO Gioco VALUES ('g11', 'plancia11', 'magenta', 100, 5);
INSERT INTO Gioco VALUES ('g12', 'plancia12', 'cian', 80, 2);
INSERT INTO Gioco VALUES ('g13', 'plancia13', 'ocra', 130, 6);
INSERT INTO Gioco VALUES ('g14', 'plancia14', 'mattone', 100, 10);
INSERT INTO Gioco VALUES ('g15', 'plancia15', 'indaco', 100, 7);
INSERT INTO Gioco VALUES ('g16', 'plancia16', 'azzurro', 100, 5);
INSERT INTO Gioco VALUES ('g17', 'plancia17', 'lilla', 90, 4);
INSERT INTO Gioco VALUES ('g18', 'plancia18', 'viola', 100, 5);
INSERT INTO Gioco VALUES ('g19', 'plancia19', 'catrame', 200, 5);
INSERT INTO Gioco VALUES ('g20', 'plancia20', 'arancione', 400, 16);

insert into sfida values('sf1', '10:30', '03:00', false , '01/31/2002', TRUE,'g1');
insert into sfida values('sf2', '11:00', '2:30', false , '11/24/1968',TRUE, 'g2');
insert into sfida values('sf3', '12:21', '3:00', true, '07/21/2001', TRUE,'g1');
insert into sfida values('sf4', '14:23', '01:00', true, '03/03/2008',FALSE, 'g3');
insert into sfida values('sf5', '02:45', '12:34', false, '06/13/2009',TRUE, 'g4');
insert into sfida values('sf6', '05:34', '03:46', true, '07/12/2011', FALSE,'g2');
insert into sfida values('sf7', '17:34', '2:34', true, '06/05/2008', TRUE,'g2');
insert into sfida values('sf8', '19:32', '1:22', false, '02/04/2005',FALSE, 'g1');
insert into sfida values('sf9', '15:10', '1:34', true, '02/07/2004',FALSE, 'g7');
insert into sfida values('sf10', '12:21', '00:30',false , '02/08/2015',TRUE, 'g1');
insert into sfida values('sf11', '15:00', '00:12', false, '01/08/2020',TRUE, 'g7');
insert into sfida values('sf12', '12:45', '07:30', true, '05/03/2018',FALSE, 'g2');
insert into sfida values('sf13', '16:39', '08:46', false, '08/01/2021', FALSE,'g12');
insert into sfida values('sf14', '19:24', '2:32', true, '08/12/2020', TRUE,'g15');
insert into sfida values('sf15', '18:32', '2:56', false, '12/31/2020',TRUE, 'g2');
insert into sfida values('sf16', '12:32', '05:45', true, '02/23/2019',FALSE, 'g3');
insert into sfida values('sf17', '11:34', '02:32', true, '01/02/2017',TRUE, 'g8');
insert into sfida values('sf', '11:11', '04:03', false, '12/04/2017', FALSE,'g17');
	
INSERT INTO Caselle VALUES ('c1', 1, 1, 'Normale', 'Podio', 1, NULL, 1, 'g1');
INSERT INTO Caselle VALUES ('c2', 1, 2, 'Normale', 'Podio', 2, NULL, 2, 'g1');
INSERT INTO Caselle VALUES ('c3', 1, 3, 'Normale', 'Podio', 3, NULL, 3, 'g1');
INSERT INTO Caselle VALUES ('c4', 2, 1, 'Normale', 'Non podio', NULL, 'video1', 4, 'g1');
INSERT INTO Caselle VALUES ('c5', 2, 2, 'Normale', 'Non podio', NULL, 'video2', 5, 'g1');
INSERT INTO Caselle VALUES ('c6', 1, 1, 'Normale', 'Podio', 1, NULL, 6, 'g2');
INSERT INTO Caselle VALUES ('c7', 1, 2, 'Normale', 'Podio', 2, NULL, 7, 'g2');
INSERT INTO Caselle VALUES ('c8', 1, 3, 'Normale', 'Podio', 3, NULL, 8, 'g2');
INSERT INTO Caselle VALUES ('c9', 5, 5, 'Scala', 'Non podio', NULL, 'video4', 9, 'g2');
INSERT INTO Caselle VALUES ('c10', 5, 7, 'Normale', 'Non podio', NULL, 'video3', 10, 'g2');
INSERT INTO Caselle VALUES ('c11', 1, 1, 'Normale', 'Podio', 1, NULL, 11, 'g3');
INSERT INTO Caselle VALUES ('c12', 1, 2, 'Normale', 'Podio', 2, NULL, 12, 'g3');
INSERT INTO Caselle VALUES ('c13', 1, 3, 'Normale', 'Podio', 3, NULL, 13, 'g3');
INSERT INTO Caselle VALUES ('c14', 3, 7, 'Serpente', 'Non podio', NULL, 'video5', 14, 'g3');
INSERT INTO Caselle VALUES ('c15', 7, 8, 'Normale', 'Non podio', NULL, 'video6', 15, 'g3');
INSERT INTO Caselle VALUES ('c16', 1, 1, 'Normale', 'Podio', 1, NULL, 16, 'g4');
INSERT INTO Caselle VALUES ('c17', 1, 2, 'Normale', 'Podio', 2, NULL, 17, 'g4');
INSERT INTO Caselle VALUES ('c18', 1, 3, 'Normale', 'Podio', 3, NULL, 18, 'g4');
INSERT INTO Caselle VALUES ('c19', 8, 1, 'Serpente', 'Non podio', NULL, 'video7', 19, 'g4');
INSERT INTO Caselle VALUES ('c20', 4, 5, 'Normale', 'Non podio', NULL, 'video8', 20, 'g4');


INSERT INTO Icone VALUES ('A', 'primo', '100x100');
INSERT INTO Icone VALUES ('B', 'secondo', '100x100');
INSERT INTO Icone VALUES ('C', 'terzo', '100x100');
INSERT INTO Icone VALUES ('D', 'primo', '100x100');
INSERT INTO Icone VALUES ('E', 'secondo', '100x100');
INSERT INTO Icone VALUES ('F', 'terzo', '100x100');
INSERT INTO Icone VALUES ('G', 'primo', '100x100');
INSERT INTO Icone VALUES ('H', 'secondo', '100x100');
INSERT INTO Icone VALUES ('I', 'terzo', '100x100');
INSERT INTO Icone VALUES ('L', 'secondo', '100x100');
INSERT INTO Icone VALUES ('M', 'terzo', '100x100');
INSERT INTO Icone VALUES ('N', 'quarto', '100x100');
INSERT INTO Icone VALUES ('O', 'quinto', '100x100');
INSERT INTO Icone VALUES ('P', 'primo', '100x100');
INSERT INTO Icone VALUES ('Q', 'secondo', '100x100');
INSERT INTO Icone VALUES ('R', 'terzo', '100x100');
INSERT INTO Icone VALUES ('S', 'primo', '100x100');
INSERT INTO Icone VALUES ('T', 'quarto', '100x100');
INSERT INTO Icone VALUES ('U', 'primo', '100x100');
INSERT INTO Icone VALUES ('V', 'quinto', '100x100');


insert into squadra values('sq1', 'rosso', 'A', 'sf2');
insert into squadra values('sq2', 'verde', 'B', 'sf1');
insert into squadra values('sq3', 'blu', 'C', 'sf1');
insert into squadra values('sq4', 'azzurro', 'D', 'sf4');
insert into squadra values('sq5', 'arancione', 'E', 'sf2');
insert into squadra values('sq6', 'lilla', 'F', 'sf1');
insert into squadra values('sq7', 'viola', 'G', 'sf5');
insert into squadra values('sq8', 'bianco', 'H', 'sf1');
insert into squadra values('sq9', 'nero', 'I', 'sf1');
insert into squadra values('sq10', 'verdeacqua', 'L', 'sf7');
insert into squadra values('sq11', 'grigio', 'M', 'sf9');
insert into squadra values('sq12', 'giallo', 'N', 'sf8');
insert into squadra values('sq13', 'rosa', 'O', 'sf4');
insert into squadra values('sq14', 'verdescuro', 'P', 'sf1');
insert into squadra values('sq15', 'giallosenape', 'Q', 'sf5');
insert into squadra values('sq16', 'tamarindo', 'R', 'sf2');
insert into squadra values('sq17', 'rossofuoco', 'S', 'sf7');
insert into squadra values('sq18', 'blumare', 'T', 'sf5');
insert into squadra values('sq19', 'verdefiume', 'U', 'sf8');
insert into squadra values('sq20', 'arancionezucca', 'V', 'sf1');

INSERT INTO Utente VALUES ('a@mail', 'bella', TRUE, FALSE,'andrea','cognome', '01/01/1999');
INSERT INTO Utente VALUES ('b@mail', 'raga', FALSE, TRUE,'paolo','paoli', '01/02/1999');
INSERT INTO Utente VALUES ('c@mail', 'martin', TRUE, FALSE,'pippo','pippi', '01/03/1999');
INSERT INTO Utente VALUES ('d@mail', 'garrix', FALSE, TRUE,'pluto','pluti', '01/04/1999');
INSERT INTO Utente VALUES ('e@mail', 'frank00', TRUE, FALSE,'topolino','topolini','01/05/1999');
INSERT INTO Utente VALUES ('f@mail', 'si23', FALSE, TRUE,'pisolo','pisoli','01/06/1999');
INSERT INTO Utente VALUES ('g@mail', 'volando2', TRUE, FALSE,'nannolo','nannoli','01/07/1999');
INSERT INTO Utente VALUES ('h@mail', 'sonotop11', FALSE, TRUE,'brontolo','brontoli','01/08/1999');
INSERT INTO Utente VALUES ('i@mail', 'tornato4', TRUE, FALSE,'mugugnolo','mugugnoli','01/09/1999');
INSERT INTO Utente VALUES ('l@mail', 'oggi6', FALSE, TRUE,'memmolo','memmoli','01/10/1999');
INSERT INTO Utente VALUES ('m@mail', 'holly5', TRUE, FALSE,'bambi','bambo','01/11/1999');
INSERT INTO Utente VALUES ('n@mail', 'vinto00', FALSE, FALSE,'buzz','lightyear','01/12/1999');
INSERT INTO Utente VALUES ('o@mail', 'trenta30', FALSE, FALSE,'woody','cowboy','01/13/1999');
INSERT INTO Utente VALUES ('p@mail', 'pallaalpiede4', FALSE, FALSE,'honda','non', '01/14/1999');
INSERT INTO Utente VALUES ('q@mail', 'stobene55', FALSE, FALSE,'finito','solo', '01/15/1999');
INSERT INTO Utente VALUES ('r@mail', 'volando', FALSE, FALSE,'alice','cosa', '01/16/1999');
INSERT INTO Utente VALUES ('s@mail', 'decollo12', FALSE, FALSE,'camillo','metter', '01/17/1999');
INSERT INTO Utente VALUES ('t@mail', 'andrea5', FALSE, FALSE,'luca','innna', '01/18/1999');
INSERT INTO Utente VALUES ('u@mail', 'diciae66', TRUE, FALSE,'marco','peroni', '01/19/1999');
INSERT INTO Utente VALUES ('v@mail', 'perla1', FALSE, TRUE,'paolo','spazi', '01/20/1999');

INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (1,4,3);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (2,4,1);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (3,5,1);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (4,4,2);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (5,4,1);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (6,5,3);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (7,5,2);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (8,6,5);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (9,6,1);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (10,5,3);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (11,5,4);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (12,6,1);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (13,3,1);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (14,5,3);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (15,3,1);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (16,3,2);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (17,6,5);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (18,6,4);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (19,5,4);
INSERT INTO "oca"."dadi" ("iddado","valoremax","valoremin") VALUES (20,6,4);


INSERT INTO Quiz VALUES ('testoq1', 900, 'immagineq1', 'c4');
INSERT INTO Quiz VALUES ('testoq2', 120, NULL, 'c5');
INSERT INTO Quiz VALUES ('testoq3', 360, 'immagineq2', 'c20');
INSERT INTO Quiz VALUES ('testoq4', 500, NULL, 'c19');
INSERT INTO Quiz VALUES ('testoq5', 640, 'immagineq3', 'c10');

insert into task values('testoTask6', 30, 6,'c19');
insert into task values('testoTask5', 45 ,4 ,'c20');
insert into task values('testoTask3',67 , 4,'c14');
insert into task values('testoTask2', 23, 8 ,'c15');
insert into task values('testoTask1', 23, 16,'c10');

INSERT INTO Composta VALUES ('sq1', 'a@mail');
INSERT INTO Composta VALUES ('sq2', 'b@mail');
INSERT INTO Composta VALUES ('sq3', 'c@mail');
INSERT INTO Composta VALUES ('sq4', 'd@mail');
INSERT INTO Composta VALUES ('sq5', 'e@mail');
INSERT INTO Composta VALUES ('sq6', 'f@mail');
INSERT INTO Composta VALUES ('sq7', 'g@mail');
INSERT INTO Composta VALUES ('sq8', 'h@mail');
INSERT INTO Composta VALUES ('sq9', 'i@mail');
INSERT INTO Composta VALUES ('sq10', 'l@mail');
INSERT INTO Composta VALUES ('sq11', 'm@mail');
INSERT INTO Composta VALUES ('sq12', 'n@mail');
INSERT INTO Composta VALUES ('sq13', 'o@mail');
INSERT INTO Composta VALUES ('sq14', 'p@mail');
INSERT INTO Composta VALUES ('sq15', 'q@mail');
INSERT INTO Composta VALUES ('sq16', 'r@mail');
INSERT INTO Composta VALUES ('sq17', 's@mail');
INSERT INTO Composta VALUES ('sq18', 't@mail');
INSERT INTO Composta VALUES ('sq19', 'u@mail');
INSERT INTO Composta VALUES ('sq20', 'v@mail');

INSERT INTO Turno VALUES (1, 'sf1');
INSERT INTO Turno VALUES (2, 'sf1');
INSERT INTO Turno VALUES (3, 'sf1');
INSERT INTO Turno VALUES (4, 'sf1');
INSERT INTO Turno VALUES (5, 'sf1');
INSERT INTO Turno VALUES (6, 'sf1');
INSERT INTO Turno VALUES (7, 'sf1');
INSERT INTO Turno VALUES (8, 'sf1');
INSERT INTO Turno VALUES (9, 'sf1');
INSERT INTO Turno VALUES (10, 'sf1');
INSERT INTO Turno VALUES (1, 'sf2');
INSERT INTO Turno VALUES (2, 'sf2');
INSERT INTO Turno VALUES (3, 'sf2');
INSERT INTO Turno VALUES (4, 'sf2');
INSERT INTO Turno VALUES (5, 'sf2');
INSERT INTO Turno VALUES (6, 'sf2');
INSERT INTO Turno VALUES (7, 'sf2');
INSERT INTO Turno VALUES (8, 'sf2');
INSERT INTO Turno VALUES (9, 'sf2');
INSERT INTO Turno VALUES (10, 'sf2');

INSERT INTO Turno VALUES (1, 'sf3');
INSERT INTO Turno VALUES (2, 'sf3');
INSERT INTO Turno VALUES (3, 'sf3');
INSERT INTO Turno VALUES (4, 'sf3');
INSERT INTO Turno VALUES (5, 'sf3');
INSERT INTO Turno VALUES (6, 'sf3');
INSERT INTO Turno VALUES (7, 'sf3');
INSERT INTO Turno VALUES (8, 'sf3');
INSERT INTO Turno VALUES (9, 'sf3');
INSERT INTO Turno VALUES (10, 'sf3');
INSERT INTO Turno VALUES (1, 'sf4');
INSERT INTO Turno VALUES (2, 'sf4');
INSERT INTO Turno VALUES (3, 'sf4');
INSERT INTO Turno VALUES (4, 'sf4');
INSERT INTO Turno VALUES (5, 'sf4');
INSERT INTO Turno VALUES (6, 'sf4');
INSERT INTO Turno VALUES (7, 'sf4');
INSERT INTO Turno VALUES (8, 'sf4');
INSERT INTO Turno VALUES (9, 'sf4');
INSERT INTO Turno VALUES (10, 'sf4');
INSERT INTO Turno VALUES (3, 'sf5');
INSERT INTO Turno  VALUES (7, 'sf5');
INSERT INTO Turno  VALUES (10, 'sf7');
INSERT INTO Turno  VALUES (11, 'sf9');
INSERT INTO Turno  VALUES (12, 'sf8');
INSERT INTO Turno  VALUES (13, 'sf4');
INSERT INTO Turno  VALUES (14, 'sf1');
INSERT INTO Turno  VALUES (15, 'sf5');
INSERT INTO Turno  VALUES (16, 'sf2');
INSERT INTO Turno  VALUES (17, 'sf7');
INSERT INTO Turno  VALUES (18, 'sf5');
INSERT INTO Turno  VALUES (19, 'sf8');
INSERT INTO Turno VALUES (20, 'sf1');

INSERT INTO Contiene VALUES ('g1', 'A');
INSERT INTO Contiene VALUES ('g2', 'B');
INSERT INTO Contiene VALUES ('g3', 'C');
INSERT INTO Contiene VALUES ('g4', 'D');
INSERT INTO Contiene VALUES ('g5', 'E');
INSERT INTO Contiene VALUES ('g6', 'F');
INSERT INTO Contiene VALUES ('g7', 'G');
INSERT INTO Contiene VALUES ('g8', 'H');
INSERT INTO Contiene VALUES ('g9', 'I');
INSERT INTO Contiene VALUES ('g10', 'L');
INSERT INTO Contiene VALUES ('g11', 'M');
INSERT INTO Contiene VALUES ('g12', 'N');
INSERT INTO Contiene VALUES ('g13', 'O');
INSERT INTO Contiene VALUES ('g14', 'P');
INSERT INTO Contiene VALUES ('g15', 'Q');
INSERT INTO Contiene VALUES ('g16', 'R');
INSERT INTO Contiene VALUES ('g17', 'S');
INSERT INTO Contiene VALUES ('g18', 'T');
INSERT INTO Contiene VALUES ('g19', 'U');
INSERT INTO Contiene VALUES ('g20', 'V');

insert into rispostequiz values('rispostaq1', 'testoq1', 'delfino', 2 );
insert into rispostequiz values('rispostaq2', 'testoq1', 'tartaruga',5 );
insert into rispostequiz values('rispostaq3', 'testoq2', 'leone',7 );
insert into rispostequiz values('rispostaq4', 'testoq2', 'mare',8 );
insert into rispostequiz values('rispostaq5', 'testoq3', 'alga',9 );
insert into rispostequiz values('rispostaq6', 'testoq3', 'trattore',3 );
insert into rispostequiz values('rispostaq7', 'testoq4', 'maratona',6 );
insert into rispostequiz values('rispostaq8', 'testoq4', 'c++', 4);
insert into rispostequiz values('rispostaq9', 'testoq5', 'sql', 6);
insert into rispostequiz values('rispostaq10', 'testoq5', 'java', 2);

insert into presente values( 1, 'g1', 2, null);
insert into presente values( 2, 'g1', 3, null);
insert into presente values( 3, 'g1', 5, null);
insert into presente values( 4, 'g1', 6, null);
insert into presente values( 5, 'g1', 6, null);
insert into presente values( 1, 'g2', 3, null);
insert into presente values( 2, 'g2', 4, null);
insert into presente values( 3, 'g2', 3, null);
insert into presente values( 4, 'g2', 2, null);
insert into presente values( 5, 'g2', 1, null);
insert into presente values( 1, 'g3', 5, null);
insert into presente values( 2, 'g3', 3, null);
insert into presente values( 3, 'g3', 5, null);
insert into presente values( 4, 'g3', 3, null);
insert into presente values( 5, 'g3', 3, null);
insert into presente values( 1, 'g4', 1, null);
insert into presente values( 2, 'g4', 6, null);
insert into presente values( 1, 'g5', 8, null);
insert into presente values( 2, 'g5', 5, null);
insert into presente values( 3, 'g5', 3, null);
insert into presente values( 4, 'g5', 5, null);
insert into presente values( 5, 'g5', 4, null);
insert into presente values( 1, 'g6', 3, null);
insert into presente values( 2, 'g6', 4, null);
insert into presente values( 3, 'g6', 2, null);
insert into presente values( 4, 'g6', 4, null);
insert into presente values( 5, 'g6', 6,null);
insert into presente values( 6, 'g6', 7, null);
insert into presente values( 7, 'g6', 9, null);
insert into presente values( 8, 'g6', 4, null);
insert into presente values( 1, 'g7', 2, null);
insert into presente values( 1, 'g8', 4, null);
insert into presente values( 2, 'g8', 6, null);
insert into presente values( 3, 'g8', 4, null);
insert into presente values( 4, 'g8', 3, null);
insert into presente values( 5, 'g8', 2, null);
insert into presente values( 6, 'g8', 3, null);
insert into presente values( 7, 'g8', 2, null);
insert into presente values( 8, 'g8', 6, null);
insert into presente values( 9, 'g8', 7, null);
insert into presente values( 1, 'g9', 8, null);
insert into presente values( 2, 'g9', 5, null);
insert into presente values( 1, 'g10', 4, null);
insert into presente values( 2, 'g10', 5, null);
insert into presente values( 3, 'g10', 4, null);
insert into presente values( 4, 'g10', 5, null);
insert into presente values( 5, 'g10', 5, null);
insert into presente values( 1, 'g11', 2, null);
insert into presente values( 2, 'g11', 2, null);
insert into presente values( 3, 'g11', 6, null);
insert into presente values( 1, 'g12', 8, null);
insert into presente values( 2, 'g12', 9, null);
insert into presente values( 3, 'g12', 1, null);
insert into presente values( 4, 'g13', 2, null);
insert into presente values( 1, 'g13', 0, null);
insert into presente values( 2, 'g13', 5, null);
insert into presente values( 3, 'g13', 4, null);
insert into presente values( 4, 'g14', 2, null);

INSERT INTO Posizione VALUES (1, 'sf2', 'sq1', 'c9', 10);
INSERT INTO Posizione VALUES (1, 'sf2', 'sq1', 'c6', 10);
INSERT INTO Posizione VALUES (1, 'sf2', 'sq5', 'c9', 9);
INSERT INTO Posizione VALUES (1, 'sf2', 'sq5', 'c7', 9);
INSERT INTO Posizione VALUES (1, 'sf2', 'sq16', 'c8', 8);
INSERT INTO Posizione VALUES (1, 'sf2', 'sq16', 'c9', 8);
INSERT INTO Posizione VALUES (3, 'sf1', 'sq2', 'c1', 50);
INSERT INTO Posizione VALUES (3, 'sf1', 'sq2', 'c4', 50);
INSERT INTO Posizione VALUES (3, 'sf1', 'sq3', 'c2', 25);
INSERT INTO Posizione VALUES (3, 'sf1', 'sq3', 'c4', 25);
INSERT INTO Posizione VALUES (3, 'sf1', 'sq6', 'c3', 11);
INSERT INTO Posizione VALUES (3, 'sf1', 'sq6', 'c4', 11);
INSERT INTO Posizione VALUES (1, 'sf1', 'sq8', 'c4', 4);
INSERT INTO Posizione VALUES (1, 'sf1', 'sq14', 'c4', 7);
INSERT INTO Posizione VALUES (3, 'sf5', 'sq7', 'c16', 50);
INSERT INTO Posizione VALUES (3, 'sf5', 'sq7', 'c19', 50);
INSERT INTO Posizione VALUES (3, 'sf5', 'sq15', 'c17', 25);
INSERT INTO Posizione VALUES (3, 'sf5', 'sq15', 'c19', 25);
INSERT INTO Posizione VALUES (3, 'sf5', 'sq18', 'c18', 11);
INSERT INTO Posizione VALUES (3, 'sf5', 'sq18', 'c19', 11);

INSERT INTO Lancio VALUES (1, 'sq1', 1, 'sf2', 1, 6);
INSERT INTO Lancio VALUES (2, 'sq2',  2,'sf1', 2, 8);
INSERT INTO Lancio VALUES (3, 'sq3',  3,'sf1', 3, 6);
INSERT INTO Lancio VALUES (4, 'sq4',  4,'sf4', 2, 4);
INSERT INTO Lancio VALUES (5, 'sq5',  5, 'sf2',3, 5);
INSERT INTO Lancio VALUES (6, 'sq6',  6,'sf1', 1, 6);
INSERT INTO Lancio VALUES (7, 'sq7',  7,'sf5', 2, 3);
INSERT INTO Lancio VALUES (8, 'sq8',  8, 'sf1', 3, 5);
INSERT INTO Lancio VALUES (9, 'sq9',  9, 'sf1', 1, 6);
INSERT INTO Lancio VALUES (10, 'sq10',  10, 'sf7',2, 7);
INSERT INTO Lancio VALUES (11, 'sq11',  11, 'sf9',3, 3);
INSERT INTO Lancio VALUES (12, 'sq12',  12, 'sf8', 4, 4);
INSERT INTO Lancio VALUES (13, 'sq13',  2,'sf4', 1, 5);
INSERT INTO Lancio VALUES (14, 'sq14',  14,'sf1', 1, 4);
INSERT INTO Lancio VALUES (15, 'sq15',  15, 'sf5', 3, 3);
INSERT INTO Lancio VALUES (16, 'sq16',  16,'sf2', 2, 6);
INSERT INTO Lancio VALUES (17, 'sq17',  17,'sf7', 4, 5);
INSERT INTO Lancio VALUES (18, 'sq18', 18, 'sf5', 2, 5);
INSERT INTO Lancio VALUES (19, 'sq19',  19,'sf8', 3, 4);
INSERT INTO Lancio VALUES (20, 'sq20',  20,'sf1', 1, 1);

insert into rispostadata values ('sq1', 'a@mail', 1, 'aragosta/delfino', true, true, null, 'rispostaq4', 'testoq2');
insert into rispostadata values ('sq2', 'b@mail', 8, 'leone/tartaruga', false, false, null, 'rispostaq6', 'testoq3');
insert into rispostadata values ('sq3', 'c@mail', -6, '../tmp/d', false, true, 'testoTask2', null, null);
insert into rispostadata values ('sq4', 'd@mail', 7, '././../proc', true, true, 'testoTask5', null, null);
insert into rispostadata values ('sq5', 'e@mail', -4, 'home/images/montagna', true, false, null, 'rispostaq1', 'testoq1');

------------------------------------------------------------------SCHEMA FISICO:----------------------------------------------------------------------------
-- Determinare l’identificatore dei giochi che coinvolgono al più quattrosquadre e richiedono l’uso di due dadi.

--Indici:
CREATE INDEX GiocoSquadre ON Gioco (MaxSquadre);
CREATE INDEX GiocoId ON Gioco (IdGioco);
CREATE INDEX DadiPresente ON Presente (NumDadi);

--Query di riferimento:
SELECT Presente.idGioco
FROM Presente JOIN Gioco ON Presente.IdGioco = Gioco.IdGioco
WHERE Gioco.MaxSquadre<= 4 AND Presente.NumDadi=2;



/*
Determinare l’identificatore delle sfide relative a un gioco A di vostra scelta (specificare direttamente l’identificatore nella richiesta)
che, in alternativa:
- hanno avuto luogo a gennaio 2021 e durata massima superiore a 2 ore, 
o 
- hanno avuto luogo a marzo 2021 e durata massima pari a 30 minuti.
*/

--Indici:
CREATE INDEX DataSfida ON Sfida (Data);
CREATE INDEX DurataSfida ON Sfida (DurataMax);

--Query di riferimento:
SELECT IdSfida 
FROM Sfida JOIN Gioco ON Sfida.IdGioco = Gioco.IdGioco
WHERE Sfida.IdGioco = 'aFKr' AND  Sfida.Data BETWEEN '01/01/2021' AND '01/31/2021'  AND DurataMax > '02:00:00'
	 	OR Sfida.Data BETWEEN '03/01/2021' AND '03/31/2021' AND DurataMax = '00:30:00';

--------------------------------------------------------QUERY CARICO DI LAVORO:----------------------------------------------------------------------

-- Determinare l’identificatore dei giochi che coinvolgono al più quattrosquadre e richiedono l’uso di due dadi.

SELECT Presente.idGioco
FROM Presente JOIN Gioco ON Presente.IdGioco = Gioco.IdGioco
WHERE Gioco.MaxSquadre<= 4 AND Presente.NumDadi=2;

/*
Determinare l’identificatore delle sfide relative a un gioco A di vostra scelta (specificare direttamente l’identificatore nella richiesta)
che, in alternativa:
- hanno avuto luogo a gennaio 2021 e durata massima superiore a 2 ore, 
o 
- hanno avuto luogo a marzo 2021 e durata massima pari a 30 minuti.
*/

SELECT IdSfida 
FROM Sfida JOIN Gioco ON Sfida.IdGioco = Gioco.IdGioco
WHERE Sfida.IdGioco = 'eSYSE2boz' AND  Sfida.Data BETWEEN '01/01/2021' AND '01/31/2021'  AND DurataMax > '02:00:00'
	 	OR Sfida.Data BETWEEN '03/01/2021' AND '03/31/2021' AND DurataMax = '00:30:00';

--Determinare le sfide,di durata massima superiore a 2 ore, dei giochi che richiedono almeno due dadi.
--Restituire sia l’identificatore della sfida sia l’identificatore del gioco.

--Team13: Applicando i principi del tuning logico abbiamo creato questa vista materializzata, per la spiegazione si veda la sezione sui piani di esecuzione

CREATE MATERIALIZED VIEW SfidaPresente AS 
SELECT DISTINCT IdSfida, Sfida.IdGioco 
FROM Sfida JOIN Presente ON Sfida.IdGioco = Presente.IdGioco
WHERE Presente.IdGioco=Sfida.IdGioco AND Presente.NumDadi >=2 AND DurataMax > '02:00:00';

SELECT IdSfida, IdGioco
FROM SfidaPresente;



--------------------------------------------------------ULTERIORI QUERY E VISTA:--------------------------------------------------------------------
/*
La definizione di una vista che fornisca alcune informazioni riassuntive per ogni gioco: 
il numero di sfide relative a quel gioco disputate, la durata media di tali sfide, 
il numero di squadre e di giocatori partecipanti a tali sfide, i punteggi minimo, 
medio e massimo ottenutidalle squadre partecipanti a tali sfide;
*/

CREATE VIEW NumGiocatoriIGAux AS
SELECT IdGioco, COUNT(Email) AS NumUt
FROM Composta JOIN Squadra ON Composta.IdSquadra= Squadra.IdSquadra 
				JOIN Sfida ON  Squadra.IdSfida=Sfida.IdSfida
GROUP BY IdGioco;

CREATE VIEW NumSquadreIGAux AS
SELECT IdGioco, COUNT(IdSquadra) AS NumSq
FROM Squadra JOIN Sfida ON  Squadra.IdSfida=Sfida.IdSfida
GROUP BY IdGioco;


CREATE VIEW NumSfideIGAux AS
SELECT IdGioco, COUNT (IdSfida) AS NumSf, AVG(DurataMax) AS MediaSf
FROM Sfida
GROUP BY IdGioco;

CREATE VIEW Punti AS
SELECT idSfida, MIN(PunteggioOttenuto) AS PtMin, 
			MAX(PunteggioOttenuto) AS PtMax, AVG(PunteggioOttenuto) AS PtAvg
FROM Posizione 
GROUP BY Idsfida;

CREATE VIEW InfoGioco AS
SELECT  IdGioco, NumSf, MediaSf, NumSq, NumUt,
			PtMax, PtMin, PtAvg
FROM Sfida NATURAL LEFT OUTER JOIN Punti 
			NATURAL LEFT OUTER JOIN NumSfideIGAux 
			NATURAL LEFT OUTER JOIN NumGiocatoriIGAux
			NATURAL LEFT OUTER JOIN NumSquadreIGAux
 
GROUP BY IdGioco, NumSq, NumUt, NumSf, MediaSf, PtMax, PtMin, PtAvg;

--a.Determinare i giochi che contengono caselle a cui sono associati task;

--Team13: Applicando i principi del tuning logico abbiamo creato questa vista materializzata, per la spiegazione si veda la sezione sui piani di esecuzione

CREATE MATERIALIZED VIEW Caselle_Task 
AS SELECT DISTINCT IdGioco
FROM Caselle NATURAL JOIN Task 
WHERE Task.IdCaselle = Caselle.IdCaselle;

SELECT IdGioco
FROM Caselle_Task;

--b.Determinare i giochi che non contengono caselle a cui sono associati task;
SELECT IdGioco
FROM Gioco
EXCEPT 
SELECT IdGioco
FROM Caselle_Task; 

--c.Determinare le sfide che hanno durata superiore alla durata media delle sfide relative allo stesso gioco.

SELECT IdSfida, DurataMax, IdGioco 
FROM Sfida S
GROUP BY IdSfida
HAVING DurataMax >= (SELECT AVG(DurataMax)
					 FROM Sfida
					 WHERE Sfida.IdGioco = S.IdGioco);



----------------------------------------------------FUNZIONI E PROCEDURE:------------------------------------------------------------------------
--a.Funzione che realizza l'interrogazione 2c in maniera parametrica rispetto all’ID del gioco;
CREATE FUNCTION DurataSfida (IN IlGioco varchar(20)) RETURNS TABLE (LaSfida varchar(20), LaDurata time) AS
	$$
	DECLARE UnGioco varchar(20);
	BEGIN
		UnGioco:= (SELECT IdGioco FROM Gioco WHERE IdGioco=IlGioco);
		IF UnGioco IS NULL THEN RAISE EXCEPTION 'Non esistiono giochi corrispondenti al parametro %',IlGioco;
		END IF;
		RETURN QUERY SELECT IdSfida, DurataMax
						FROM Sfida
						WHERE IdGioco=UnGioco
						GROUP BY IdSfida
						HAVING DurataMax >= (SELECT AVG(DurataMax)
											 FROM Sfida
											 WHERE IdGioco = UnGioco);
		IF NOT FOUND THEN RAISE EXCEPTION 'Non esistono sfide per il gioco %', IlGioco;
		END IF;
		RETURN;
		END;
	$$
LANGUAGE plpgsql;



--b.Funzione di scelta dell’icona da parte di una squadra in una sfida:
--possono essere scelte solo le icone corrispondenti al gioco cui si riferisce la sfida che non siano già state scelte da altre squadre.

CREATE FUNCTION IconaSquadra (IN LaSquadra varchar(20), IN LaIcona varchar(20)) RETURNS void AS
	$$
	DECLARE
	UnaSquadra varchar(20);
	UnaIcona varchar(20);
	IlGioco varchar(20);
	BEGIN
		SELECT IdSquadra INTO UnaSquadra FROM Squadra WHERE IdSquadra=LaSquadra;
		IF UnaSquadra IS NULL THEN RAISE EXCEPTION 'Non esistiono squadre corrispondenti al parametro %',LaSquadra;
		END IF;
		
		SELECT Nome INTO UnaIcona FROM Icone WHERE Nome=LaIcona;
		IF UnaIcona IS NULL THEN RAISE EXCEPTION 'Non esistiono icone corrispondenti al parametro %',LaIcona;
		END IF;
		
		SELECT IdGioco INTO IlGioco FROM Sfida NATURAL JOIN Squadra  WHERE Squadra.IdSquadra=UnaSquadra;
		IF(SELECT NomeI FROM Contiene WHERE NomeI=UnaIcona AND IdGioco=IlGioco) IS NOT NULL THEN 
			IF (SELECT NomeI FROM Squadra WHERE NomeI=UnaIcona) IS NOT NULL THEN RAISE EXCEPTION 'Questa icona è gia stata scelta';
			ELSE UPDATE Squadra SET NomeI = UnaIcona WHERE IdSquadra=UnaSquadra;
			
			END IF;
		
		ELSE RAISE NOTICE 'Questa icona non appartiene al gioco di cui fa parte questa sfida';
		
		END IF;
	
	END;
	$$
LANGUAGE plpgsql;


--------------------------------------------------------------------------TRIGGER:------------------------------------------------------------------------------------
--4.I seguenti trigger:
--a.Verifica del vincolo che nessun utente possa partecipare a sfide contemporanee;

CREATE OR REPLACE FUNCTION non_contemporanea() 
RETURNS trigger AS $non_contemporanea$        

BEGIN
	IF (SELECT COUNT(*) FROM Composta NATURAL JOIN Squadra NATURAL JOIN Sfida 
		WHERE Sfida.Terminata = FALSE AND Composta.Email=NEW.Email )=1      
		THEN RAISE NOTICE '% fa già parte di una sfida!',  NEW.Email;
	ELSE
		RETURN NEW;
	END IF;       
END;
$non_contemporanea$ 
LANGUAGE plpgsql;

CREATE TRIGGER non_piu_contemp
BEFORE INSERT OR UPDATE ON Composta FOR EACH ROW 
EXECUTE PROCEDURE non_contemporanea();

--b.Mantenimento del punteggio corrente di ciascuna squadra in ogni sfida e inserimento delle icone opportune nella casella podio.

--Team13: Non abbiamo implementato l'inserimento delle icone all'interno delle caselle ma, ad ogni turno, ordiniamo la classifica sulla base del punteggio ottenuto.

CREATE OR REPLACE FUNCTION classifica_squadra() RETURNS TRIGGER AS $classifica_squadra$        
	DECLARE
	Sq1 varchar(20);
	Sq2 varchar(20);
	Sq3 varchar(20);
	LaCasella varchar(20);
	Counter integer;
	Pt1 smallint;
	Pt2 smallint;
	Pt3 smallint;

	IlCursore CURSOR FOR SELECT Posizione.IdCaselle  FROM Posizione NATURAL JOIN Caselle
			WHERE NTurno=NEW.NTurno AND IdSfida=NEW.IdSfida AND Caselle.Tipologia = 'Podio'
			ORDER BY PunteggioOttenuto DESC
			LIMIT 3;
	BEGIN
		SELECT IdSquadra, PunteggioOttenuto INTO Sq1, Pt1 FROM Posizione NATURAL JOIN Caselle
				WHERE NTurno=NEW.NTurno AND IdSfida=NEW.IdSfida AND Caselle.Tipologia = 'Non podio'
				GROUP BY idSquadra, PunteggioOttenuto
				ORDER BY PunteggioOttenuto DESC
				LIMIT 1;

		SELECT IdSquadra, PunteggioOttenuto INTO Sq2, Pt2 FROM Posizione NATURAL JOIN Caselle
				WHERE NTurno=NEW.NTurno AND IdSfida=NEW.IdSfida AND Caselle.Tipologia = 'Non podio'
				GROUP BY idSquadra, PunteggioOttenuto
				ORDER BY PunteggioOttenuto DESC
				LIMIT 1 offset 1;

		SELECT IdSquadra, PunteggioOttenuto INTO Sq3, Pt3 FROM Posizione NATURAL JOIN Caselle
				WHERE NTurno=NEW.NTurno AND IdSfida=NEW.IdSfida AND Caselle.Tipologia = 'Non podio'
				GROUP BY idSquadra, PunteggioOttenuto
				ORDER BY PunteggioOttenuto DESC
				LIMIT 1 offset 2;
		Counter = 1;
		OPEN IlCursore;
		FETCH IlCursore INTO LaCasella;
		WHILE FOUND LOOP 
			
				IF(Counter=1) THEN
					UPDATE Posizione SET IdSquadra=Sq1, PunteggioOttenuto= Pt1 WHERE 
											NTurno =NEW.NTurno AND IdCaselle= LaCasella AND IdSquadra<> Sq1;
				END IF;
				
				IF(Counter=2) THEN
					UPDATE Posizione SET IdSquadra=Sq2, PunteggioOttenuto = Pt2 WHERE
											NTurno =NEW.NTurno AND IdCaselle= LaCasella AND IdSquadra<> Sq2;
				END IF;
				IF(Counter=3) THEN
					UPDATE Posizione SET IdSquadra=Sq3, PunteggioOttenuto = Pt3 WHERE 
											NTurno =NEW.NTurno AND IdCaselle= laCasella AND IdSquadra<> Sq3;
				END IF;
				Counter=Counter+1;
				FETCH IlCursore INTO LaCasella;
			
		END LOOP;
		CLOSE IlCursore;
		
	END;
	$classifica_squadra$ 
LANGUAGE plpgsql;

CREATE TRIGGER posizione_squadra_classifica
AFTER INSERT OR UPDATE ON Posizione FOR EACH ROW 
WHEN (pg_trigger_depth() = 0)
EXECUTE PROCEDURE classifica_squadra();
