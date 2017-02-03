CREATE TABLE Matchs 
( 
 MatchID     SERIAL, 
 HeureDebutMatch time NOT NULL, 
 HeureFinMatch       time,  
 DateMatch          date NOT NULL, 
 CONSTRAINT PK_Matchs PRIMARY KEY (MatchID), 
 CONSTRAINT CK_Matchs_HeureFinMatch CHECK (HeureDebutMatch < HeureFinMatch) 
 ); 
  
 CREATE TABLE Equipe 
 ( 
 EquipeID SERIAL, 
 NomEquipe varchar(25) NOT NULL, 
 NbJoueurs integer NOT NULL,  
 CONSTRAINT PK_Equipe PRIMARY KEY (EquipeID) 
 ); 
   
 CREATE TABLE Resultat 
 ( 
 MatchID integer NOT NULL, 
 EquipeID integer NOT NULL, 
 Score integer NOT NULL, 
 Classement integer, 
 CONSTRAINT PK_Resultat PRIMARY KEY (MatchID,EquipeID), 
 CONSTRAINT "FK_Resultat_MatchID" FOREIGN KEY (MatchID) REFERENCES Matchs (MatchID) ON UPDATE RESTRICT ON DELETE RESTRICT,  
 CONSTRAINT "FK_Resultat_EquipeID" FOREIGN KEY (EquipeID) REFERENCES Equipe (EquipeID) ON UPDATE RESTRICT ON DELETE RESTRICT 
 ); 
  
 CREATE TABLE Joueurs 
 ( 
 Numero Integer NOT NULL, 
 EquipeID Integer NOT NULL, 
 Nom varchar(25) NOT NULL, 
 Prenom varchar(25) NOT NULL, 
 DateNaissance date NOT NULL, 
 CONSTRAINT PK_Joueurs PRIMARY KEY (Numero,EquipeID), 
 CONSTRAINT "FK_Joueurs_EquipeID" FOREIGN KEY (EquipeID) REFERENCES Equipe (EquipeID) ON UPDATE RESTRICT ON DELETE RESTRICT 
  
 ); 
  
  CREATE TABLE Gardien 
 ( 
 NumeroGardien Integer NOT NULL, 
 EquipeID Integer NOT NULL, 
 CONSTRAINT PK_Gardien PRIMARY KEY (NumeroGardien,EquipeID), 
 CONSTRAINT "FK_Gardien_NumeroGardien_EquipeID" FOREIGN KEY (NumeroGardien,EquipeID) REFERENCES Joueurs (Numero,EquipeID) ON UPDATE RESTRICT ON DELETE RESTRICT 
  
 ); 
  
 CREATE TABLE Buts 
 ( 
 ButID SERIAL, 
 MatchID integer NOT NULL, 
 HeureBut time NOT NULL, 
 NumeroButeur integer NOT NULL, 
 EquipeIDButeur Integer NOT NULL, 
 NumeroPasseur integer NOT NULL, 
 EquipeIDPasseur Integer NOT NULL, 
 CONSTRAINT PK_Buts PRIMARY KEY (ButID), 
 CONSTRAINT "FK_Buts_MatchID" FOREIGN KEY (MatchID) REFERENCES Matchs (MatchID) ON UPDATE RESTRICT ON DELETE RESTRICT, 
 CONSTRAINT "FK_Buts_NumeroButeur_EquipeIDButeur" FOREIGN KEY (NumeroButeur,EquipeIDButeur) REFERENCES Joueurs (Numero,EquipeID) ON UPDATE RESTRICT ON DELETE RESTRICT, 
 CONSTRAINT "FK_Buts_NumeroPasseur_EquipeIDPasseur" FOREIGN KEY (NumeroPasseur,EquipeIDPasseur) REFERENCES Joueurs (Numero,EquipeID) ON UPDATE RESTRICT ON DELETE RESTRICT 
  
 ); 
  
  CREATE TABLE StatsGardiens 
 ( 
 StatID SERIAL, 
 MatchID integer NOT NULL, 
 NumeroGardien integer NOT NULL, 
 EquipeID Integer NOT NULL,  
 HeureDebutGardien time NOT NULL, 
 HeureFinGardien time NOT NULL, 
 NbButsGardien integer NOT NULL, 
 CONSTRAINT PK_StatsGardiens PRIMARY KEY (StatID), 
 CONSTRAINT "FK_StatsGardiens_MatchID" FOREIGN KEY (MatchID) REFERENCES Matchs (MatchID) ON UPDATE RESTRICT ON DELETE RESTRICT, 
 CONSTRAINT "FK_StatsGardiens_NumeroGardien_EquipeID" FOREIGN KEY (NumeroGardien,EquipeID) REFERENCES Gardien (NumeroGardien,EquipeID) ON UPDATE RESTRICT ON DELETE RESTRICT 
  
 ); 
  
 
