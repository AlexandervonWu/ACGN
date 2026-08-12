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

pred cap003159 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA)) and ((some capBenchR and some CapBenchB) or some capBenchS)) }
pred cap003159c { all renamed: CapBenchA | (((some capBenchR and some CapBenchB) or some capBenchS) and renamed->renamed in capBenchR and (inv5 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap003159 { cap003159 iff cap003159c }
check CapBenchEquivalent_cap003159 for 4
