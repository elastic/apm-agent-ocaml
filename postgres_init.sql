CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP TABLE IF EXISTS message;

CREATE TABLE message
(
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  message text,
  created_at timestamp DEFAULT now()
);

INSERT INTO message(message) VALUES ('Hello world!'), ('Welcome to postgres');
