USE master
GO
--We opted for this fancy statement to drop the entire database if it is already there and then create it and mount it.
--otherwise just create it and mount it.
--Chat GPT wrote this if block because we refactored the database alot in ways that just altering tables would not have been able to handle
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'Swaims_Zane_Nemynova_Evgeniia_db')
BEGIN
	ALTER DATABASE Swaims_Zane_Nemynova_Evgeniia_db SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE Swaims_Zane_Nemynova_Evgeniia_db
END
GO

CREATE DATABASE Swaims_Zane_Nemynova_Evgeniia_db
GO

USE Swaims_Zane_Nemynova_Evgeniia_db
GO

CREATE TABLE SealOrCIB(
	SealOrCIB			CHAR(8)									NOT NULL DEFAULT 'Neither',
	CONSTRAINT			SealOrCIBPK									PRIMARY KEY(SealOrCIB)
	);

CREATE TABLE Condition(
	Condition			CHAR(16)									NOT NULL,
	CONSTRAINT			ConditionPK									PRIMARY KEY(Condition)
	);

CREATE TABLE Regions(
	Region				VARCHAR(255)									NOT NULL,
	CONSTRAINT			RegionPK									PRIMARY KEY(Region)
	);

CREATE TABLE ESRB_Ratings(
	Rating				CHAR(8)									NOT NULL,
	CONSTRAINT			ESRBRatingPK								PRIMARY KEY(Rating)
	);

CREATE TABLE Series(
	Series				VARCHAR(255)								NOT NULL,
	CONSTRAINT			SeriesPK									PRIMARY KEY(Series)
	);

CREATE TABLE CoOp_Or_Vs(
	CoOpOrVs			CHAR(16)									NOT NULL DEFAULT 'Neither',
	OfflineOrOnline		BIT											NOT NULL,
	CONSTRAINT			CoOpOrVsPK									PRIMARY KEY(CoOpOrVs, OfflineOrOnline)
	);

CREATE TABLE Player_Numbers(
	MaxPlayerNumber		INT											NOT NULL,
	CONSTRAINT			PlayerNumberPK								PRIMARY KEY(MaxPlayerNumber)
	);

CREATE TABLE Genres(
	Genre				VARCHAR(255)									NOT NULL,
	CONSTRAINT			GenresPK									PRIMARY KEY(Genre)
	);

CREATE TABLE Game_Names(
	GameName			VARCHAR(255)									NOT NULL,
	UPC					BIGINT										NULL DEFAULT 0,
	ReleaseDate			DATE										NOT NULL,
	Rating				CHAR(8)									NOT NULL,
	CONSTRAINT			GameNamePK									PRIMARY KEY(GameName),
	CONSTRAINT			GameRatingFK								FOREIGN KEY(Rating) REFERENCES ESRB_Ratings(Rating),
	);

CREATE TABLE Game_Has_a_Series(
	GameName			VARCHAR(255)									NOT NULL,
	Series				VARCHAR(255)									NOT NULL,
	CONSTRAINT			GameHasaSeriesPK							PRIMARY KEY(GameName, Series),
	CONSTRAINT			GameHasaSeriesGameNameFK					FOREIGN KEY(GameName) REFERENCES Game_Names(GameName),
	CONSTRAINT			GameHasaSeriesSeriesFK						FOREIGN KEY(Series) REFERENCES Series(Series)
	);

CREATE TABLE Game_Has_Players(
	GameName			VARCHAR(255)									NOT NULL,
	MaxPlayerNumber		INT											NOT NULL,
	CoOpOrVs			CHAR(16)									NOT NULL DEFAULT 'Neither',
	OfflineOrOnline		BIT											NOT NULL,
	CONSTRAINT			GameHasPlayersPK							PRIMARY KEY (GameName, MaxPlayerNumber),
	CONSTRAINT			GameHasPlayersGameNameFK					FOREIGN KEY (GameName) REFERENCES Game_Names(GameName),
	CONSTRAINT			GameHasPlayersMaxPlayerNumberFK				FOREIGN KEY (MaxPlayerNumber) REFERENCES Player_Numbers(MaxPlayerNumber),
	CONSTRAINT			GameHasPlayersCoOpOrVsFK					FOREIGN KEY (CoOpOrVs, OfflineOrOnline) REFERENCES CoOp_Or_Vs(CoOpOrVs, OfflineOrOnline)

	);

CREATE TABLE Game_Has_Genres(
	GameName			VARCHAR(255)									NOT NULL,
    Genre				VARCHAR(255)									NOT NULL,
    CONSTRAINT			GameHasGenresPK								PRIMARY KEY (GameName, Genre),
    CONSTRAINT			GameHasGenresGameNameFK						FOREIGN KEY (GameName) REFERENCES Game_Names(GameName),
    CONSTRAINT			GameHasGenresGenreFK						FOREIGN KEY (Genre) REFERENCES Genres(Genre)
	);

CREATE TABLE Console_Publishers(
	ConsolePublisher	VARCHAR(255)									NOT NULL,
	CONSTRAINT			ConsolePublisherPK							PRIMARY KEY(ConsolePublisher)
	);

CREATE TABLE Console_Models(
	ModelName			VARCHAR(255)									NOT NULL,
	ModelNumber			VARCHAR(255)									NULL,
	ConsolePublisher	VARCHAR(255)									NOT NULL,
	CONSTRAINT			ConsoleModelPK								PRIMARY KEY(ModelName),
	CONSTRAINT			ConsolePublisherFK							FOREIGN KEY(ConsolePublisher) REFERENCES Console_Publishers(ConsolePublisher),
	);

CREATE TABLE Peripheral_Names(
	PeripheralName		VARCHAR(255)									NOT NULL,
	UPC					BIGINT										NULL DEFAULT 0,
	CONSTRAINT			PeripheralNamePK							PRIMARY KEY(PeripheralName)
	);

CREATE TABLE Magazine_Names(
	MagazineName		VARCHAR(255)									NOT NULL,
	MagazineVolume		INT											NOT NULL DEFAULT 1,
	ReleaseDate			DATE										NOT NULL,
	CONSTRAINT			MagazineNamePK								PRIMARY KEY(MagazineName, MagazineVolume)
	);

