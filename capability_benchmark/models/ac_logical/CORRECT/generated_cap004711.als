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

pred cap004711 { not ((inv10 and ((no CapBenchB or no CapBenchA) and no CapBenchB)) and ((some CapBenchA and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004711c { ((not ((some CapBenchA and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv10 and ((no CapBenchB or no CapBenchA) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004711 { cap004711 iff cap004711c }
check CapBenchEquivalent_cap004711 for 4
