sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv1 {
some e:Entry,ex:Exit | e in Track and ex in Track
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

pred cap000845 { (inv1 and ((some CapBenchB or no CapBenchB) or some capBenchS)) }
pred cap000845c { ((inv1 and ((some CapBenchB or no CapBenchB) or some capBenchS)) or (inv1 and ((some CapBenchB or no CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap000845 { cap000845 iff cap000845c }
check CapBenchEquivalent_cap000845 for 4
