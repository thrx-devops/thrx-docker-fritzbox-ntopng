#!/bin/bash

# This is the address of the router
FRITZIP=http://fritz.box

if [ -z "$IFACE" ] ; then 
   # This is the WAN interface
   IFACE="2-0"
   
   # Lan Interface
   #IFACE="1-lan"
fi


# Required: You must create & switch your Fritz!Box to usernamed-based login authentification!
#FRITZUSER=$1
#FRITZPWD=$2

SIDFILE="/tmp/fritz.sid"

if [ -z "$FRITZPWD" ] || [ -z "$FRITZUSER" ]  ; then echo "Username/Password empty. Usage: $0 <username> <password>" ; exit 1; fi

echo "Trying to login into $FRITZIP as user $FRITZUSER"

if [ ! -f $SIDFILE ]; then
  touch $SIDFILE
fi

#SID=$(cat $SIDFILE)

# Request challenge token from Fritz!Box
#CHALLENGE=$(curl -k -s $FRITZIP/login_sid.lua |  grep -o "<Challenge>[a-z0-9]\{8\}" | cut -d'>' -f 2)

# Very proprieatry way of AVM: Create a authentication token by hashing challenge token with password
#HASH=$(perl -MPOSIX -e '
#    use Digest::MD5 "md5_hex";
#    my $ch_Pw = "$ARGV[0]-$ARGV[1]";
#    $ch_Pw =~ s/(.)/$1 . chr(0)/eg;
#    my $md5 = lc(md5_hex($ch_Pw));
#    print $md5;
#  ' -- "$CHALLENGE" "$FRITZPWD")
#  curl -k -s "$FRITZIP/login_sid.lua" -d "response=$CHALLENGE-$HASH" -d 'username='${FRITZUSER} | grep -o "<SID>[a-z0-9]\{16\}" | cut -d'>' -f 2 > $SIDFILE

#SID=$(cat $SIDFILE)

# Login and get SID
username=${FRITZUSER}
password=${FRITZPWD}
box_url=${FRITZIP}
challenge=$(curl -k -s $FRITZIP/login_sid.lua |  grep -o "<Challenge>[a-z0-9]\{8\}" | cut -d'>' -f 2)
#challenge=$(curl -s "${box_url}/login_sid.lua?username=${username}" | grep -Po '(?<=).*(?=)') 
echo "received challenge: $challenge"
md5=$(echo -n ${challenge}"-"${password} | iconv -f ISO8859-1 -t UTF-16LE | md5sum -b | awk '{print substr($0,1,32)}') 
echo "md5 created: $md5"
response="${challenge}-${md5}"
echo "using response: $response"
SID=$(curl -i -s -k -d "response=${response}&username=${username}" "${box_url}" | grep -Po -m 1 '(?<=sid=)[a-f\d]+')

echo "received SID: $SID"

# Check for successfull authentification
if [[ $SID =~ ^0+$ ]] ; then echo "Login failed. Did you create & use explicit Fritz!Box users?" ; exit 1 ; fi

echo "Capturing traffic on Fritz!Box interface $IFACE ..." 1>&2

# In case you want to use tshark instead of ntopng
#wget --no-check-certificate -qO- $FRITZIP/cgi-bin/capture_notimeout?ifaceorminor=$IFACE\&snaplen=\&capture=Start\&sid=$SID | /usr/bin/tshark -r -

# Start redis
#https://github.com/antirez/redis/issues/5055
sed -i "s/bind .*/bind 127.0.0.1/g" /etc/redis/redis.conf
/etc/init.d/redis-server start

#tail -f /var/log/redis/redis-server.log

wget --no-check-certificate -qO- $FRITZIP/cgi-bin/capture_notimeout?ifaceorminor=$IFACE\&snaplen=\&capture=Start\&sid=$SID | ntopng -i -

#curl -kv $FRITZIP/cgi-bin/capture_notimeout?ifaceorminor=$IFACE\&snaplen=\&capture=Start\&sid=${SID}

## for test:
#Angefragte Adresse:http://fritz.box/cgi-bin/capture_notimeout?sid=9bfc4ba412b39802&capture=Start&snaplen=1600&ifaceorminor=1-lan
#Angefragte Adresse:http://fritz.box/cgi-bin/capture_notimeout?sid=9bfc4ba412b39802&capture=Start&snaplen=1600&ifaceorminor=1-wan
