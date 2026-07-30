sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv3 {
all ex:Exit, j:Junction, e:Entry, t:Track | j not in ex.succs and e not in ex.succs and ex not in ex.succs and t not in ex.succs and t not in t.succs
}

pred inv3c {
	all t : Track | t in Exit iff no t.succs
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 

