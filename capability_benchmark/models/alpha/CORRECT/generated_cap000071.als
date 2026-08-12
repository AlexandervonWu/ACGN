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

pred cap000071 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv9 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB))) }
pred cap000071c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv9 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap000071 { cap000071 iff cap000071c }
check CapBenchEquivalent_cap000071 for 4
