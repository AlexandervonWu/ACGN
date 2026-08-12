sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv6 {
all f1, f2, f3 : File | (f1 -> f2 in link && f1 -> f3 in link) => f2 = f3
}

pred inv6c {
	link in File -> lone File
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003390 { all x: CapBenchA | (x->x in capBenchR and (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) }
pred cap003390c { all renamed: CapBenchA | (((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA) and renamed->renamed in capBenchR and (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003390 { cap003390 iff cap003390c }
check CapBenchEquivalent_cap003390 for 4
