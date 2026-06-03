-- ============================================================
--  consultas_analiticas.sql
--  Entrega 3 - Proyecto Telemetria y UX Chocolate-Doom
--  6 consultas analiticas sobre el esquema corregido.
--  Nota: en este esquema un game_id es una SESION COMPARTIDA;
--  cada participante es una fila (game_id, player_id) en Game y
--  cada evento de telemetria trae (game_id, player_id, tic).
-- ============================================================


-- ------------------------------------------------------------
-- Consulta 1: Promedio de duracion de las sesiones por mapa
-- Idea: AVG sobre (end_time - start_time) de cada participacion
--       de partida, agrupado por mapa (y su episodio).
-- ------------------------------------------------------------
SELECT
    m.map_id,
    m.map_code,
    e.name                              AS episodio,
    COUNT(*)                            AS sesiones,
    AVG(g.end_time - g.start_time)      AS duracion_promedio
FROM Game g
JOIN Map     m ON g.map_id = m.map_id
JOIN Episode e ON m.episode_id = e.episode_id
WHERE g.end_time IS NOT NULL
GROUP BY m.map_id, m.map_code, e.name
ORDER BY duracion_promedio DESC;


-- ------------------------------------------------------------
-- Consulta 2: Jugadores con la mayor proximidad promedio
-- Idea: auto-join de TelemetryEvent por (game_id, tic). Se calcula
--       la distancia euclidiana entre cada par de jugadores en el
--       mismo instante y se promedia por par. Menor distancia
--       promedio = mayor proximidad (se ordena ascendente).
-- ------------------------------------------------------------
SELECT
    a.player_id AS jugador_a,
    b.player_id AS jugador_b,
    COUNT(*)    AS tics_comparados,
    ROUND(AVG(sqrt(power(a.pos_x - b.pos_x, 2)
                 + power(a.pos_y - b.pos_y, 2)))::numeric, 2) AS distancia_promedio
FROM TelemetryEvent a
JOIN TelemetryEvent b
       ON a.game_id = b.game_id
      AND a.tic     = b.tic
      AND a.player_id < b.player_id          -- evita duplicar el par y auto-comparaciones
GROUP BY a.player_id, b.player_id
ORDER BY distancia_promedio ASC;             -- los mas proximos primero


-- ------------------------------------------------------------
-- Consulta 3: Distancia de trayectoria mas corta y mas larga por
--             jugador  (¡usa funciones de ventana -> puntos extra!)
-- Idea: LAG() ordena por tic dentro de cada (game_id, player_id) y
--       toma la posicion anterior; se suman las distancias entre
--       tics consecutivos para obtener la longitud de cada
--       trayectoria, y luego MIN/MAX por jugador.
-- ------------------------------------------------------------
WITH pasos AS (
    SELECT
        game_id, player_id, tic, pos_x, pos_y,
        LAG(pos_x) OVER w AS px_prev,
        LAG(pos_y) OVER w AS py_prev
    FROM TelemetryEvent
    WINDOW w AS (PARTITION BY game_id, player_id ORDER BY tic)
),
dist_por_partida AS (
    SELECT
        game_id, player_id,
        SUM(sqrt(power(pos_x - px_prev, 2) + power(pos_y - py_prev, 2))) AS dist_total
    FROM pasos
    WHERE px_prev IS NOT NULL
    GROUP BY game_id, player_id
)
SELECT
    player_id,
    COUNT(*)                          AS partidas_jugadas,
    ROUND(MIN(dist_total)::numeric, 2) AS trayectoria_min,
    ROUND(MAX(dist_total)::numeric, 2) AS trayectoria_max
FROM dist_por_partida
GROUP BY player_id
ORDER BY player_id;


-- ------------------------------------------------------------
-- Consulta 4: Respuestas de encuestas UX para jugadores con
--             duracion de trayectoria por encima del promedio
-- Idea: la "duracion de trayectoria" se mide como el total de tics
--       registrados por jugador. Se calcula el promedio global y se
--       seleccionan los jugadores por encima de el; luego se unen a
--       sus respuestas UX (promedio por subescala GUESS-18).
-- ------------------------------------------------------------
WITH duracion AS (
    SELECT player_id, COUNT(*) AS tics_totales
    FROM TelemetryEvent
    GROUP BY player_id
),
promedio AS (
    SELECT AVG(tics_totales) AS media_global FROM duracion
)
SELECT
    p.player_id,
    p.nickname,
    d.tics_totales,
    s.code                       AS subescala,
    ROUND(AVG(ri.score), 2)      AS puntaje_promedio
FROM duracion d
CROSS JOIN promedio pr
JOIN Player          p  ON p.player_id   = d.player_id
JOIN UXResponse      r  ON r.user_id     = p.user_id
JOIN UXResponseItem  ri ON ri.response_id = r.response_id
JOIN UXItem          i  ON i.item_id     = ri.item_id
JOIN UXSubscale      s  ON s.subscale_id = i.subscale_id
WHERE d.tics_totales > pr.media_global
GROUP BY p.player_id, p.nickname, d.tics_totales, s.code
ORDER BY p.player_id, s.code;


-- ------------------------------------------------------------
-- Consulta 5: Sector mas visitado (Hotspot) por episodio y mapa
-- Idea: se cuentan los eventos por (episodio, mapa, sector) y se usa
--       ROW_NUMBER() para quedarse con el sector mas frecuente de
--       cada combinacion episodio-mapa.
-- ------------------------------------------------------------
WITH conteo AS (
    SELECT
        e.episode_id, e.name AS episodio,
        m.map_id, m.map_code,
        t.sector_id,
        COUNT(*) AS visitas,
        ROW_NUMBER() OVER (PARTITION BY e.episode_id, m.map_id
                           ORDER BY COUNT(*) DESC) AS rn
    FROM TelemetryEvent t
    JOIN Game    g ON g.game_id = t.game_id AND g.player_id = t.player_id
    JOIN Map     m ON m.map_id  = g.map_id
    JOIN Episode e ON e.episode_id = m.episode_id
    WHERE t.sector_id IS NOT NULL
    GROUP BY e.episode_id, e.name, m.map_id, m.map_code, t.sector_id
)
SELECT episodio, map_code, sector_id AS sector_hotspot, visitas
FROM conteo
WHERE rn = 1
ORDER BY episodio, map_code;


-- ------------------------------------------------------------
-- Consulta 6: Numero de tics donde los jugadores estuvieron juntos
--             en un mismo sector
-- Idea: auto-join por (game_id, tic, sector_id) entre jugadores
--       distintos; COUNT(DISTINCT tic) mide la duracion del
--       solapamiento en el mismo sector.
-- ------------------------------------------------------------
SELECT
    a.game_id,
    a.player_id AS jugador_a,
    b.player_id AS jugador_b,
    COUNT(DISTINCT a.tic) AS tics_juntos
FROM TelemetryEvent a
JOIN TelemetryEvent b
       ON a.game_id   = b.game_id
      AND a.tic       = b.tic
      AND a.sector_id = b.sector_id
      AND a.player_id < b.player_id
GROUP BY a.game_id, a.player_id, b.player_id
ORDER BY tics_juntos DESC;
