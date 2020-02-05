# Setup

Make sure it runs without errors
```shell
./config.sh install
```

Start psql service
```shell
brew services start postgresql
```

Edit `config.sh` file and adjust to your setup.

Create DB
```shell
./config.sh init-db
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
./config.sh gen-ca
bash script/ca_state_loader.sh
```

Cleanup: create missing indixes and vacuum tables
```shell
./config.sh final
```

Check if it works:
```sql
SELECT g.rating, ST_AsText(ST_SnapToGrid(g.geomout,0.00001)) As wktlonlat,
(addy).address As stno, (addy).streetname As street,
(addy).streettypeabbrev As styp, (addy).location As city, (addy).stateabbrev As st,(addy).zip
FROM geocode('424 3rd St, Davis, CA 95616',1) As g;
```
