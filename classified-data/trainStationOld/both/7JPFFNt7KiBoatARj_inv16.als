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
pred inv16 {
always all t : Train | (t.pos = Exit) implies ((always some t.pos) since (t.pos = Entry))
}

pred inv16c {
	all t : Train | always (some t.pos & Exit implies (some t.pos since some t.pos & Entry))
}

check correct { inv16 <=> inv16c}
pred under { inv16 and !inv16c}
pred over { !inv16 and inv16c}
run over 
run under 


