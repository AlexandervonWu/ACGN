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

pred cap003175 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA)) and ((some capBenchR and no CapBenchB) or some capBenchS)) }
pred cap003175c { all renamed: CapBenchA | (((some capBenchR and no CapBenchB) or some capBenchS) and renamed->renamed in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA))) }
assert CapBenchEquivalent_cap003175 { cap003175 iff cap003175c }
check CapBenchEquivalent_cap003175 for 4
