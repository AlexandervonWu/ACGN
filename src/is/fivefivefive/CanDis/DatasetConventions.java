package is.fivefivefive.CanDis;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Map;

final class DatasetConventions {
    private DatasetConventions() {
    }

    static String normalizeStatusFolder(String folder) {
        if (folder == null || folder.isEmpty()) {
            return "";
        }
        String normalized = folder.trim().toUpperCase(Locale.ROOT)
                .replace("-", "")
                .replace("_", "");
        switch (normalized) {
            case "CORRECT":
                return "CORRECT";
            case "BOTH":
                return "BOTH";
            case "OVER":
            case "OVERCONSTRAINED":
                return "OVERCONSTRAINED";
            case "UNDER":
            case "UNDERCONSTRAINED":
                return "UNDERCONSTRAINED";
            default:
                return folder.trim().toUpperCase(Locale.ROOT);
        }
    }

    static String[] findPredicatePairNames(String preferred, Map<String, ?> predicates) {
        if (preferred != null) {
            String student = matchingName(preferred, predicates);
            String oracle = student == null ? null : matchingName(student + "C", predicates);
            if (oracle != null && !oracle.equals(student)) {
                return new String[] { student, oracle };
            }
        }

        List<String> names = new ArrayList<>(predicates.keySet());
        names.sort(Comparator.comparing((String name) -> name.toLowerCase(Locale.ROOT))
                .thenComparing(Comparator.naturalOrder()));
        for (String oracle : names) {
            if (oracle.length() <= 1 || Character.toLowerCase(oracle.charAt(oracle.length() - 1)) != 'c') {
                continue;
            }
            String student = matchingName(oracle.substring(0, oracle.length() - 1), predicates);
            if (student != null && !student.equals(oracle)) {
                return new String[] { student, oracle };
            }
        }
        return null;
    }

    private static String matchingName(String requested, Map<String, ?> predicates) {
        if (predicates.containsKey(requested)) {
            return requested;
        }
        String best = null;
        for (String name : predicates.keySet()) {
            if (name.equalsIgnoreCase(requested) && (best == null || name.compareTo(best) < 0)) {
                best = name;
            }
        }
        return best;
    }
}
