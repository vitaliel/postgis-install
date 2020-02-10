# Setup RDS database

Currently psql 11.4 from RDS support postgis version: 2.5 USE_GEOS=1 USE_PROJ=1 USE_STATS=1

Activate extensions:
```shell
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
SET search_path=public,tiger;

SELECT na.address, na.streetname,na.streettypeabbrev, na.zip
FROM normalize_address('1 Devonshire Place, Boston, MA 02109') AS na;
```

Load state data for CA,MA,NY,TX:
```shell
./config.sh gen-4
bash script/4_state_loader.sh
```





(Amazon Instructions)[https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html#Appendix.PostgreSQL.CommonDBATasks.PostGIS]
