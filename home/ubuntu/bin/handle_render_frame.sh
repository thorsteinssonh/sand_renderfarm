#! /bin/bash
filen=$(basename $1)
taskfolder=${filen%%_*}
remainder=${filen#*_}
scenefolder=${remainder%_*}

aws s3 cp $1 s3://sandrbucket/$taskfolder/$scenefolder/ && echo "sent file $1" || echo "failed to send $1"

# cleanup
rm -f $1

