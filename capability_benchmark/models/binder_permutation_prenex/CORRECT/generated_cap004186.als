sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv1 {
some t,a:Track| t in Entry and a in Exit
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

pred cap004186 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
pred cap004186c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap004186 { cap004186 iff cap004186c }
check CapBenchEquivalent_cap004186 for 4
