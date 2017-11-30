# Twilio Utils

## Bulk delete

Delete recording from Twilio using python2 library given list of call ids to 
retain. Implement FetchSuccessIdsByDate.py to get a list of ids to retain.

1. Install python library 
   * pip install twilio==6.0.0rc13
   * pip install pymongo

2. Install gnu parallel

3. Following environment variables need to be set
   * TWILIO_AUTH_TOKEN
   * TWILIO_AUTH_SID
   * WORK_DIR_BASE - working directory. It will get cleaned up after job run

4. Usage
   ```
    ./clean_recording.sh #offset #num_days
    Start deleting records #offset days back for #num_days
    for e.g. if current date is June 7th, then running 
        ./clean_recording.sh 5 2 
    will delete records for June 3rd and June 4th
   ```

4. Archive out.txt and err.txt for review
   ```
    tail -4 work/out.txt
    Delete RE102d801aa288eac6dcba396a3731525c
    Delete RE4799d26dbfd5cd0eda47a9df9b351f64
    Delete REb8a5b573d69510793fb1ef31f39a07af
    Delete REa8111aeff6b85e293d9051a3e98b155d
   ```

   ```
    tail -4 work/err.txt 
    HTTP 404 error: Unable to delete record: The requested resource /2010-04-01/Accounts/AC2a76c665eb3c39046214a9a6a2bd3935/Recordings/RE03ef62e5a5312e969caa5f82baee61a7.json was not found
    HTTP 404 error: Unable to delete record: The requested resource /2010-04-01/Accounts/AC2a76c665eb3c39046214a9a6a2bd3935/Recordings/RE984489683bd19fa4c7049e6212d65711.json was not found
    HTTP 404 error: Unable to delete record: The requested resource /2010-04-01/Accounts/AC2a76c665eb3c39046214a9a6a2bd3935/Recordings/RE7ee0c904ee01a8734bed54b15c90a633.json was not found
    HTTP 404 error: Unable to delete record: The requested resource /2010-04-01/Accounts/AC2a76c665eb3c39046214a9a6a2bd3935/Recordings/RE4bbea7975398a4493368bea52fe1f5c3.json was not found
   ```


## Twilio Usage Report

1. Fetch last 30 days usage report 
   ``` 
    python UsageRecords.py
   ```

