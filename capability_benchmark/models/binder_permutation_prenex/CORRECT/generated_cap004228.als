sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv1 {
some Entry and some Exit
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

pred cap004228 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some capBenchR and some capBenchR) or no CapBenchB))) }
pred cap004228c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some capBenchR and some capBenchR) or no CapBenchB))) }
assert CapBenchEquivalent_cap004228 { cap004228 iff cap004228c }
check CapBenchEquivalent_cap004228 for 4
