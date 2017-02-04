--******************************
--Création de la vue MeilleursButeurs
--Utilisée dans le trigger resultat
--******************************
CREATE OR REPLACE VIEW MeilleursButeurs AS
SELECT numerobuteur,nom,matchid, COUNT(*) AS nombreDeButs
FROM buts b, joueurs e
WHERE b.equipeIDBUTEUR = e.equipeID
AND b.numerobuteur = e.numero
GROUP BY numerobuteur, nom, matchid
ORDER BY COUNT(*) DESC;
--******************************
--Fonction Resultat
--Calcule le nombre de points par équipe en fonction du score final
--Affiche le résultat à la fin de chaque match
--Affiche le nom de l'équipe gagnante
--Affiche le nom du meilleur buteur
--i.e. quand l'heure de fin de match est mise à jour
--******************************
CREATE OR REPLACE FUNCTION FunctionTriggerResultat() RETURNS trigger AS
$$
DECLARE
-- le curseur nous permet de récupérer plusieurs nuplets (ici les 2 concernant un matchID)
 scores CURSOR FOR
 SELECT score, equipeID FROM resultat
 WHERE matchid = NEW.matchid
 ORDER BY score DESC;
 score1 resultat.score%TYPE;
 score2 resultat.score%TYPE;
 equipeid1 resultat.equipeid%TYPE;
 equipeid2 resultat.equipeid%TYPE;
 equipeNom1 equipe.nomequipe%TYPE;
 equipeNom2 equipe.nomequipe%TYPE;
 meilleurButeur joueurs.nom%TYPE;
BEGIN
-- nous récupérons le score et l'équipeID de chaque ligne
-- on sait qu'il n'y a que deux lignes retournées par la requête précédente
-- pas besoin de boucle, deux fetch suffisent
 OPEN scores;
 FETCH scores INTO score1, equipeid1;
 FETCH scores INTO score2, equipeid2;
 CLOSE scores;
-- On récupére le nom des équipes
 SELECT nomequipe INTO equipeNom1 FROM Equipe WHERE equipeID =
equipeid1;
 SELECT nomequipe INTO equipeNom2 FROM Equipe WHERE equipeID =
equipeid2;
-- On compare les deux scores :
-- si identiques, alors match nul,
-- on donne 1 point à chaque équipe
 IF (score1 = score2) THEN
 UPDATE resultat
 SET classement = 1
 WHERE score = score1
 AND matchid=NEW.matchid;
 UPDATE resultat
 SET classement = 1
 WHERE score = score1
 AND matchid=NEW.matchid;
-- si scores différents, alors equipe 1 gagne,
-- on donne 3 points à l'équipe 1 et 0 à l'équipe 2
-- pas besoin de tester si score1>score2 car requete avec un order by desc sur le score
 ELSE
 UPDATE resultat
 SET classement = 0
 WHERE score = score2
 AND matchid=NEW.matchid;
 UPDATE resultat
 SET classement = 3
 WHERE score = score1
 AND matchid=NEW.matchid;
 END IF;
-- On affiche le résultat du match
 RAISE INFO 'Résultat final : % % - % %
',equipeNom1,score1,score2,equipeNom2;
-- On affiche le vainqueur, en prenant soin de tester si nous avions affaire à un match nul
 IF (score1<>score2) THEN
 RAISE INFO 'Victoire de : %',equipeNom1;
 ELSE
 RAISE INFO 'Match nul !';
 END IF;
-- On récupère le nom du meilleur buteur du match à partir de la vue MeilleurButeur
-- on précise le matchID du match qui vient de se finir
 SELECT nom INTO meilleurButeur
 FROM meilleursbuteurs
 WHERE matchid = NEW.matchid
 AND nombredebuts = (SELECT MAX(nombredebuts)
  FROM meilleursbuteurs
  WHERE matchid = NEW.matchid);
-- On affiche le nom du meilleur buteur
 RAISE INFO 'Meilleur buteur : %', meilleurButeur;
 RETURN NULL;
END;
$$
LANGUAGE 'plpgsql';

