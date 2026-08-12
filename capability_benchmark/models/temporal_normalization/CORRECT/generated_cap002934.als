sig Node {
	adj : set Node
}
pred inv8 {
all n: Node | n.adj.adj in n.adj
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

pred cap002934 { not historically ((inv8 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002934c { once (not (inv8 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002934 { cap002934 iff cap002934c }
check CapBenchEquivalent_cap002934 for 4
