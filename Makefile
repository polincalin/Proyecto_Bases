DB_NAME=chocolate_doom
DB_USER=postgres

.PHONY: reset generate load views refresh analytics indexes test

reset:
	psql -U $(DB_USER) -c "DROP DATABASE IF EXISTS $(DB_NAME);"
	psql -U $(DB_USER) -c "CREATE DATABASE $(DB_NAME);"

generate:
	python procesar.py Telemetry.tsv \
		--game-id 1 \
		--player-id 1 \
		--map-id 1 \
		--output telemetry.tsv

load: reset
	psql -U $(DB_USER) -d $(DB_NAME) -f "DDL proyecto(1).sql"
	psql -U $(DB_USER) -d $(DB_NAME) -f "master_data.sql"
	psql -U $(DB_USER) -d $(DB_NAME) -f "parte_3_puntoB.sql"
	psql -U $(DB_USER) -d $(DB_NAME) -f "parte2_puntoB.sql"
	psql -U $(DB_USER) -d $(DB_NAME) -c "\copy staging_telemetry FROM 'telemetry.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER true);"
	psql -U $(DB_USER) -d $(DB_NAME) -f "etl_core.sql"
	psql -U $(DB_USER) -d $(DB_NAME) -f "C3_Views.sql"
	psql -U $(DB_USER) -d $(DB_NAME) -f "consultas_analiticas.sql"
	psql -U $(DB_USER) -d $(DB_NAME) -f "indices_evaluacion.sql"

views:
	psql -U $(DB_USER) -d $(DB_NAME) -f "C3_Views.sql"

refresh:
	psql -U $(DB_USER) -d $(DB_NAME) -c "REFRESH MATERIALIZED VIEW player_telemetry_summary;"

analytics:
	psql -U $(DB_USER) -d $(DB_NAME) -f "consultas_analiticas.sql"

indexes:
	psql -U $(DB_USER) -d $(DB_NAME) -f "indices_evaluacion.sql"

test:
	psql -U $(DB_USER) -d $(DB_NAME) -c "SELECT * FROM player_game_summary LIMIT 5;"
	psql -U $(DB_USER) -d $(DB_NAME) -c "SELECT * FROM map_activity_summary LIMIT 5;"
