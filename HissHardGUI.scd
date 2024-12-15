s.reboot;

(
SynthDef(\HissHard, {

	arg amp, freqTest, freqSpread, hard, hard2, lfo, bold, waveForm;
	var sig;

	//generator selector
	sig = Select.ar(waveForm,
		[
			//sinusoid (Core Synth)
			sig = SinOsc.ar(LFPulse.kr(lfo * 3).range(freqTest - freqSpread, freqTest + freqSpread));

			sig = [Convolution.ar(sig, SinOsc.ar(freqTest*2)),
				Convolution.ar(sig, SinOsc.ar(freqTest * (hard2 * 2) + 1))]
			-(bold * [Convolution.ar(sig, SinOsc.ar(freqTest*2)),
				Convolution.ar(sig, SinOsc.ar(freqTest * (hard2 * 2) + 1))])
			+(Saw.ar(LFPulse.kr(lfo * 3).range(freqTest - freqSpread, freqTest + freqSpread))!2 * bold);
			,
			//saw
			sig = Saw.ar(LFPulse.kr(lfo * 3).range(freqTest - freqSpread, freqTest + freqSpread));

			sig = [Convolution.ar(sig, Saw.ar(freqTest*2)),
				Convolution.ar(sig, Saw.ar(freqTest * (hard2 * 2) + 1))]
			-(bold * [Convolution.ar(sig, Saw.ar(freqTest*2)),
				Convolution.ar(sig, Saw.ar(freqTest * (hard2 * 2) + 1))])
			+(Saw.ar(LFPulse.kr(lfo * 3).range(freqTest - freqSpread, freqTest + freqSpread))!2 * bold);
			,
			//pulse
			sig = Pulse.ar(LFPulse.kr(lfo * 3).range(freqTest - freqSpread, freqTest + freqSpread));

			sig = [Convolution.ar(sig, Pulse.ar(freqTest*2)),
				Convolution.ar(sig, Pulse.ar(freqTest * (hard2 * 2) + 1))]
			-(bold * [Convolution.ar(sig, Pulse.ar(freqTest*2)),
				Convolution.ar(sig, Pulse.ar(freqTest * (hard2 * 2) + 1))])
			+(Pulse.ar(LFPulse.kr(lfo * 3).range(freqTest - freqSpread, freqTest + freqSpread))!2 * bold);
		]
	);

	//shaping
	sig = [BPF.ar(sig[0], (1000 - (hard2 * 1000)) * hard.reciprocal + 50, hard + 0.05),
		BPF.ar(sig[1], 1000 - (hard2 * 1000) * hard.reciprocal + 50, hard + 0.05)];

	sig = [sig * Convolution.ar(sig, SinOsc.ar(lfo)),
		Convolution.ar(sig, SinOsc.ar(lfo * 1.4 + lfo))];

	sig = sig; //bold

	//out
	sig = Limiter.ar(Clip.ar(sig, -0.3, 0.3));
	sig = sig * amp;
	Out.ar(0, sig);

}).add;
)

