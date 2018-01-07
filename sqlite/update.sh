#!/bin/sh
echo "Rebuilding macros.db"
rm macros.db
sqlite3 macros.db ".read create.sql"
sqlite3 macros.db ".read default_rules.sql"
echo "Copying to app directory"
cp macros.db ..
echo "Copying to test app directory"
cp macros.db ../../MacroDialTest/macros_test.db


