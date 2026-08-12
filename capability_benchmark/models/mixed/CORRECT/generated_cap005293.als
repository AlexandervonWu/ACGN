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

pred cap005293 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some capBenchS or some capBenchR) or some capBenchR)) and ((no CapBenchA and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap005293c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv4 and ((some capBenchS or some capBenchR) or some capBenchR)))) }
assert CapBenchEquivalent_cap005293 { cap005293 iff cap005293c }
check CapBenchEquivalent_cap005293 for 4