--******************************
--Création du trigger AffichageResultat
--******************************
CREATE TRIGGER AffichageResultat
-- Le trigger se déclencera après toute mise à jour de la table match
AFTER UPDATE ON MATCHS
FOR EACH ROW
EXECUTE PROCEDURE FunctionTriggerResultat();

--******************************
--Fonction SCORE
--Ajoute un point au score de l'équipe venant de marquer
--******************************
CREATE OR REPLACE FUNCTION FunctionTriggerScore() RETURNS trigger AS
$$
BEGIN
-- On teste si le trigger s'est déclenché sur un insert
-- si oui nous ajoutons un point à l'équipeID qui vient d'être ajoutée
 IF (TG_OP = 'INSERT') THEN
 UPDATE resultat
 SET score = score + 1
 WHERE equipeID = NEW.equipeidbuteur
 AND matchid = NEW.matchid;
-- Si ce n'est pas un insert, c'est un delete
-- nous retirons un point à l'équipeID qui vient d'être supprimé
 ELSE
 UPDATE resultat
 SET score = score - 1
 WHERE equipeID = OLD.equipeidbuteur
 AND matchid = OLD.matchid;
 END IF;
 RETURN NULL;
END;
$$
LANGUAGE 'plpgsql';

--******************************
--Création du trigger CalculScore
--******************************
CREATE TRIGGER CalculScore
-- Le trigger se déclenchera après chaque insertion ou suppression de nuplets de la table BUTS
-- Après insertion : une équipe vient de marquer, il faut lui ajouter un point
-- Après suppression : un but avait été accordé à une équipe mais a été invalidé, un point doit être retiré à l'équipe concernée
AFTER INSERT OR DELETE ON BUTS
FOR EACH ROW
EXECUTE PROCEDURE FunctionTriggerScore();



--Verifie que le but est insere dans un match en cours
CREATE OR REPLACE FUNCTION FunctionTriggerVerifBut() RETURNS trigger AS
'
  DECLARE
   debut time;
   fin time;

  BEGIN
   SELECT INTO debut HeureDebutMatch
    FROM matchs
     WHERE NEW.matchid = matchs.matchid;

  IF debut > NEW.HeureBut THEN
    RAISE EXCEPTION ''Insertion impossible car le match n est pas commence'';
  END IF;

   SELECT INTO fin HeureFinMatch
    FROM matchs
     WHERE NEW.matchid = matchs.matchid
      AND HeureFinMatch IS NOT NULL;

  IF FOUND THEN
    RAISE EXCEPTION ''Insertion impossible car le match est termine'';
  ELSE RETURN NEW;
  END IF;

 END;'
LANGUAGE 'plpgsql';


CREATE TRIGGER VerifBut
BEFORE INSERT OR UPDATE ON buts
FOR EACH ROW
EXECUTE PROCEDURE FunctionTriggerVerifBut();


--Verifie que le score est 0 au debut du match
CREATE OR REPLACE FUNCTION FunctionTriggerVerifResultat() RETURNS trigger AS
'
  BEGIN
   IF NEW.score <> 0 THEN
    RAISE EXCEPTION ''Au debut d un match le score doit être 0'';
  ELSE RETURN NEW;
  END IF;

 END;'
LANGUAGE 'plpgsql';


CREATE TRIGGER VerifResultat
BEFORE INSERT ON resultat
FOR EACH ROW
EXECUTE PROCEDURE FunctionTriggerVerifResultat();


--Verifie que l'heure de fin du match est supperieure a celle du dernier but
CREATE OR REPLACE FUNCTION FunctionTriggerVerifFinMatch() RETURNS trigger AS
'
  DECLARE
    dernierBut time;

  BEGIN
   SELECT INTO dernierBut MAX(HeureBut)
   FROM buts
   WHERE buts.matchid = NEW.matchid;

   IF dernierBut > NEW.HeureFinMatch AND NEW.HeureFinMatch <> NULL THEN
    RAISE EXCEPTION ''l heure de fin de match doit etre supperieure au dernier but'';
  ELSE RETURN NEW;
  END IF;

 END;'
LANGUAGE 'plpgsql';


CREATE TRIGGER VerifFinMatch
BEFORE UPDATE ON matchs
FOR EACH ROW
EXECUTE PROCEDURE FunctionTriggerVerifFinMatch();
