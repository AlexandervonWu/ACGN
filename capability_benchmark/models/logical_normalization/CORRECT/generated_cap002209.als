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

pred cap002209 { no x: CapBenchA | (x->x in capBenchR and (inv1 and ((some CapBenchB or no CapBenchA) or no CapBenchB))) }
pred cap002209c { all x: CapBenchA | not (x->x in capBenchR and (inv1 and ((some CapBenchB or no CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap002209 { cap002209 iff cap002209c }
check CapBenchEquivalent_cap002209 for 4
