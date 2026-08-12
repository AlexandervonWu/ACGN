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

pred cap003835 { all x, y: CapBenchA | (x->y in capBenchR and (inv9 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchS))) }
pred cap003835c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv9 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap003835 { cap003835 iff cap003835c }
check CapBenchEquivalent_cap003835 for 4
