sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv1 {
some e:Entry,ex:Exit | e in Track and ex in Track
}

pred inv1c {
	some Entry
	some Exit
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001415 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001415c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap001415 { cap001415 iff cap001415c }
check CapBenchEquivalent_cap001415 for 4
