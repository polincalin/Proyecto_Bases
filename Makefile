DB_NAME=chocolate_doom
DB_USER=postgres

setup:
	psql -U $(DB_USER) -c "DROP DATABASE IF EXISTS $(DB_NAME);"
	psql -U $(DB_USER) -c "CREATE DATABASE $(DB_NAME);"
	psql -U $(DB_USER) -d $(DB_NAME) -f DDL.sql
	psql -U $(DB_USER) -d $(DB_NAME) -f C3_views.sql
	psql -U $(DB_USER) -d $(DB_NAME) -f parte2.sql
	psql -U $(DB_USER) -d $(DB_NAME) -f parte3.sql

views:
	psql -U $(DB_USER) -d $(DB_NAME) -f C3_views.sql

refresh:
	psql -U $(DB_USER) -d $(DB_NAME) -c "REFRESH MATERIALIZED VIEW player_telemetry_summary;"

test:
	psql -U $(DB_USER) -d $(DB_NAME) -c "SELECT * FROM player_game_summary LIMIT 5;"
	psql -U $(DB_USER) -d $(DB_NAME) -c "SELECT * FROM map_activity_summary LIMIT 5;"
