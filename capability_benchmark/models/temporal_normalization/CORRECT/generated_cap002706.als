sig Node {
	adj : set Node
}
pred inv3 {
all n:Node | n not in n.^adj
}

pred inv3c {
	all n : Node | n not in n.^adj
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002706 { not historically ((inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchB))) }
pred cap002706c { once (not (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap002706 { cap002706 iff cap002706c }
check CapBenchEquivalent_cap002706 for 4
