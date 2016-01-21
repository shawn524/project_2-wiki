DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS image CASCADE;
DROP TABLE IF EXISTS page CASCADE;
DROP TABLE IF EXISTS revision CASCADE;
DROP TABLE IF EXISTS tags CASCADE;

CREATE TABLE users (
  user_id                   SERIAL    PRIMARY KEY,
  user_name                 TEXT      NOT NULL UNIQUE,
  user_password             TEXT      NOT NULL,
  user_newpassword          TEXT,
  user_token                TEXT,
  user_email                TEXT      NOT NULL,
  user_editcount            INTEGER
);

CREATE TABLE image (
  img_id                    SERIAL    PRIMARY KEY,
  img_url                   TEXT,
  img_page                  INTEGER,               -- Link to page id
  img_size                  INTEGER   NOT NULL,
  img_width                 INTEGER   NOT NULL,
  img_height                INTEGER   NOT NULL,
  img_description           TEXT      NOT NULL
);

CREATE TABLE page (
  page_id                   SERIAL    PRIMARY KEY,
  page_url                  TEXT,
  page_title                TEXT      NOT NULL,
  page_tag                  INTEGER
);

CREATE TABLE revision (
  rev_id                    SERIAL    PRIMARY KEY,
  rev_page                  INTEGER   NOT NULL,
  rev_user                  INTEGER   NOT NULL,    -- Link to user id
  rev_user_name             TEXT      NOT NULL,    -- Link to user name
  rev_text                  TEXT      NOT NULL,    -- Page content
  rev_markdown              TEXT      NOT NULL,
  rev_created               TIMESTAMPTZ default current_timestamp
);

CREATE TABLE tags (
  tag_id                    SERIAL    PRIMARY KEY,
  tag_name                  TEXT      NOT NULL
);