CREATE TABLE Strategy_Guide_Publishers(
	GuidePublisher		VARCHAR(255)									NOT NULL,
	CONSTRAINT			StrategyGuidePublishersNamePK				PRIMARY KEY(GuidePublisher)
	);

CREATE TABLE Strategy_Guide_Names(
	GuideName			VARCHAR(255)									NOT NULL,
	GuidePublisher		VARCHAR(255)									NOT	NULL,
	CONSTRAINT			StrategyGuideNamePK							PRIMARY KEY(GuideName, GuidePublisher),
	CONSTRAINT			StrategyGuidePublisherFK					FOREIGN KEY(GuidePublisher) REFERENCES Strategy_Guide_Publishers(GuidePublisher)
	);

CREATE TABLE Game_Has_a_Guide(
	GameName			VARCHAR(255)									NOT NULL,
	GuideName			VARCHAR(255)									NOT NULL,
	GuidePublisher		VARCHAR(255)									NOT	NULL,
	CONSTRAINT			GameHasaGuidePK								PRIMARY KEY (GameName, GuideName),
	CONSTRAINT			GameHasaGuideGameNameFK						FOREIGN KEY (GameName) REFERENCES Game_Names(GameName),
	CONSTRAINT			GameHasaGuideGuideNameFK					FOREIGN KEY (GuideName, GuidePublisher) REFERENCES Strategy_Guide_Names(GuideName, GuidePublisher)
	);

CREATE TABLE Game_Has_a_Console(
	GameName			VARCHAR(255)									NOT NULL,
    ModelName			VARCHAR(255)									NOT NULL,
    CONSTRAINT			GameHasaConsolePK							PRIMARY KEY (GameName, ModelName),
    CONSTRAINT			GameHasaConsoleGameNameFK					FOREIGN KEY (GameName) REFERENCES Game_Names(GameName),
    CONSTRAINT			GameHasaConsoleModelNameFK					FOREIGN KEY (ModelName) REFERENCES Console_Models(ModelName)
	);

CREATE TABLE Magazine_Has_a_Game(
	MagazineName		VARCHAR(255)									NOT NULL,
	MagazineVolume		INT											NOT NULL DEFAULT 1,
	GameName			VARCHAR(255)									NOT NULL,
	GuideOrCheats		BIT											NULL,
	CONSTRAINT			MagazineHasaGamePK							PRIMARY KEY (MagazineName,MagazineVolume , GameName),
	CONSTRAINT			MagazineHasaGameGameMagazineNameVolumeFK	FOREIGN KEY (MagazineName, MagazineVolume) REFERENCES Magazine_Names(MagazineName, MagazineVolume),
	CONSTRAINT			MagazineHasaGameGameNameFK					FOREIGN KEY (GameName) REFERENCES Game_Names(GameName)
	);

CREATE TABLE Game_Has_a_Peripheral(
	GameName			VARCHAR(255)									NOT NULL,
	PeripheralName		VARCHAR(255)									NOT NULL,
	CONSTRAINT			GameHasaPeripheralPK						PRIMARY KEY (GameName, PeripheralName),
	CONSTRAINT			GameHasaPeripheralGameNameFK				FOREIGN KEY (GameName) REFERENCES Game_Names(GameName),
	CONSTRAINT			GameHasaPeripheralPeripheralNameFK			FOREIGN KEY (PeripheralName) REFERENCES Peripheral_Names(PeripheralName)
	);

CREATE TABLE Console_Has_a_Peripheral(
	ModelName			VARCHAR(255)									NOT NULL,
	PeripheralName		VARCHAR(255)									NOT NULL,
	CONSTRAINT			ConsoleHasaPeripheralPK						PRIMARY KEY (ModelName, PeripheralName),
	CONSTRAINT			ConsoleHasaPeripheralConsoleModelFK			FOREIGN KEY (ModelName) REFERENCES Console_Models(ModelName),
	CONSTRAINT			ConsoleHasaPeripheralPeripheralNameFK		FOREIGN KEY (PeripheralName) REFERENCES Peripheral_Names(PeripheralName)
	);


-- Creating tables for the primary entities
CREATE TABLE Games(
	UID					UNIQUEIDENTIFIER							NOT NULL DEFAULT NEWID(),
	Notes				VARCHAR(255)									NULL,
	GameName			VARCHAR(255)									NOT NULL,
	Condition			CHAR(16)									NOT NULL,
	SealOrCIB			CHAR(8)									NOT NULL DEFAULT 'Neither',
	Region				VARCHAR(255)									NOT NULL,
	CONSTRAINT			GameRegion									FOREIGN KEY(Region) REFERENCES Regions(Region),
	CONSTRAINT			GameUIDPK									PRIMARY KEY(UID),
	CONSTRAINT			GameNameFK									FOREIGN KEY(GameName) REFERENCES Game_Names(GameName),
	CONSTRAINT			GamesConditionFK						FOREIGN KEY(Condition) REFERENCES Condition(Condition),
	CONSTRAINT			GamesSealOrCIBFK						FOREIGN KEY(SealOrCIB) REFERENCES SealOrCIB(SealOrCIB)
	);

CREATE TABLE Peripherals(
	UID					UNIQUEIDENTIFIER							NOT NULL DEFAULT NEWID(),
	Notes				VARCHAR(255)									NULL,
	PeripheralName		VARCHAR(255)									NOT NULL,
	Condition			CHAR(16)									NOT NULL,
	SealOrCIB			CHAR(8)									NOT NULL DEFAULT 'Neither',
	CONSTRAINT			PeripheralUIDPK								PRIMARY KEY(UID),
	CONSTRAINT			PeripheralNameFK							FOREIGN KEY(PeripheralName) REFERENCES Peripheral_Names(PeripheralName),
	CONSTRAINT			PeripheralConditionFK						FOREIGN KEY(Condition) REFERENCES Condition(Condition),
	CONSTRAINT			PeripheralSealOrCIBFK						FOREIGN KEY(SealOrCIB) REFERENCES SealOrCIB(SealOrCIB)
	);

