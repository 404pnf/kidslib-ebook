$(function () {
  var mp3json = $("#js_mp3_url").html();
  var player = $("#player");
  player.hide();

 $("#mybook").booklet({
  closed: true,
  arrows: true, //翻页箭头
  pagePadding: 0, // default padding is 10px; bad bad!
  shadows: false, // 不要让右边的页面有一层阴影覆盖着
  width:  1130, // 两页加起来的宽度
  height: 800,
  //speed: 250,
  //pageNumbers: true,
  keyboard: true,
  change: function(event, data) {
    // alert(data.index);
    if(mp3json[data.index]){
      player.appendTo( "#player_here" );
      player.show();
      $f("player", "../flowplayer/flowplayer-3.2.16.swf", {
        clip: {
           url: "../pageimg/" + mp3json[data.index]
        }
      });
    }
    else {
      player.detach();
      player.hide();
    }
  }
  });
});