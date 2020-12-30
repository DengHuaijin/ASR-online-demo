// JavaScript Document

var rec_btn_cnt = 1;
var play_btn_cnt = 1;
$(function(){
	$("#record_btn").click(function(){
		/* alert($(this).css("background-color")) */
		if(rec_btn_cnt == 1)
		{
			$(this).css("background-color", "#E71D32");	
			$(this).css("color", "#FFF")
			$("#record_img").attr("src", "../../static/demo/image/stop.png")
			rec_btn_cnt *= -1;				
		}
		else if(rec_btn_cnt == -1)
		{
			$(this).css("background-color", "#FFF");
			$(this).css("color", "#000")
			$("#record_img").attr("src", "../../static/demo/image/recorder.png")
			rec_btn_cnt *= -1;
		}

	});
	
	$("#play_btn").click(function(){
		/* alert($(this).css("background-color")) */
		if(play_btn_cnt == 1)
		{
			$("#play_img").attr("src", "../../static/demo/image/stop.png")
			play_btn_cnt *= -1;				
		}
		else if(play_btn_cnt == -1)
		{
			$("#play_img").attr("src", "../../static/demo/image/play.png")
			play_btn_cnt *= -1;
		}

	});	
	
	$("#play_btn").click(function(){
		
	});
	
});