CREATE TABLE Magazines(
	UID					UNIQUEIDENTIFIER							NOT NULL DEFAULT NEWID(),
	Notes				VARCHAR(255)									NULL,
	MagazineName		VARCHAR(255)									NOT NULL,
	MagazineVolume		INT											NOT NULL DEFAULT 1,
	Condition			CHAR(16)									NOT NULL,
	SealOrCIB			CHAR(8)									NOT NULL DEFAULT 'Neither',
	CONSTRAINT			MagazineUIDPK								PRIMARY KEY(UID),
	CONSTRAINT			MagazineConditionFK						FOREIGN KEY(Condition) REFERENCES Condition(Condition),
	CONSTRAINT			MagazineSealOrCIBFK						FOREIGN KEY(SealOrCIB) REFERENCES SealOrCIB(SealOrCIB),
	CONSTRAINT			MagazineNameVolumeFK						FOREIGN KEY(MagazineName, MagazineVolume) REFERENCES Magazine_Names(MagazineName, MagazineVolume)
	);

CREATE TABLE Strategy_Guides(
	UID					UNIQUEIDENTIFIER							NOT NULL DEFAULT NEWID(),
	Notes				VARCHAR(255)									NULL,
	GuideName			VARCHAR(255)									NOT NULL,
	GuidePublisher		VARCHAR(255)									NOT NULL,
	Condition			CHAR(16)									NOT NULL,
	SealOrCIB			CHAR(8)									NOT NULL DEFAULT 'Neither',
	CONSTRAINT			StrategyGuideUIDPK							PRIMARY KEY(UID),
	CONSTRAINT			StrategyGuideNameFK							FOREIGN KEY(GuideName, GuidePublisher) REFERENCES Strategy_Guide_Names(GuideName, GuidePublisher),
		CONSTRAINT			StrategyGuideConditionFK						FOREIGN KEY(Condition) REFERENCES Condition(Condition),
	CONSTRAINT			StrategyGuideSealOrCIBFK						FOREIGN KEY(SealOrCIB) REFERENCES SealOrCIB(SealOrCIB)
	);

CREATE TABLE Memorabilia(
	UID					UNIQUEIDENTIFIER							NOT NULL DEFAULT NEWID(),
	Description			VARCHAR(255)									NULL,
	GameName            VARCHAR(255)									NULL,
    Series              VARCHAR(255)									NULL,
	Condition			CHAR(16)									NOT NULL,
	SealOrCIB			CHAR(8)									NOT NULL DEFAULT 'Neither',
	CONSTRAINT			MemorabiliaUIDPK							PRIMARY KEY(UID),
	CONSTRAINT			MemorabiliaGameNameFK						FOREIGN KEY(GameName) REFERENCES Game_Names(GameName),
	CONSTRAINT			MemorabiliaSeriesFK							FOREIGN KEY(Series) REFERENCES Series(Series),
	CONSTRAINT			MemorabiliaConditionFK						FOREIGN KEY(Condition) REFERENCES Condition(Condition),
	CONSTRAINT			MemorabiliaSealOrCIBFK						FOREIGN KEY(SealOrCIB) REFERENCES SealOrCIB(SealOrCIB),
	CONSTRAINT          MemorabiliaExclusiveOR						CHECK (
																	(GameName IS NOT NULL AND Series IS NULL) OR
																	(GameName IS NULL AND Series IS NOT NULL)
																			)
	);

CREATE TABLE Consoles(
	UID					UNIQUEIDENTIFIER							NOT NULL DEFAULT NEWID(),
	isModded			BIT											NOT NULL DEFAULT 0,
	Notes				VARCHAR(255)									NULL,
	ModelName			VARCHAR(255)									NOT NULL,
	Condition			CHAR(16)									NOT NULL,
	SealOrCIB			CHAR(8)									NOT NULL DEFAULT 'Neither',
	Region				VARCHAR(255)									NOT NULL,
	CONSTRAINT			ConsoleRegionFK								FOREIGN KEY(Region) REFERENCES Regions(Region),
	CONSTRAINT			ConsolesUIDPK								PRIMARY KEY(UID),
	CONSTRAINT			ModelNameFK									FOREIGN KEY(ModelName) REFERENCES Console_Models(ModelName),
	CONSTRAINT			ConsoleConditionFK						FOREIGN KEY(Condition) REFERENCES Condition(Condition),
	CONSTRAINT			ConsoleSealOrCIBFK						FOREIGN KEY(SealOrCIB) REFERENCES SealOrCIB(SealOrCIB)
	);


--Adding in a few objects into the tables

-- SealOrCIB
INSERT INTO		SealOrCIB (SealOrCIB)					VALUES		('Neither')
INSERT INTO		SealOrCIB (SealOrCIB)					VALUES		('Sealed')
INSERT INTO		SealOrCIB (SealOrCIB)					VALUES		('CIB')

--Conditions
INSERT INTO		Condition (Condition)					VALUES		('Near Mint')
INSERT INTO		Condition (Condition)					VALUES		('Very Good')
INSERT INTO		Condition (Condition)					VALUES		('Good')
INSERT INTO		Condition (Condition)					VALUES		('Not Very Good')
INSERT INTO		Condition (Condition)					VALUES		('Damaged')

--Games
--ESRB ratings
INSERT INTO		ESRB_Ratings (Rating)		VALUES		('E')
INSERT INTO		ESRB_Ratings (Rating)		VALUES		('E 10+')
INSERT INTO		ESRB_Ratings (Rating)		VALUES		('T')
INSERT INTO		ESRB_Ratings (Rating)		VALUES		('M')
INSERT INTO		ESRB_Ratings (Rating)		VALUES		('AO')
INSERT INTO		ESRB_Ratings (Rating)		VALUES		('RP')

--Regions
INSERT INTO		Regions (Region)			VALUES		('NTSC-U/C')
INSERT INTO		Regions (Region)			VALUES		('NTSC-J')
INSERT INTO		Regions (Region)			VALUES		('NTSC-C')
INSERT INTO		Regions (Region)			VALUES		('PAL')

--Game names
INSERT INTO		Game_Names (GameName, UPC, ReleaseDate, Rating)
				VALUES		('Rule of Rose', 730865530205, '2006-09-12', 'M')
