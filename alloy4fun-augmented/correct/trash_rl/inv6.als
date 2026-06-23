module alloy4fun_augmented_trash_rl_inv6
open util/integer [] as integer
sig File {
link: (set File)
}
sig Trash in File {}
sig Protected in File {}

pred inv6_oracle[] {
(((~link).link) in iden)
}

pred inv6_correct_0[] {
(all f: (one File) {
(lone (f.link))
})
}

pred inv6_correct_1[] {
(((~link).link) in iden)
}

pred inv6_correct_2[] {
(all f,f1,f2: (one File) {
((((f->f2) in link) && ((f->f1) in link)) => (f1 = f2))
})
}

pred inv6_correct_3[] {
(all f: (one File) {
((#(f.link)) < 2)
})
}

pred inv6_correct_4[] {
(all f,a1,a2: (one File) {
((((f->a1) in link) && ((f->a2) in link)) => (a1 = a2))
})
}

pred inv6_correct_5[] {
(all f,f1,f2: (one File) {
((((f->f1) + (f->f2)) in link) => (f1 = f2))
})
}

pred inv6_correct_6[] {
(all f1,f2,f3: (one File) {
((((f1->f2) in link) && ((f1->f3) in link)) => (f2 = f3))
})
}

pred inv6_correct_7[] {
(all f,g,h: (one File) {
((((f->g) in link) && ((f->h) in link)) => (g = h))
})
}

pred inv6_correct_8[] {
(all f: (one File) {
(lone (f <: link))
})
}

pred inv6_correct_9[] {
(all x: (one File),y,z: (one File) {
((((x->y) in link) && ((x->z) in link)) => (y = z))
})
}

pred inv6_correct_10[] {
(all file: (one File) {
(lone (file.link))
})
}

pred inv6_correct_11[] {
(all x: (one File) {
(lone (x.link))
})
}

pred inv6_correct_12[] {
((all f: (one File) {
((#(f.link)) < 2)
}) && (all f1,f2,f3: (one File) {
((((f1->f2) in link) && ((f1->f3) in link)) => (f2 = f3))
}))
}

pred inv6_correct_13[] {
(all f,f2,f3: (one File) {
((((f->f2) in link) && ((f->f3) in link)) => (f2 = f3))
})
}

