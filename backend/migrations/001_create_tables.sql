-- migrations/001_create_tables.sql

-- 1. Users
CREATE TABLE IF NOT EXISTS users (
  id             SERIAL      PRIMARY KEY,
  username       TEXT        NOT NULL UNIQUE,
  password       TEXT        NOT NULL,
  first_name     TEXT,
  last_name      TEXT,
  phone          TEXT,
  email          TEXT,
  is_manager     BOOLEAN     DEFAULT FALSE
);

-- 2. Parkings
CREATE TABLE IF NOT EXISTS parkings (
  id               SERIAL           PRIMARY KEY,
  address          TEXT,
  latitude         DOUBLE PRECISION,
  longitude        DOUBLE PRECISION,
  rating           REAL,
  hourly_rate      TEXT,
  phone            TEXT,
  whatsapp         TEXT,
  opening_time     TIME,
  closing_time     TIME,
  payment_methods  TEXT
);
