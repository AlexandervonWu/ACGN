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

pred cap000708 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv5 and ((some CapBenchA and no CapBenchA) or no CapBenchB))) }
pred cap000708c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv5 and ((some CapBenchA and no CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap000708 { cap000708 iff cap000708c }
check CapBenchEquivalent_cap000708 for 4
