// JavaScript Document

//************************** CSRF COOKIE **************************//
function getCookie(name) {
    var cookieValue = null;
    if (document.cookie && document.cookie !== '') {
        var cookies = document.cookie.split(';');
        for (var i = 0; i < cookies.length; i++) {
            var cookie = jQuery.trim(cookies[i]);
            // Does this cookie string begin with the name we want?
            if (cookie.substring(0, name.length + 1) === (name + '=')) {
                cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                break;
            }
        }
    }
    return cookieValue;
}

function csrfSafeMethod(method) {
    // these HTTP methods do not require CSRF protection
    return (/^(GET|HEAD|OPTIONS|TRACE)$/.test(method));
}

const csrftoken = getCookie('csrftoken');
//************************** CSRF COOKIE **************************//

var rec_btn_cnt = 1;
var play_btn_cnt = 1;

//************************** RECORD **************************//
function __log(e, data) {
    //log.innerHTML += "\n" + e + " " + (data || '');
    console.log("\n" + e + " " + (data || ''));
}

var reco;
var audio_context;

function create_stream(user_media) {
    var stream_input = audio_context.createMediaStreamSource(user_media);
    audio_context.resume();
    __log("Media stream created")
    reco = new Recorder(stream_input);
    __log("Recorder initialized");
}

window.onload = function init() {
    try {
        window.AudioContext = window.AudioContext || window.webkitAudioContext;
        if (navigator.mediaDevices === undefined) {
            navigator.mediaDevices = {};
        }
        if (navigator.mediaDevices.getUserMedia === undefined) {
            navigator.mediaDevices.getUserMedia = function (constraints) {
                let getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia;
                if (!getUserMedia) {
                    return Promise.reject(new Error("getUserMedia is not implemented in this browser"))
                }
                return new Promise(function (resolve, reject) {
                    getUserMedia.call(navigator, constraints, resolve, reject);
                });
            }
        }
        window.URL = window.URL || window.webkitURL;
        audio_context = new AudioContext;
        __log("Audio context set up");
        __log('navigator.getUserMedia ' + (navigator.getUserMedia ? 'available.' : 'not present!'));
    } catch (e) {
        alert("No web audio support in this browser!");
    }
    navigator.mediaDevices.getUserMedia({ audio: true }).then(function (user_media) {
        create_stream(user_media)
    })
    .catch(function(e) {
        __log('No live audio input: ' + e);
    });
};

function start_reco() {
    $("#wav_div").empty();
    //window.history.pushState("/demo/")
    reco && reco.record();
    __log("Recording...");
}

function stop_reco() {
    reco && reco.stop();
    __log("Stopped recording");
    __log($("#language").val());
    language = $("#language").val();
    reco.exportWAV(function (blob) {
        var formAudio = new FormData();
	      formAudio.append("audio", blob);
        formAudio.append("name", "recordfile");
        formAudio.append("language", language);

        var url = window.URL.createObjectURL(blob);

        $("<audio>").attr({
            id: "audio_control"
        }).appendTo("#wav_div");

        $("#audio_control").attr("controls", true);
        $("#audio_control").attr("src", url);

        //*************
        //const request = new Request(
        //    "/demo/record/", {
        //        headers: { 'X-CSRFToken': csrftoken }
        //    });

        //fetch(request, {
        //    method: 'POST',
        //    body: formAudio,
        //    mode: 'same-origin'  // Do not send CSRF token to another domain.
        //}).then(function (response) { return response.formData(); });
        $.ajax({
            url: "/demo/record/",
            type: 'POST',
            async: true,
	          cache: false,
            processData: false,
            contentType: false,
            data: formAudio,
            success: function (context) {
                $("#bar").attr("style", "width:" + String(0) + "%");
                $("#display").html(context["text"]);
            },
            error: function () {
                alert("Failed");
            }
        });
        //*************
    });
    reco.clear();
}
//************************** RECORD **************************//

$(function(){
	$("#record_btn").click(function(){
		/* alert($(this).css("background-color")) */
		if(rec_btn_cnt == 1)
		{
			$(this).css("background-color", "#E71D32");
			$(this).css("color", "#FFF");
			$("#record_img").attr("src", "../../static/image/stop.png");
            		rec_btn_cnt *= -1;
			start_reco();
		}
		else if(rec_btn_cnt == -1)
        	{
            		$("#bar").attr("style", "width:" + String(100) + "%");
			$(this).css("background-color", "#FFF");
			$(this).css("color", "#000");
			$("#record_img").attr("src", "../../static/image/recorder.png");
            		rec_btn_cnt *= -1;
			stop_reco();
		}
	});

	$("#play_btn").click(function(){
		if(play_btn_cnt == 1)
		{
			$("#play_img").attr("src", "../../static/image/stop.png")
			play_btn_cnt *= -1;
		}
		else if(play_btn_cnt == -1)
		{
			$("#play_img").attr("src", "../../static/image/play.png")
			play_btn_cnt *= -1;
		}
	});

    $("#upload_btn").click(function(){
        $("#audiofile").click();
	});

    $("#audiofile").change(function () {
      	$("#language_form").val($("#language").val());
        $("#submit_btn").click();
        for (i = 0; i <= 1000; i++) {
            $("#bar").attr("style", "width:" + String(i/10) + "%");
        }
    });

});
