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
(8, 1, 'Visual Aesthetics', 'VISU');
 
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
 
-- Visual Aesthetics
(17, 1, 8, 17, 'I enjoy the game''s graphics.', FALSE),
(18, 1, 8, 18, 'I think the game is visually appealing.', FALSE);
 
-- Resincronizar las secuencias en PostgreSQL para futuros INSERTS
SELECT setval('uxinstrument_instrument_id_seq', (SELECT MAX(instrument_id) FROM UXInstrument));
SELECT setval('uxsubscale_subscale_id_seq', (SELECT MAX(subscale_id) FROM UXSubscale));
SELECT setval('uxitem_item_id_seq', (SELECT MAX(item_id) FROM UXItem));
 

-- ============================================================
-- Respuestas UX: una por usuario para el instrumento GUESS-18
-- Puntajes 1-7 con variación por perfil de experiencia:
--   Advanced (users 3,6): base 6 | Intermediate (1,4): base 5
--   Beginner (2): base 4        | Beginner (5): base 3
-- ============================================================
INSERT INTO UXResponse (response_id, user_id, instrument_id, responded_at) VALUES
(1, 1, 1, '2026-01-15 12:00:00'),
(2, 2, 1, '2026-01-15 12:00:00'),
(3, 3, 1, '2026-01-15 12:00:00'),
(4, 4, 1, '2026-01-15 12:00:00'),
(5, 5, 1, '2026-01-15 12:00:00'),
(6, 6, 1, '2026-01-15 12:00:00');

INSERT INTO UXResponseItem (response_id, item_id, score) VALUES
(1, 1, 6),(1, 2, 4),(1, 3, 4),(1, 4, 6),(1, 5, 5),(1, 6, 4),
(1, 7, 4),(1, 8, 4),(1, 9, 6),(1, 10, 4),(1, 11, 6),(1, 12, 6),
(1, 13, 6),(1, 14, 4),(1, 17, 6),(1, 18, 5),
(2, 1, 3),(2, 2, 3),(2, 3, 3),(2, 4, 3),(2, 5, 3),(2, 6, 5),
(2, 7, 5),(2, 8, 3),(2, 9, 5),(2, 10, 3),(2, 11, 5),(2, 12, 5),
(2, 13, 5),(2, 14, 5),(2, 17, 4),(2, 18, 3),
(3, 1, 6),(3, 2, 7),(3, 3, 6),(3, 4, 5),(3, 5, 5),(3, 6, 7),
(3, 7, 6),(3, 8, 6),(3, 9, 6),(3, 10, 5),(3, 11, 5),(3, 12, 6),
(3, 13, 5),(3, 14, 5),(3, 17, 6),(3, 18, 5),
(4, 1, 5),(4, 2, 5),(4, 3, 6),(4, 4, 5),(4, 5, 4),(4, 6, 6),
(4, 7, 5),(4, 8, 6),(4, 9, 4),(4, 10, 5),(4, 11, 4),(4, 12, 6),
(4, 13, 5),(4, 14, 6),(4, 17, 6),(4, 18, 5),
(5, 1, 4),(5, 2, 2),(5, 3, 4),(5, 4, 2),(5, 5, 2),(5, 6, 4),
(5, 7, 2),(5, 8, 3),(5, 9, 2),(5, 10, 2),(5, 11, 2),(5, 12, 3),
(5, 13, 3),(5, 14, 3),(5, 17, 4),(5, 18, 3),
(6, 1, 5),(6, 2, 6),(6, 3, 6),(6, 4, 5),(6, 5, 7),(6, 6, 6),
(6, 7, 7),(6, 8, 7),(6, 9, 7),(6, 10, 5),(6, 11, 7),(6, 12, 7),
(6, 13, 5),(6, 14, 7),(6, 17, 7),(6, 18, 5);

SELECT setval('uxresponse_response_id_seq', 6);
