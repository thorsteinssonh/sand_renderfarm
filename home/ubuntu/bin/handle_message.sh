#! /bin/bash
LOGFILE=$HOME/log/handle_render_frame.log

message=$(basename $1)

if [ "$message" == "render_task_complete" ]; then
    # wait a bit, then check if render process running,
    # if not, shutdown this instance
    sleep 5
    pgrep render_task.sh || (sudo shutdown -h now)
fi

# cleanup
rm -f $1

