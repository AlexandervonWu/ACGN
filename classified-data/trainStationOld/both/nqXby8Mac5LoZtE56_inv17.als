sig Track {
	prox : set Track,
	signal : lone Signal
}
sig Junction extends Track {}
sig Entry, Exit in Track {}

sig Signal {}
var sig Green in Signal {}

sig Train {
	var pos : lone Track
}

fact Layout {
	all t : Track | t not in Junction iff (lone t.prox and lone prox.t)
	no t : Track | t in t.^prox
	all s : Signal | one signal.s
	all j : Junction, t : prox.j | some t.signal
	all t : Track | t in Entry iff no prox.t
	all t : Track | t in Exit iff no t.prox
}
pred inv17 {
always (some Train => (one Train.pos:>Exit  since one pos))
}

pred inv17c {
	all t : Train | always ((some t.pos and historically no (Train-t).pos) implies (no Train.pos & Exit until some t.pos & Exit))
}

check correct { inv17 <=> inv17c}
pred under { inv17 and !inv17c}
pred over { !inv17 and inv17c}
run over 
run under 


