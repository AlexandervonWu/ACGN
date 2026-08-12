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

pred cap001033 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv10 and ((some CapBenchB or some capBenchR) or some CapBenchA))) }
pred cap001033c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv10 and ((some CapBenchB or some capBenchR) or some CapBenchA))) }
assert CapBenchEquivalent_cap001033 { cap001033 iff cap001033c }
check CapBenchEquivalent_cap001033 for 4
