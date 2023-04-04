# Snowflake ODBC Container

This is a docker container that installs and runs the snowflake ODBC drivers so you can check that it works locally
without all the hassle of trying to configure it to run properly.  This may not mimick your environment, but it will
at least let you test and validate that the drivers can/will run.

To get started:

1. edit `config_files/odbc.ini` to reflect your snowflake account URL and account
2. run the ./buildrun.sh
3. Run the `isql` command with your username and password

You should see an output similar to below:

```
root@62bd94cc2df0:/# isql -v snowflake demo_user 'super_secret_password'
+---------------------------------------+
| Connected!                            |
|                                       |
| sql-statement                         |
| help [tablename]                      |
| quit                                  |
|                                       |
+---------------------------------------+
SQL> 
```

# Troubleshooting

### Role does not exist

This can occur if you're not allowed to connect without a default role in the connect string - reach out to your admin and refer to the configuration docs at https://docs.snowflake.com/en/developer-guide/odbc/odbc-linux#step-4-configure-the-odbc-driver for additional options

```
root@35ed0c991b5c:/# isql -v snowflake demo_user 'super_secret_password'
[28000][unixODBC]Role 'demo_role' specified in the connect string does not exist or not authorized. Contact your local system administrator, or attempt to login with another role, e.g. PUBLIC.
[ISQL]ERROR: Could not SQLConnect
root@35ed0c991b5c:/#
```

### Can't resolve host name

If you see errors with the host name please verify that you've updated the `config_files/odbc.ini` to point at your snowflake account.

```
root@43d03c649c81:/# isql -v snowflake demo_user 'super_secret_password'
[S1000][unixODBC][Snowflake][Snowflake] (4) 
      REST request for URL ttps://bad_url.us-east-1.snowflakecomputing-wrongdomain.com/:443/session/v1/login-request?requestId=e887306b-7b21-470d-a79c-ba276a15fd0f&request_guid=68387f2d-4617-448d-a1ab-d6c39de05e98&roleName=demo_role failed: CURLerror (curl_easy_perform() failed) - code=6 msg='Couldn't resolve host name'.
    
[ISQL]ERROR: Could not SQLConnect
root@43d03c649c81:/# 
```

# TODO

* Update the build args and build our policy and config files on the fly to work with your own account inputs.
