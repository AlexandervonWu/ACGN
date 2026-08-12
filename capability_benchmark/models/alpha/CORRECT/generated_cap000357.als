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

pred cap000357 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((some capBenchS or some capBenchR) or some capBenchS))) }
pred cap000357c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv1 and ((some capBenchS or some capBenchR) or some capBenchS))) }
assert CapBenchEquivalent_cap000357 { cap000357 iff cap000357c }
check CapBenchEquivalent_cap000357 for 4
