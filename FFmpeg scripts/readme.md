# FFmpeg scripts

The directory contains a few FFmpeg scripts used for this project. <br/>

The scripts can here can both be used separately, as well as in conjuncture with scripts from other repositories ( after making the necessary changes in the scripts as highlighted ). 

## Explanations of a few arguments used in the script are as follows:

 ```ffmpeg``` - self explanatory
 
 ```-f dshow ``` -  use direct show as file type. Microsoft DirectShow only works on Windows. Check alternatives for other operating systems. See [FFmpeg's DirectShow page for more info](https://trac.ffmpeg.org/wiki/DirectShow).
 
 ```-rtbufsize 1000M ``` - buffer size for the camera
 
 ```-i video="Integrated Camera":audio="Microphone (Realtek(R) Audio)" ``` - inputs (use ffmpeg -list_devices true -f dshow -i dummy to get list of possible sources).
 
 ```-map_metadata 0 ``` - copies metadata from source file, useful when transmitting stored files
 
 ```-c copy ``` - copies the source video codec
 
 ```-c:v libx265 ``` - video codec (libx265 for h265).
 
 `-preset ultrafast` - encoding preset (ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo).
 
 `-thread_type slice` - slice-based threading tells all CPU threads work on the same frame, reducing latency a lot.
 
 ```-maxrate 250k ``` - max data rate video
 
 ```-bufsize 6000k ``` - buffer size for encoding, double max data rate seems to be a good starting point.
 
 ```-pix_fmt yuv420p ``` - color space of the video
 
 ```-g 60 ``` - GOP (Group of Pictures), simply multiply your output frame rate * 2.
 
 ```-c:a aac ``` - audio encode using AAC.
 
 ```-b:a 128k ``` - desired bitrate for audio 128 Kbps, can play with this.
 
 ```-ac 2 ``` - number of audio channels
 
 ```-ar 44100 ``` - audio sample rate 44.1 KHz.
 
 ```demoIn.mkv``` - output file

