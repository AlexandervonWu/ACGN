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

pred cap000039 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv5 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA))) }
pred cap000039c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv5 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA))) }
assert CapBenchEquivalent_cap000039 { cap000039 iff cap000039c }
check CapBenchEquivalent_cap000039 for 4
