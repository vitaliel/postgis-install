#!/usr/bin/env bash

# configurable options
DB=geocoder_dev
PGUSER=vitalie
PGPASSWORD=
PGHOST=localhost
PGPORT=5432

PGBIN=/usr/local/Cellar/postgresql/12.1/bin
WWW_HOST=www2.census.gov
FTP_HOST=ftp2.census.gov

install() {
  brew install postgis
}

init_db() {
  psql postgres -c "CREATE DATABASE $DB;"
  psql $DB -f extensions.sql
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

  psql $DB -f temp/config.sql
  psql $DB -c "update tiger.loader_variables set staging_fold='$PWD'"
  mkdir -p $WWW_HOST
  ln -s $WWW_HOST $FTP_HOST
  use_ftp
}

use_ftp() {
  psql $DB -c "update tiger.loader_variables set website_root='ftp://$FTP_HOST/geo/tiger/TIGER2019'"
}

use_www() {
  # PROBLEM: webserver does not return content-length of a file,
  # so wget can not mirror without downloading the whole file again.
  psql $DB -c "update tiger.loader_variables set website_root='https://$WWW_HOST/geo/tiger/TIGER2019'"
}

test_zips() {
  find . -name '*.zip' -exec unzip -q -t {} \;
}

gen_nation() {
  psql -c "SELECT Loader_Generate_Nation_Script('sh')" -d $DB -tA >script/nation_loader.sh
}

gen_ca() {
  psql -c "SELECT Loader_Generate_Script(ARRAY['CA'], 'sh')" -d $DB -tA > script/ca_state_loader.sh
}

gen_ma() {
  psql -c "SELECT Loader_Generate_Script(ARRAY['MA'], 'sh')" -d $DB -tA > script/ma_state_loader.sh
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

  config)
    config
    ;;

  use-ftp)
    use_ftp
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

  final)
    final
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
