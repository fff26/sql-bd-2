-- запрос количества исполнителей в каждом жанре
SELECT ag.genre_id, g.genre_name, COUNT(*) AS artist_count
FROM artist_genres ag
JOIN genres g ON ag.genre_id = g.genre_id
GROUP BY ag.genre_id, g.genre_name;

-- запрос кол-ва треков из альбмов определённых годов
SELECT COUNT(*) AS track_count
FROM albums a
JOIN tracks t ON a.album_id = t.album_id
WHERE a.album_year BETWEEN 2019 AND 2020;

-- запрос средней продолжительности трека (в сек.) по каждому альбому
SELECT album_id, AVG(track_duration) AS avg_duration
FROM tracks
GROUP BY album_id;

-- запрос исполнителей не выпускавших альбомы в 2020 году
SELECT artist_name
FROM Artists
WHERE artist_id NOT IN (
    SELECT artist_id
    FROM Artist_albums
    JOIN Albums ON Artist_albums.album_id = Albums.album_id
    WHERE album_year = 2020
);

-- запрос сборников имеющих конкретного исполнителя в составе
-- выдаёт ошибку синтаксиса (примерное положение: ")" - не понимаю почему?!
SELECT DISTINCT collection_title
FROM (
  SELECT *
  FROM Collections
  JOIN UNNEST(Collections.track_id) AS track_id
) AS c
JOIN Tracks ON c.track_id = Tracks.track_id
JOIN Albums ON Tracks.album_id = Albums.album_id
JOIN Artist_albums ON Albums.album_id = Artist_albums.album_id
JOIN Artists ON Artist_albums.artist_id = Artists.artist_id
WHERE artist_name LIKE 'Егор Летов';

-- запрос самого длинного трека
SELECT track_title, track_duration
FROM Tracks
WHERE track_duration = (
  SELECT MAX(track_duration)
  FROM Tracks
);

-- апрос названия треков, продолжительность которых не менее 3,5 минут.
SELECT track_title
FROM Tracks
WHERE track_duration/60 >= 3.5;

-- запрос названий сборников выпущенных в определённом промежутке лет
SELECT collection_title
FROM Collections
WHERE collection_year BETWEEN 2018 AND 2020;

-- запрсос имён артистов из одного слова
SELECT artist_name
FROM Artists
WHERE artist_name LIKE '% %' = false;

-- запрос названий треков со словом мой или my
SELECT track_title
FROM Tracks
WHERE track_title LIKE '%мой%' OR track_title LIKE '%my%' or track_title like 'Мой%' or track_title like 'My%';

-- запрос названий треков, которые не входят в сборники
SELECT track_title
FROM Tracks
WHERE track_id NOT IN (
  SELECT UNNEST(track_id) AS track_id
  FROM Collections
);

-- запрос исполнителя/исполнителей написавших самый короткий трек
SELECT artist_name
FROM Artists
JOIN Artist_albums ON Artists.artist_id = Artist_albums.artist_id
JOIN Tracks ON Artist_albums.album_id = Tracks.album_id
WHERE track_duration = (
  SELECT MIN(track_duration)
  FROM Tracks
);

-- запрос названий альбомов, содержащих наименьшее количество треков.
-- у меня во всех альбомах одинаковое кол-во треков.
SELECT album_title 
FROM Albums 
WHERE album_id IN ( 
  SELECT album_id 
  FROM Tracks 
  GROUP BY album_id 
  HAVING COUNT(*) = ( 
    SELECT MIN(track_count) 
    FROM ( 
      SELECT COUNT(*) AS track_count 
      FROM Tracks 
      GROUP BY album_id 
    ) AS album_track_counts 
  ) 
) 
ORDER BY album_title ASC;