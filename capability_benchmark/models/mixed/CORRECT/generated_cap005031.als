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

pred cap005031 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv9 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchA)) and ((some capBenchR and some CapBenchB) or no CapBenchB))) }
pred cap005031c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and some CapBenchB) or no CapBenchB)) or (not (inv9 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005031 { cap005031 iff cap005031c }
check CapBenchEquivalent_cap005031 for 4
