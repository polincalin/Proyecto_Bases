-- 1. AppUser
CREATE TABLE AppUser (
    user_id SERIAL PRIMARY KEY,
    age INTEGER,
    gender VARCHAR(50),
    experience_level VARCHAR(50),
    consent BOOLEAN NOT NULL DEFAULT FALSE
);

-- 2. Player 
CREATE TABLE Player (
    player_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES AppUser(user_id),
    nickname VARCHAR(100) NOT NULL
);

-- 3. Episode
CREATE TABLE Episode (
    episode_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- 4. Map
CREATE TABLE Map (
    map_id SERIAL PRIMARY KEY,
    episode_id INTEGER REFERENCES Episode(episode_id),
    map_code VARCHAR(50) NOT NULL
);

-- 5. Sector
CREATE TABLE Sector (
    sector_id SERIAL PRIMARY KEY,
    map_id INTEGER REFERENCES Map(map_id),
    grid_x INTEGER,
    grid_y INTEGER
);

-- 6. Game
CREATE TABLE Game (
    game_id SERIAL PRIMARY KEY,
    map_id INTEGER REFERENCES Map(map_id),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP
);

-- 7. GameParticipant 
CREATE TABLE GameParticipant (
    game_id INTEGER REFERENCES Game(game_id),
    player_id INTEGER REFERENCES Player(player_id),
    PRIMARY KEY (game_id, player_id)
);

-- 8. TelemetryEvent 
CREATE TABLE TelemetryEvent (
    event_id BIGSERIAL PRIMARY KEY,
    game_id INTEGER REFERENCES Game(game_id),
    player_id INTEGER REFERENCES Player(player_id),
    sector_id INTEGER REFERENCES Sector(sector_id),
    tic INTEGER NOT NULL,
    pos_x DOUBLE PRECISION NOT NULL,
    pos_y DOUBLE PRECISION NOT NULL,
    pos_z DOUBLE PRECISION NOT NULL,
    mom_x DOUBLE PRECISION,
    mom_y DOUBLE PRECISION,
    mom_z DOUBLE PRECISION,
    angle DOUBLE PRECISION,
    fov DOUBLE PRECISION,
    health INTEGER,
    armor INTEGER,
    ammo INTEGER,
    CONSTRAINT uq_game_player_tic UNIQUE (game_id, player_id, tic)
);

-- 9. UXInstrument (Metadatos GUESS-18)
CREATE TABLE UXInstrument (
    instrument_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    version VARCHAR(50),
    scale_min INTEGER,
    scale_max INTEGER
);

-- 10. UXSubscale
CREATE TABLE UXSubscale (
    subscale_id SERIAL PRIMARY KEY,
    instrument_id INTEGER REFERENCES UXInstrument(instrument_id),
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20)
);

-- 11. UXItem
CREATE TABLE UXItem (
    item_id SERIAL PRIMARY KEY,
    instrument_id INTEGER REFERENCES UXInstrument(instrument_id),
    subscale_id INTEGER REFERENCES UXSubscale(subscale_id),
    item_number INTEGER NOT NULL,
    question_text TEXT NOT NULL,
    is_reverse_scored BOOLEAN DEFAULT FALSE
);

-- 12. UXResponse
CREATE TABLE UXResponse (
    response_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES AppUser(user_id),
    instrument_id INTEGER REFERENCES UXInstrument(instrument_id),
    responded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 13. UXResponseItem
CREATE TABLE UXResponseItem (
    response_id INTEGER REFERENCES UXResponse(response_id),
    item_id INTEGER REFERENCES UXItem(item_id),
    score INTEGER NOT NULL,
    PRIMARY KEY (response_id, item_id)
);