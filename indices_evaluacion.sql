-- ============================================================
--  indices_evaluacion.sql
--  Entrega 3 - Definicion y evaluacion de 3 indices.
--  Para cada indice se muestra EXPLAIN (ANALYZE, BUFFERS) ANTES y
--  DESPUES de crearlo, sobre una consulta representativa.
--
--  Nota importante: la restriccion UNIQUE uq_telem(game_id, player_id,
--  tic) YA crea un indice btree sobre esas columnas, y la PK de Game
--  (game_id, player_id) crea uno con game_id como lider. Esto se tiene
--  en cuenta al elegir los indices para NO duplicar lo que ya existe:
--    * idx_telemetry_game_tic usa (game_id, tic) -en vez de
--      (game_id, player_id, tic)- para no duplicar uq_telem.
--    * idx_game_player usa player_id como lider (la PK no lo cubre).
--
--  Sugerencia: ejecutar con  psql -e -f indices_evaluacion.sql > salida.txt
-- ============================================================

\timing on

-- Asegura un punto de partida limpio
DROP INDEX IF EXISTS idx_telemetry_game_tic;
DROP INDEX IF EXISTS idx_telemetry_sector;
DROP INDEX IF EXISTS idx_game_player;


-- ############################################################
-- INDICE 1: idx_telemetry_game_tic  ->  TelemetryEvent(game_id, tic)
-- Justificacion: acelera las consultas TEMPORALES de una sesion
-- (reconstruir la trayectoria de una partida ordenada por tic) y los
-- auto-joins de proximidad/co-presencia que emparejan por (game_id, tic).
-- Consulta representativa: proximidad dentro de una sola partida.
-- ############################################################

-- ---- ANTES ----
EXPLAIN (ANALYZE, BUFFERS)
SELECT a.player_id, b.player_id,
       AVG(sqrt(power(a.pos_x-b.pos_x,2)+power(a.pos_y-b.pos_y,2)))
FROM TelemetryEvent a
JOIN TelemetryEvent b
  ON a.game_id=b.game_id AND a.tic=b.tic AND a.player_id<b.player_id
WHERE a.game_id = 1
GROUP BY a.player_id, b.player_id;

CREATE INDEX idx_telemetry_game_tic ON TelemetryEvent(game_id, tic);
ANALYZE TelemetryEvent;

-- ---- DESPUES ----
EXPLAIN (ANALYZE, BUFFERS)
SELECT a.player_id, b.player_id,
       AVG(sqrt(power(a.pos_x-b.pos_x,2)+power(a.pos_y-b.pos_y,2)))
FROM TelemetryEvent a
JOIN TelemetryEvent b
  ON a.game_id=b.game_id AND a.tic=b.tic AND a.player_id<b.player_id
WHERE a.game_id = 1
GROUP BY a.player_id, b.player_id;


-- ############################################################
-- INDICE 2: idx_telemetry_sector  ->  TelemetryEvent(sector_id)
-- Justificacion: acelera los filtros y busquedas SELECTIVAS por sector
-- (consultas de hotspots puntuales y la co-presencia filtrada por sector).
-- Consulta representativa: eventos registrados en un sector concreto.
-- ############################################################

-- ---- ANTES ----
EXPLAIN (ANALYZE, BUFFERS)
SELECT sector_id, COUNT(*)
FROM TelemetryEvent
WHERE sector_id = 655
GROUP BY sector_id;

CREATE INDEX idx_telemetry_sector ON TelemetryEvent(sector_id);
ANALYZE TelemetryEvent;

-- ---- DESPUES ----
EXPLAIN (ANALYZE, BUFFERS)
SELECT sector_id, COUNT(*)
FROM TelemetryEvent
WHERE sector_id = 655
GROUP BY sector_id;


-- ############################################################
-- INDICE 3: idx_game_player  ->  Game(player_id)
-- Justificacion: la PK de Game es (game_id, player_id), por lo que NO
-- existe indice con player_id como lider. Este indice acelera las
-- busquedas y uniones centradas en el jugador (consultas 3 y 4) y es un
-- requisito de ESCALABILIDAD: hoy Game tiene 28 filas y el planificador
-- usa Seq Scan, pero a medida que crezcan las partidas el indice evita
-- recorrer toda la tabla.
-- Consulta representativa: todas las partidas de un jugador.
-- ############################################################

-- ---- ANTES ----
EXPLAIN (ANALYZE, BUFFERS)
SELECT g.game_id, g.map_id, g.start_time
FROM Game g
WHERE g.player_id = 3;

CREATE INDEX idx_game_player ON Game(player_id);
ANALYZE Game;

-- ---- DESPUES (eleccion automatica del planificador) ----
EXPLAIN (ANALYZE, BUFFERS)
SELECT g.game_id, g.map_id, g.start_time
FROM Game g
WHERE g.player_id = 3;

-- ---- DESPUES (forzando el uso del indice para evidenciar que es usable) ----
SET enable_seqscan = off;
EXPLAIN (ANALYZE, BUFFERS)
SELECT g.game_id, g.map_id, g.start_time
FROM Game g
WHERE g.player_id = 3;
SET enable_seqscan = on;

\timing off
