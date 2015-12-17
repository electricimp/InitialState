# InitialState

[Initial State](https://www.initialstate.com/) is a hosted service that allows you to easily push event-based data.

This class wraps Initial State’s Event API (aka groker) in an agent-side library.

**To add this library to your project, add** `#require "InitialState.class.nut:1.0.0"` **to the top of your agent code.**

## Class Usage

### Constructor: InitialState(*accessKey[, bucketKey][, bucketName]*)

To instantiate the InitialState class, you need an Access Key and, optionally, the Bucket Key and Bucket Name:

| Parameter   |  Optional  |  Notes |
| ---------   |  --------  |  ----- |
| Access key  |  No        |  Available in Initial State [account page](https://www.initialstate.com/app#/account) under “Streaming Access Keys” |
| Bucket key  |  Yes       |  User-generated bucket ID, defaults to your agent ID |
| Bucket name |  Yes       |  User-generated bucket name, defaults to the bucket ID |

&nbsp;<br>For example:

```squirrel
#require "InitialState.class.nut:1.0.0"

is <- InitialState(MY_ACCESS_KEY);
```

## Class Methods

### Send Events

There are two methods that may be used to send events to Initial State. One method, *sendEvent()*, is for singular events. The other, *sendEvents()*, is for a batch of events. Both methods can take an optional callback function which will be fired when the request is complete.

### sendEvent(*key, value[, epoch][, callback]*)

The parameters *key* and *value* are the data to be sent to Initial State. The third parameter, *epoch*, is optional: it is an event timestamp *(see below)*. It is possible to exclude *epoch* but include the (also optional) *callback* &mdash; *sendEvent()* will manage this for you.

```squirrel
// Send an event
is.sendEvent("temperature", 72, function(err, data) {
    if (err != null) server.error("Error: " + err);
});
```

### sendEvents(*events[, callback]*)

The *events* parameter is an array of key-value pairs, each a data point that could be sent to Initial State singly using *sendEvent()*.

```squirrel
// Send an array of events
is.sendEvents([
    {"key": "temperature", "value": 72},
    {"key": "humidity", "value": 55}
], function(err, data) {
    if (err != null) server.error("Error: " + err);
});
```

### Overriding Event Timestamps

You can optionally override the timestamp of an event by passing in an *epoch* to the *sendEvent()* method. Values for *epoch* may also be added to the array items sent using *sendEvents()*:

```squirrel
// Override the timestamp for a single event
is.sendEvent("temperature", 72, time());

// Override timestamps for multiple events
is.sendEvents([
    {"key": "temperature", "value": 72, "epoch": time() },
    {"key": "humidity", "value": 55, "epoch": time() }
]);
```

## License

The Initial State library is copyright 2015 Initial State Technologies, Inc. It is licensed under the [MIT License](LICENSE).
