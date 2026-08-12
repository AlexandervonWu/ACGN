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

pred cap003689 { all x, y: CapBenchA | (x->y in capBenchR and (inv7 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
pred cap003689c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv7 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap003689 { cap003689 iff cap003689c }
check CapBenchEquivalent_cap003689 for 4
