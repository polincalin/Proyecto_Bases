
-- 1. Crear tabla de Staging
CREATE TABLE IF NOT EXISTS staging_telemetry (
    game_id_raw      TEXT,
    player_id_raw    TEXT,
    sector_id_raw    TEXT,
    tic_raw          TEXT,
    pos_x_raw        TEXT,
    pos_y_raw        TEXT,
    pos_z_raw        TEXT,
    mom_x_raw        TEXT,
    mom_y_raw        TEXT,
    mom_z_raw        TEXT,
    angle_raw        TEXT,
    fov_raw          TEXT,
    health_raw       TEXT,
    armor_raw        TEXT,
    ammo_raw         TEXT
);

-- 2. Crear tabla de Log de Errores 
CREATE TABLE IF NOT EXISTS ingestion_error_log (
    error_id   SERIAL PRIMARY KEY,
    game_id    TEXT,
    tic        TEXT,
    motivo     TEXT,
    fecha_err  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Proceso ETL 
INSERT INTO ingestion_error_log (game_id, tic, motivo)
SELECT game_id_raw, tic_raw, 'Faltan IDs críticos o TIC'
FROM staging_telemetry
WHERE game_id_raw IS NULL OR player_id_raw IS NULL OR tic_raw IS NULL;

INSERT INTO TelemetryEvent (
    game_id, player_id, sector_id, tic, 
    pos_x, pos_y, pos_z, 
    mom_x, mom_y, mom_z, 
    angle, fov, health, armor, ammo
)
SELECT DISTINCT ON (CAST(game_id_raw AS INT), CAST(player_id_raw AS INT), CAST(tic_raw AS INT))
    CAST(game_id_raw AS INT),
    CAST(player_id_raw AS INT),
    CAST(NULLIF(sector_id_raw, '') AS INT),
    CAST(tic_raw AS INT),
    CAST(pos_x_raw AS DOUBLE PRECISION),
    CAST(pos_y_raw AS DOUBLE PRECISION),
    CAST(pos_z_raw AS DOUBLE PRECISION),
    CAST(NULLIF(mom_x_raw, '') AS DOUBLE PRECISION),
    CAST(NULLIF(mom_y_raw, '') AS DOUBLE PRECISION),
    CAST(NULLIF(mom_z_raw, '') AS DOUBLE PRECISION),
    CAST(NULLIF(angle_raw, '') AS DOUBLE PRECISION),
    CAST(NULLIF(fov_raw, '') AS DOUBLE PRECISION),
    CAST(NULLIF(health_raw, '') AS INT),
    CAST(NULLIF(armor_raw, '') AS INT),
    CAST(NULLIF(ammo_raw, '') AS INT)
FROM staging_telemetry
WHERE game_id_raw IS NOT NULL 
  AND player_id_raw IS NOT NULL 
  AND tic_raw IS NOT NULL
ORDER BY CAST(game_id_raw AS INT), CAST(player_id_raw AS INT), CAST(tic_raw AS INT);

