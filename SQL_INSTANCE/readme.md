
# Cloud SQL Trip Data Pipeline

This project demonstrates how to create and manage a Cloud SQL instance using Google Cloud tools and load NYC taxi trip data into a MySQL database for analysis. Follow the steps below to prepare your environment, set up the database, load data, and perform integrity checks.

## Steps Overview

### Task 1: Prepare Your Environment
1. Authenticate and set up your project:
   ```bash
   gcloud auth list
   gcloud config list project
   export PROJECT_ID=$(gcloud info --format='value(config.project)')
   export BUCKET=${PROJECT_ID}-ml
   ```

### Task 2: Create a Cloud SQL Instance
1. Create a SQL instance:
   ```bash
   gcloud sql instances create taxi \
       --tier=db-n1-standard-1 --activation-policy=ALWAYS
   ```
2. Set a root password:
   ```bash
   gcloud sql users set-password root --host % --instance taxi --password ----
   ```
3. Configure access for your Cloud Shell instance:
   ```bash
   export ADDRESS=$(wget -qO - http://ipecho.net/plain)/32
   gcloud sql instances patch taxi --authorized-networks $ADDRESS
   ```
4. Get the SQL instance's IP address:
   ```bash
   MYSQLIP=$(gcloud sql instances describe taxi --format="value(ipAddresses.ipAddress)")
   echo $MYSQLIP
   ```

### Task 3: Create and Load the Database
1. Connect to the MySQL console:
   ```bash
   mysql --host=$MYSQLIP --user=root --password --verbose
   ```
2. Create the database and schema:
   ```sql
   create database if not exists bts;
   use bts;

   drop table if exists trips;

   create table trips (
     vendor_id VARCHAR(16),
     pickup_datetime DATETIME,
     dropoff_datetime DATETIME,
     passenger_count INT,
     trip_distance FLOAT,
     rate_code VARCHAR(16),
     store_and_fwd_flag VARCHAR(16),
     payment_type VARCHAR(16),
     fare_amount FLOAT,
     extra FLOAT,
     mta_tax FLOAT,
     tip_amount FLOAT,
     tolls_amount FLOAT,
     imp_surcharge FLOAT,
     total_amount FLOAT,
     pickup_location_id VARCHAR(16),
     dropoff_location_id VARCHAR(16)
   );
   ```
3. Import taxi trip data:
   ```bash
   gcloud storage cp gs://cloud-training/OCBL013/nyc_tlc_yellow_trips_2018_subset_1.csv trips.csv-1
   gcloud storage cp gs://cloud-training/OCBL013/nyc_tlc_yellow_trips_2018_subset_2.csv trips.csv-2
   mysql --host=$MYSQLIP --user=root --password --local-infile
   ```
   In the MySQL console:
   ```sql
   use bts;

   LOAD DATA LOCAL INFILE 'trips.csv-1' INTO TABLE trips
   FIELDS TERMINATED BY ','
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (vendor_id, pickup_datetime, dropoff_datetime, passenger_count, trip_distance, rate_code, store_and_fwd_flag, payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, imp_surcharge, total_amount, pickup_location_id, dropoff_location_id);

   LOAD DATA LOCAL INFILE 'trips.csv-2' INTO TABLE trips
   FIELDS TERMINATED BY ','
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (vendor_id, pickup_datetime, dropoff_datetime, passenger_count, trip_distance, rate_code, store_and_fwd_flag, payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, imp_surcharge, total_amount, pickup_location_id, dropoff_location_id);
   ```

### Task 4: Data Integrity Checks
1. Verify distinct pickup locations:
   ```sql
   select distinct(pickup_location_id) from trips;
   ```
2. Analyze trip distance:
   ```sql
   select max(trip_distance), min(trip_distance) from trips;
   select count(*) from trips where trip_distance = 0;
   ```
3. Validate fare amounts:
   ```sql
   select count(*) from trips where fare_amount < 0;
   ```
4. Investigate payment types:
   ```sql
   select payment_type, count(*) from trips group by payment_type;
   ```

## Conclusion
This pipeline sets up a Cloud SQL database, imports NYC taxi trip data, and performs initial quality checks. These steps serve as a foundation for deeper analysis and data processing.

