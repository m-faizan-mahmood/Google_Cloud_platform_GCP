gcloud auth list
gcloud config list project

#Task 1. Preparing your environment
export PROJECT_ID=$(gcloud info --format='value(config.project)')
export BUCKET=${PROJECT_ID}-ml

#Task 2. Create a Cloud SQL instance
gcloud sql instances create taxi \
    --tier=db-n1-standard-1 --activation-policy=ALWAYS

#Set a root password
gcloud sql users set-password root --host % --instance taxi \
 --password Passw0rd

 #Now create an environment variable with the IP address of the Cloud Shell
 export ADDRESS=$(wget -qO - http://ipecho.net/plain)/32

 #Cloud Shell instance for management access to your SQL instance:
 gcloud sql instances patch taxi --authorized-networks $ADDRESS

#Get the IP address of your Cloud SQL instance by running:

MYSQLIP=$(gcloud sql instances describe \
taxi --format="value(ipAddresses.ipAddress)")

#Check the variable MYSQLIP:
Check the variable MYSQLIP:


#Create the taxi trips table by logging into the mysql command line interface:
mysql --host=$MYSQLIP --user=root \
      --password --verbose


 # following content to the command line to create the schema for the trips table:
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

#check the import by entering the following commands:
describe trips;

#Query the trips table:
select distinct(pickup_location_id) from trips;

exit

#Task 3. Add data to Cloud SQL instance
gcloud storage cp gs://cloud-training/OCBL013/nyc_tlc_yellow_trips_2018_subset_1.csv trips.csv-1
gcloud storage cp gs://cloud-training/OCBL013/nyc_tlc_yellow_trips_2018_subset_2.csv trips.csv-2

#Connect to the mysql interactive console to load local infile data:
mysql --host=$MYSQLIP --user=root  --password  --local-infile

#In the mysql interactive console select the database
use bts;

#CSV file data using local-infile
LOAD DATA LOCAL INFILE 'trips.csv-1' INTO TABLE trips
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(vendor_id,pickup_datetime,dropoff_datetime,passenger_count,trip_distance,rate_code,store_and_fwd_flag,payment_type,fare_amount,extra,mta_tax,tip_amount,tolls_amount,imp_surcharge,total_amount,pickup_location_id,dropoff_location_id);


LOAD DATA LOCAL INFILE 'trips.csv-2' INTO TABLE trips
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(vendor_id,pickup_datetime,dropoff_datetime,passenger_count,trip_distance,rate_code,store_and_fwd_flag,payment_type,fare_amount,extra,mta_tax,tip_amount,tolls_amount,imp_surcharge,total_amount,pickup_location_id,dropoff_location_id);




#Task 4. Checking for data integrity

select distinct(pickup_location_id) from trips;


#Let's start by digging into the trip_distance column. 

#trip_distance column.

select
  max(trip_distance),
  min(trip_distance)
from
  trips;
  
#dataset have a trip distance of 0?

select count(*) from trips where trip_distance = 0;


#fare_amount column to be positive.

select count(*) from trips where fare_amount < 0;


# investigate the payment_type column
select
  payment_type,
  count(*)
from
  trips
group by
  payment_type;
  
  
 
