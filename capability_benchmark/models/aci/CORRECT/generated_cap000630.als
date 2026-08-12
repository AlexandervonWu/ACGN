sig Node {
	adj : set Node
}
pred inv8 {
all a,b,c : Node | c in b.adj and b in a.adj implies c in a.adj
}

pred inv8c {
	adj = ^adj
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000630 { (some ((CapBenchA.capBenchR).capBenchR) and (inv8 and ((no CapBenchA and some CapBenchA) and no CapBenchA))) }
pred cap000630c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv8 and ((no CapBenchA and some CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap000630 { cap000630 iff cap000630c }
check CapBenchEquivalent_cap000630 for 4
