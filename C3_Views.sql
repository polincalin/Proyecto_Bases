-- C.3 Views and Materialized View
-- This file contains analytical views for frequent queries

-- View 1: Player game summary
CREATE VIEW player_game_summary AS
SELECT
    p.player_id,
    p.nickname,
    COUNT(g.game_id) AS total_games,
    MIN(g.start_time) AS first_game,
    MAX(g.end_time) AS last_game
FROM Player p
JOIN Game g ON p.player_id = g.player_id
GROUP BY p.player_id, p.nickname;


-- View 2: Map & Episode summary
CREATE VIEW map_activity_summary AS
SELECT
    e.episode_id,
    e.name AS episode_name,
    m.map_id,
    m.map_code,
    COUNT(g.game_id) AS total_games
FROM Episode e
JOIN Map m ON e.episode_id = m.episode_id
JOIN Game g ON m.map_id = g.map_id
GROUP BY e.episode_id, e.name, m.map_id, m.map_code;


-- Materialized view: player telemetry summary (Player movement & Telemetry Load)
CREATE MATERIALIZED VIEW player_telemetry_summary AS
SELECT
    g.game_id,
    g.player_id,
    COUNT(t.event_id) AS total_events,
    AVG(t.pos_x) AS avg_pos_x,
    AVG(t.pos_y) AS avg_pos_y,
    AVG(t.health) FILTER (WHERE t.health IS NOT NULL) AS avg_health,
    AVG(t.ammo) FILTER (WHERE t.ammo IS NOT NULL) AS avg_ammo
FROM Game g
JOIN TelemetryEvent t ON g.game_id = t.game_id
GROUP BY g.game_id, g.player_id;

-- Refresh materialized view
-- REFRESH MATERIALIZED VIEW player_telemetry_summary;
