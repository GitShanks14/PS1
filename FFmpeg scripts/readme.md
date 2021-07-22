# FFmpeg scripts

The directory contains a few FFmpeg scripts used for this project. <br/>

The scripts can here can both be used separately, as well as in conjuncture with scripts from other repositories ( after making the necessary changes in the scripts as highlighted ). 

Explanations of a few parameters used in the script are as follows:

 ```ffmpeg``` 
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
