CREATE ROLE gameadmin;
GRANT ALL ON ALL TABLES IN SCHEMA oca
TO gameadmin
WITH GRANT OPTION;

CREATE ROLE gamecreator;
GRANT INSERT, UPDATE, DELETE 
ON oca.Gioco, oca.Icone, oca.Caselle, Oca.Quiz, Oca.Task, oca.rispostequiz, oca.dadi, oca.contiene, oca.presente
TO gamecreator WITH GRANT OPTION;
GRANT SELECT ON ALL TABLES IN SCHEMA oca 
TO gamecreator WITH GRANT OPTION; 

GRANT gamecreator TO gameadmin;


CREATE ROLE giocatore;
GRANT SELECT ON ALL TABLES IN SCHEMA oca 
TO giocatore;
GRANT INSERT ON oca.utente, oca.rispostadata, oca.lancio
TO giocatore;

GRANT giocatore TO gameadmin;

CREATE ROLE utente;
GRANT SELECT ON oca.gioco, oca.sfida, oca.utente
TO utente;

GRANT utente TO giocatore;










