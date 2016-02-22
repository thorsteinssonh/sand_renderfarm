install blender under /opt/blender..version../

setup incrontab event handlers:
/home/ubuntu/render IN_CLOSE_WRITE /home/ubuntu/bin/handle_render_frame.sh $@/$#
/home/ubuntu/message IN_CLOSE_WRITE /home/ubuntu/bin/handle_message.sh $@/$#

The rc.local under /etc/rc.local will kick off rendering on virtual machine boot-up.