INSERT INTO		Game_Names (GameName, UPC, ReleaseDate, Rating)
				VALUES		('LSD: Dream Emulator', 4988126510244, '1998-10-22', 'T')
INSERT INTO		Game_Names (GameName, UPC, ReleaseDate, Rating)
				VALUES		('Shenmue', 010086510591, '2000-11-08', 'T')
INSERT INTO		Game_Names (GameName, UPC, ReleaseDate, Rating)
				VALUES		('Gauntlet Legends', 031719198184, '1999-09-29', 'T')
INSERT INTO		Game_Names (GameName, UPC, ReleaseDate, Rating)
				VALUES		('Mega Man 2', 013388110117, '1989-06-01', 'E')
INSERT INTO		Game_Names (GameName, UPC, ReleaseDate, Rating)
				VALUES		('.hack//INFECTION Part 1', 045557180119, '2000-02-01', 'T')
INSERT INTO		Game_Names (GameName, UPC, ReleaseDate, Rating)
				VALUES		('Front Mission 3', 662248900056, '2003-02-28', 'T')
INSERT INTO		Game_Names (GameName, UPC, ReleaseDate, Rating)
				VALUES		('Parasite Eve', 662248998015, '1998-09-09', 'M')
INSERT INTO		Game_Names (GameName, UPC, ReleaseDate, Rating)
				VALUES		('Pokemon Red', 045496730734, '1998-09-27', 'E')
INSERT INTO		Game_Names (GameName, UPC, ReleaseDate, Rating)
				VALUES		('Pokemon Blue', 045496730826, '1998-09-27', 'E')
INSERT INTO		Game_Names (GameName, UPC, ReleaseDate, Rating)
				VALUES		('Pokemon Yellow', 045496730895, '1999-10-01', 'E')

--CoOpOrVs
INSERT INTO CoOp_Or_Vs(CoOpOrVs, OfflineOrOnline) VALUES ('Neither', 0)
INSERT INTO CoOp_Or_Vs(CoOpOrVs, OfflineOrOnline) VALUES ('CoOp', 0)
INSERT INTO CoOp_Or_Vs(CoOpOrVs, OfflineOrOnline) VALUES ('Versus', 0)
INSERT INTO CoOp_Or_Vs(CoOpOrVs, OfflineOrOnline) VALUES ('Neither', 1)
INSERT INTO CoOp_Or_Vs(CoOpOrVs, OfflineOrOnline) VALUES ('CoOp', 1)
INSERT INTO CoOp_Or_Vs(CoOpOrVs, OfflineOrOnline) VALUES ('Versus', 1)

--Players
INSERT INTO Player_Numbers (MaxPlayerNumber) VALUES (1)
INSERT INTO Player_Numbers (MaxPlayerNumber) VALUES (4)
INSERT INTO Player_Numbers (MaxPlayerNumber) VALUES (2)

--Series
INSERT INTO Series (Series) VALUES ('Bomberman')
INSERT INTO Series (Series) VALUES ('Fallout')
INSERT INTO Series (Series) VALUES ('Gauntlet')
INSERT INTO Series (Series) VALUES ('Legacy of Kain')
INSERT INTO Series (Series)	VALUES ('Mega Man')
INSERT INTO Series (Series) VALUES ('Pokemon')
INSERT INTO Series (Series) VALUES ('Shenmue')
INSERT INTO Series (Series) VALUES ('Front Mission')
INSERT INTO Series (Series) VALUES ('.hack//')
INSERT INTO Series (Series) VALUES ('Parasite Eve')

--Genres
INSERT INTO Genres (Genre)	VALUES ('Adventure')
INSERT INTO Genres (Genre)	VALUES ('Fighting')
INSERT INTO Genres (Genre)  VALUES ('Hack and Slash')
INSERT INTO Genres (Genre)	VALUES ('Horror')
INSERT INTO Genres (Genre)  VALUES ('Platformer')
INSERT INTO Genres (Genre)	VALUES ('RPG')
INSERT INTO Genres (Genre)	VALUES ('Survival')
INSERT INTO Genres (Genre)	VALUES ('Strategy')
INSERT INTO Genres (Genre)	VALUES ('Turn Based Strategy')

--Inserting additional info for games
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline)	VALUES ('Gauntlet Legends', 1, 'Neither', 0)
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline)	VALUES ('Gauntlet Legends', 4, 'CoOp', 0)
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline)	VALUES ('LSD: Dream Emulator', 1, 'Neither', 0)
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline)	VALUES ('Mega Man 2', 1, 'Neither', 0)
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline)	VALUES ('Rule of Rose', 1, 'Neither', 0)
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline)	VALUES ('Shenmue', 1, 'Neither', 0)
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline)	VALUES ('.hack//INFECTION Part 1', 1, 'Neither', 0)
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline)	VALUES ('Front Mission 3', 1, 'Neither', 0)
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline)	VALUES ('Parasite Eve', 1, 'Neither', 0)
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline)	VALUES ('Pokemon Red', 1, 'Neither', 0)
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline)	VALUES ('Pokemon Red', 2, 'Versus', 0)
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline)	VALUES ('Pokemon Blue', 1, 'Neither', 0)
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline)	VALUES ('Pokemon Blue', 2, 'Versus', 0)
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline)	VALUES ('Pokemon Yellow', 1, 'Neither', 0)
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline)	VALUES ('Pokemon Yellow', 2, 'Versus', 0)

INSERT INTO Game_Has_a_Series (GameName, Series) VALUES ('Pokemon Red', 'Pokemon')
INSERT INTO Game_Has_a_Series (GameName, Series) VALUES ('Pokemon Blue', 'Pokemon')
INSERT INTO Game_Has_a_Series (GameName, Series) VALUES ('Pokemon Yellow', 'Pokemon')
INSERT INTO Game_Has_a_Series (GameName, Series) VALUES ('Front Mission 3', 'Front Mission')
INSERT INTO Game_Has_a_Series (GameName, Series) VALUES ('Shenmue', 'Shenmue')
INSERT INTO Game_Has_a_Series (GameName, Series) VALUES ('Mega Man 2', 'Mega Man')
INSERT INTO Game_Has_a_Series (GameName, Series) VALUES ('Gauntlet Legends', 'Gauntlet')
INSERT INTO Game_Has_a_Series (GameName, Series) VALUES ('.hack//INFECTION Part 1', '.hack//')
INSERT INTO Game_Has_a_Series (GameName, Series) VALUES ('Parasite Eve', 'Parasite Eve')

INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Gauntlet Legends', 'Adventure')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Gauntlet Legends', 'Hack and Slash')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('LSD: Dream Emulator', 'Adventure')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Mega Man 2', 'Adventure')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Mega Man 2', 'Platformer')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Rule of Rose', 'Horror')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Rule of Rose', 'Survival')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Shenmue', 'Adventure')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Shenmue', 'Fighting')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Shenmue', 'RPG')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('.hack//INFECTION Part 1', 'RPG')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('.hack//INFECTION Part 1', 'Hack and Slash')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Front Mission 3', 'RPG')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Front Mission 3', 'Strategy')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Front Mission 3', 'Turn Based Strategy')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Parasite Eve', 'RPG')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Parasite Eve', 'Adventure')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Parasite Eve', 'Horror')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Pokemon Red', 'RPG')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Pokemon Red', 'Turn Based Strategy')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Pokemon Red', 'Adventure')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Pokemon Blue', 'RPG')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Pokemon Blue', 'Turn Based Strategy')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Pokemon Blue', 'Adventure')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Pokemon Yellow', 'RPG')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Pokemon Yellow', 'Turn Based Strategy')
INSERT INTO Game_Has_Genres (GameName, Genre)	VALUES ('Pokemon Yellow', 'Adventure')

INSERT INTO Games (GameName, Notes, Condition, Region)				VALUES ('Gauntlet Legends', 'Loose Cart', 'Very Good', 'NTSC-U/C')
INSERT INTO Games (GameName, Notes, Condition, Region)				VALUES ('Gauntlet Legends', 'Has manual', 'Near Mint', 'NTSC-U/C')

INSERT INTO Games (GameName, Condition, SealOrCIB, Region)			VALUES ('LSD: Dream Emulator', 'Near Mint', 'CIB', 'NTSC-J')
INSERT INTO Games (GameName, Notes, Condition, SealOrCIB, Region)	VALUES ('Mega Man 2', 'Loose Cart', 'Very Good', 'CIB', 'NTSC-U/C')
INSERT INTO Games (GameName, Condition, SealOrCIB, Region)			VALUES ('Rule of Rose', 'Near Mint', 'CIB', 'NTSC-U/C')
INSERT INTO Games (GameName, Condition, SealOrCIB, Region)			VALUES ('Shenmue', 'Near Mint', 'CIB', 'NTSC-U/C')

--Memorabilia
INSERT INTO Memorabilia(Description, Series, Condition) VALUES ('Bomberman Plush', 'Bomberman', 'Near Mint')
INSERT INTO Memorabilia(Description, Series, Condition, SealOrCIB) VALUES ('Magic the Gathering Fallout Collectors Booster Box', 'Fallout', 'Near Mint', 'Sealed')
INSERT INTO Memorabilia(Description, Series, Condition) VALUES ('Legacy of Kain: Soul Reaver Comic Book', 'Legacy of Kain', 'Very Good')
INSERT INTO Memorabilia(Description, Series, Condition, SealOrCIB) VALUES ('Mega Bloks Pokedex', 'Pokemon', 'Near Mint', 'Sealed')
INSERT INTO Memorabilia(Description, Series, Condition) VALUES ('Complete Base Set of Pokemon Cards', 'Pokemon', 'Very Good')

--Consoles
--Publishers
INSERT INTO Console_Publishers (ConsolePublisher) VALUES ('Atari')
INSERT INTO Console_Publishers (ConsolePublisher) VALUES ('Microsoft')
INSERT INTO Console_Publishers (ConsolePublisher) VALUES ('Nintendo')
INSERT INTO Console_Publishers (ConsolePublisher) VALUES ('Sega')
INSERT INTO Console_Publishers (ConsolePublisher) VALUES ('Sony')

--Console Models
INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES ('Playstation 2', 'SCPH-50001-N', 'Sony')
INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES ('Switch', 'HAC S KABAA USZ', 'Nintendo')
INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES ('Atari 2600', 'CX-2600A', 'Atari')
INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES ('Xbox', 'X0061-001', 'Microsoft')
INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES ('Dreamcast', 'HKT-3020', 'Sega')
INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES ('Gameboy', 'DMG-01', 'Nintendo')
INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES ('Super Nintendo', 'SNS-001', 'Nintendo')
INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES ('Playstation', 'SCPH-5501', 'Sony')
INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES ('Nintendo 64', 'NUS-001', 'Nintendo')
INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES ('Nintendo Entertainment System', 'NES-001', 'Nintendo')

--Consoles
INSERT INTO Consoles (ModelName, Notes, Condition, Region) VALUES ('Playstation 2', 'This is my original PS2, have manual and cables', 'Good', 'PAL')
INSERT INTO Consoles (ModelName, Notes, Condition, Region) VALUES ('Atari 2600', 'Loose console with cables', 'Good', 'NTSC-U/C')
INSERT INTO Consoles (ModelName, Condition, SealOrCIB, Region) VALUES ('Switch', 'Very Good', 'CIB', 'NTSC-U/C')
INSERT INTO Consoles (ModelName, isModded, Notes, Condition, Region) VALUES ('Xbox', 1, 'Loose console with cables', 'Good', 'NTSC-U/C')
INSERT INTO Consoles (ModelName, Notes, Condition, Region) VALUES ('Dreamcast', 'Loose console with cables', 'Good', 'NTSC-U/C')

--Peripherals
INSERT INTO Peripheral_Names (PeripheralName, UPC) VALUES ('Gameboy Printer Pokemon Edition', '4902370503678')
INSERT INTO Peripheral_Names (PeripheralName, UPC) VALUES ('Super Multitap 2', '4988607000639')
INSERT INTO Peripheral_Names (PeripheralName, UPC) VALUES ('Guncon', '4907892010321')
INSERT INTO Peripheral_Names (PeripheralName, UPC) VALUES ('Steel Battalion Controller', '013388290024')
INSERT INTO Peripheral_Names (PeripheralName, UPC) VALUES ('Dualshock', '711719405900')

