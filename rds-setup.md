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

Fix permissions
```shell
./config.sh rds-ownership
```

Make sure it works:
```sql
SELECT na.address, na.streetname,na.streettypeabbrev, na.zip
FROM normalize_address('1 Devonshire Place, Boston, MA 02109') AS na;
```

Load state data for CA,MA, etc:
```shell
./config.sh import-state ca
./config.sh import-state ma
```

Load congressional districts
```shell
./config.sh import-districts
```

[Amazon Instructions](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html#Appendix.PostgreSQL.CommonDBATasks.PostGIS)
