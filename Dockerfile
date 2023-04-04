FROM ubuntu:22.04

RUN apt update
RUN apt install -y curl \
    lsb-release \
    gnupg \
    debsig-verify

# Add the keys for installing the msodbcsql18 and unixodbc-dev packages.
RUN curl -k https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl -k https://packages.microsoft.com/config/ubuntu/22.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

# They don't verify their packages properly, so we get to skip verification to get this to work for now.
RUN apt -o "Acquire::https::Verify-Peer=false" update
RUN ACCEPT_EULA=Y apt -o "Acquire::https::Verify-Peer=false" install -y msodbcsql18
RUN ACCEPT_EULA=Y apt -o "Acquire::https::Verify-Peer=false" install -y unixodbc-dev

# Download snowflake odbc drivers
RUN curl -o snowflake-odbc-2.25.10.aarch64.deb https://sfc-repo.snowflakecomputing.com/odbc/linux/2.25.9/snowflake-odbc-2.25.9.x86_64.deb

# Make sure mssql tols are in our PATH so they'll be found.
RUN echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc

# Import the snowflake deb signature verification keys
RUN gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 630D9F3CAB551AF3
RUN mkdir /usr/share/debsig/keyrings/630D9F3CAB551AF3
RUN gpg --export 630D9F3CAB551AF3 > snowflakeKey.asc
RUN touch /usr/share/debsig/keyrings/630D9F3CAB551AF3/debsig.gpg
RUN gpg --no-default-keyring --keyring /usr/share/debsig/keyrings/630D9F3CAB551AF3/debsig.gpg --import snowflakeKey.asc

# Import our config files policy and run debsig-verify to make sure the package
# is the valid snowflake deb
COPY config_files/policy /etc/debsig/policies/630D9F3CAB551AF3/630D9F3CAB551AF3.pol
RUN debsig-verify snowflake-odbc-2.25.10.aarch64.deb

# Install the snowflake ODBC drivers
RUN dpkg -i snowflake-odbc-2.25.10.aarch64.deb

# Update our configuration files
COPY config_files/simba.snowflake.ini /usr/lib/snowflake/odbc/lib/simba.snowflake.ini
COPY config_files/odbc.ini /etc/odbc.ini
COPY config_files/odbcinst.ini /etc/odbcinst.ini

echo "Run 'isql -v snowflake <username> <password>' to get started!"