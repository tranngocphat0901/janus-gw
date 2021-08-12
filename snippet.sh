
curl -X GET http://localhost:6088/janus/info 2>&1| awk -F ' ' '/\"local-ip\"/ {print $2}'

local-ip=$(curl -X GET http://localhost:6088/janus/info 2>&1| awk -F ' ' '/\"local-ip\"/ {print $2}');
echo "Janus local-ip received: ${local-ip}";

## create session
session_id=5;
curl -X POST http://localhost:6088/janus --data "{\"transaction\": \"demo-rtp-fowarding\", \"janus\": \"create\", \"id\":$session_id}" 

## create handle
handle=$(curl -X POST http://localhost:6088/janus/5 --data "{
          \"transaction\": \"demo-rtp-fowarding\",
          \"janus\": \"attach\",
          \"plugin\": \"janus.plugin.streaming\"}" 2>&1| awk -F ' ' '/\"id\"/ {print $2}');

handle=$(curl -X POST http://localhost:6088/janus/5 --data "{
          \"transaction\": \"demo-rtp-fowarding\",
          \"janus\": \"attach\",
          \"plugin\": \"janus.plugin.streaming\"}" 2>&1| awk -F ' ' '/\"id\"/ {print $2}');
echo "Handle received: $handle";

## list mountpoints
session_id=$(curl -X POST http://localhost:8088/janus -d "{
  \"janus\": \"create\",
  \"transaction\": \"demo-rtp-fowarding\"}" 2>/dev/null  | awk -F ' ' '/\"id\"/ {print $2}');
handle_id=$(curl -X POST http://localhost:8088/janus/$session_id --data "{
  \"transaction\": \"demo-rtp-fowarding\", 
  \"janus\": \"attach\", 
  \"plugin\":\"janus.plugin.streaming\"}" 2>/dev/null | awk -F ' ' '/\"id\"/ {print $2}');
curl -X POST http://localhost:8088/janus/$session_id/$handle_id --data "{
  \"transaction\": \"demo-rtp-fowarding\",
  \"janus\": \"message\",
  \"body\": {
    \"request\": \"list\"}}";

## destroy mountpoint
mountpoint_id=1299111707080483
session_id=$(curl -X POST http://localhost:8088/janus -d "{
  \"janus\": \"create\",
  \"transaction\": \"demo-rtp-fowarding\"}" 2>/dev/null  | awk -F ' ' '/\"id\"/ {print $2}');
handle_id=$(curl -X POST http://localhost:8088/janus/$session_id --data "{
  \"transaction\": \"demo-rtp-fowarding\", 
  \"janus\": \"attach\", 
  \"plugin\":\"janus.plugin.streaming\"}" 2>/dev/null | awk -F ' ' '/\"id\"/ {print $2}');
curl -X POST http://localhost:8088/janus/$session_id/$handle_id --data "{
  \"transaction\": \"demo-rtp-fowarding\",
  \"janus\": \"message\",
  \"body\": {
    \"request\": \"destroy\",
    \"id\": ${mountpoint_id}}}";

# =============================================


## create mountpoint
mountpoint_id=7;
session_id=$(curl -X POST http://localhost:8088/janus -d "{
  \"janus\": \"create\",
  \"transaction\": \"demo-rtp-fowarding\"}" 2>/dev/null  | awk -F ' ' '/\"id\"/ {print $2}');

handle_id=$(curl -X POST http://localhost:8088/janus/$session_id --data "{
  \"transaction\": \"demo-rtp-fowarding\", 
  \"janus\": \"attach\", 
  \"plugin\":\"janus.plugin.streaming\"}" 2>/dev/null | awk -F ' ' '/\"id\"/ {print $2}');
curl -X POST http://localhost:6088/janus/${session_id}/${handle_id} --data "{
  \"transaction\": \"demo-rtp-fowarding\",
  \"janus\": \"message\",
  \"body\": {
    \"request\": \"create\",
    \"type\": \"rtp\",
    \"audio\": true,
    \"audioport\": 5007,
    \"audiopt\": 111,
    \"audiortpmap\": \"opus/48000/2\",
    \"video\": true,
    \"videoport\": 5008,
    \"videopt\": 100,
    \"videortpmap\":\"VP8/90000\",
    \"id\": $mountpoint_id }}";

# ===============================================
## create session
session_id=$(curl -X POST http://localhost:8088/janus -d "{
  \"janus\": \"create\",
  \"transaction\": \"demo-rtp-fowarding\"}" 2>/dev/null  | awk -F ' ' '/\"id\"/ {print $2}');
echo "Session id: $session_id";

## create handle
handle_id=$(curl -X POST http://localhost:8088/janus/$session_id --data "{
  \"transaction\": \"demo-rtp-fowarding\", 
  \"janus\": \"attach\", 
  \"plugin\":\"janus.plugin.videoroom\"}" 2>/dev/null | awk -F ' ' '/\"id\"/ {print $2}');
echo "Handle id: $handle_id" ;

## create room
curl -X POST http://localhost:8088/janus/$session_id/$handle_id --data "{
  \"transaction\": \"demo-rtp-fowarding\", 
  \"janus\": \"message\", 
  \"body\": {
    \"request\": \"create\", 
    \"room\": 4321, 
    \"publishers\": 1, 
    \"bitrate\":128000, 
    \"record\": false, 
    \"description\": \"culo\", 
    \"fir_freq\": 100}}"  2>/dev/null;
room_id=4321

# room_id=$(curl -X POST http://localhost:8088/janus/$session_id/$handle_id --data "{\"transaction\": \"demo-rtp-fowarding\", \"janus\": \"message\", \"body\": {\"request\": \"list\"}}"  2>/dev/null | awk -F ' ' '/\"room\"/ {print $2}' | cut -d ',' -f 1 | tail -n1)  ; echo "Room id: $room_id" 

## get publisher_id
user_id=$(curl -X POST http://localhost:8088/janus/$session_id/$handle_id --data "{
  \"transaction\": \"demo-rtp-fowarding\", 
  \"janus\": \"message\", 
  \"body\": {
    \"request\": \"listparticipants\", 
    \"room\": $room_id}}" 2>/dev/null | awk -F ' ' '/\"id\"/ {print $2}' | cut -d ',' -f 1);
echo "User id: $user_id" 

## create rtp_forward
curl -X POST http://localhost:8088/janus/$session_id/$handle_id --data "{ 
  \"transaction\": \"demo-rtp-fowarding\", 
  \"janus\": \"message\", 
  \"body\": { 
    \"request\": \"rtp_forward\", 
    \"room\": $room_id, 
    \"publisher_id\": $user_id, 
    \"host\": \"localhost\", 
    \"audio_port\": 5007, 
    \"video_port\": 5008, 
    \"audio_pt\": 111, 
    \"video_pt\": 98, 
    \"secret\": \"adminpwd\"}}" 
# curl -X POST http://localhost:8088/janus/$session_id/$handle_id --data "{\"transaction\": \"demo-rtp-fowarding\", \"janus\": \"message\", \"body\": {\"request\": \"rtp_forward\", \"room\": $room_id, \"publisher_id\": $user_id, \"host\": \"localhost\", \"audio_port\": 5007, \"video_port\": 5008, \"audio_pt\": 111, \"video_pt\": 98, \"secret\": \"adminpwd\"}}" 





# ===============================================
audio_port=5027;
audio_pt=111;
video_port=5028;
video_pt=100;

janus_server="http://localhost:8088/janus";
session_id=$(curl -X POST $janus_server -d "{
  \"janus\": \"create\",
  \"transaction\": \"demo-rtp-fowarding\"}" 2>/dev/null  | awk -F ' ' '/\"id\"/ {print $2}');
echo "Session id: $session_id";
handle=$(curl -X POST $janus_server/$session_id --data "{
          \"transaction\": \"demo-rtp-fowarding\",
          \"janus\": \"attach\",
          \"plugin\": \"janus.plugin.streaming\"}" 2>&1| awk -F ' ' '/\"id\"/ {print $2}');
echo "Handle received: $handle";
mountpoint_id=$(curl -X POST $janus_server/$session_id/$handle --data "{
  \"transaction\": \"demo-rtp-fowarding\",
  \"janus\": \"message\",
  \"body\": {
    \"request\": \"create\",
    \"type\": \"rtp\",
    \"audio\": true,
    \"audioport\": $audio_port,
    \"audiopt\": $audio_pt,
    \"audiortpmap\": \"opus/48000/2\",
    \"video\": true,
    \"videoport\": $video_port,
    \"videopt\": $video_pt,
    \"videortpmap\":\"VP8/90000\",
    \"description\": \"demo-rtp-fowarding\"}}" 2>&1| awk -F ' ' '/\"id\"/ {print $2}');
echo "Mountpoint id: $mountpoint_id" ;





# ===============================================
room_id=9091;
janus_server="http://localhost:8088/janus";

session_id=$(curl -X POST $janus_server -d "{
  \"janus\": \"create\",
  \"transaction\": \"demo-rtp-fowarding\"}" 2>/dev/null  | awk -F ' ' '/\"id\"/ {print $2}');
echo "Session id: $session_id";
handle_id=$(curl -X POST $janus_server/$session_id --data "{
  \"transaction\": \"demo-rtp-fowarding\", 
  \"janus\": \"attach\", 
  \"plugin\":\"janus.plugin.videoroom\"}" 2>/dev/null | awk -F ' ' '/\"id\"/ {print $2}');
echo "Handle id: $handle_id" ;
curl -X POST $janus_server/$session_id/$handle_id --data "{
  \"transaction\": \"demo-rtp-fowarding\", 
  \"janus\": \"message\", 
  \"body\": {
    \"request\": \"create\", 
    \"room\": $room_id, 
    \"publishers\": 1, 
    \"bitrate\":128000, 
    \"record\": false, 
    \"description\": \"demo-rtp-fowarding\", 
    \"fir_freq\": 100}}"  2>/dev/null;

# join vo room
open "http://localhost:81/videoroomtest.html?room=9090"


audio_port=5027;
audio_pt=111;
video_port=5028;
video_pt=100;

janus_server="http://localhost:8088/janus";
session_id=$(curl -X POST $janus_server -d "{
  \"janus\": \"create\",
  \"transaction\": \"demo-rtp-fowarding\"}" 2>/dev/null  | awk -F ' ' '/\"id\"/ {print $2}');
echo "Session id: $session_id";
handle_id=$(curl -X POST $janus_server/$session_id --data "{
  \"transaction\": \"demo-rtp-fowarding\", 
  \"janus\": \"attach\", 
  \"plugin\":\"janus.plugin.videoroom\"}" 2>/dev/null | awk -F ' ' '/\"id\"/ {print $2}');
echo "Handle id: $handle_id" ;
user_id=$(curl -X POST $janus_server/$session_id/$handle_id --data "{
  \"transaction\": \"demo-rtp-fowarding\", 
  \"janus\": \"message\", 
  \"body\": {
    \"request\": \"listparticipants\", 
    \"room\": $room_id}}" 2>/dev/null | awk -F ' ' '/\"id\"/ {print $2}' | cut -d ',' -f 1);
echo "User id: $user_id";
curl -X POST $janus_server/$session_id/$handle_id --data "{ 
  \"transaction\": \"demo-rtp-fowarding\", 
  \"janus\": \"message\", 
  \"body\": { 
    \"request\": \"rtp_forward\", 
    \"room\": $room_id, 
    \"publisher_id\": $user_id, 
    \"host\": \"localhost\", 
    \"audio_port\": $audio_port, 
    \"video_port\": $video_port, 
    \"audio_pt\": 111, 
    \"video_pt\": 100, 
    \"secret\": \"adminpwd\"}}" ;
# ================================================ß==============



docker-compose -f janus1/docker-compose.yml down;
docker-compose -f janus1/docker-compose.yml up -d;   
docker-compose -f janus2/docker-compose.yml down;
docker-compose -f janus2/docker-compose.yml up -d;