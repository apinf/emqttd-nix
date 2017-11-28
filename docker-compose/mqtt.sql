
CREATE TABLE mqtt_user (
  id SERIAL primary key,
  is_superuser boolean,
  username character varying(100),
  clientid character varying(1024),
  ipaddr character varying(100),
  password character varying(100),
  salt character varying(40)
);

CREATE TABLE mqtt_acl (
  id SERIAL primary key,
  allow integer,
  ipaddr character varying(60),
  username character varying(100),
  clientid character varying(1024),
  access  integer,
  topic character varying(100)
);

INSERT INTO mqtt_user (is_superuser, username, clientid, ipaddr, password) VALUES
  ( false, 'username', NULL, NULL, 'password'),
  ( false, 'username', 'client1', '127.0.0.1', 'password'),
  ( false, NULL, 'client2', '127.0.0.1', NULL),
  ( false, 'username', 'client3', NULL, 'password'),
  ( false, 'username', 'client4', '$all', 'password');

INSERT INTO mqtt_acl (id, allow, ipaddr, username, clientid, access, topic)
VALUES
	(1,1,NULL,'$all',NULL,2,'#'),
	(2,0,NULL,'$all',NULL,1,'$SYS/#'),
	(3,0,NULL,'$all',NULL,1,'eq #'),
	(5,1,'127.0.0.1',NULL,NULL,2,'$SYS/#'),
	(6,1,'127.0.0.1',NULL,NULL,2,'#'),
(7,1,NULL,'dashboard',NULL,1,'$SYS/#');
