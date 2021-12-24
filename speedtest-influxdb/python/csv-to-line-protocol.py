#!/usr/bin/env python

# Convert CSV data to Line Protocol.
# See https://github.com/lisenet/kubernetes-homelab

# I was previously running speedtest-cli with "--csv" flag and
# storing results in MySQL. Needless to say MySQL was overkill.
# Now that I have moved on InfluxDB, I wanted to migrate existing
# speedtest data from MySQL to InfluxDB. I did this by converting
# CSV data to Line Protocol that is used by InfluxDB to write data points.

# CVS data looks like this:
#
# Server ID,Sponsor,Server Name,Timestamp,Distance,Ping,Download,Upload,Share,IP Address
# 30690,Community Fibre Limited,London,2021-10-16T23:15:01.745083Z,137.28267836533254,26.57,195993149.1169437,21897256.738718312,,0.0.0.0
# 30690,Community Fibre Limited,London,2021-10-17T01:15:01.641649Z,137.28267836533254,31.777,191308422.08521518,20355124.0785163,,0.0.0.0

# Line Protocol is a text-based format that provides the measurement,
# tag set, field set, and timestamp of a data point.

import pandas as pd

df = pd.read_csv("speedtest-from-mysql.csv")
lines = ["speedtest"
         + " "
         + "ping=" + str(df["Ping"][d]) + ","
         + "download=" + str(df["Download"][d]) + ","
         + "upload=" + str(df["Upload"][d])
         + " " + str(df["Timestamp"][d]) for d in range(len(df))]

thefile = open('speedtest-line-protocol.txt', 'w')
for item in lines:
    thefile.write("%s\n" % item)
