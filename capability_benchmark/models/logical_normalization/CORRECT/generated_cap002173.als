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

pred cap002173 { no x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchS or some capBenchS) or no CapBenchA))) }
pred cap002173c { all x: CapBenchA | not (x->x in capBenchR and (inv1 and ((some capBenchS or some capBenchS) or no CapBenchA))) }
assert CapBenchEquivalent_cap002173 { cap002173 iff cap002173c }
check CapBenchEquivalent_cap002173 for 4
