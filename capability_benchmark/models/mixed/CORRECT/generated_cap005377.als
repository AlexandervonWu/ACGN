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

pred cap005377 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA))) }
pred cap005377c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA)) or (not (inv1 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap005377 { cap005377 iff cap005377c }
check CapBenchEquivalent_cap005377 for 4
