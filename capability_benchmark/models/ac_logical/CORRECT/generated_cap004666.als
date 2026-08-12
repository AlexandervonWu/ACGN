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

pred cap004666 { not ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA)) and ((no CapBenchB or no CapBenchA) and some capBenchS)) }
pred cap004666c { ((not ((no CapBenchB or no CapBenchA) and some capBenchS)) or (not (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004666 { cap004666 iff cap004666c }
check CapBenchEquivalent_cap004666 for 4
