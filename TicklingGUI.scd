s.boot;

(
SynthDef(\theremin, {

	arg glissRate, minHeight, maxHeight, attenuate, jitterRate, jitterDepth, ampModDepth, movementRate, lpFreq;
	var sig, height, jitter, movement;

	// randomness
	height = LFNoise2.kr(glissRate).exprange(minHeight, maxHeight);
	jitter = LFNoise2.kr(jitterRate).range(0 - jitterDepth, jitterDepth);
	movement = LFNoise2.kr(movementRate).range(-0.5, 0.5);

	// generators
	sig = LFSaw.ar(height * (1 + jitter) * (movement / 2.5 + 1));

	//signal processing
	sig = sig * (height - minHeight) / maxHeight;
	sig = sig * (1 + jitter);
	sig = sig * LFSaw.ar(movement * 200 - ampModDepth).range(0.1, 1);
	sig = LPF.ar(sig, lpFreq + (movement * 1900));
	sig = sig * {1 - attenuate};

	// safety
	sig = Clip.ar(sig, -1.0, 1.0);
	sig = Limiter.ar(sig);

	// out
    Out.ar(0, sig!2);

}).add;
)

//-----------------------GUI---------------------------//
(
//Window
arg wWidth = 500, wHeight = 280, color1 = Color(0.9, 0.7, 0.9); var win;
Window.closeAll;
win = Window(\Tickling, Rect(Window.screenBounds.width/2 - (wWidth/2),Window.screenBounds.height/2 - (wHeight/2), wWidth, wHeight))
.background_(Color(0.43, 1.0, 0.76))
.front
.alwaysOnTop_(true);

// glissRate Fader
~glissRateSlider = Slider(win, Rect(20, 20, 80, 200))
.value_(0.05)
.background_(color1)
.knobColor_(Color(0.65, 0.34, 0.61))
.thumbSize_(10)
.action_({
	arg obj; var val;
	val = ControlSpec(1.8, 20).map(obj.value);
	if(x.isPlaying,
		{x.set(\glissRate, val)}
	);
});

~glissRateLabel = StaticText(win, Rect(20, 222, 80, 18))
.string_("Rate")
.stringColor_(Color.black)
.font_(Font(\Garamond, 16))
.align_(\center);

// Range Fader
~glissRangeSlider = RangeSlider(win, Rect(120, 20, 80, 200))
.lo_(0.05).hi_(0.2)
.background_(color1)
.knobColor_(Color(0.65, 0.34, 0.61))
.action_({
	arg obj; var loVal, hiVal;
	loVal = ControlSpec(80, 1000).map(obj.lo);
	hiVal = ControlSpec(80, 1000).map(obj.hi);
	if(x.isPlaying,
		{x.set(\minHeight, loVal, \maxHeight, hiVal)}
	);
});

~glissRangeLabel = StaticText(win, Rect(120, 222, 80, 18))
.string_("Range")
.stringColor_(Color.black)
.font_(Font(\Garamond, 16))
.align_(\center);

// jitterRate Fader
~jitterRateSlider = Slider(win, Rect(220, 80, 80, 80))
.value_(0.2)
.background_(color1)
.knobColor_(Color(0.65, 0.34, 0.61))
.thumbSize_(10)
.action_({
	arg obj; var val;
	val = ControlSpec(4, 45).map(obj.value);
	if(x.isPlaying,
		{x.set(\jitterRate, val)}
	);
});

~jitterRateLabel = StaticText(win, Rect(300, 95, 80, 50))
.string_("Intensity")
.stringColor_(Color.black)
.font_(Font(\Garamond, 16))
.align_(\center);

// jitter Depth Knob
~jitterDepthKnob = Knob(win, Rect(220, 20, 80, 50))
.value_(0.06)
.action_({
	arg obj; var val;
	val = ControlSpec(0, 1).map(obj.value);
	if(x.isPlaying,
		{x.set(\jitterDepth, val)}
	);
});

~jitterDepthLabel = StaticText(win, Rect(280, 20, 80, 50))
.string_("Smudge")
.stringColor_(Color.black)
.font_(Font(\Garamond, 16))
.align_(\center);

// AM Depth Knob
~ampModDepthKnob = Knob(win, Rect(220, 170, 80, 50))
.value_(0.6)
.action_({
	arg obj; var val;
	val = ControlSpec(20, 100).map(obj.value);
	if(x.isPlaying,
		{x.set(\ampModDepth, val)}
	);
});

~amDepthLabel = StaticText(win, Rect(285, 170, 80, 50))
.string_("Serration")
.stringColor_(Color.black)
.font_(Font(\Garamond, 16))
.align_(\center);

// movement Fader
~movementSlider = Slider(win, Rect(20, 255,180 , 15))
.value_(0.25)
.background_(color1)
.knobColor_(Color(0.65, 0.34, 0.61))
.thumbSize_(8)
.action_({
	arg obj; var val;
	val = ControlSpec(0.001, 0.2).map(obj.value);
	if(x.isPlaying,
		{x.set(\movementRate, val)}
	);
});

~movementLabel = StaticText(win, Rect(200, 258, 55, 10))
.string_("Movement")
.stringColor_(Color.black)
.font_(Font(\Garamond, 11, true))
.align_(\center);

// level Knob
~levelKnob = Knob(win, Rect(402, 20, 75, 75))
.value_(0.5)
.action_({
	arg obj; var val;
	val = ControlSpec(1, 0).map(obj.value);
	if(x.isPlaying,
		{x.set(\attenuate, val)}
	);
});

~levelLabel = StaticText(win, Rect(427, 88, 25, 10))
.string_("Level")
.stringColor_(Color.black)
.font_(Font(\Garamond, 11, true))
.align_(\center);

// Modes Button (3500+)
~onOffButton = Button(win, Rect(310, 245, 70, 25))
.states_([
	[\Low, Color.white, Color(0.65, 0.34, 0.61)],
	[\Mid, Color.black, color1],
	[\High, Color.black, Color.white]
])
.font_(Font(\Garamond, 16))
.value_(1)
.action_({
	arg obj;
	if(obj.value == 0,
		{x.set(\lpFreq, 2000)});
	if(obj.value == 1,
		{x.set(\lpFreq, 3500)});
	if(obj.value == 2,
		{x.set(\lpFreq, 8000)});
});

// On-Off Button
~onOffButton = Button(win, Rect(400, 110, 80, 160))
.states_([
	[\Off, Color.black, Color(0.65, 0.34, 0.61)],
	[\On, Color.black, color1]
])
.font_(Font(\Garamond, 18))
.value_(0)
.action_({
	arg obj;
	if(obj.value == 1,
		{x = Synth.new(\theremin,[
		glissRate: ControlSpec(1.8, 20).map(~glissRateSlider.value),
		minHeight: ControlSpec(80, 1000).map(~glissRangeSlider.lo),
		maxHeight: ControlSpec(80, 1000).map(~glissRangeSlider.hi),
		attenuate: ControlSpec(1, 0).map(~levelKnob.value),
		jitterRate: ControlSpec(4, 45).map(~jitterRateSlider.value),
		jitterDepth: ControlSpec(0, 1).map(~jitterDepthKnob.value),
		ampModDepth: ControlSpec(20, 100).map(~ampModDepthKnob.value),
		movementRate: ControlSpec(0.001, 0.2).map(~movementSlider.value),
		lpFreq: 3500]).register},
		{x.free}
	);
});
)