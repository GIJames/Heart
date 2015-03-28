import fl.controls.TextArea;
stage.align = StageAlign.TOP_LEFT;

var my_menu:ContextMenu = new ContextMenu();
my_menu.hideBuiltInItems();

var version = new ContextMenuItem("Heart (Perspective Test) rev.3");
version.enabled = false;

var credit = new ContextMenuItem("Rubber NAND 2015");
credit.enabled = false;

var thissong = new ContextMenuItem("Soundcloud");
function openSClink(e:ContextMenuEvent):void {
	navigateToURL(new URLRequest("https://soundcloud.com/9c5"));
}
thissong.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, openSClink);
thissong.separatorBefore = true;

var othersong = new ContextMenuItem("Bandcamp");
function openBClink(e:ContextMenuEvent):void {
	navigateToURL(new URLRequest("https://jamesjerram.bandcamp.com/"));
}
othersong.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, openBClink);

var debugger = new ContextMenuItem("Debug Mode");
function toggledebugger(e:ContextMenuEvent):void {
	toggleVis();
}
debugger.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, toggledebugger);
debugger.separatorBefore = true;

var scaleMode = true;
var rescale = new ContextMenuItem("Scaling Mode");
function rescalemode(e:ContextMenuEvent):void {
	if (scaleMode) {
		scaleMode = false;
	} else {
		scaleMode = true;
	}
}
rescale.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, rescalemode);

my_menu.customItems.push(version, credit, thissong, othersong, debugger, rescale);
contextMenu = my_menu;


Mouse.hide();
var sound:Loop = new Loop();
var soundChannel:SoundChannel = new SoundChannel();
soundChannel = sound.play(0, int.MAX_VALUE);
var tempo = 125;
var beat = (1/tempo)*60*1000;
var env = 0;
var looptimes = 0;
var lastpos = 0;
function refreshEnv() {
	var newpos = soundChannel.position % sound.length;
	env = (((newpos)%beat)/beat);
	if (newpos < lastpos) {
		looptimes++;
	}
	lastpos = newpos;
}

var cameraX = stage.stageWidth/2;
var cameraY = stage.stageHeight/2;
var originX = 0;
var originY = 0;
var originScale = 4;
var deltaX = 0;
var deltaY = 0;
var maxDeltaX = 16 * originScale;
var maxDeltaY = 9 * originScale;

var back:Heart2 = new Heart2();
back.scaleX = originScale;
back.scaleY = originScale;
back.blurX = originScale;
back.blurY = originScale;
var front:Heart1 = new Heart1();
front.scaleX = originScale;
front.scaleY = originScale;
stage.addChild(back);
stage.addChild(front);

var vis:Boolean = false;

var cameraVis:Sprite = new Sprite();
cameraVis.graphics.beginFill(0x00FF00, .3);
cameraVis.graphics.drawRect(-16,-9,32,18);
cameraVis.graphics.drawRect(-2,-2,4,4);
cameraVis.graphics.endFill();
cameraVis.x = cameraX;
cameraVis.y = cameraY;

var mouseVis:Sprite = new Sprite();
mouseVis.graphics.beginFill(0x0000FF, .5);
mouseVis.graphics.drawCircle(0,0,2);
mouseVis.graphics.endFill();

var debugText:TextArea = new TextArea();
debugText.enabled = false;
debugText.editable = false;
debugText.setSize(stage.stageWidth, stage.stageHeight);

function enableVis() {
	stage.addChild(cameraVis);
	stage.addChild(mouseVis);
	stage.addChild(debugText);
}

function disableVis() {
	stage.removeChild(cameraVis);
	stage.removeChild(mouseVis);
	stage.removeChild(debugText);
}

function toggleVis() {
	if (vis) {
		vis = false;
		disableVis();
	} else {
		vis = true;
		enableVis();
	}
}


var skewMatrix:Matrix = new Matrix();
var skewX = 0;
var skewY = 0;
var scaleMatrix:Matrix = new Matrix();
scaleMatrix.a = originScale;
scaleMatrix.d = originScale;
var frontPosMatrix:Matrix = new Matrix();
var backPosMatrix:Matrix = new Matrix();

var frontMatrix:Matrix = new Matrix();
var backMatrix:Matrix = new Matrix();

