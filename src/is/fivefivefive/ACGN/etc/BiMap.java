package is.fivefivefive.ACGN.etc;

import java.io.Serializable;
import java.util.Map;

import is.fivefivefive.alloyasg.etc.DoubleMap;

// Serializable extension of AlloyASG.DoubleMap
public class BiMap<K, V> extends DoubleMap<K, V> implements Serializable {
    public BiMap() {
        super();
    }
    public BiMap(Map<K, V> lmap) {
        super(lmap);
    }
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("BiMap:\n");
        for (K key : keys()) {
            sb.append(key).append(" -> ").append(get(key)).append("\n");
        }
        return sb.toString();
    }
}