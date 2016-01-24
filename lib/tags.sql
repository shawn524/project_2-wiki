DROP TABLE IF EXISTS tags;
CREATE TABLE tags (
  tag_id                    SERIAL    PRIMARY KEY,
  tag_name                  TEXT      NOT NULL
);
INSERT INTO tags (tag_name) VALUES ('Animal');
INSERT INTO tags (tag_name) VALUES ('Place');
INSERT INTO tags (tag_name) VALUES ('Person');
INSERT INTO tags (tag_name) VALUES ('Thing');
