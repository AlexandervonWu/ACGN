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

pred cap002945 { not eventually ((inv10 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002945c { always (not (inv10 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002945 { cap002945 iff cap002945c }
check CapBenchEquivalent_cap002945 for 4
