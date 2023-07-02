CREATE TABLE if not exists Artists (
  artist_id SERIAL PRIMARY KEY,
  artist_name VARCHAR(255) NOT NULL,
  artist_country VARCHAR(255)
);

CREATE TABLE Genres (
  genre_id SERIAL PRIMARY KEY,
  genre_name VARCHAR(255) NOT NULL
);

CREATE TABLE Albums (
  album_id SERIAL PRIMARY KEY,
  album_title VARCHAR(255) UNIQUE NOT NULL,
  album_year NUMERIC(4) NOT NULL,
  album_cover VARCHAR(255),
  track_id INTEGER[]
);

CREATE TABLE Tracks (
  track_id SERIAL PRIMARY KEY,
  track_title VARCHAR(255) NOT NULL,
  track_duration SMALLINT NOT NULL,
  album_id INTEGER REFERENCES Albums(album_id)
);

CREATE TABLE Collections (
  collection_id SERIAL PRIMARY KEY,
  collection_title VARCHAR(50) NOT NULL,
  collection_year NUMERIC(4) NOT NULL,
  track_id INTEGER[]
);

CREATE TABLE Artist_Genres (
  artist_id INTEGER REFERENCES Artists(artist_id),
  genre_id INTEGER REFERENCES Genres(genre_id),
  PRIMARY KEY (artist_id, genre_id)
);

CREATE TABLE Artist_Albums (
  artist_id INTEGER REFERENCES Artists(artist_id),
  album_id INTEGER REFERENCES Albums(album_id),
  PRIMARY KEY (artist_id, album_id)
);

CREATE TABLE Collection_Tracks (
  collection_id INTEGER REFERENCES Collections(collection_id),
  track_id INTEGER REFERENCES Tracks(track_id),
  PRIMARY KEY (collection_id, track_id)
);

ALTER TABLE Tracks
DROP CONSTRAINT IF EXISTS tracks_album_id_fkey;

ALTER TABLE Tracks
ADD COLUMN collection_id INTEGER REFERENCES Collections(collection_id);

ALTER TABLE Tracks
ADD CONSTRAINT tracks_album_id_fkey
FOREIGN KEY (album_id) REFERENCES Albums(album_id);

ALTER TABLE Tracks
DROP COLUMN collection_id;

CREATE TABLE if not exists Album_Tracks (
  album_id INTEGER REFERENCES Albums(album_id),
  track_id INTEGER REFERENCES Tracks(track_id),
  PRIMARY KEY (album_id, track_id)
);

CREATE OR REPLACE FUNCTION update_album_track_ids()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE Albums
  SET track_id = array_append(track_id, NEW.track_id)
  WHERE album_id = NEW.album_id;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER album_tracks_trigger
AFTER INSERT ON Album_Tracks
FOR EACH ROW
EXECUTE FUNCTION update_album_track_ids();

CREATE OR REPLACE FUNCTION update_collection_track_ids()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE Collections
  SET track_id = array_append(track_id, NEW.track_id)
  WHERE collection_id = NEW.collection_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER collection_tracks_trigger
AFTER INSERT ON Collection_Tracks
FOR EACH ROW
EXECUTE FUNCTION update_collection_track_ids();
