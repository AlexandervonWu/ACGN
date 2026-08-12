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

pred cap002533 { not once ((inv1 and ((some CapBenchB or some capBenchR) or some CapBenchA))) }
pred cap002533c { historically (not (inv1 and ((some CapBenchB or some capBenchR) or some CapBenchA))) }
assert CapBenchEquivalent_cap002533 { cap002533 iff cap002533c }
check CapBenchEquivalent_cap002533 for 4
