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

pred cap001249 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv5 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) }
pred cap001249c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv5 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap001249 { cap001249 iff cap001249c }
check CapBenchEquivalent_cap001249 for 4
