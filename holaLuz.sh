#!/bin/bash

#psql -U myDatabaseUsername --password -d myDatabaseName -f mySqlScript.sql -h myHostName

psql -U postgres -h localhost -d holaluz -f scripts/drop_schema.sql

psql -U rafael -h localhost -d holaluz -f scripts/create_tables.sql

psql -U postgres -h localhost -d holaluz -f scripts/load_csv_data.sql

psql -U rafael -h localhost -d holaluz -f scripts/magic.sql
