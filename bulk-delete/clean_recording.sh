#! /bin/bash
# Script to Delete unsuccessful recordings from Twilio

#### Environment variables required
# TWILIO_AUTH_TOKEN
# TWILIO_ACCOUNT_SID
# MONGODB_URL
# WORK_DIR_BASE

#### Constants
PROGNAME=$(basename $0)
DIR_SUFFIX=$(echo $PROGNAME | cut -d . -f 1).$(date "+%m%d%Y%H%M%Z").$$.$RANDOM
WORK_DIR=$WORK_DIR_BASE/$DIR_SUFFIX

#### Functions
log() {
    echo "${DIR_SUFFIX}.$(date "+%m%d%Y%H%M%S%Z"): $1" 1>&2 | tee $WORK_DIR.err.txt
}


usage() {

	# Display usage message on standard error
    echo "Usage: $PROGNAME offset num_of_days [options]  
        offset = (today - report_start_date)
        script will clean num_of_days worth recording
		options
		--dry-run | -n : do everything other than deleting recordings" 1>&2
		
}

clean_up() {

	# Perform program exit housekeeping
	# Optionally accepts an exit status
#	[ -e $WORK_DIR ] && cd $WORK_DIR && rm -i * && cd .. && rmdir $WORK_DIR
   	[ -e $WORK_DIR ] && rm -rf $WORK_DIR
	exit $1
}

error_exit() {

	# Display error message and exit
	echo "${DIR_SUFFIX}.$(date "+%m%d%Y%H%M%S%Z"): ${1:-"Unknown Error"}" 1>&2
	clean_up 1
}

create_work_dir() {
    
    # Create work dir
    mkdir -p $WORK_DIR
}

fetch_success_call_sids() {
    
    # Fetch twilio call sids for succesful prospect calls from db
    log "Fetch twilio call sids"
    python FetchSuccessIdsByDate.py $1 $2 | grep -v info: > $WORK_DIR/success-call-ids.txt && 
    log "Found $(wc -l $WORK_DIR/success-call-ids.txt | awk '{print $1}') successful calls"
}

fetch_recordings() {
    
    # Fetch call recordings from twilio
    log "Fetch call recordings"
    python FetchRecordingsByDate.py $1 $2 | grep -v info: > $WORK_DIR/recording-ids.txt &&
    log "Found $(wc -l $WORK_DIR/recording-ids.txt | awk '{print $1}') recordings"
}

get_sids_to_be_deleted() {

    # Relational operations to get set of recordings not in set of successful recordings
    cat $WORK_DIR/success-call-ids.txt | sort | uniq | awk 'NF'> $WORK_DIR/preprocessed-success-call-ids.txt &&
    cat $WORK_DIR/recording-ids.txt | sort | uniq | awk 'NF'> $WORK_DIR/preprocessed-recording-ids.txt &&
    # Create a set of successful recordings which will be removed from set of all recordins
    join $WORK_DIR/preprocessed-success-call-ids.txt $WORK_DIR/preprocessed-recording-ids.txt > $WORK_DIR/joined-recording-ids.txt &&
    diff -U $(wc -l < $WORK_DIR/preprocessed-recording-ids.txt) $WORK_DIR/preprocessed-recording-ids.txt $WORK_DIR/joined-recording-ids.txt | grep '^-' | grep -v '^---' | sed 's/^-//g' > $WORK_DIR/delete-recording-ids.txt 
}

delete_recordings() {
    
    # Delete recordings with ids in delete-recording-ids.txt
    log "Delete unsuccessful recordings"
    get_sids_to_be_deleted && ($dryrun ||
    (cat $WORK_DIR/delete-recording-ids.txt | awk '{print $2}'| parallel -j20 --pipe  python DeleteRecording.py  2>$WORK_DIR.err.txt >$WORK_DIR.out.txt))
    log "Deleted $(wc -l $WORK_DIR.out.txt | awk '{print $1}') recordings"
}

generate_report() {

    # Best effort to estimate saving
    # Adjusted for minute termination per call
    cpm=0.0005
    retained_calls=$(cat ${WORK_DIR}/joined-recording-ids.txt | wc -l)
    retained_min=$(cat ${WORK_DIR}/joined-recording-ids.txt | awk '{ sum+=(($NF - ($NF % 60))/60 + (($NF % 60) > 0 ? 1 : 0))} END {print sum}')
    rcost=$(bc -l <<< "($retained_min * $cpm)")
    log "Retained $retained_calls successful recordings will cost USD $rcost"

    deleted_calls=$(cat ${WORK_DIR}/delete-recording-ids.txt | wc -l)
    deleted_min=$(cat ${WORK_DIR}/delete-recording-ids.txt | awk '{ sum+=(($NF - ($NF % 60))/60 + (($NF % 60) > 0 ? 1 : 0))} END {print sum}')
    scost=$(bc -l <<< "($deleted_min * $cpm)")
    log "Deleted $deleted_calls recordings saved USD $scost"
}


#### Main

trap clean_up SIGHUP SIGINT SIGTERM

if [ $# -lt 2 ]; then
    usage
    error_exit "missing command line params" 
fi

[ -z $TWILIO_AUTH_TOKEN ] && error_exit "env var TWILIO_AUTH_TOKEN is not set"
[ -z $TWILIO_ACCOUNT_SID ] && error_exit "env var TWILIO_ACCOUNT_SID is not set"
[ -z $MONGODB_URL ] && error_exit "env var MONGODB_URL is not set"
[ -z $WORK_DIR_BASE ] && error_exit "env var WORK_DIR_BASE is not set"

offset=$1
num_of_days=$2

#option
dryrun=false

if [ $# -eq 3 ]; then
    for option in "${@:3}"
    do
		case $option in
    		--dry-run | -n )
      			dryrun=true ;;
		esac
    done
fi

[ $num_of_days -gt $offset ] && error_exit "num_of_days cannot be greater than offset"

log "Delete recordings from $(date -d "-${offset}day 00:00:00") to $(date -d "-$(( $offset - $num_of_days ))day")"

$dryrun && log "This is a dryrun"

create_work_dir || error_exit "error creating work directory: $WORK_DIR"

fetch_recordings $offset $num_of_days || error_exit "error fetching recordings"

fetch_success_call_sids $offset $num_of_days || error_exit "error fetching success call ids"

delete_recordings || error_exit "error deleting recordings"

generate_report || error_exit "error generating report"

log "Clean up work directory"

clean_up
