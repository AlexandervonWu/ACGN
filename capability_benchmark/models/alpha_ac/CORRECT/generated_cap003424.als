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

pred cap003424 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((some CapBenchA and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchS or no CapBenchA) or some CapBenchB)) }
pred cap003424c { all renamed: CapBenchA | (((some capBenchS or no CapBenchA) or some CapBenchB) and renamed->renamed in capBenchR and (inv7 and ((some CapBenchA and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003424 { cap003424 iff cap003424c }
check CapBenchEquivalent_cap003424 for 4
