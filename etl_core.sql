-- etl_core.sql
INSERT INTO TelemetryEvent (
    game_id, player_id, sector_id, tic,
    pos_x, pos_y, mom_x, mom_y,
    angle, fov, health, armor, ammo
)
SELECT DISTINCT ON (CAST(game_id_raw AS INT), CAST(player_id_raw AS INT), CAST(tic_raw AS INT))
    CAST(game_id_raw AS INT), CAST(player_id_raw AS INT),
    CAST(NULLIF(sector_id_raw, '') AS INT), CAST(tic_raw AS INT),
    CAST(pos_x_raw AS DOUBLE PRECISION), CAST(pos_y_raw AS DOUBLE PRECISION),
    CAST(NULLIF(mom_x_raw, '') AS DOUBLE PRECISION), CAST(NULLIF(mom_y_raw, '') AS DOUBLE PRECISION),
    CAST(NULLIF(angle_raw, '') AS DOUBLE PRECISION), CAST(NULLIF(fov_raw, '') AS DOUBLE PRECISION),
    CAST(NULLIF(health_raw, '') AS INT), CAST(NULLIF(armor_raw, '') AS INT),
    CAST(NULLIF(ammo_raw, '') AS INT)
FROM staging_telemetry
WHERE game_id_raw IS NOT NULL AND player_id_raw IS NOT NULL AND tic_raw IS NOT NULL
ORDER BY CAST(game_id_raw AS INT), CAST(player_id_raw AS INT), CAST(tic_raw AS INT);
