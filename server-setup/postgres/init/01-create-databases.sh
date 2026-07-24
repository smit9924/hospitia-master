#!/bin/bash
set -e

# Create databases for the applications
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
CREATE DATABASE auth;
EOSQL