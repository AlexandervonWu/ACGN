package is.fivefivefive.CanDis.theory;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Consumer;

/** Deterministic, uncapped enumeration of all typed context bijections. */
final class TypedRenamingEnumerator {
    private TypedRenamingEnumerator() {
    }

    static void forEach(
            TypedSlotContext source,
            TypedSlotContext codomain,
            Consumer<TypedRenaming> consumer) {
        Objects.requireNonNull(source, "source");
        Objects.requireNonNull(codomain, "codomain");
        Objects.requireNonNull(consumer, "consumer");
        if (!source.typeCounts().equals(codomain.typeCounts())) {
            return;
        }
        List<TypedSlot> domain = new ArrayList<>(source.slots());
        List<TypedSlot> targets = new ArrayList<>(codomain.slots());
        enumerate(
                source,
                codomain,
                domain,
                targets,
                0,
                new boolean[targets.size()],
                new LinkedHashMap<>(),
                consumer);
    }

    private static void enumerate(
            TypedSlotContext source,
            TypedSlotContext codomain,
            List<TypedSlot> domain,
            List<TypedSlot> targets,
            int index,
            boolean[] used,
            Map<TypedSlot, TypedSlot> mapping,
            Consumer<TypedRenaming> consumer) {
        if (index == domain.size()) {
            consumer.accept(TypedRenaming.of(source, codomain, mapping));
            return;
        }
        TypedSlot slot = domain.get(index);
        for (int targetIndex = 0; targetIndex < targets.size(); targetIndex++) {
            TypedSlot target = targets.get(targetIndex);
            if (used[targetIndex] || !slot.type().equals(target.type())) {
                continue;
            }
            used[targetIndex] = true;
            mapping.put(slot, target);
            enumerate(
                    source,
                    codomain,
                    domain,
                    targets,
                    index + 1,
                    used,
                    mapping,
                    consumer);
            mapping.remove(slot);
            used[targetIndex] = false;
        }
    }
}
