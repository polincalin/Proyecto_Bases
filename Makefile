DB_NAME=doom_db


reset:
	dropdb $(DB_NAME) || true
	createdb $(DB_NAME)
	psql $(DB-NAME) -f ddl.sql
	psql $(DB_NAME) -f parte2_puntoB.sql
	psql $(DB_NAME) -f parte3_puntoB.sql
	psql $(DB_NAME) -f C3_views.sql