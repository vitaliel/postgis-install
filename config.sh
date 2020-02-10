#!/usr/bin/env bash

# configurable options
DB=geocoder_dev
PGUSER=$USER
PGPASSWORD=
PGHOST=localhost
PGPORT=5432
PGBIN=/usr/local/Cellar/postgresql/12.1/bin
SHP2PGSQL=shp2pgsql

TIGER_YEAR=2019
TMPDIR=$PWD/temp
DISTRICT_EC=116

test -e config-local.sh && source config-local.sh

PSQL=${PGBIN}/psql

export PGBIN
export PGPORT
export PGHOST
export PGUSER
export PGPASSWORD
export PGDATABASE

WWW_HOST=www2.census.gov
FTP_HOST=ftp2.census.gov

install() {
  brew install postgis
}

init_db() {
  ${PSQL} postgres -c "CREATE DATABASE $DB;"
}

activate_ext() {
  ${PSQL} $DB -f extensions.sql
}

config() {
  wget_path=$(which wget)
  mkdir -p temp
  cat <<EOF >temp/config.sql
update tiger.loader_platform
set declare_sect='
TMPDIR="\${staging_fold}/temp/"
UNZIPTOOL=unzip
WGETTOOL=$wget_path
export PGBIN=$PGBIN
export PGPORT=$PGPORT
export PGHOST=$PGHOST
export PGUSER=$PGUSER
export PGPASSWORD=$PGPASSWORD
export PGDATABASE=$DB
PSQL=\${PGBIN}/psql
SHP2PGSQL=shp2pgsql
cd \${staging_fold}
'
where os='sh';
EOF

  ${PSQL} $DB -f temp/config.sql
  ${PSQL} $DB -c "update tiger.loader_variables set staging_fold='$PWD'"
  mkdir -p $WWW_HOST
  ln -s $WWW_HOST $FTP_HOST
  use_ftp
}

use_ftp() {
  ${PSQL} $DB -c "update tiger.loader_variables set website_root='ftp://$FTP_HOST/geo/tiger/TIGER' || (select tiger_year from tiger.loader_variables limit 1);"
}

use_www() {
  # PROBLEM: webserver does not return content-length of a file,
  # so wget can not mirror without downloading the whole file again.
  ${PSQL} $DB -c "update tiger.loader_variables set website_root='https://$WWW_HOST/geo/tiger/TIGER' || (select tiger_year from tiger.loader_variables limit 1)"
}

test_zips() {
  find . -name '*.zip' -exec unzip -q -t {} \;
}

gen_nation() {
  ${PSQL} -c "SELECT Loader_Generate_Nation_Script('sh')" -d $DB -tA >script/nation_loader.sh
}

# Generate loader for California
gen_ca() {
  psql -c "SELECT Loader_Generate_Script(ARRAY['CA'], 'sh')" -d $DB -tA > script/ca_state_loader.sh
}

# Generate loader for Massachusetts
gen_ma() {
  ${PSQL} -c "SELECT Loader_Generate_Script(ARRAY['MA'], 'sh')" -d $DB -tA > script/ma_state_loader.sh
}

# Generate loader for CA,MA,NY,TX
gen_4() {
  ${PSQL} -c "SET search_path=public,tiger;SELECT Loader_Generate_Script(ARRAY['CA','MA','NY','TX'], 'sh')" -d $DB -tA > script/4_state_loader.sh
}

rds_ownership() {
   ${PSQL} $DB -f rds_ownership.sql
}

# Import Congressional districts
import_districts() {
  file_name=tl_${TIGER_YEAR}_us_cd${DISTRICT_EC}
  arc=${file_name}.zip
  arc_path=${FTP_HOST}/geo/tiger/TIGER${TIGER_YEAR}/CD/$arc

  if [ -e $arc_path ]; then
    echo $arc_path exists
  else
    wget --mirror ftp://$arc_path
  fi
  rm -f ${TMPDIR}/*.*
  unzip -o -d $TMPDIR $arc_path

  ${SHP2PGSQL} -D -c -s 4269 -g the_geom -W "latin1" \
    $file_name.dbf tiger_data.districts | ${PSQL}
  ${PSQL} -c "CREATE INDEX tiger_data_districts_the_geom_gist ON tiger_data.districts USING gist(the_geom);"
  ${PSQL} -c "VACUUM ANALYZE tiger_data.districts"
}

console() {
  ${PSQL} $DB
}

final() {
  psql $DB -f final.sql
}

case "$1" in
  install)
    install
    ;;

  init-db)
    init_db
    ;;
  activate-ext)
    activate_ext
    ;;
  config)
    config
    ;;

  use-ftp)
    use_ftp
    ;;

  rds-ownership)
    rds_ownership
  ;;

  gen-nation)
    gen_nation
    ;;

  gen-ca)
    gen_ca
    ;;

  gen-ma)
    gen_ma
    ;;

  gen-4)
    gen_4
    ;;
  import-districts)
    import_districts
    ;;

  final)
    final
    ;;
  console)
    console
    ;;
  test-zips)
    test_zips
    ;;
*)
  echo commands: config use-ftp use-www test-zips
  ;;
esac

# Refs:
# * https://experimentalcraft.wordpress.com/2017/11/01/how-to-make-a-postgis-tiger-geocoder-in-less-than-5-days/
# * https://postgis.net/docs/Loader_Generate_Script.html
