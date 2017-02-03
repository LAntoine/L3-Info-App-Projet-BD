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


CREATE OR REPLACE VIEW efficacite_gardiens AS SELECT S.matchid, J.nom, J.prenom,
floor((nbbutsgardien+0.0)/nbbutsmatch*100) AS Efficacite
FROM statsgardiens S, joueurs J, nb_buts_par_match NB
WHERE S.numerogardien = J.numero 
AND S.equipeid = J.equipeid
AND S.matchid = NB.matchid
AND nbbutsmatch IS NOT NULL;

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