/*stage.addEventListener(MouseEvent.CLICK, traceMatrices);
function traceMatrices(e:MouseEvent):void {
trace("skew Matrix");
trace(skewMatrix);
trace("scale Matrix");
trace(scaleMatrix);
trace("pos Matrix");
trace(frontPosMatrix);
trace(backPosMatrix);
trace("end Matrix");
trace(frontMatrix);
trace(backMatrix);
}*/
var maxDistance = Math.sqrt(Math.pow(stage.stageWidth/2,2) + Math.pow(stage.stageHeight/2,2));
function update() {
	refreshEnv();
	originX = stage.mouseX;
	originY = stage.mouseY;
	backPosMatrix.tx = originX - 12.5*originScale;
	backPosMatrix.ty = originY - 12.5*originScale;
	var diffX = originX - cameraX;
	var diffY = originY - cameraY;
	var midDeltaX = (diffX/cameraX);
	var midDeltaY = (diffY/cameraY);
	deltaX = midDeltaX*maxDeltaX;
	deltaY = midDeltaY*maxDeltaY;

	if (scaleMode) {
		skewX = midDeltaX * midDeltaY * -1;
		skewY = midDeltaX * midDeltaY * -1;
		var distance = Math.sqrt(Math.pow(diffX,2) + Math.pow(diffY,2));
		var distanceMod = 1 - distance/maxDistance;
		skewMatrix.b = Math.tan(skewX);//skew X
		skewMatrix.c = Math.tan(skewY);//skew Y
		scaleMatrix.a = originScale * distanceMod * (1-Math.abs(midDeltaX));
		scaleMatrix.d = originScale * distanceMod * (1-Math.abs(midDeltaY));
		if (Math.abs(skewMatrix.b) > .45) {
			front.alpha = 0;
			back.alpha = 0;
		} else {
			front.alpha = 1;
			back.alpha = 1;
		}

	} else {
		skewMatrix.b = 0;
		skewMatrix.c = 0;
		scaleMatrix.a = originScale;
		scaleMatrix.d = originScale;
		front.alpha = 1;
		back.alpha = 1;
	}
	frontPosMatrix.tx = originX + (deltaX*env) - 12.5*originScale;
	frontPosMatrix.ty = originY + (deltaY*env) - 12.5*originScale;
	frontMatrix.b = skewMatrix.b;
	frontMatrix.c = skewMatrix.c;
	backMatrix.b = skewMatrix.b;
	backMatrix.c = skewMatrix.c;
	frontMatrix.tx = frontPosMatrix.tx;
	frontMatrix.ty = frontPosMatrix.ty;
	backMatrix.tx = backPosMatrix.tx;
	backMatrix.ty = backPosMatrix.ty;
	frontMatrix.a = scaleMatrix.a;
	frontMatrix.d = scaleMatrix.d;
	backMatrix.a = scaleMatrix.a;
	backMatrix.d = scaleMatrix.d;
	front.transform.matrix = frontMatrix;
	back.transform.matrix = backMatrix;
	if (vis) {
		mouseVis.x = stage.mouseX;
		mouseVis.y = stage.mouseY;
		debugText.text = "Debug Mode";
		debugText.appendText("\nStage Width:");
		debugText.appendText(String(stage.stageWidth));
		debugText.appendText("\nStage Height:");
		debugText.appendText(String(stage.stageHeight));
		debugText.appendText("\nCameraX:");
		debugText.appendText(String(cameraX));
		debugText.appendText("\nCameraY:");
		debugText.appendText(String(cameraY));
		debugText.appendText("\nMouseX:");
		debugText.appendText(String(stage.mouseX));
		debugText.appendText("\nMouseY:");
		debugText.appendText(String(stage.mouseY));
		debugText.appendText("\nRaw Sound Position:");
		debugText.appendText(String(Math.round(soundChannel.position)));
		debugText.appendText("\nSound Length:");
		debugText.appendText(String(Math.round(sound.length)));
		debugText.appendText("\nSound Position In Loop:");
		debugText.appendText(String(Math.round(soundChannel.position % sound.length)));
		debugText.appendText("\nTimes Looped:");
		debugText.appendText(String(looptimes));
		debugText.appendText("\nTempo:");
		debugText.appendText(String(tempo));
		debugText.appendText("\nBar:");
		debugText.appendText(String(1+Math.floor((soundChannel.position % sound.length)/(beat*4))));
		debugText.appendText("\nBeat:");
		debugText.appendText(String(1+(Math.floor((soundChannel.position % sound.length)/beat)%4)));
		debugText.appendText("\nSixteenth:");
		debugText.appendText(String(1+(Math.floor((soundChannel.position % sound.length)/(beat/16))%16)));
		debugText.appendText("\nEnvelope:");
		debugText.appendText(String(Math.round(env*100)));
		debugText.appendText("\nMaxDeltaX:");
		debugText.appendText(String(deltaX));
		debugText.appendText("\nMaxDeltaY:");
		debugText.appendText(String(deltaY));
		/*debugText.appendText("\nModifiedX:");
		debugText.appendText(String(front.x));
		debugText.appendText("\nModifiedY:");
		debugText.appendText(String(front.y));*/
		//matrices
		debugText.appendText("\nA:");
		debugText.appendText(String(backMatrix.a));
		debugText.appendText("\nB:");
		debugText.appendText(String(backMatrix.b));
		debugText.appendText("\nC:");
		debugText.appendText(String(backMatrix.c));
		debugText.appendText("\nD:");
		debugText.appendText(String(backMatrix.d));
		debugText.appendText("\nTX:");
		debugText.appendText(String(backMatrix.tx));
		debugText.appendText("\nTY:");
		debugText.appendText(String(backMatrix.ty));

	}
}
