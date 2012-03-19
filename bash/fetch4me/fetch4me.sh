#!/bin/bash -e

files_in_queue=""
iterator=0
optindex=0
args=""
ref=""
QQEDIR="${HOME}/.fetch4me"
GETELEMFUNC="wget"

startdaemon() {
exec >/dev/null 
exec < /dev/null
1>&2
(  
trap "" HUP 

while true 
do 
while [ -f $QQEDIR/.locked_queue ]; do
	sleep 1
done

if [ -f $QQEDIR/.queue ]; then
mv $QQEDIR/.queue $QQEDIR/.locked_queue
	exec 10<&0

exec < "$QQEDIR/.locked_queue"
iterator=0

  if [ -d $QQEDIR ] ; then
	for file in $QQEDIR/* ; do
	if [ "$file" != "$QQEDIR/*" ]; then
		echo `cat "$file"` >> $QQEDIR/.locked_queue
		iterator=$[ $iterator + 1 ]
		rm -rf "$file"
	fi
	done
fi

iterator=0
files_in_queue[0]=""
while read l; do
	files_in_queue[$iterator]=$l
	iterator=$[ $iterator + 1 ]
done

>$QQEDIR/.status
if [ $iterator -ne 0 ]; then
	ar=(${files_in_queue[0]});
	if [ ${#ar[*]} -eq 8 ]; then
		r=${ar[6]:10}
		url=${ar[7]}
		echo "Downloading ${r} ${url}" >> $QQEDIR/.status
	else
	if [ ${#ar[*]} -eq 7 ]; then
		url=${ar[6]}
		echo "Downloading ${url}" >> $QQEDIR/.status
	fi
	fi
fi
  for (( i=1;i<$iterator;i++)); do  
	ar=(${files_in_queue[${i}]});
	if [ ${#ar[*]} -eq 8 ]; then
		r=${ar[6]:10}
		url=${ar[7]}
		echo "Queued file number ${i} ${r} ${url}" >> $QQEDIR/.status
	else
	if [ ${#ar[*]} -eq 7 ]; then
		url=${ar[6]}
		echo "Queued file number ${i} ${url}" >> $QQEDIR/.status
	fi
	fi
	done	

exec 0<&10 10<&-
mv $QQEDIR/.locked_queue $QQEDIR/.queue

if ${files_in_queue[0]} >> /dev/null;
	then
	ar=(${files_in_queue[0]});
	if [ ${#ar[*]} -eq 8 ]; then
		r=${ar[6]:10}
		url=${ar[7]}
		echo "`date +%s` ${r} ${url}" >> $QQEDIR/.finished
	else
	if [ ${#ar[*]} -eq 7 ]; then
		url=${ar[6]}
		echo "`date +%s` ${url}" >> $QQEDIR/.finished
	fi
	fi
	
while [ -f $QQEDIR/.locked_queue ]; do
	sleep 1
done

mv $QQEDIR/.queue $QQEDIR/.locked_queue
	exec 10<&0

exec < "$QQEDIR/.locked_queue"
iterator=0

while read l; do
	files_in_queue[$iterator]=$l
	iterator=$[ $iterator + 1 ]
done
>$QQEDIR/.locked_queue
  for (( i=1;i<$iterator;i++)); do  
    echo ${files_in_queue[${i}]} >> $QQEDIR/.locked_queue
	done	
	
exec 0<&10 10<&-
mv $QQEDIR/.locked_queue $QQEDIR/.queue
fi
else 
case "$?" in
       "1")   echo "Generic error code."
       exit $?
	;;
       "2")   echo "Parse error---for instance, when parsing command-l options, the .wgetrc or .netrc..."
	exit $?
	;;
       "3")   echo "File I/O error."
       echo "out of space" >> $QQEDIR/.status
       exit $?
	;;
       "4")   echo "Network failure."
       exit $?
	;;
       "5")   echo "SSL verification failure."
       exit $?
	;;
       "6")   echo "Username/password authentication failure."
       exit $?
	;;
       "7")   echo "Protocol errors."
       exit $?
	;;
       "8")   echo "Server issued an error response."
       exit $?
	;;
esac
fi	
sleep 1
done 
) & 
newpid=$!
echo $newpid > $QQEDIR/.pid
disown -h $newpid
}

firststart() {
if [ ! -f $QQEDIR/.queue ]; then
	if [ ! -f $QQEDIR/.locked_queue ]; then
		touch $QQEDIR/.queue
	fi
fi
}

showhelp () {
echo "
Usage:  $0 [-w <dir>] [-r <referer>] (<url>)*

Parameters:
    -w - QQEDIR
    -r - referer
"
    exit $?
}

start() {
if [ -f $QQEDIR/.pid ]; 
then
	THISPID=`cat $QQEDIR/.pid`
	if ps -A | grep ${THISPID} | grep fetch4me >> /dev/null
	then
		echo "files added"
	else startdaemon
	fi	
else startdaemon
fi
}

getoptions () {
while getopts 2>/dev/null "r:w:h"  optname 
  do
    case "$optname" in
        "r")
        ref="$OPTARG"
        ;;
        "w")
        QQEDIR="$OPTARG"
        ;;
        "h")
        showhelp
        exit 1
        ;;
      "?")
        echo "Unknown option $OPTARG"
        exit 1
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        exit 1
        ;;
      *)
        echo "Unknown error while processing options"
        exit 1
        ;;
    esac
  done
  optindex=$OPTIND
return 0
}

showargs () {
  args=("$@")
  numargs=${#args[@]}
if [ $numargs -ne 0 ]; then
  for (( i=0;i<$numargs;i++)); do  
        withoutslashes=$QQEDIR/.`echo ${args[${i}]} | sed -e 's/\///g'`
      if [ -z $ref ]; then
      echo "$GETELEMFUNC -P ${HOME}/Downloads/fetched4you/${args[${i}]} -o log -c ${args[${i}]}" > $withoutslashes
    else
    echo "$GETELEMFUNC -P ${HOME}/Downloads/fetched4you/${ref}/${args[${i}]} -o log -c --ref=$ref ${args[${i}]}" > $withoutslashes
  fi
  mv $withoutslashes $QQEDIR/`echo ${args[${i}]} | sed -e 's/\///g'`
  done 
else
  if [ -n $ref ]; then 
    echo "ref without file to dwnload"
 #   exit 1;
  fi
fi

}

readrc() {
exec 10<&0

exec < "${HOME}/.fetch4merc"

while read l; do
    if [ `echo ${l} | awk '{print $1}'` = QQEDIR ] 
	then
    QQEDIR=`echo ${l} | awk '{print $3}'`
	else    
    if [ `echo ${l} | awk '{print $1}'` = GETELEMFUNC ] 
    	then
    GETELEMFUNC=`echo ${l} | awk '{print $3}'`
    fi
    fi
done

exec 0<&10 10<&-
}

readrc

getoptions "$@"

if [ ! -d $QQEDIR ]; then
mkdir $QQEDIR
fi

showargs "${@:$optindex}"

firststart
start