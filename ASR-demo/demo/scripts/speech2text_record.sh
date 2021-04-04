#!/bin/bash
audio_file="/home/ASR-online-demo/ASR-demo/demo/static/upload/recordAudio.wav"
audio_file="test_audio.wav"
curl -X POST -u "apikey:86MYTsm1Z-jYr8t29Xp6n4u6gmehsY0uuywtpWnR2Zfy" --header "Content-Type: audio/wav" --data-binary @/home/ASR-online-demo/ASR-demo/demo/static/upload/recordAudio.wav "https://gateway-tok.watsonplatform.net/speech-to-text/api/v1/recognize?model=en-US_BroadbandModel"  