--Peripherals proper
INSERT INTO Peripherals (PeripheralName, Condition, SealOrCIB) VALUES ('Gameboy Printer Pokemon Edition', 'Good', 'CIB')
INSERT INTO Peripherals (PeripheralName, Condition, SealOrCIB) VALUES ('Super Multitap 2', 'Good', 'CIB')
INSERT INTO Peripherals (PeripheralName, Condition, SealOrCIB) VALUES ('Guncon', 'Good', 'CIB')
INSERT INTO Peripherals (PeripheralName, Condition, SealOrCIB) VALUES ('Steel Battalion Controller', 'Good', 'Sealed')
INSERT INTO Peripherals (PeripheralName, Condition) VALUES ('Dualshock', 'Not Very Good')

--Peripheral Bridges
INSERT INTO Console_Has_a_Peripheral (PeripheralName, ModelName) VALUES ('Gameboy Printer Pokemon Edition', 'Gameboy')
INSERT INTO Console_Has_a_Peripheral (PeripheralName, ModelName) VALUES ('Super Multitap 2', 'Super Nintendo')
INSERT INTO Console_Has_a_Peripheral (PeripheralName, ModelName) VALUES ('Guncon', 'Playstation')
INSERT INTO Console_Has_a_Peripheral (PeripheralName, ModelName) VALUES ('Steel Battalion Controller', 'Xbox')
INSERT INTO Console_Has_a_Peripheral (PeripheralName, ModelName) VALUES ('Dualshock', 'Playstation')

--Magazines
INSERT INTO Magazine_Names (MagazineName, MagazineVolume, ReleaseDate) VALUES ('Tips & Tricks', '97', '2003-03-01')
INSERT INTO Magazine_Names (MagazineName, MagazineVolume, ReleaseDate) VALUES ('Tips & Tricks', '98', '2003-04-01')
INSERT INTO Magazine_Names (MagazineName, MagazineVolume, ReleaseDate) VALUES ('Tips & Tricks', '102', '2003-08-01')
INSERT INTO Magazine_Names (MagazineName, MagazineVolume, ReleaseDate) VALUES ('Tips & Tricks', '103', '2003-09-01')
INSERT INTO Magazine_Names (MagazineName, MagazineVolume, ReleaseDate) VALUES ('Tips & Tricks', '111', '2004-05-01')

INSERT INTO Magazines (MagazineName, MagazineVolume, Condition) VALUES ('Tips & Tricks', '97', 'Not Very Good')
INSERT INTO Magazines (MagazineName, MagazineVolume, Condition) VALUES ('Tips & Tricks', '98', 'Not Very Good')
INSERT INTO Magazines (MagazineName, MagazineVolume, Condition) VALUES ('Tips & Tricks', '102', 'Not Very Good')
INSERT INTO Magazines (MagazineName, MagazineVolume, Condition) VALUES ('Tips & Tricks', '103', 'Not Very Good')
INSERT INTO Magazines (MagazineName, MagazineVolume, Condition) VALUES ('Tips & Tricks', '111', 'Not Very Good')

--Magazine has a game
--These games are not the correct games in the magazines it just requires alot of extra work to put the real ones in
INSERT INTO Magazine_Has_a_Game (MagazineName, MagazineVolume, GameName, GuideOrCheats) VALUES
								('Tips & Tricks', '97', '.hack//INFECTION Part 1', 0)
INSERT INTO Magazine_Has_a_Game (MagazineName, MagazineVolume, GameName, GuideOrCheats) VALUES
								('Tips & Tricks', '98', 'Rule of Rose', 0)
INSERT INTO Magazine_Has_a_Game (MagazineName, MagazineVolume, GameName, GuideOrCheats) VALUES
								('Tips & Tricks', '102', 'Pokemon Blue', 0)
INSERT INTO Magazine_Has_a_Game (MagazineName, MagazineVolume, GameName, GuideOrCheats) VALUES
								('Tips & Tricks', '103', 'Gauntlet Legends', 1)
INSERT INTO Magazine_Has_a_Game (MagazineName, MagazineVolume, GameName, GuideOrCheats) VALUES
								('Tips & Tricks', '97', 'Mega Man 2', 1)

--Game Has a Console
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('Rule of Rose', 'Playstation 2')
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('.hack//INFECTION PART 1', 'Playstation 2')
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('LSD: Dream Emulator', 'Playstation')
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('Front Mission 3', 'Playstation')
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('Parasite Eve', 'Playstation')
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('Shenmue', 'Dreamcast')
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('Gauntlet Legends', 'Nintendo 64')
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('Mega Man 2', 'Nintendo Entertainment System')
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('Pokemon Red', 'Gameboy')
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('Pokemon Blue', 'Gameboy')
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('Pokemon Yellow', 'Gameboy')

--Strategy Guides
INSERT INTO Strategy_Guide_Publishers (GuidePublisher) VALUES ('Brady Games')
INSERT INTO Strategy_Guide_Publishers (GuidePublisher) VALUES ('Prima Games')
INSERT INTO Strategy_Guide_Publishers (GuidePublisher) VALUES ('Nintendo')

INSERT INTO Strategy_Guide_Names (GuideName, GuidePublisher) VALUES ('.hack//INFECTION Part 1', 'Brady Games')
INSERT INTO Strategy_Guide_Names (GuideName, GuidePublisher) VALUES ('Front Mission 3', 'Brady Games')
INSERT INTO Strategy_Guide_Names (GuideName, GuidePublisher) VALUES ('Parasite Eve', 'Brady Games')
INSERT INTO Strategy_Guide_Names (GuideName, GuidePublisher) VALUES ('Pokemon Special Edition for Yellow, Red and Blue', 'Nintendo')
INSERT INTO Strategy_Guide_Names (GuideName, GuidePublisher) VALUES ('Pokemon Trading Card Game', 'Prima Games')

