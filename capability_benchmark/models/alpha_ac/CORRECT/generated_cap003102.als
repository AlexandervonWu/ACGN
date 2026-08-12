sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv7 {
all f,lk1 : File | f->lk1 in link implies lk1 not in Trash
}

pred inv7c {
	no File.link & Trash
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003102 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB)) and ((no CapBenchB or no CapBenchA) and some capBenchR)) }
pred cap003102c { all renamed: CapBenchA | (((no CapBenchB or no CapBenchA) and some capBenchR) and renamed->renamed in capBenchR and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB))) }
assert CapBenchEquivalent_cap003102 { cap003102 iff cap003102c }
check CapBenchEquivalent_cap003102 for 4
