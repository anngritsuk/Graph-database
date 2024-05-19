USE master;
DROP DATABASE IF EXISTS MusicWorld;

CREATE DATABASE MusicWorld;
USE MusicWorld;

--Таблицы узлов
CREATE TABLE Musician
(
id INT NOT NULL PRIMARY KEY,
name NVARCHAR(30) NOT NULL
) AS NODE;

CREATE TABLE Band
(
id INT NOT NULL PRIMARY KEY,
name NVARCHAR(30) NOT NULL
) AS NODE;

CREATE TABLE ConcertHall
(
id INT NOT NULL PRIMARY KEY,
name NVARCHAR(30) NOT NULL,
city NVARCHAR(30) NOT NULL
) AS NODE;
--Таблицы рёбер
CREATE TABLE PlaysIn AS EDGE;

CREATE TABLE PerformsIn AS EDGE;

CREATE TABLE LocatedIn AS EDGE;

--Заполнение таблиц узлов
INSERT INTO Musician (id, name)
VALUES (1, N'Джон'),
       (2, N'Пол'),
       (3, N'Джордж'),
       (4, N'Ринго'),
       (5, N'Мик'),
       (6, N'Кит'),
       (7, N'Чарли'),
       (8, N'Ронни');

	   INSERT INTO Band (id, name)
VALUES (1, N'Битлз'),
       (2, N'Роллинг Стоунз');

INSERT INTO ConcertHall (id, name, city)
VALUES (1, N'Мэдисон Сквер Гарден', N'Нью-Йорк'),
       (2, N'О2 Арена', N'Лондон'),
       (3, N'Будокан', N'Токио');

	   --Заполнение таблиц рёбер
INSERT INTO PlaysIn ($from_id, $to_id)
VALUES ((SELECT $node_id FROM Musician WHERE id = 1),
        (SELECT $node_id FROM Band WHERE id = 1)),
       ((SELECT $node_id FROM Musician WHERE id = 2),
        (SELECT $node_id FROM Band WHERE id = 1)),
       ((SELECT $node_id FROM Musician WHERE id = 3),
        (SELECT $node_id FROM Band WHERE id = 1)),
       ((SELECT $node_id FROM Musician WHERE id = 4),
        (SELECT $node_id FROM Band WHERE id = 1)),
       ((SELECT $node_id FROM Musician WHERE id = 5),
        (SELECT $node_id FROM Band WHERE id = 2)),
       ((SELECT $node_id FROM Musician WHERE id = 6),
        (SELECT $node_id FROM Band WHERE id = 2)),
       ((SELECT $node_id FROM Musician WHERE id = 7),
        (SELECT $node_id FROM Band WHERE id = 2)),
       ((SELECT $node_id FROM Musician WHERE id = 8),
        (SELECT $node_id FROM Band WHERE id = 2));

INSERT INTO PerformsIn ($from_id, $to_id)
VALUES ((SELECT $node_id FROM Band WHERE id = 1),
        (SELECT $node_id FROM ConcertHall WHERE id = 1)),
       ((SELECT $node_id FROM Band WHERE id = 1),
        (SELECT $node_id FROM ConcertHall WHERE id = 2)),
       ((SELECT $node_id FROM Band WHERE id = 1),
        (SELECT $node_id FROM ConcertHall WHERE id = 3)),
       ((SELECT $node_id FROM Band WHERE id = 2),
        (SELECT $node_id FROM ConcertHall WHERE id = 1)),
       ((SELECT $node_id FROM Band WHERE id = 2),
        (SELECT $node_id FROM ConcertHall WHERE id = 2)),
       ((SELECT $node_id FROM Band WHERE id = 2),
        (SELECT $node_id FROM ConcertHall WHERE id = 3));

INSERT INTO LocatedIn ($from_id, $to_id)
VALUES ((SELECT $node_id FROM ConcertHall WHERE id = 1),
        (SELECT $node_id FROM Band WHERE id = 1)),
       ((SELECT $node_id FROM ConcertHall WHERE id = 2),
        (SELECT $node_id FROM Band WHERE id = 1)),
       ((SELECT $node_id FROM ConcertHall WHERE id = 3),
        (SELECT $node_id FROM Band WHERE id = 1)),
       ((SELECT $node_id FROM ConcertHall WHERE id = 1),
        (SELECT $node_id FROM Band WHERE id = 2)),
       ((SELECT $node_id FROM ConcertHall WHERE id = 2),
        (SELECT $node_id FROM Band WHERE id = 2)),
       ((SELECT $node_id FROM ConcertHall WHERE id = 3),
        (SELECT $node_id FROM Band WHERE id = 2));
GO

--Запросы с Match
-- Узнаем, в каких группах играет Джон
SELECT Band.name AS band
FROM Musician AS musician , PlaysIn , Band
WHERE MATCH(musician-(PlaysIn)->Band)
      AND musician.name = N'Джон';

-- Узнаем, в каких концертных залах выступает группа "Битлз"
SELECT ConcertHall.name AS concert_hall
FROM Band AS band , PerformsIn , ConcertHall
WHERE MATCH(band-(PerformsIn)->ConcertHall)
      AND band.name = N'Битлз';

--Узнаем, какие музыканты играют в группе “Роллинг Стоунз”
SELECT Musician.name AS musician
FROM Band AS band , PlaysIn , Musician
WHERE MATCH(band-(PlaysIn)->Musician)
      AND band.name = N'Роллинг Стоунз';

--Узнаем, какие группы выступают в “О2 Арена”
SELECT Band.name AS band
FROM ConcertHall AS concert_hall , PerformsIn , Band
WHERE MATCH(concert_hall-(PerformsIn)->Band)
      AND concert_hall.name = N'О2 Арена';

-- Узнаем, какие группы выступают в "Мэдисон Сквер Гарден"
SELECT Band.name AS band
FROM ConcertHall AS concert_hall , LocatedIn , Band
WHERE MATCH(concert_hall-(LocatedIn)->Band)
      AND concert_hall.name = N'Мэдисон Сквер Гарден';

--Запросы с SHORTEST_PATH

--С кем может познакомиться Джон (id = 1)
SELECT Musician1.name AS MusicianName
	  , STRING_AGG(Musician2.name, '->') WITHIN GROUP (GRAPH PATH) AS Friends
FROM Musician AS Musician1
     , PlaysIn FOR PATH AS pi
     , Musician FOR PATH AS Musician2
WHERE MATCH(SHORTEST_PATH(Musician1(-(pi)->Musician2)+))
            AND Musician1.id = 1;

--С кем может познакомиться Джон (id = 1) за 3 шага
SELECT Musician1.name AS MusicianName
	  , STRING_AGG(Musician2.name, '->') WITHIN GROUP (GRAPH PATH) AS Friends
FROM Musician AS Musician1
     , PlaysIn FOR PATH AS pi
     , Musician FOR PATH AS Musician2
WHERE MATCH(SHORTEST_PATH(Musician1(-(pi)->Musician2){1,3}))
            AND Musician1.id = 1;




GO

