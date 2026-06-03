DB_NAME=chocolate_doom
DB_USER=postgres

reset:
	psql -U $(DB_USER) -c "DROP DATABASE IF EXISTS $(DB_NAME);"
	psql -U $(DB_USER) -c "CREATE DATABASE $(DB_NAME);"

load: reset
	psql -U $(DB_USER) -d $(DB_NAME) -f "DDL proyecto(1).sql"
	psql -U $(DB_USER) -d $(DB_NAME) -f "C3_Views.sql"
	psql -U $(DB_USER) -d $(DB_NAME) -f "parte2_puntoB.sql"
	psql -U $(DB_USER) -d $(DB_NAME) -f "parte_3_puntoB.sql"

views:
	psql -U $(DB_USER) -d $(DB_NAME) -f "C3_Views.sql"

refresh:
	psql -U $(DB_USER) -d $(DB_NAME) -c "REFRESH MATERIALIZED VIEW player_telemetry_summary;"

test:
	psql -U $(DB_USER) -d $(DB_NAME) -c "SELECT * FROM player_game_summary LIMIT 5;"
	psql -U $(DB_USER) -d $(DB_NAME) -c "SELECT * FROM map_activity_summary LIMIT 5;"
