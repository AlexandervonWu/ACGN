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

pred cap003169 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some CapBenchB or some capBenchS) or no CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchS)) }
pred cap003169c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchS) and renamed->renamed in capBenchR and (inv1 and ((some CapBenchB or some capBenchS) or no CapBenchA))) }
assert CapBenchEquivalent_cap003169 { cap003169 iff cap003169c }
check CapBenchEquivalent_cap003169 for 4
