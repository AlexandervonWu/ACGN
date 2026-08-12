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

pred cap001515 { ((all x: CapBenchA | x->x in capBenchR) or (inv9 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA))) }
pred cap001515c { (all x: CapBenchA | (x->x in capBenchR or (inv9 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap001515 { cap001515 iff cap001515c }
check CapBenchEquivalent_cap001515 for 4
