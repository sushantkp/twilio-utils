WORK_DIR_BASE=/tmp
OUTPUT_DIR_BASE=/obelix/storage/xtaas/call-recordings
today=`date +%Y-%m-%d`

output_dir=${OUTPUT_DIR_BASE}/${today}
DIR_SUFFIX=$(echo $PROGNAME | cut -d . -f 1).$(date "+%m%d%Y%H%M%Z").$$.$RANDOM 
WORK_DIR=$WORK_DIR_BASE/$DIR_SUFFIX     

mkdir -p $output_dir
mkdir -p $WORK_DIR

echo $today

python ../bulk-delete/FetchRecordingsByDate.py 1 1 | grep -v info: > $WORK_DIR/recording-ids.txt &&
      echo "Found $(wc -l $WORK_DIR/recording-ids.txt | awk '{print $1}') recordings"

while IFS='' read -r line || [[ -n "$line" ]]; do
    call_id=$(echo $line | awk '{print $1}')
    rec_id=$(echo $line | awk '{print $2}')
    duration=$(echo $line | awk '{print $NF}')
    ./fetch_recording_mp3.sh $output_dir $call_id $rec_id $duration
done < $WORK_DIR/recording-ids.txt

total_sec=$(cat ${WORK_DIR}/recording-ids.txt | awk '{ sum+=$NF } END {print sum}')
twilio_min=$(cat ${WORK_DIR}/recording-ids.txt | awk '{ sum+=(($NF - ($NF % 60))/60 + (($NF % 60) > 0 ? 1 : 0))} END {print sum}')

echo "total_sec = $total_sec" 
echo "twilio_min = $twilio_min"
echo "total_size = $(du -sh $output_dir | awk '{print $1}')"

rm -rf $WORK_DIR
