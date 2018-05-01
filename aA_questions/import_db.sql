DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows(
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies(
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes(
  id INTEGER PRIMARY KEY, 
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);


INSERT INTO
  users (fname, lname)
VALUES
  ('Bob', 'An'),
  ('Dan', 'Luo'),
  ('Aakash','Sarang');


INSERT INTO
  questions (title, body, author_id)
VALUES
  ('Q1', 'Which of the following is an example of an RDBMS?',1),
  ('Q2', 'SELECT, UPDATE, and INSERT are keywords used in which of the following?',2),
  ('Q2', 'SELECT, UPDATE, and INSERT are keywords used in which of the following?',3);


INSERT INTO
  replies (question_id, parent_id, user_id, body)
VALUES
  (1, NULL, 1, 'SQLite Oracle Database MySQL PostgreSQL'),
  (1, 1, 1, 'cat pokemon.db sqlite3 | create_tables.sql'),
  (1, 2, 1, 'Data Manipulation Language');
