DROP TABLE IF EXISTS macro_current;
CREATE TABLE macro_current
(
	macro_id	INTEGER PRIMARY KEY,
	macro_name	TEXT,
	definition	TEXT,
	lastuse		REAL DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS macro_user_variables;
CREATE TABLE macro_user_variables
(
	macro_id	INTEGER,
	variable_name	TEXT,
	variable_value	TEXT
);

DROP TABLE IF EXISTS recent_calls;
CREATE TABLE recent_calls
(
	call_time	REAL,
	macro_name	TEXT,
	call_number	TEXT,
	contact_name	TEXT,
	contact_id	INTEGER
);

DROP TABLE IF EXISTS packages;
CREATE TABLE packages
(
	package_id	INTEGER PRIMARY KEY,
	package_name	TEXT
);

DROP TABLE IF EXISTS packages_macros;
CREATE TABLE packages_macros
(
	package_id	INTEGER,
	macro_xml	TEXT,
	macro_name	TEXT
);