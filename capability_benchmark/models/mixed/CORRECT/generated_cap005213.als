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

pred cap005213 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some capBenchS or no CapBenchA) or no CapBenchB)) and ((no CapBenchA and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005213c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv4 and ((some capBenchS or no CapBenchA) or no CapBenchB)))) }
assert CapBenchEquivalent_cap005213 { cap005213 iff cap005213c }
check CapBenchEquivalent_cap005213 for 4
