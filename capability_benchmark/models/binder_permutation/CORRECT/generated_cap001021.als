sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv4 {
all e : Track | e in Entry iff (all t : Track | t not in succs.e)
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

pred cap001021 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv4 and ((some capBenchS or no CapBenchA) or some CapBenchA))) }
pred cap001021c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv4 and ((some capBenchS or no CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap001021 { cap001021 iff cap001021c }
check CapBenchEquivalent_cap001021 for 4
