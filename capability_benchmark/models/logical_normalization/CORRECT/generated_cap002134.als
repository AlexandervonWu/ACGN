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

pred cap002134 { ((inv10 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchA)) implies ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) }
pred cap002134c { ((not (inv10 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchA))) or ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) }
assert CapBenchEquivalent_cap002134 { cap002134 iff cap002134c }
check CapBenchEquivalent_cap002134 for 4
