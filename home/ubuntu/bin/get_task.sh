#! /bin/bash

# vars
LOGFILE=$HOME/log/render_task.log
WORKDIR=$HOME/work/rendertask
MSGDIR=$HOME/message

mkdir -p $WORKDIR
cd $WORKDIR 

taskfile_listing=$(aws s3 ls s3://sandschedulebucket/ | grep ".zip$" | head -1)

taskfile=${taskfile_listing##* }
taskname=${taskfile%.zip}

if [ -z $taskfile ]; then
	echo "No render task found"
	echo ""
	exit 1
fi

# fetch file
echo "Task found: $taskfile"
aws s3 cp s3://sandschedulebucket/$taskfile ./

# extract
unzip -o $taskfile

# clean up zip file
rm -f $taskfile

# echo taskname
echo "Taskname is:"
echo $taskname

