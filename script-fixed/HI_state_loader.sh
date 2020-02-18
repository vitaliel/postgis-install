
TMPDIR="/Users/vitalie/projects/gp/postgis/temp/"
UNZIPTOOL=unzip
WGETTOOL=/usr/local/bin/wget
export PGBIN=/usr/local/Cellar/postgresql@11/11.6/bin
export PGPORT=5632
export PGHOST=devhost
export PGUSER=moneyball
export PGPASSWORD=secret
export PGDATABASE=moneyball_development
PSQL=${PGBIN}/psql
SHP2PGSQL=shp2pgsql
cd /Users/vitalie/projects/gp/postgis

cd /Users/vitalie/projects/gp/postgis
wget ftp://ftp2.census.gov/geo/tiger/TIGER2017/PLACE/tl_2017_15_place.zip --mirror --reject=html
cd /Users/vitalie/projects/gp/postgis/ftp2.census.gov/geo/tiger/TIGER2017/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_2017_15*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.HI_place(CONSTRAINT pk_HI_place PRIMARY KEY (plcidfp) ) INHERITS(tiger.place);" 
${SHP2PGSQL} -D -c -s 4269 -g the_geom   -W "latin1" tl_2017_15_place.dbf tiger_staging.hi_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.HI_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('HI_place'), lower('HI_place')); ALTER TABLE tiger_data.HI_place ADD CONSTRAINT uidx_HI_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_HI_place_soundex_name ON tiger_data.HI_place USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX tiger_data_HI_place_the_geom_gist ON tiger_data.HI_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.HI_place ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
cd /Users/vitalie/projects/gp/postgis
wget ftp://ftp2.census.gov/geo/tiger/TIGER2017/COUSUB/tl_2017_15_cousub.zip --mirror --reject=html
cd /Users/vitalie/projects/gp/postgis/ftp2.census.gov/geo/tiger/TIGER2017/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_2017_15*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.HI_cousub(CONSTRAINT pk_HI_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_HI_cousub_gid UNIQUE (gid)) INHERITS(tiger.cousub);" 
${SHP2PGSQL} -D -c -s 4269 -g the_geom   -W "latin1" tl_2017_15_cousub.dbf tiger_staging.hi_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.HI_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('HI_cousub'), lower('HI_cousub')); ALTER TABLE tiger_data.HI_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
${PSQL} -c "CREATE INDEX tiger_data_HI_cousub_the_geom_gist ON tiger_data.HI_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_HI_cousub_countyfp ON tiger_data.HI_cousub USING btree(countyfp);"
cd /Users/vitalie/projects/gp/postgis
wget ftp://ftp2.census.gov/geo/tiger/TIGER2017/TRACT/tl_2017_15_tract.zip --mirror --reject=html
cd /Users/vitalie/projects/gp/postgis/ftp2.census.gov/geo/tiger/TIGER2017/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_2017_15*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.HI_tract(CONSTRAINT pk_HI_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -D -c -s 4269 -g the_geom   -W "latin1" tl_2017_15_tract.dbf tiger_staging.hi_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.HI_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('HI_tract'), lower('HI_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_HI_tract_the_geom_gist ON tiger_data.HI_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.HI_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.HI_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
cd /Users/vitalie/projects/gp/postgis
cd /Users/vitalie/projects/gp/postgis/ftp2.census.gov/geo/tiger/TIGER2017/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_15*_faces*.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.HI_faces(CONSTRAINT pk_HI_faces PRIMARY KEY (gid)) INHERITS(tiger.faces);" 
for z in *faces*.dbf; do
${SHP2PGSQL} -D   -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.HI_faces | ${PSQL}
${PSQL} -c "SELECT loader_load_staged_data(lower('HI_faces'), lower('HI_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_HI_faces_the_geom_gist ON tiger_data.HI_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_HI_faces_tfid ON tiger_data.HI_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_HI_faces_countyfp ON tiger_data.HI_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.HI_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
	${PSQL} -c "vacuum analyze tiger_data.HI_faces;"
cd /Users/vitalie/projects/gp/postgis
cd /Users/vitalie/projects/gp/postgis/ftp2.census.gov/geo/tiger/TIGER2017/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_15*_featnames*.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.HI_featnames(CONSTRAINT pk_HI_featnames PRIMARY KEY (gid)) INHERITS(tiger.featnames);ALTER TABLE tiger_data.HI_featnames ALTER COLUMN statefp SET DEFAULT '15';" 
for z in *featnames*.dbf; do
${SHP2PGSQL} -D   -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.HI_featnames | ${PSQL}
${PSQL} -c "SELECT loader_load_staged_data(lower('HI_featnames'), lower('HI_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_HI_featnames_snd_name ON tiger_data.HI_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_HI_featnames_lname ON tiger_data.HI_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_HI_featnames_tlid_statefp ON tiger_data.HI_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.HI_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
${PSQL} -c "vacuum analyze tiger_data.HI_featnames;"
cd /Users/vitalie/projects/gp/postgis
cd /Users/vitalie/projects/gp/postgis/ftp2.census.gov/geo/tiger/TIGER2017/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_15*_edges*.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.HI_edges(CONSTRAINT pk_HI_edges PRIMARY KEY (gid)) INHERITS(tiger.edges);"
for z in *edges*.dbf; do
${SHP2PGSQL} -D   -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.HI_edges | ${PSQL}
${PSQL} -c "SELECT loader_load_staged_data(lower('HI_edges'), lower('HI_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.HI_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
${PSQL} -c "CREATE INDEX idx_tiger_data_HI_edges_tlid ON tiger_data.HI_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_HI_edgestfidr ON tiger_data.HI_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_HI_edges_tfidl ON tiger_data.HI_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_HI_edges_countyfp ON tiger_data.HI_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_HI_edges_the_geom_gist ON tiger_data.HI_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_HI_edges_zipl ON tiger_data.HI_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.HI_zip_state_loc(CONSTRAINT pk_HI_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(tiger.zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.HI_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'HI', '15', p.name FROM tiger_data.HI_edges AS e INNER JOIN tiger_data.HI_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.HI_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_HI_zip_state_loc_place ON tiger_data.HI_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.HI_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
${PSQL} -c "vacuum analyze tiger_data.HI_edges;"
${PSQL} -c "vacuum analyze tiger_data.HI_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.HI_zip_lookup_base(CONSTRAINT pk_HI_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(tiger.zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.HI_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'HI', c.name,p.name,'15'  FROM tiger_data.HI_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '15') INNER JOIN tiger_data.HI_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.HI_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.HI_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
${PSQL} -c "CREATE INDEX idx_tiger_data_HI_zip_lookup_base_citysnd ON tiger_data.HI_zip_lookup_base USING btree(soundex(city));"
cd /Users/vitalie/projects/gp/postgis
cd /Users/vitalie/projects/gp/postgis/ftp2.census.gov/geo/tiger/TIGER2017/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_15*_addr*.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.HI_addr(CONSTRAINT pk_HI_addr PRIMARY KEY (gid)) INHERITS(tiger.addr);ALTER TABLE tiger_data.HI_addr ALTER COLUMN statefp SET DEFAULT '15';" 
for z in *addr*.dbf; do
${SHP2PGSQL} -D   -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.HI_addr | ${PSQL}
${PSQL} -c "SELECT loader_load_staged_data(lower('HI_addr'), lower('HI_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.HI_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_HI_addr_least_address ON tiger_data.HI_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_HI_addr_tlid_statefp ON tiger_data.HI_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_HI_addr_zip ON tiger_data.HI_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.HI_zip_state(CONSTRAINT pk_HI_zip_state PRIMARY KEY(zip,stusps)) INHERITS(tiger.zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.HI_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'HI', '15' FROM tiger_data.HI_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.HI_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
	${PSQL} -c "vacuum analyze tiger_data.HI_addr;"
