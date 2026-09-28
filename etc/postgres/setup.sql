SELECT 'CREATE ROLE root' WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'root') \gexec
ALTER ROLE root WITH LOGIN SUPERUSER PASSWORD 'root';

SELECT 'CREATE DATABASE root OWNER root' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'root') \gexec

\connect root
SET client_min_messages = warning;
SET ROLE root;

CREATE TABLE IF NOT EXISTS root (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO root (name) SELECT 'root' WHERE NOT EXISTS (SELECT FROM root);
