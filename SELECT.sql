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
SELECT DISTINCT c.collection_title
FROM Collections c
JOIN Collection_Tracks ct ON ct.collection_id = c.collection_id
JOIN Tracks t ON t.track_id = ct.track_id
JOIN Albums a ON a.album_id = t.album_id
JOIN Artist_albums aa ON aa.album_id = a.album_id
JOIN Artists ar ON ar.artist_id = aa.artist_id
WHERE ar.artist_name = 'Егор Летов';

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
WHERE track_title LIKE '% мой %' 
   OR track_title LIKE '% my %' 
   OR track_title LIKE 'мой %' 
   OR track_title LIKE 'my %'
   OR track_title LIKE '% Мой %' 
   OR track_title LIKE '% My %' 
   OR track_title LIKE 'Мой %' 
   OR track_title LIKE 'My %';
  
-- запрос названий треков, которые не входят в сборники
SELECT t.track_title
FROM Tracks t
LEFT JOIN Collection_Tracks ct ON t.track_id = ct.track_id
WHERE ct.track_id IS NULL;

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
