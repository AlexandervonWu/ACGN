sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv7 {
all t:Track | no t & t.(^succs)
}

pred inv7c {
	no t : Track | t in t.^succs
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005204 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((some capBenchR and some CapBenchB) or no CapBenchB)) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
pred cap005204c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) or (not (inv7 and ((some capBenchR and some CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap005204 { cap005204 iff cap005204c }
check CapBenchEquivalent_cap005204 for 4
