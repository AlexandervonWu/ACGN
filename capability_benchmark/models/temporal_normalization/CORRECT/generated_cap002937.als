var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv9 {
always no Trash & Protected
}

pred inv9c {
	always no Protected & Trash
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002937 { not (((inv9 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA)))) since (((no CapBenchA and some capBenchR) and some CapBenchB))) }
pred cap002937c { ((not (inv9 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA)))) triggered (not ((no CapBenchA and some capBenchR) and some CapBenchB))) }
assert CapBenchEquivalent_cap002937 { cap002937 iff cap002937c }
check CapBenchEquivalent_cap002937 for 4
