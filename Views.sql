CREATE VIEW nb_matchs_gagnes AS SELECT E.nomequipe, COUNT(*) AS Matchs_gagnes
FROM resultat NATURAL JOIN equipe E
WHERE classement = 3
GROUP BY E.nomequipe;


CREATE VIEW nb_matchs_nuls AS SELECT E.nomequipe, COUNT(*) AS Matchs_nuls
FROM resultat NATURAL JOIN equipe E
WHERE classement = 1
GROUP BY E.nomequipe;


CREATE VIEW nb_matchs_perdus AS SELECT E.nomequipe, COUNT(*) AS Matchs_perdus
FROM resultat NATURAL JOIN equipe E
WHERE classement = 0
GROUP BY E.nomequipe;


CREATE VIEW nb_buts_par_match AS SELECT matchid, COUNT(*) AS nbbutsmatch
FROM buts
GROUP BY matchid;


CREATE VIEW efficacite_gardiens AS SELECT matchid, joueurs.nom, joueurs.prenom,
nbbutsgardien/nbbutsmatch*100
FROM (statsgardiens NATURAL JOIN joueurs) INNER JOIN nb_buts_par_match ON
nb_buts_par_match.nbbutsmatch= equipeID
WHERE nbbutsmatch IS NOT NULL;


CREATE VIEW resultat_matchs SELECT R1.matchid, R1.Nom, R1.score, E2.Nom, R2.score
FROM resultat R1, resultat R2, , equipe E1, equipe E2
WHERE NEW.matchid = R1.matchid AND NEW.matchid = R2.matchid
AND R1.equipeid = E1.equipeid AND R2.equipeid = E2.equipeid;

--******************************
--Affichage du classement des équipes
--par nb de points décroissants
--avec nb de matchs joués
--******************************
CREATE OR REPLACE VIEW SELECT nomEquipe, SUM(classement) AS TotalPoints, Count(*) As nbMatchJoués
From resultat r, equipe e
Where r.equipeId = e.equipeID
Group by r.equipeID, e.nomEquipe
ORDER BY TotalPoints DESC;
