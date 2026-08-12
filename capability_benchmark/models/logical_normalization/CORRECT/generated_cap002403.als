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

pred cap002403 { not ((inv5 and ((no CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchA and some CapBenchA) or some CapBenchB)) }
pred cap002403c { ((not (inv5 and ((no CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) or (not ((some CapBenchA and some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap002403 { cap002403 iff cap002403c }
check CapBenchEquivalent_cap002403 for 4
