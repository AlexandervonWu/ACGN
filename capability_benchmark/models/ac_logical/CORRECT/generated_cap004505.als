sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv10 {
all f1, f2 : File | (f1->f2 in link and f1 in Trash) => f2 in Trash
}

pred inv10c {
	all f : File | f in Trash implies f.link in Trash
}

check correct { inv10 <=> inv10c}
pred under { inv10 and !inv10c}
pred over { !inv10 and inv10c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004505 { not ((inv10 and ((some capBenchS or some CapBenchA) or some CapBenchA)) and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) }
pred cap004505c { ((not ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) or (not (inv10 and ((some capBenchS or some CapBenchA) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004505 { cap004505 iff cap004505c }
check CapBenchEquivalent_cap004505 for 4
