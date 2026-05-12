-- 1. Insertar el instrumento GUESS-18
INSERT INTO UXInstrument (instrument_id, name, version, scale_min, scale_max) 
VALUES (1, 'GUESS', '18-Item Short Scale', 1, 7);
 
-- 2. Insertar las 9 Subescalas oficiales del GUESS-18
INSERT INTO UXSubscale (subscale_id, instrument_id, name, code) VALUES 
(1, 1, 'Usability/Playability', 'USAB'),
(2, 1, 'Narratives', 'NARR'),
(3, 1, 'Play Engrossment', 'ENGR'),
(4, 1, 'Enjoyment', 'ENJO'),
(5, 1, 'Creative Freedom', 'CREA'),
(6, 1, 'Audio Aesthetics', 'AUDI'),
(7, 1, 'Personal Gratification', 'GRAT'),
(8, 1, 'Social Connectivity', 'SOCI'),
(9, 1, 'Visual Aesthetics', 'VISU');
 
-- 3. Insertar los 18 ítems (2 por subescala)
INSERT INTO UXItem (item_id, instrument_id, subscale_id, item_number, question_text, is_reverse_scored) VALUES 
-- Usability/Playability
(1, 1, 1, 1, 'I find the controls of the game to be straightforward.', FALSE),
(2, 1, 1, 2, 'I find the game''s interface to be easy to navigate.', FALSE),
 
-- Narratives
(3, 1, 2, 3, 'I am captivated by the game''s story from the beginning.', FALSE),
(4, 1, 2, 4, 'I enjoy the fantasy or story provided by the game.', FALSE),
 
-- Play Engrossment
(5, 1, 3, 5, 'I feel detached from the outside world while playing the game.', FALSE),
(6, 1, 3, 6, 'I do not care to check events that are happening in the real world during the game.', FALSE),
 
-- Enjoyment
(7, 1, 4, 7, 'I think the game is fun.', FALSE),
(8, 1, 4, 8, 'I feel bored while playing the game.', TRUE),
 
-- Creative Freedom
(9, 1, 5, 9, 'I feel the game allows me to be imaginative.', FALSE),
(10, 1, 5, 10, 'I feel creative while playing the game.', FALSE),
 
-- Audio Aesthetics
(11, 1, 6, 11, 'I enjoy the sound effects in the game.', FALSE),
(12, 1, 6, 12, 'I feel the game''s audio (e.g., sound effects, music) enhances my gaming experience.', FALSE),
 
-- Personal Gratification
(13, 1, 7, 13, 'I am very focused on my own performance while playing the game.', FALSE),
(14, 1, 7, 14, 'I want to do as well as possible during the game.', FALSE),
 
-- Social Connectivity (Clave para detectar cooperación/sabotaje)
(15, 1, 8, 15, 'I find the game supports social interaction (e.g., chat) between players.', FALSE),
(16, 1, 8, 16, 'I like to play this game with other players.', FALSE),
 
-- Visual Aesthetics
(17, 1, 9, 17, 'I enjoy the game''s graphics.', FALSE),
(18, 1, 9, 18, 'I think the game is visually appealing.', FALSE);
 
-- Resincronizar las secuencias en PostgreSQL para futuros INSERTS
SELECT setval('uxinstrument_instrument_id_seq', (SELECT MAX(instrument_id) FROM UXInstrument));
SELECT setval('uxsubscale_subscale_id_seq', (SELECT MAX(subscale_id) FROM UXSubscale));
SELECT setval('uxitem_item_id_seq', (SELECT MAX(item_id) FROM UXItem));
 