
output_dir=$1
call_id=$2
recording_id=$3
duration=$4 

output_file_name="${output_dir}/${call_id}-${recording_id}-${duration}.mp3"

wget -q -O $output_file_name http://api.twilio.com/2010-04-01/Accounts/$TWILIO_ACCOUNT_SID/Recordings/$recording_id.mp3
