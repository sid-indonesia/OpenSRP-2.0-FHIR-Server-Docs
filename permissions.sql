-- ATTENTION!
-- All commands must be executed while connected to the right database cluster. Make sure of it.

@unset schemaName

CREATE USER "${userName}" WITH ENCRYPTED PASSWORD '${password}';

-- Read-only
GRANT CONNECT ON
DATABASE ${databaseName} TO "${userName}";

GRANT USAGE ON
SCHEMA
${schemaName}
TO "${userName}";

GRANT
SELECT
	ON
	ALL TABLES IN SCHEMA
    ${schemaName}
TO "${userName}";

ALTER DEFAULT PRIVILEGES IN SCHEMA
${schemaName}
GRANT
SELECT
	ON
	TABLES TO "${userName}";

--
--
-- Grant All Privileges (Remember to connect to the correct DB first)

-- Run these as member of `cloudsqlsuperuser` or the owner
GRANT ALL PRIVILEGES ON
DATABASE ${databaseName} TO "${userName}";

GRANT ALL ON
SCHEMA
${schemaName}
TO "${userName}";

ALTER DEFAULT PRIVILEGES
IN SCHEMA ${schemaName}
GRANT ALL PRIVILEGES ON
TABLES TO "${userName}";

-- Run these as the owner
GRANT ALL PRIVILEGES ON
ALL TABLES IN SCHEMA ${schemaName} TO "${userName}";

GRANT ALL PRIVILEGES ON
ALL SEQUENCES IN SCHEMA ${schemaName} TO "${userName}";

--
--
-- Revoke All Privileges
REVOKE ALL PRIVILEGES ON
DATABASE ${databaseName} FROM "${userName}";

REVOKE ALL PRIVILEGES ON
SCHEMA
${schemaName}
FROM "${userName}";

ALTER DEFAULT PRIVILEGES
IN SCHEMA ${schemaName}
REVOKE ALL PRIVILEGES ON
TABLES FROM "${userName}";

REVOKE ALL PRIVILEGES ON
ALL TABLES IN SCHEMA ${schemaName} FROM "${userName}";

REVOKE ALL PRIVILEGES ON
ALL SEQUENCES IN SCHEMA ${schemaName} FROM "${userName}";

--
--
-- Related to https://github.com/sid-indonesia/it-team/issues/80
-- Revoke `cloudsqlsuperuser` from users created through Google Cloud SQL console
REVOKE cloudsqlsuperuser FROM ${userName};
ALTER ROLE ${userName} NOCREATEDB NOCREATEROLE;
-- GRANT cloudsqlsuperuser TO ${userName};
