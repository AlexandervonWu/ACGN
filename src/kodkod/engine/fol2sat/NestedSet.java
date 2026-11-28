package kodkod.engine.fol2sat;

import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

/**
 * Variables observed at one nesting level of a Pardinus translation.
 * Adapted from Pardinus 6.2.0 (author: aleks, Apache-2.0).
 * Each translation owns its mutable root as well as its child scopes.
 */
public class NestedSet<T> implements Iterable<T> {
    private final NestedSet<T> parent;
    private final Set<T> elements = new HashSet<>();

    private NestedSet(NestedSet<T> parent) {
        this.parent = parent;
    }

    public static <T> NestedSet<T> empty() {
        return new NestedSet<>(null);
    }

    public NestedSet<T> createNested() {
        return new NestedSet<>(this);
    }

    public void add(T element) {
        elements.add(element);
    }

    public void addAll(Collection<? extends T> additions) {
        elements.addAll(additions);
    }

    public NestedSet<T> parent() {
        return parent;
    }

    @Override
    public Iterator<T> iterator() {
        return elements.iterator();
    }
}
