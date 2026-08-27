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

pred cap000810 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
pred cap000810c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
assert CapBenchEquivalent_cap000810 { cap000810 iff cap000810c }
check CapBenchEquivalent_cap000810 for 4
