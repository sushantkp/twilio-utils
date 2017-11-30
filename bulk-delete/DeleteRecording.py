import os
import sys
from datetime import datetime, timedelta
from twilio.rest import Client
from twilio.base.exceptions import TwilioRestException

# To find these visit https://www.twilio.com/user/account
account = os.environ['TWILIO_ACCOUNT_SID']
token = os.environ['TWILIO_AUTH_TOKEN']

client = Client(account, token)
for line in sys.stdin:
    rsid = line.strip()
    try:
        ctx = client.recordings.get(sid=rsid) 
        status = ctx.delete()
        if status:
            sys.stdout.write('Delete ' + rsid + '\n')
        else:
            sys.stderr.write('Error ' + rsid + '\n')
    except TwilioRestException as e:
        sys.stderr.write("HTTP {0} error: {1}\n".format(e.status, e.msg))

