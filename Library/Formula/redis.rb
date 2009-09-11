require 'brewkit'

REDIS_CONF=<<-EOS
# Redis configuration file example

# By default Redis does not run as a daemon. Use 'yes' if you need it.
# Note that Redis will write a pid file in /var/run/redis.pid when daemonized.
daemonize no

# When run as a daemon, Redis write a pid file in /var/run/redis.pid by default.
# You can specify a custom pid file location here.
pidfile /var/run/redis.pid

# Accept connections on the specified port, default is 6379
port 6379

# If you want you can bind a single interface, if the bind option is not
# specified all the interfaces will listen for connections.
#
# bind 127.0.0.1

# Close the connection after a client is idle for N seconds (0 to disable)
timeout 300

# Save the DB on disk:
#
#   save <seconds> <changes>
#
#   Will save the DB if both the given number of seconds and the given
#   number of write operations against the DB occurred.
#
#   In the example below the behaviour will be to save:
#   after 900 sec (15 min) if at least 1 key changed
#   after 300 sec (5 min) if at least 10 keys changed
#   after 60 sec if at least 10000 keys changed
save 900 1
save 300 10
save 60 10000

# The filename where to dump the DB
dbfilename dump.rdb

# For default save/load DB in/from the working directory
# Note that you must specify a directory not a file name.
dir /var/db/redis/

# Set server verbosity to 'debug'
# it can be one of:
# debug (a lot of information, useful for development/testing)
# notice (moderately verbose, what you want in production probably)
# warning (only very important / critical messages are logged)
loglevel notice

# Specify the log file name. Also 'stdout' can be used to force
# the demon to log on the standard output. Note that if you use standard
# output for logging but daemonize, logs will be sent to /dev/null
logfile /var/log/redis.log

# Set the number of databases. The default database is DB 0, you can select
# a different one on a per-connection basis using SELECT <dbid> where
# dbid is a number between 0 and 'databases'-1
databases 16

################################# REPLICATION #################################

# Master-Slave replication. Use slaveof to make a Redis instance a copy of
# another Redis server. Note that the configuration is local to the slave
# so for example it is possible to configure the slave to save the DB with a
# different interval, or to listen to another port, and so on.

# slaveof <masterip> <masterport>

################################## SECURITY ###################################

# Require clients to issue AUTH <PASSWORD> before processing any other
# commands.  This might be useful in environments in which you do not trust
# others with access to the host running redis-server.
#
# This should stay commented out for backward compatibility and because most
# people do not need auth (e.g. they run their own servers).

# requirepass foobared

################################### LIMITS ####################################

# Set the max number of connected clients at the same time. By default there
# is no limit, and it's up to the number of file descriptors the Redis process
# is able to open. The special value '0' means no limts.
# Once the limit is reached Redis will close all the new connections sending
# an error 'max number of clients reached'.

# maxclients 128

# Don't use more memory than the specified amount of bytes.
# When the memory limit is reached Redis will try to remove keys with an
# EXPIRE set. It will try to start freeing keys that are going to expire
# in little time and preserve keys with a longer time to live.
# Redis will also try to remove objects from free lists if possible.
#
# If all this fails, Redis will start to reply with errors to commands
# that will use more memory, like SET, LPUSH, and so on, and will continue
# to reply to most read-only commands like GET.
#
# WARNING: maxmemory can be a good idea mainly if you want to use Redis as a
# 'state' server or cache, not as a real DB. When Redis is used as a real
# database the memory usage will grow over the weeks, it will be obvious if
# it is going to use too much memory in the long run, and you'll have the time
# to upgrade. With maxmemory after the limit is reached you'll start to get
# errors for write operations, and this may even lead to DB inconsistency.

# maxmemory <bytes>

############################### ADVANCED CONFIG ###############################

# Glue small output buffers together in order to send small replies in a
# single TCP packet. Uses a bit more CPU but most of the times it is a win
# in terms of number of queries per second. Use 'yes' if unsure.
glueoutputbuf yes

# Use object sharing. Can save a lot of memory if you have many common
# string in your dataset, but performs lookups against the shared objects
# pool so it uses more CPU and can be a bit slower. Usually it's a good
# idea.
#
# When object sharing is enabled (shareobjects yes) you can use
# shareobjectspoolsize to control the size of the pool used in order to try
# object sharing. A bigger pool size will lead to better sharing capabilities.
# In general you want this value to be at least the double of the number of
# very common strings you have in your dataset.
#
# WARNING: object sharing is experimental, don't enable this feature
# in production before of Redis 1.0-stable. Still please try this feature in
# your development environment so that we can test it better.
shareobjects no
shareobjectspoolsize 1024
EOS

class Redis <Formula
  @url='http://redis.googlecode.com/files/redis-1.0.tar.gz'
  @homepage='http://code.google.com/p/redis/'
  @md5='0bc1f0daca6abf92cdc4f00613ee1f2a'

  def install
    system "make"

    (share+'redis').install %w( utils client-libraries doc )
    bin.install %w( redis-benchmark redis-cli redis-server )

     # set up the conf file
    (etc+'redis.conf').write REDIS_CONF
  end

  def caveats
    "To start redis: $ redis-server #{etc}/redis.conf"
  end
end