//-----------------------GUI---------------------------//
(
//window
arg wWidth = 390, wHeight = 280,
color1 = Color(1, 0.547, 0.349), color2 = Color(0.8, 0.5, 0.5), color3 = Color(0.4, 0.96, 0.722),
font = "Courier", fontSize = 14; var win;
Window.closeAll;
win = Window("HissHard", Rect(Window.screenBounds.width/2 - (wWidth/2),Window.screenBounds.height/2 - (wHeight/2), wWidth, wHeight),resizable:  true)
.background_(color3)
.front
.alwaysOnTop_(true);

// hard
~hardSlider = Slider(win, Rect(30, 20, 20, 170))
.value_(0)
.background_(color1)
.knobColor_(color2)
.thumbSize_(10)
.action_({
	arg obj; var val;
	val = ControlSpec(0.1, 0.7).map(obj.value);
	if(x.isPlaying,
		{x.set(\hard, val)}
	);
});

~hardLabel = StaticText(win, Rect(2, 200, 80, 18))
.string_("hard²")
.stringColor_(Color.black)
.font_(Font(font, fontSize + 2))
.align_(\center);

// hard^2
~hard2Slider = Slider(win, Rect(96, 20, 40, 170))
.value_(0)
.background_(color1)
.knobColor_(color2)
.thumbSize_(10)
.action_({
	arg obj; var val;
	val = ControlSpec(0.1, 1).map(obj.value);
	if(x.isPlaying,
		{x.set(\hard2, val)}
	);
});

~hard2Label = StaticText(win, Rect(78, 200, 80, 18))
.string_("hard³")
.stringColor_(Color.black)
.font_(Font(font, fontSize + 4))
.align_(\center);

//bold
~boldSlider = Slider(win, Rect(175, 20, 80, 50))
.value_(0.8)
.background_(color1)
.knobColor_(color2)
.thumbSize_(10)
.action_({
	arg obj; var val;
	val = ControlSpec(0.95, 0.1, \linear).map(obj.value);
	if(x.isPlaying,
		{x.set(\bold, val)}
	);
});

~boldLabel = StaticText(win, Rect(175, 80, 80, 18))
.string_("saturation")
.stringColor_(Color.black)
.font_(Font(font, fontSize))
.align_(\center);

//freq
~freqKnob = Knob(win, Rect(20, 230, 40, 40))
.value_(0)
.action_({
	arg obj; var val;
	val = ControlSpec(170, 200).map(obj.value);
	if(x.isPlaying,
		{x.set(\freqTest, val)}
	);
});

~freqLabel = StaticText(win, Rect(63, 240, 40, 18))
.string_("hard")
.stringColor_(Color.black)
.font_(Font(font, fontSize))
.align_(\center);

//interval
~spreadFreqKnob = Knob(win, Rect(170, 230, 40, 40))
.value_(0.2)
.action_({
	arg obj; var val;
	val = ControlSpec(0.001, 20).map(obj.value);
	if(x.isPlaying,
		{x.set(\freqSpread, val)}
	);
});

~spreadFreqLabel = StaticText(win, Rect(215, 240, 60, 18))
.string_("interval")
.stringColor_(Color.black)
.font_(Font(font, fontSize))
.align_(\center);

//rate
~rateKnob = Knob(win, Rect(170, 180, 40, 40))
.value_(0.01)
.action_({
	arg obj; var val;
	val = ControlSpec(0.0001, 4).map(obj.value);
	if(x.isPlaying,
		{x.set(\lfo, val)}
	);
});

~rateLabel = StaticText(win, Rect(205, 190, 50, 18))
.string_("rate")
.stringColor_(Color.black)
.font_(Font(font, fontSize))
.align_(\center);


// gain
~gainKnob = Knob(win, Rect(292, 80, 75, 75))
.value_(0.5)
.action_({
	arg obj; var val;
	val = ControlSpec(0, 0.8).map(obj.value);
	if(x.isPlaying,
		{x.set(\amp, val)}
	);
});

~gainLabel = StaticText(win, Rect(313, 153, 32, 12))
.string_("gain")
.stringColor_(Color.black)
.font_(Font(font, 9))
.align_(\center);

// waveShape
~waveButton = Button(win, Rect(290, 20, 80, 50))
.states_([
	["sin", Color.black, color3],
	["saw", Color.black, color3],
	["pulse", Color.black, color3]
])
.font_(Font(font, fontSize))
.value_(0)
.action_({
	arg obj;
	if(obj.value == 0,{
		x.set(\waveForm, 0);
	},{
		if(obj.value == 1, {
			x.set(\waveForm, 1);
		},{
			x.set(\waveForm, 2);
		})
	});
});

// On-Off Button
~onOffButton = Button(win, Rect(290, 180, 80, 85))
.states_([
	["◯", Color.black, color2],
	["|", Color.black, color1]
])
.font_(Font(font, 50))
.value_(0)
.action_({
	arg obj;
	if(obj.value == 1,{
		x = Synth.new(\HissHard,[
		freqTest: ControlSpec(170, 200).map(~freqKnob.value),
		hard: ControlSpec(0.1, 0.7).map(~hardSlider.value),
		hard2: ControlSpec(0.1, 1).map(~hard2Slider.value),
		lfo: ControlSpec(0.0001, 4).map(~rateKnob.value),
		freqSpread: ControlSpec(0.001, 20).map(~spreadFreqKnob.value),
		amp: ControlSpec(0, 0.8).map(~gainKnob.value),
		waveForm: ~waveButton.value,
		bold: ControlSpec(0.95, 0.1).map(~boldSlider.value)
		]).register
	},{
		x.free
	});
});
)