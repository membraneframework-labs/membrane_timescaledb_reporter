# Grafana Integration

This document provides indtroduciton to integrating this repostory TimescaleDB's schema with Grafana to create dashboards for monitoring your pipeline behaviour.

## Setup

First of all you will need to setup PostgreSQL database instance with installed TimescaleDB extension.
It's recommended to use official docker image `timescaledb/timescaledb` that will fit our requirements.

Second of all, you will need Grafana instance. Again it's recommended to use another docker image `grafana/grafana`.

You can use `docker-compose.yml` file to setup it all at once:

```yaml
version: '3.7'

services:
  grafana:
    image: grafana/grafana
    ports:
      - 3000:3000
  timescale:
    image: timescale/timescaledb
    ports:
      - 5432:5432
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
```

You will need postgres credentials not only for `membrane_timescaledb_reporter` but as well for creating Grafana's data source.

## Grafana
Grafana is a web browser tool that you will be able to access after running e.g. with help of docker.
Default credentials for a fresh Grafana instance are, both for username and passowrd: `admin`.

## Grafana Dashboard

Grafana's dashboard is a basic building block that will contain all your panels necessary for monitoring your pipeline.
You have to start by creating one and then adding new pannels that will be used for displaying graphs and maybe some kind of diagrams.

Grafana's power comes from an ability to easily share a dashboard layout between users. Dashboard can be imported to Grafana with a simple *.json* file.
We provide a simple example dashboard containing 2 panels both of which contain graphs plotting `Membrane's InputBuffer's` internal buffer sizes reported by two function inside mentioned module. 
Dashboard layout is available at `example_setup/sample_grafana_dashboard.json`.

To import dashboard navigate in to Grafana's page and then to `Create > Import > Upload JSON file` and select mentioned file and click *Import*.

## Grafana's Data Source

For the imported dashboard to work you will need to add a data source.

A data source is used by Grafana to fetch necessary data requested by panels inside of your dashboard.
In this case you will need to add PostgreSQL data source.
Follow `Configuration > Data Sources > Add data source` and search for `PostgreSQL` and click *Select*.
Then you will need to provide connection information and enable `TimescaleDB` option in `PostgreSQL details` section.
You might need either to set current data source as default (at the very top of settings, right to the name) or change data source location inside of given dashboard's panels as those panels use a default one. 

## Creating new visualizations
You might want to create new panels that will visualize other aspects of your pipeline. Then you will need to provide them with previously created data source and make
proper SQL queries that will fetch necessary data. You can inspect example's panels how to write such queries (they are very basic) or you might consider visiting TimescaleDB's and Grafana's documentations.

## Warnings
Be carefull when quering large time ranges as some metrics might be reported thousands times per second and querying for example last 6h at once might crash your database instance or Grafana's dashboard.

