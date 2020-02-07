
# Congretional districts

set -e

export PGBIN=/usr/local/Cellar/postgresql/12.1/bin
export PGPORT=5432
export PGHOST=localhost
export PGUSER=vitalie
export PGPASSWORD=
export PGDATABASE=geocoder_dev
PSQL=${PGBIN}/psql
SHP2PGSQL=shp2pgsql

FILE_NAME=tl_2019_us_cd116
arc=${FILE_NAME}.zip

if [ -e $arc ]; then
  echo $arc exists
else
  wget https://www2.census.gov/geo/tiger/TIGER2019/CD/$arc
  unzip $arc
fi

${SHP2PGSQL} -D -c -s 4269 -g the_geom -W "latin1" \
  tl_2019_us_cd116.dbf tiger_data.districts | ${PSQL}
${PSQL} -c "CREATE INDEX tiger_data_districts_the_geom_gist ON tiger_data.districts USING gist(the_geom);"
${PSQL} -c "VACUUM ANALYZE tiger_data.districts"
