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

pred cap004013 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some capBenchS or some CapBenchB) or some CapBenchA))) }
pred cap004013c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some capBenchS or some CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap004013 { cap004013 iff cap004013c }
check CapBenchEquivalent_cap004013 for 4