INSERT INTO Strategy_Guides (GuideName, GuidePublisher, Condition) VALUES ('.hack//INFECTION Part 1', 'Brady Games', 'Good')
INSERT INTO Strategy_Guides (GuideName, GuidePublisher, Condition) VALUES ('Front Mission 3', 'Brady Games', 'Good')
INSERT INTO Strategy_Guides (GuideName, GuidePublisher, Condition) VALUES ('Parasite Eve', 'Brady Games', 'Good')
INSERT INTO Strategy_Guides (GuideName, GuidePublisher, Condition) VALUES ('Pokemon Special Edition for Yellow, Red and Blue', 'Nintendo', 'Good')
INSERT INTO Strategy_Guides (GuideName, GuidePublisher, Condition) VALUES ('Pokemon Trading Card Game', 'Prima Games', 'Good')

INSERT INTO Game_Has_a_Guide (GameName, GuideName, GuidePublisher) VALUES ('.hack//INFECTION Part 1', '.hack//INFECTION Part 1', 'Brady Games')
INSERT INTO Game_Has_a_Guide (GameName, GuideName, GuidePublisher) VALUES ('Front Mission 3', 'Front Mission 3', 'Brady Games')
INSERT INTO Game_Has_a_Guide (GameName, GuideName, GuidePublisher) VALUES ('Parasite Eve', 'Parasite Eve', 'Brady Games')
INSERT INTO Game_Has_a_Guide (GameName, GuideName, GuidePublisher) VALUES ('Pokemon Red', 'Pokemon Special Edition for Yellow, Red and Blue', 'Nintendo')
INSERT INTO Game_Has_a_Guide (GameName, GuideName, GuidePublisher) VALUES ('Pokemon Blue', 'Pokemon Special Edition for Yellow, Red and Blue', 'Nintendo')
INSERT INTO Game_Has_a_Guide (GameName, GuideName, GuidePublisher) VALUES ('Pokemon Yellow', 'Pokemon Special Edition for Yellow, Red and Blue', 'Nintendo')


-- Queries
-- 1. List all owned games and their attributes: game name, genre, region, console, series, peripherals, rating, condition
SELECT 
    Games.GameName, 
    Game_Names.Rating, 
    Games.Region, 
    Game_Has_a_Console.ModelName, 
    Game_Has_a_Series.Series, 
    Game_Has_a_Peripheral.PeripheralName,
	STRING_AGG(TRIM(Game_Has_Genres.Genre), ', ') AS Genres,
	Games.Condition,
	Games.SealOrCIB,
	Games.Notes
FROM Games
LEFT JOIN Game_Names ON Games.GameName = Game_Names.GameName
LEFT JOIN Game_Has_a_Console ON Games.GameName = Game_Has_a_Console.GameName
LEFT JOIN Game_Has_a_Series ON Games.GameName = Game_Has_a_Series.GameName
LEFT JOIN Game_Has_a_Peripheral ON Games.GameName = Game_Has_a_Peripheral.GameName
LEFT JOIN Game_Has_Genres ON Games.GameName = Game_Has_Genres.GameName
GROUP BY Games.GameName, Game_Names.Rating, Games.Region, Game_Has_a_Console.ModelName, Game_Has_a_Series.Series, Game_Has_a_Peripheral.PeripheralName, Games.Condition, Games.SealOrCIB, Games.Notes

-- 2. List all owned peripherals and their attributes: name, game and/or console
SELECT 
    Peripherals.PeripheralName,
	Game_Has_a_Peripheral.GameName,
	Console_Has_a_Peripheral.ModelName,
	Peripherals.Condition,
	Peripherals.SealOrCIB,
	Peripherals.Notes
FROM Peripherals
LEFT JOIN Game_Has_a_Peripheral ON Peripherals.PeripheralName = Game_Has_a_Peripheral.PeripheralName
LEFT JOIN Console_Has_a_Peripheral ON Peripherals.PeripheralName = Console_Has_a_Peripheral.PeripheralName

-- 3. List all owned consoles and their attributes: model, modded, model number, region, console publisher
SELECT 
    Consoles.ModelName,
	Consoles.isModded,
	Console_Models.ConsolePublisher,
	Consoles.Region,
	Console_Models.ModelNumber,
	Consoles.Condition,
	Consoles.SealOrCIB,
	Consoles.Notes
FROM Consoles
LEFT JOIN Console_Models ON Console_Models.ModelName = Consoles.ModelName

-- 4. List all owned strategy guides and their attributes: guide name, publisher, game, notes
SELECT 
    Strategy_Guides.GuideName,
	Strategy_Guides.GuidePublisher,
	STRING_AGG(TRIM(Game_Has_a_Guide.GameName), ', ') AS Games,
	Strategy_Guides.Condition,
	Strategy_Guides.SealOrCIB,
	Strategy_Guides.Notes
FROM Strategy_Guides
LEFT JOIN Game_Has_a_Guide ON Game_Has_a_Guide.GuideName = Strategy_Guides.GuideName
GROUP BY Strategy_Guides.GuideName,
	Strategy_Guides.GuidePublisher,
	Strategy_Guides.Condition,
	Strategy_Guides.SealOrCIB,
	Strategy_Guides.Notes

-- 5. List all owned magazines and their attributes: name, volume, release date, notes
SELECT 
    Magazines.MagazineName,
	Magazine_Names.MagazineVolume,
	Magazine_Names.ReleaseDate,
	Magazines.Condition,
	Magazines.SealOrCIB,
	Magazines.Notes
FROM Magazines
LEFT JOIN Magazine_Names ON Magazine_Names.MagazineName = Magazines.MagazineName AND Magazines.MagazineVolume = Magazine_Names.MagazineVolume
ORDER BY Magazines.MagazineName, Magazines.MagazineVolume

-- 6. List all attributes for memorabilia: description, series that it is in (and the games in the series) or game , condition
SELECT 
    Memorabilia.Description,
	Memorabilia.Series,
	STRING_AGG(TRIM(Game_Has_a_Series.GameName), ', ') AS SeriesGames,
	Memorabilia.GameName,
	Memorabilia.Condition,
	Memorabilia.SealOrCIB
FROM Memorabilia
LEFT JOIN Game_Has_a_Series ON Game_Has_a_Series.Series = Memorabilia.Series
GROUP BY Memorabilia.Description, Memorabilia.Series, Memorabilia.GameName, Memorabilia.Condition, Memorabilia.SealOrCIB

