--
-- Para testar o MySQL
--
CREATE TABLE IF NOT EXISTS CRUDClass (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  email varchar(255) NOT NULL,
  PRIMARY KEY (id)
);

INSERT INTO CRUDClass VALUES(NULL,'Name 1','name1@email.com');
INSERT INTO CRUDClass VALUES(NULL,'Name 2','name2@email.com');
INSERT INTO CRUDClass VALUES(NULL,'Name 3','name3@email.com');
COMMIT;
