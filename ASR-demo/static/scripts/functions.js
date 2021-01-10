// JavaScript Document

var rec_btn_cnt = 1;
var play_btn_cnt = 1;
var reco = null;
var audio_context = new AudioContext();

navigator.getUserMedia = (navigator.getUserMedia ||
	navigator.webkitGetUserMedia ||
	navigator.mozGetUserMedia ||
	navigator.msGetUserMedia); 

function create_stream(user_media){
	var stream_input = audio_context.createMediaStreamSource(user_media);
	reco = new Recorder(stream_input);	
}

function start_reco() {
	reco.record();
}

function stop_reco() {
	reco.stop();
	reco.exportWAV(function (wav_file) {
	console.log(wav_file);
	var formData = new FormData(); 
	formData.append("audio", wav_file);
	formData.append("name", "recordfile");
	$.ajax({
		url: "http://localhost:8080/",
		type: 'POST',
		processData: false,
		contentType: false,
		data: formData,
		success: function (data) {
			console.log(data);
			window.location.href("https://localhost:8080/record/");
			},
		error: function(){alert("audio upload error");}
		})
  	});
	reco.clear();	
}

$(function(){
	$("#record_btn").click(function(){
		/* alert($(this).css("background-color")) */
		if(rec_btn_cnt == 1)
		{
			$(this).css("background-color", "#E71D32");	
			$(this).css("color", "#FFF");
			$("#record_img").attr("src", "../../static/image/stop.png");
			
			navigator.getUserMedia({audio: true}, create_stream, function (err) {
			console.log(err)});
						
			rec_btn_cnt *= -1;	
			start_reco();			
		}
		else if(rec_btn_cnt == -1)
		{
			$(this).css("background-color", "#FFF");
			$(this).css("color", "#000");
			$("#record_img").attr("src", "../../static/image/recorder.png");
			rec_btn_cnt *= -1;
			stop_reco();
		}

	});
	
	$("#play_btn").click(function(){
		/* alert($(this).css("background-color")) */
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
	
	// dataType: json jsonp text script xml html String 
//	$("#audiofile").change(function(){
//	var formData = new FormData();
//	file = $("#audiofile")[0].files[0];
//	formData.append("file", file);
//	formData.append("name", "audiofile");
//	/*alert(file);*/
//	$.ajax({
//		url:"/demo/",
//		type:"POST",
//		data:formData,
//		processData:false,
//		contentType:false,
//		success: function(){
//			window.location.href="/demo/upload/";
//			},
//		error: function(){alert("failed");}
//		});
//	});

	$("#audiofile").change(function(){
		if($("#audiofile").val() == ""){
			return;}	
		$("#uploadForm").ajaxSubmit({
			type:"post",
			dataType:"",
			success: function(){
				//$("#audiofile").val("");
				alert("ajaxSubmit succeed");
				window.location.href = "/upload/";
			},
			error: function(){
				alert("Failed");
			}
		});
	});
});
