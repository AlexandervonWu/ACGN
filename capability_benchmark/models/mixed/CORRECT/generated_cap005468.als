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

pred cap005468 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv9 and ((some capBenchR and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or some CapBenchA) or no CapBenchA))) }
pred cap005468c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some CapBenchA) or no CapBenchA)) or (not (inv9 and ((some capBenchR and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005468 { cap005468 iff cap005468c }
check CapBenchEquivalent_cap005468 for 4
