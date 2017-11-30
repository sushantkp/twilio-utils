# Bulk delete

Delete recording from Twilio using python library given list of call ids to 
retain. Implement FetchSuccessIdsByDate.py to get a list of ids to retain. 
The reason we use call ids is because that value is saved in the app. The 
implementation will be simpler if recording ids was retained but not 
necessary.

Algorithm

1. Get a list of call ids which you need to keep and save in work/success-call-ids.txt
    ```
    Usage: python FetchRecordingsByDate.py <<days_since_end_date>> <<number_of_days_recordings>>
    ```
2. Fetch a list of recordings you want to delete using FetchRecordingsByDate.py and save in work/recording-ids.txt
    ```
    Usage: python FetchRecordingsByDate.py <<days-since-end-date>> <<number-of-days-recordings>>
    ```
3. Create a list of recording ids to delete
    ```
    cat work/success-call-ids.txt| sort | uniq | awk 'NF' > work/preprocessed-success-call-ids.txt
    cat work/recording-ids.txt| sort | uniq | awk 'NF' > work/preprocessed-recording-ids.txt
    # get a list of to-be-retained recording ids 
    join work/preprocessed-success-call-ids.txt work/preprocessed-recording-ids.txt > work/joined-recording-ids.txt 
    # Remove the above recording ids from the delete list
    diff -U $(wc -l < work/preprocessed-recording-ids.txt) work/preprocessed-recording-ids.txt work/joined-recording-ids.txt | grep '^-' | sed 's/^-//g' > work/delete-recording-ids.txt 
    ```
4. Delete the recordings using DeleteRecording.py. gnu parallel is used for 
    process parallelization and speedup
    ```
    cat work/delete-recording-ids.txt | awk '{print $2}'| parallel --pipe  python DeleteRecording.py  2>work/err.txt |tee work/out.txt
    ```
