# Setup

Tested on postgresql 12.1.

Make sure it runs without errors
```shell
./config.sh install
```

Start psql service
```shell
brew services start postgresql
```

Copy `config-local-example.sh` to `config-local.sh` file and adjust to your setup.

Create DB and activate extensions
```shell
./config.sh init-db
./config.sh activate-ext
```

Update db tables for script generation:
```shell
./config.sh config
```

Generate nation script and run it:
```shell
./config.sh gen-nation
bash script/nation_loader.sh
```

Make sure it works:
```sql
SELECT na.address, na.streetname,na.streettypeabbrev, na.zip
FROM normalize_address('1 Devonshire Place, Boston, MA 02109') AS na;
```

Load state data for California:
```shell
./config.sh import-state ca
```

Cleanup: create missing indexes and vacuum tables
```shell
./config.sh final
```

Check if it works:
```sql
SELECT g.rating, ST_AsText(ST_SnapToGrid(g.geomout,0.00001)) As wktlonlat,
ST_X(g.geomout) As lon, ST_Y(g.geomout) As lat,
(addy).address As stno, (addy).streetname As street,
(addy).streettypeabbrev As styp, (addy).location As city, (addy).stateabbrev As st,(addy).zip
FROM geocode('424 3rd St, Davis, CA 95616',1) As g;
```
