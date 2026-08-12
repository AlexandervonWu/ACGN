sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv9 {
all t : Track | (no t.succs & Junction) implies no (t.signals & Semaphore)
}

pred inv9c {
	all t : Track | no t.succs & Junction implies no t.signals & Semaphore
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001334 { all x, y: CapBenchA | (x->y in capBenchR and (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchS))) }
pred cap001334c { all a, b: CapBenchA | (b->a in capBenchR and (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap001334 { cap001334 iff cap001334c }
check CapBenchEquivalent_cap001334 for 4
