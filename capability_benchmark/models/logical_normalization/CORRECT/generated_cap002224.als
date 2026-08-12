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

pred cap002224 { ((inv1 and ((some CapBenchA and some capBenchR) or no CapBenchB)) implies ((some capBenchS or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap002224c { ((not (inv1 and ((some CapBenchA and some capBenchR) or no CapBenchB))) or ((some capBenchS or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
assert CapBenchEquivalent_cap002224 { cap002224 iff cap002224c }
check CapBenchEquivalent_cap002224 for 4
