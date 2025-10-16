import os

source_path = '/Volumes/prod_lakehouse/dev_john_armstrong_policy/raw_landing_zone/'
destination_path = '/Volumes/prod_lakehouse/policy/raw_landing_zone/'

dbutils.fs.cp(source_path, destination_path, True)