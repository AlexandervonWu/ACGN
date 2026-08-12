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

pred cap001821 { ((all x: CapBenchA | x->x in capBenchR) or (inv1 and ((some CapBenchB or some CapBenchA) or some capBenchS))) }
pred cap001821c { (all x: CapBenchA | (x->x in capBenchR or (inv1 and ((some CapBenchB or some CapBenchA) or some capBenchS)))) }
assert CapBenchEquivalent_cap001821 { cap001821 iff cap001821c }
check CapBenchEquivalent_cap001821 for 4
