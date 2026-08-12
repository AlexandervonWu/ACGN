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

pred cap002213 { ((inv7 and ((some capBenchS or no CapBenchA) or no CapBenchB)) iff ((no CapBenchA and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap002213c { (((not (inv7 and ((some capBenchS or no CapBenchA) or no CapBenchB))) or ((no CapBenchA and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) and ((not ((no CapBenchA and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) or (inv7 and ((some capBenchS or no CapBenchA) or no CapBenchB)))) }
assert CapBenchEquivalent_cap002213 { cap002213 iff cap002213c }
check CapBenchEquivalent_cap002213 for 4
