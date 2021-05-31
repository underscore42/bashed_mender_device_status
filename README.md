# bashed_mender_device_status
Reports changes in the connected devices using the mender api

Will generate a device.list as a valid json if there is a difference from the previous run.
Uses .mender_dev_report_last to the previous run, doesn't do any ceck for existance, so
create or run once.

Diff is outputted to console.

JWT bearer token is time limited in our system. Set URL to mender server, if user requires
interaction, password can be entered instead.

An extended version of this is running as a crontab on the same ec2 that has my mender service docker containers. Logging connection
changes over time, and then reporting up to a test monitor.
