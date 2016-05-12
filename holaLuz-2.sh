#!/bin/bash

#psql -U myDatabaseUsername --password -d myDatabaseName -f mySqlScript.sql -h myHostName

psql -U postgres -h localhost -d holaluz -f scripts2/drop_schema.sql

psql -U rafael -h localhost -d holaluz -f scripts2/create_tables-2.sql

psql -U postgres -h localhost -d holaluz -f scripts2/load_csv_data.sql

psql -U rafael -h localhost -d holaluz -f scripts2/magic-2.sql

psql -U postgres -h localhost -d holaluz -f scripts2/export_perfils_finals.sql
