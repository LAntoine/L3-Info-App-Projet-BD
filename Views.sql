CREATE OR REPLACE VIEW nb_matchs_gagnes AS SELECT E.nomequipe, COUNT(*) AS Matchs_gagnes
FROM resultat NATURAL JOIN equipe E
WHERE classement = 3
GROUP BY E.nomequipe;


CREATE OR REPLACE VIEW nb_matchs_nuls AS SELECT E.nomequipe, COUNT(*) AS Matchs_nuls
FROM resultat NATURAL JOIN equipe E
WHERE classement = 1
GROUP BY E.nomequipe;


CREATE OR REPLACE VIEW nb_matchs_perdus AS SELECT E.nomequipe, COUNT(*) AS Matchs_perdus
FROM resultat NATURAL JOIN equipe E
WHERE classement = 0
GROUP BY E.nomequipe;


CREATE OR REPLACE VIEW nb_buts_par_match AS SELECT matchid, COUNT(*) AS nbbutsmatch
FROM buts
GROUP BY matchid;

--******************************
-- Création de la vue EfficaciteGardiens
-- Utilisée dans le trigger resultat
-- L'efficacite est le ratio du nb de buts encaissés / temps passé sur le terrain en min
-- Plus il est faible et plus le gardien a été efficace
-- Nbbutsgardien/tempsPresence
-- Le temps de présence est calculé en minute
-- On utilise EXTRACT(epoch from ...) afin de convertir l'interval en valeur numérique
--******************************
CREATE VIEW EfficaciteGardiens AS
SELECT statsgardiens.matchid,
numerogardien,
equipeid,nbbutsgardien,
EXTRACT(epoch FROM heurefingardien-heuredebutgardien)/60 AS tempsPresence ,
nbbutsgardien/(EXTRACT(epoch FROM heurefingardien-heuredebutgardien)/60) AS efficacite
FROM statsgardiens, nb_buts_par_match
WHERE statsgardiens.matchid=nb_buts_par_match.matchid;

--******************************
--Affichage du classement des équipes
--par nb de points décroissants
--avec nb de matchs joués
--******************************
CREATE OR REPLACE VIEW classement_general AS SELECT nomEquipe, SUM(classement) AS TotalPoints, Count(*) As nbMatchJoués
From resultat r, equipe e
Where r.equipeId = e.equipeID
Group by r.equipeID, e.nomEquipe
ORDER BY TotalPoints DESC;


