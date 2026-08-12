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

pred cap000652 { (inv1 and ((some CapBenchA and no CapBenchB) or no CapBenchA)) }
pred cap000652c { ((inv1 and ((some CapBenchA and no CapBenchB) or no CapBenchA)) and (inv1 and ((some CapBenchA and no CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap000652 { cap000652 iff cap000652c }
check CapBenchEquivalent_cap000652 for 4
