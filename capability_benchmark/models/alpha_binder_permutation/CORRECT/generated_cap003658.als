sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv5 {
all t : Track | t in Junction <=> #(succs.t) > 1
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

pred cap003658 { all x, y: CapBenchA | (x->y in capBenchR and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchA))) }
pred cap003658c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap003658 { cap003658 iff cap003658c }
check CapBenchEquivalent_cap003658 for 4
