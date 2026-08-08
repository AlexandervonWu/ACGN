module alloy4fun_augmented_productionLine_v1_inv2
sig Position {}

sig Product {}

sig Component extends Product {
    parts : set Product,
    position : one Position
}
sig Resource extends Product {}

sig Robot {
        position : one Position
}

pred inv2_oracle[] {
all c : Component | c not in c.^parts
}

pred inv2_correct_0[] {
no ^parts & iden
}

pred inv2_correct_1[] {
all c : Component | c not in (c.parts).*parts
}

pred inv2_correct_2[] {
all c: Component | no (c & c.^parts)
}

pred inv2_correct_3[] {
no c : Component | c in c.^(parts)
}

pred inv2_correct_4[] {
no iden & ^parts
}

pred inv2_correct_5[] {
all c : Component | c not in (c.parts).^parts
}

pred inv2_correct_6[] {
all c:Component | no c.^parts & c
}

pred inv2_correct_7[] {
all c:Product | c not in c.^parts
}

pred inv2_correct_8[] {
all c1:Component | c1 not in c1.^parts
}

