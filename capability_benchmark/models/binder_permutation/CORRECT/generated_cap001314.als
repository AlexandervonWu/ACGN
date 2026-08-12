sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv4 {
all t : Track | t in Entry iff no t.~succs
}

pred inv4c {
	all t : Track | t in Entry iff no succs.t
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001314 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) }
pred cap001314c { all a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap001314 { cap001314 iff cap001314c }
check CapBenchEquivalent_cap001314 for 4
