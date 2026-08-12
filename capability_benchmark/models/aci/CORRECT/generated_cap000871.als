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

pred cap000871 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv1 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) }
pred cap000871c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv1 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) }
assert CapBenchEquivalent_cap000871 { cap000871 iff cap000871c }
check CapBenchEquivalent_cap000871 for 4
