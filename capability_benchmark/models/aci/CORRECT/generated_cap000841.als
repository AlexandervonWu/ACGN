sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv5 {
all t : Track | t in Junction <=> #(succs.t) > 1
}

pred inv5c {
	all t : Track | t not in Junction iff lone succs.t
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000841 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv5 and ((some capBenchS or no CapBenchA) or some capBenchS))) }
pred cap000841c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv5 and ((some capBenchS or no CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap000841 { cap000841 iff cap000841c }
check CapBenchEquivalent_cap000841 for 4
