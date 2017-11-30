import os
import sys
from datetime import datetime, timedelta
from pymongo import MongoClient


if len(sys.argv) < 3:
    print 'Usage: python FetchRecordingsByDate.py <<days_since_end_date>> <<number_of_days_recordings>>'
    exit()

offset = int(sys.argv[1])
number_of_days_recordings = int(sys.argv[2])

today = datetime.now()
print 'info: Today: {0}'.format(today)
start_day = today - timedelta(days=offset)
# Reset to midnight
start = datetime(start_day.year, start_day.month, start_day.day)
print 'info: Start Date: {0}'.format(start)
end = start_day + timedelta(days=number_of_days_recordings)
print 'info: End Date: {0}'.format(end)


# Implement logic to fetch twilio call sids and print them 
# one id per line on stdout

