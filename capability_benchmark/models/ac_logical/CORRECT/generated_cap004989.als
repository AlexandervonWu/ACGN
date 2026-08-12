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

pred cap004989 { not ((inv1 and ((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchA)) }
pred cap004989c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchA)) or (not (inv1 and ((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004989 { cap004989 iff cap004989c }
check CapBenchEquivalent_cap004989 for 4
