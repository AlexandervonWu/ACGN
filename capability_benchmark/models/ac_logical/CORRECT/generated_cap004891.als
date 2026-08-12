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

pred cap004891 { not ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) }
pred cap004891c { ((not ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) or (not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004891 { cap004891 iff cap004891c }
check CapBenchEquivalent_cap004891 for 4