-- 7. List all attributes for specified game: game name, genre, console, series, peripherals, rating
SELECT DISTINCT
    Games.GameName, 
    Game_Names.Rating, 
    Games.Region, 
    Game_Has_a_Console.ModelName, 
    Game_Has_a_Series.Series, 
    Game_Has_a_Peripheral.PeripheralName,
	STRING_AGG(TRIM(Game_Has_Genres.Genre), ', ') AS Genres
FROM Games
LEFT JOIN Game_Names ON Games.GameName = Game_Names.GameName
LEFT JOIN Game_Has_a_Console ON Games.GameName = Game_Has_a_Console.GameName
LEFT JOIN Game_Has_a_Series ON Games.GameName = Game_Has_a_Series.GameName
LEFT JOIN Game_Has_a_Peripheral ON Games.GameName = Game_Has_a_Peripheral.GameName
LEFT JOIN Game_Has_Genres ON Games.GameName = Game_Has_Genres.GameName
WHERE Games.GameName LIKE 'Rule of Rose'
GROUP BY Games.GameName, Game_Names.Rating, Games.Region, Game_Has_a_Console.ModelName, Game_Has_a_Series.Series, Game_Has_a_Peripheral.PeripheralName


-- Analytical Queries

-- 1. Search magazines and guides by game name for guides for the game
SELECT GameName, MagazineName, MagazineVolume, NULL AS GuidePublisher, NULL AS GuideName
FROM Magazine_Has_a_Game
WHERE Magazine_Has_a_Game.GameName = '.hack//INFECTION Part 1'
AND Magazine_Has_a_Game.GuideOrCheats = 0
UNION
SELECT GameName, NULL AS MagazineName, NULL AS MagazineVolume, GuidePublisher, GuideName
FROM Game_Has_a_Guide
WHERE Game_Has_a_Guide.GameName = '.hack//INFECTION Part 1';

-- 2. Display games for sale (duplicates), condition, and notes
SELECT Games.GameName, Games.Condition, Games.SealOrCIB, Games.Notes
FROM Games,
(
	SELECT Games.GameName AS GameName, COUNT(Games.GameName) AS GameCount
	FROM Games
	GROUP BY Games.GameName
) Duplicates
WHERE Duplicates.GameCount > 1 AND Games.GameName = Duplicates.GameName

-- 3. Find game by playstation 2, fighting, vs, offline, 2 player (there are none)
SELECT	Games.GameName, 
		Game_Has_a_Console.ModelName, 
		STRING_AGG(TRIM(Game_Has_Genres.Genre), ', ') AS Genres,
		Game_Has_Players.MaxPlayerNumber,
		Game_Has_Players.CoOpOrVs,
		Game_Has_Players.OfflineOrOnline
FROM Games
LEFT JOIN Game_Has_a_Console ON Games.GameName = Game_Has_a_Console.GameName
LEFT JOIN Game_Has_Genres ON Games.GameName = Game_Has_Genres.GameName
LEFT JOIN Game_Has_Players ON Games.GameName = Game_Has_Players.GameName
WHERE Game_Has_a_Console.GameName = games.GameName AND Game_Has_a_Console.ModelName = 'Playstation 2'
	AND Game_Has_Genres.GameName = games.GameName AND Game_Has_Genres.Genre = 'Fighting'
	AND Game_Has_Players.GameName = games.GameName AND Game_Has_Players.CoOpOrVs = 'Neither'
		AND Game_Has_Players.MaxPlayerNumber = 2
		AND Game_Has_Players.OfflineOrOnline = 0
GROUP BY 
    Games.GameName, 
    Game_Has_a_Console.ModelName, 
	Game_Has_Players.CoOpOrVs,
	Game_Has_Players.OfflineOrOnline,
	Game_Has_Players.MaxPlayerNumber

-- 4. Find game that has duplicates, horror, on xbox (there are none in the database)
SELECT Games.GameName, Games.Condition, Games.SealOrCIB, Games.Notes
FROM Games, Game_Has_Genres, Game_Has_a_Console,
(
	SELECT Games.GameName AS GameName, COUNT(Games.GameName) AS GameCount
	FROM Games
	GROUP BY Games.GameName
) Duplicates
WHERE Duplicates.GameCount > 1 AND Games.GameName = Duplicates.GameName
	AND Game_Has_Genres.Genre = 'Horror'
	AND Game_Has_a_Console.ModelName LIKE '%xbox%'

-- 5. Find games that cannot be played due to region lock or lack of a console
SELECT DISTINCT Game_Names.GameName, Games.Region AS GameRegion, Consoles.ModelName
FROM Game_Names, Game_Has_a_Console, Games, Consoles
WHERE Game_Names.GameName = Game_Has_a_Console.GameName 
	AND Consoles.ModelName = Game_Has_a_Console.ModelName
	AND Consoles.Region <> Games.Region
	AND Game_Names.GameName = Games.GameName
UNION
SELECT DISTINCT 
    Games.GameName, 
    Games.Region AS GameRegion, 
    Game_Has_a_Console.ModelName
FROM 
    Games
    LEFT JOIN Game_Has_a_Console ON Games.GameName = Game_Has_a_Console.GameName
    LEFT JOIN Consoles ON Consoles.ModelName = Game_Has_a_Console.ModelName
WHERE 
    Consoles.ModelName IS NULL;

-- 6. Find consoles that cannot be played due to region lock
SELECT DISTINCT A.ModelName, A.ConsoleRegion
FROM (
	SELECT DISTINCT Console_Models.ModelName, Consoles.Region AS ConsoleRegion
	FROM Console_Models, Games, Game_Has_a_Console, Consoles
	WHERE Games.GameName = Game_Has_a_Console.GameName 
		AND Console_Models.ModelName = Game_Has_a_Console.ModelName
		AND Consoles.ModelName = Console_Models.ModelName
		AND Consoles.Region <> Games.Region
		) A
WHERE (
	SELECT COUNT(DISTINCT Games.GameName)
	FROM Games, Game_Names
	WHERE Games.Region = A.ConsoleRegion
) = 0