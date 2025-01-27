#!/bin/bash
gcloud storage cp gs://cloud-training/bdml/taxisrcdata/schema.json  gs://qwiklabs-gcp-01-147a63a847c2-bucket/tmp/schema.json
gcloud storage cp gs://cloud-training/bdml/taxisrcdata/transform.js  gs://qwiklabs-gcp-01-147a63a847c2-bucket/tmp/transform.js
gcloud storage cp gs://cloud-training/bdml/taxisrcdata/rt_taxidata.csv  gs://qwiklabs-gcp-01-147a63a847c2-bucket/tmp/rt_taxidata.csv

#Dataflow API.
gcloud services disable dataflow.googleapis.com
gcloud services enable dataflow.googleapis.com



# Ingest a new dataset from Google Cloud Storage (--sricpt--shell)
bq load \
--source_format=CSV \
--autodetect \
--noreplace  \
nyctaxi.2018trips \
gs://cloud-training/OCBL013/nyc_tlc_yellow_trips_2018_subset_2.csv
