#! /bin/bash

# opts
taskname=$1
DEV="cpu"
while (($#)); do
case $1 in --device)
DEV=$2 ;;
esac;
shift; done

echo "Render task: $taskname"
echo "Render device: $DEV"

# vars
LOGDIR=$HOME/log
LOGFILE=$LOGDIR/render_task.log
WORKDIR=$HOME/work/rendertask
MSGDIR=$HOME/message
BLENDER="/opt/blender-2.75a-linux-glibc211-x86_64/blender"
BLENDER_SETUP_FILE="/home/ubuntu/python/${DEV}_setup.py"
S3BUCKET="sandrbucket"

# This instance index
IID=$(curl http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)
IID=${IID:2}
if [ "$DEV" == "cpu" ]; then IID="f${IID}"; fi
echo "Instance ID: $IID"

cd $WORKDIR 

blendfile=$taskname.blend
cd $WORKDIR/$taskname/

# loop through render task files
for rendertaskfile in *.render; do

scene=${rendertaskfile%.render}
echo $scene

# get frame list
framesconf=$(grep "frames" $rendertaskfile)
frames=${framesconf#* }
start_frame=${frames% *}
stop_frame=${frames#* }
echo "start frame: $start_frame"
echo "stop  frame: $stop_frame"

# for this scene loop through frames and render
for ((i=$start_frame; i<=$stop_frame; i++)); do
	I=$(printf "%05d\n" $i)
	frameid=${taskname}_${scene}_${I}
	frameidlog=${LOGDIR}/${frameid}_${IID}.log
	listing=$(aws s3 ls s3://${S3BUCKET}/${taskname}_progress/${scene}/)
	echo ---------
	if [[ $listing != *"$frameid"* ]]
	then
		echo "Beginning work on ${frameid}"
		# mark this frame id as taken with lock file on s3
		touch ${frameid}_${IID}
		aws s3 cp ${frameid}_${IID} s3://${S3BUCKET}/${taskname}_progress/${scene}/

		# sleep 2 and check no conflict
		sleep 2
		listing=$(aws s3 ls s3://${S3BUCKET}/${taskname}_progress/${scene}/ | grep ${frameid})
		while read -r line; do
			tiid=${line##*_};
			if (( 16#$tiid < 16#$IID )); then
				# some other node with lower IID also working on the frame.
				echo "Node $tiid already working on frame: skipping"
				# mark conflicting lock file as skipped
				aws s3 cp ${frameid}_${IID} s3://${S3BUCKET}/${taskname}_progress/${scene}/${frameid}_${IID}_skipping
				continue 2
			fi
		done <<< "$listing"
		# render this frameid
		echo "Rendering frame ${frameid}"
		echo "Rendering frame ${frameid}" >> $frameidlog
		LC_ALL="C" $BLENDER -b $blendfile -P ${BLENDER_SETUP_FILE} -S ${scene} -o $HOME/render/${taskname}_${scene}_##### -f $i >> $frameidlog 2>&1
		# check render folder status
		ls -l $HOME/render/ >> $frameidlog 2>&1
		# upload render log
		zip ${frameidlog}.zip ${frameidlog}
		aws s3 cp ${frameidlog}.zip s3://${S3BUCKET}/${taskname}_log/${scene}/
	else
		echo "Another node has lock on ${frameid}"
	fi
	echo ---------
done
echo "Scene ${scene} complete"
done
# all jobs complete, register message
touch $MSGDIR/render_task_complete
