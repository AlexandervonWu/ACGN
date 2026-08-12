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

pred cap000513 { ((inv1 and ((some capBenchS or some CapBenchB) or some CapBenchA)) or ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA) or ((some CapBenchA and some capBenchS) or some capBenchS)) }
pred cap000513c { (((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA) or ((some CapBenchA and some capBenchS) or some capBenchS) or (inv1 and ((some capBenchS or some CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap000513 { cap000513 iff cap000513c }
check CapBenchEquivalent_cap000513 for 4
