sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv5 {
all t:Track | t in Junction iff #(succs.t) > 1
}

pred inv5c {
	all t : Track | t not in Junction iff lone succs.t
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003840 { all x, y: CapBenchA | (x->y in capBenchR and (inv5 and ((some capBenchR and no CapBenchA) or some capBenchS))) }
pred cap003840c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv5 and ((some capBenchR and no CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap003840 { cap003840 iff cap003840c }
check CapBenchEquivalent_cap003840 for 4
