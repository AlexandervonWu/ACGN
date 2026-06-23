module alloy4fun_augmented_trash_rl_inv9
open util/integer [] as integer
sig File {
link: (set File)
}
sig Trash in File {}
sig Protected in File {}

pred inv9_oracle[] {
(no (link.link))
}

pred inv9_correct_0[] {
(no (link.link))
}

pred inv9_correct_1[] {
(all f,f1,f2: (one File) {
(((f->f1) in link) => ((f1->f2) !in link))
})
}

pred inv9_correct_2[] {
(all x: (one File) {
(all y,z: (one File) {
(((x->y) in link) => ((y->z) !in link))
})
})
}

pred inv9_correct_3[] {
(all f: (one File) {
((some (f.link)) => (no (link.f)))
})
}

pred inv9_correct_4[] {
(all f,l1,l2: (one File) {
(((f->l1) in link) => ((l1->l2) !in link))
})
}

pred inv9_correct_5[] {
(no ((File.link).link))
}

pred inv9_correct_6[] {
(all f,g,h: (one File) {
(((f->g) in link) => ((g->h) !in link))
})
}

pred inv9_correct_7[] {
(all f: (one (File.link)) {
(no (f.link))
})
}

pred inv9_correct_8[] {
(all l1: (one (File.link)) {
((l1.link) = none)
})
}

pred inv9_correct_9[] {
(all f: (one File) {
(no ((f.link).link))
})
}

pred inv9_correct_10[] {
(all f: (one File) {
((some (link.f)) => (no (f.link)))
})
}

pred inv9_correct_11[] {
(all f1,f2: (one File) {
(no ((f1.link) & (f2.(~link))))
})
}

pred inv9_correct_12[] {
(((File.link).link) = none)
}

pred inv9_correct_13[] {
(no ((link.File) & (File.link)))
}

pred inv9_correct_14[] {
(all f: (one File) {
((some (f.link)) => (no ((f.link).link)))
})
}

pred inv9_correct_15[] {
(all l: (one (File.link)) {
(no (l.link))
})
}

pred inv9_correct_16[] {
(all f1,f2,f3: (one File) {
(((f1->f2) in link) => ((f2->f3) !in link))
})
}

pred inv9_correct_17[] {
(all f,g: (one File) {
(((f->g) in link) => (no (g.link)))
})
}

