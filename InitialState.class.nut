// Copyright (c) 2015 Initial State Technologies, Inc.
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

class InitialState {

    static version = [1,0,0];

    _bucketKey = null;
    _accessKey = null;
    _bucketName = null;

    _isBucketCreated = false;
    _eventRequestHeaders = null;

    constructor(accessKey, bucketKey = null, bucketName = null) {

        const _baseUrl = "https://groker.initialstate.com/api/";
        const _apiVersion = "~0";

        if (!bucketKey) bucketKey = split(http.agenturl(), "/").top();
        if (!bucketName) bucketName = bucketKey;

        _accessKey = accessKey;
        _bucketKey = bucketKey;
        _bucketName = bucketName;

        _eventRequestHeaders = {
            "Content-Type": "application/json",
            "X-IS-AccessKey": _accessKey,
            "X-IS-BucketKey": _bucketKey,
            "Accept-Version": _apiVersion
        }
    }

    // Creates a new bucket on the IS server. This is called automatically.
    //
    // Parameters:
    //      callback:   The function to call on the completion of this request.
    //
    // Returns:         this

    function createBucket(callback = null) {

        // Prepare the URL and POST data
        local url = _baseUrl + "buckets";
        local data = http.jsonencode({
            "bucketName": _bucketName,
            "bucketKey": _bucketKey
        });

        local headers = {
            "Content-Type": "application/json",
            "X-IS-AccessKey": _accessKey,
            "Accept-Version": _apiVersion
        };

        // Post the event to the Initial State server
        local req = http.post(url, headers, data);
        req.sendasync(function(resp) {

            local err = null;
            local data = null;
            if (resp.statuscode == 429) {
                // We have been throttled. Try again in a second
                imp.wakeup(1, function() {
                    createBucket(callback);
                }.bindenv(this))
                return;
            } else if (resp.statuscode < 200 || resp.statuscode >= 300) {
                // Failure
                err = "StatusCode: " + resp.statuscode + ", Message: " + resp.body;
            } else {
                // Success
                data = http.jsonencode(resp.body);
                _isBucketCreated = true;
            }

            // Feed back to the calling function
            if (callback) callback(err, data);

        }.bindenv(this));

        return this;
    }

    // Sends a single events to the IS server.
    //
    // Parameters:
    //      callback:   The function to call on the completion of this request.
    //
    // Returns:         this
    
    function sendEvent(eventKey, eventValue, epoch = null, callback = null) {

        // Rearrange the optional parameters
        if (typeof epoch == "function") {
            callback = epoch;
            epoch = null;
        }

        if (epoch == null) {
            local d = date();
            epoch = format("%d.%s", d.time, format("%0.06f", d.usec / 1000000.0).slice(2));
        }

        // If we haven't created the bucket, create it now and repeat this function.
        if (_isBucketCreated == false) {
            createBucket(function(err, data) {
                if (err) {
                    if (callback) callback(err, null)
                } else {
                    sendEvent(eventKey, eventValue, epoch, callback);
                }
            }.bindenv(this))
            return;
        }

        // Prepare the URL and POST body
        local url = _baseUrl + "events";
        local eventObject = {
            key = eventKey,
            value = eventValue,
            epoch = epoch
        };
        local data = http.jsonencode(eventObject);

        // Post the event to the Initial State server
        local req = http.post(url, _eventRequestHeaders, data);
        req.sendasync(function(resp) {

            local err = null;
            local data = null;
            if (resp.statuscode == 429) {
                // We have been throttled. Try again in a second
                imp.wakeup(1, function() {
                    sendEvent(eventKey, eventValue, epoch, callback);
                }.bindenv(this))
                return;
            } else if (resp.statuscode < 200 || resp.statuscode >= 300) {
                // Failure
                err = "StatusCode: " + resp.statuscode + ", Message: " + resp.body;
            } else {
                // Success
                data = resp.body;
            }

            // Feed back to the calling function
            if (callback) callback(err, data);

        }.bindenv(this));

        return this;
    }


    // Sends an array of events to the IS server. Each event should be a table containing:
    //      "key", "value" and "epoch" (optional)
    //
    // Parameters:
    //      callback:   The function to call on the completion of this request.
    //
    // Returns:         this
    
    function sendEvents(events, callback = null) {

        // If we haven't created the bucket, create it now and repeat this function.
        if (_isBucketCreated == false) {
            createBucket(function(err, data) {
                if (err) {
                    if (callback) callback(err, null)
                } else {
                    sendEvents(events, callback);
                }
            }.bindenv(this))
            return;
        }

        // Prepare the URL and POST body
        local url = _baseUrl + "events";
        local data = http.jsonencode(events);

        // Post the event to the Initial State server
        local req = http.post(url, _eventRequestHeaders, data);
        req.sendasync(function(resp) {

            local err = null;
            local data = null;
            if (resp.statuscode == 429) {
                // We have been throttled. Try again in a second
                imp.wakeup(1, function() {
                    sendEvents(events, callback);
                }.bindenv(this))
                return;
            } else if (resp.statuscode < 200 || resp.statuscode >= 300) {
                // Failure
                err = "StatusCode: " + resp.statuscode + ", Message: " + resp.body;
            } else {
                // Success
                data = resp.body;
            }

            // Feed back to the calling function
            if (callback) callback(err, data);

        }.bindenv(this));

        return this;
    }
}
