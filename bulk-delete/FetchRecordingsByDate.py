import os
import sys
from datetime import datetime, timedelta
from twilio.rest import Client
from twilio.base.exceptions import TwilioRestException


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

account = os.environ['TWILIO_ACCOUNT_SID']
token = os.environ['TWILIO_AUTH_TOKEN']

client = Client(account, token)
#for recording in client.recordings.list(jlimit=100):
#  print recording.duration

try:
    gen = client.recordings.stream(date_created_before=end, 
            date_created_after=start)
    for rec in gen: 
         print '{0} {1} {2} {3} {4}'.format(rec.call_sid, rec.sid, 
                 rec.date_created, rec.date_updated, rec.duration)
except TwilioRestException as e:                                            
     sys.stderr.write("HTTP {0} error: {1}\n".format(e.status, e.msg)) 



