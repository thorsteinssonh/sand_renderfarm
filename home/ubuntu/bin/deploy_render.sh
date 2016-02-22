#! /bin/bash

taskname=$(/home/ubuntu/bin/get_task.sh | tail -1)
if [ -z $taskname ]; then
    echo "Exiting"
    exit
fi

/home/ubuntu/bin/render_task.sh $taskname --device gpu &
/home/ubuntu/bin/render_task.sh $taskname --device cpu &
