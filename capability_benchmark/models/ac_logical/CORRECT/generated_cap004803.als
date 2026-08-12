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

pred cap004803 { not ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR)) and ((some capBenchR and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004803c { ((not ((some capBenchR and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR)))) }
assert CapBenchEquivalent_cap004803 { cap004803 iff cap004803c }
check CapBenchEquivalent_cap004803 for 4
