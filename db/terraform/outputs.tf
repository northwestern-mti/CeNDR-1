output "db_connection_name" {
  value = google_sql_database_instance.postgres_db_instance.connection_name
}