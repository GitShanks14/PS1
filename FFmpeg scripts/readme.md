# FFmpeg scripts

The directory contains a few FFmpeg scripts used for this project. <br/>

The scripts can here can both be used separately, as well as in conjuncture with scripts from other repositories ( after making the necessary changes in the scripts as highlighted ). 

Explanations of a few arguments used in the script are as follows:

 ```ffmpeg``` - self explanatory
 
 ```-f dshow ```
 
 ```-rtbufsize 1000M ```
 ```-i video="Integrated Camera":audio="Microphone (Realtek(R) Audio)" ```
 
 ```-map_metadata 0 ```
 
 ```-c copy -c:v libx265 ```
 
 ```-preset ultrafast ```
 
 ```-thread_type slice ```
 
 ```-maxrate 250k ```
 
 ```-bufsize 6000k ```
 
 ```-pix_fmt yuv420p ```
 
 ```-g 60 ```
 
 ```-c:a aac ```
 
 ```-b:a 128k ```
 
 
 ```-ac 2 ```
 
 ```-ar 44100 ```
 
 ```demoIn.mkv```

What all the arguments mean:
==

`ffmpeg	-loglevel error` - logging level (quiet, error, warning).

`-f dshow` - use direct show as file type.

`-i video="USB Video Device":audio="Microphone (USB Audio Device)"` - inputs (use ffmpeg -list_devices true -f dshow -i dummy to get list of possible sources).

`-vcodec libx264` - video codec (libx264 for h264).

`-acodec aac` - audio codec (aac).

`-preset ultrafast` - encoding preset (ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo).

`-tune zerolatency` - tune zerolatency sends an I-Frame (complete pic) every frame so that users to not need to wait for intermetiate frames to complete.

`-thread_type slice` - slice-based threading tells all CPU threads work on the same frame, reducing latency a lot.

`-slices 1`  - has to be 1 for vMix to decode the stream, don't know why.

`-intra-refresh 1` intra-refresh has to be set to 1 because vMix expects a latency of 1 frame, I think.

`-r 30` - framerate.

`-g 60` - GOP (Group of Pictures), simply multiply your output frame rate * 2.

`-s 800x600` - scale my webcam's native picture is 1600x1200, so I scale it down.

`-aspect 4:3` - aspect ratio, my webcam is a Logitec 9000 which is 4:3.

`-acodec aac` - audio encode using AAC.

`-ar 44100` - audio sample rate 44.1 KHz.

`-b:v 2.5M` - desired bitrate for video 2.5 Mbps, can play with this.

`-minrate:v 900k` - min data rate video 900k, can play with this. 

`-maxrate:v 2.5M` - min data rate video 2.5 Mbps, can play with this.

`-bufsize:v 5M` - buffer size for encoding, double max data rate seems to be a good starting point.

`-b:a 128K` - desired bitrate for audio 128 Kbps, can play with this.

`-pix_fmt yuv420p ` - color space, has to be yuv420p for vMix to decode properly.

`-bufsize 5000k` - buffer size (double max data rate seems to be a good starting point)

`-f mpegts udp://192.168.0.123:35001?pkt_size=1316` output format mpegts udp IP address, port, packet size - really important - The size of an MPEG-TS packet is 188 Bytes and 7 of them will fit into an Ethernet frame, 7*188=1316.
