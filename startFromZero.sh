#! /bin/bash

psql -f dropTables.sql
psql -f CreateTables.sql
psql -f Triggers.sql
psql -f Views.sql
psql -f Insertions.sql
