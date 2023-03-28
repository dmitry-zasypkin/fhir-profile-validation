#!/bin/bash

iris start $ISC_PACKAGE_INSTANCENAME quietly
 
cat << EOF | iris session $ISC_PACKAGE_INSTANCENAME -U USER
do ##class(%SYSTEM.Process).CurrentDirectory("$PWD")
$@
if '\$Get(sc,1) do ##class(%SYSTEM.Process).Terminate(, 1)
zn "%SYS"
do ##class(SYS.Container).QuiesceForBundling()
// Do ##class(Security.Users).UnExpireUserPasswords("*")  // moved to docker-compose.yml in order to keep the image as small as possible
halt
EOF

exit=$?

iris stop $ISC_PACKAGE_INSTANCENAME quietly

exit $exit