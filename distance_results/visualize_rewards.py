#!/usr/bin/env python3
import csv
import json
import math
import sys
from collections import defaultdict
from pathlib import Path


def load_points(json_path):
    with json_path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)
    points = []
    for row in data.get("results", []):
        if not row.get("success"):
            continue
        reward = row.get("candidateReward")
        if reward is None:
            continue
        candidate_reward = float(reward)
        points.append({
            "relativePath": row.get("relativePath", ""),
            "problemClass": row.get("problemClass", ""),
            "statusFolder": row.get("statusFolder", ""),
            "distance": float(row.get("distance", 0)),
            "predicateBodyLevenshteinDistance": float(row.get("predicateBodyLevenshteinDistance", 0)),
            "rawAstTreeDistance": float(row.get("rawAstTreeDistance", 0)),
            "candidateReward": candidate_reward,
            "groundTruthReward": float(row.get("groundTruthReward", 0)),
            "rewardGap": float(row.get("rewardGap", 0)),
            "rewardError": max(0.0, 1.0 - candidate_reward),
        })
    return points


def write_csv(points, output_dir):
    path = output_dir / "distance_reward_points.csv"
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=[
            "relativePath",
            "problemClass",
            "statusFolder",
            "distance",
            "predicateBodyLevenshteinDistance",
            "rawAstTreeDistance",
            "candidateReward",
            "groundTruthReward",
            "rewardGap",
            "rewardError",
        ], lineterminator="\n")
        writer.writeheader()
        writer.writerows(points)
    return path


def mean(values):
    return sum(values) / len(values) if values else 0.0


def correlation(xs, ys):
    if len(xs) < 2:
        return 0.0
    x_bar = mean(xs)
    y_bar = mean(ys)
    numerator = sum((x - x_bar) * (y - y_bar) for x, y in zip(xs, ys))
    x_den = math.sqrt(sum((x - x_bar) ** 2 for x in xs))
    y_den = math.sqrt(sum((y - y_bar) ** 2 for y in ys))
    if x_den == 0.0 or y_den == 0.0:
        return 0.0
    return numerator / (x_den * y_den)


def reward_error_floor(points):
    positives = [p["rewardError"] for p in points if p["rewardError"] > 0.0]
    return min(positives) / 10.0 if positives else 1e-6


def plottable_reward_error(point, floor):
    return max(point["rewardError"], floor)


def plot(points, output_dir):
    try:
        import matplotlib.pyplot as plt
    except ImportError:
        return []

    colors = {
        "CORRECT": "#2ca02c",
        "OVERCONSTRAINED": "#d62728",
        "UNDERCONSTRAINED": "#1f77b4",
        "BOTH": "#9467bd",
    }
    markers = {
        "CORRECT": "o",
        "OVERCONSTRAINED": "^",
        "UNDERCONSTRAINED": "s",
        "BOTH": "x",
    }

    grouped = defaultdict(list)
    for point in points:
        grouped[point["statusFolder"]].append(point)
    error_floor = reward_error_floor(points)

    generated = []
    fig, ax = plt.subplots(figsize=(10, 6))
    for status, rows in sorted(grouped.items()):
        ax.scatter(
            [row["distance"] for row in rows],
            [row["candidateReward"] for row in rows],
            s=14,
            alpha=0.65,
            label=status,
            c=colors.get(status, "#7f7f7f"),
            marker=markers.get(status, "o"),
        )
    corr_points = [p for p in points if p["statusFolder"] != "CORRECT"]
    corr = correlation([p["distance"] for p in corr_points], [p["candidateReward"] for p in corr_points])
    ax.set_title(f"Canonical edit distance vs Rewarder candidate reward (r={corr:.3f})")
    ax.set_xlabel("Canonical edit distance")
    ax.set_ylabel("Candidate reward against invXC")
    ax.grid(True, alpha=0.2)
    ax.legend(title="Status", markerscale=1.5)
    fig.tight_layout()
    path = output_dir / "distance_vs_candidate_reward.png"
    fig.savefig(path, dpi=180)
    generated.append(path)
    plt.close(fig)

    fig, ax = plt.subplots(figsize=(10, 6))
    for status, rows in sorted(grouped.items()):
        ax.scatter(
            [row["distance"] for row in rows],
            [plottable_reward_error(row, error_floor) for row in rows],
            s=14,
            alpha=0.65,
            label=status,
            c=colors.get(status, "#7f7f7f"),
            marker=markers.get(status, "o"),
        )
    corr_points = [p for p in points if p["statusFolder"] != "CORRECT"]
    corr = correlation(
        [p["distance"] for p in corr_points],
        [math.log10(plottable_reward_error(p, error_floor)) for p in corr_points],
    )
    ax.set_yscale("log")
    ax.set_title(f"Canonical edit distance vs log reward error (r={corr:.3f})")
    ax.set_xlabel("Canonical edit distance")
    ax.set_ylabel("1 - candidate reward")
    ax.grid(True, alpha=0.2)
    ax.legend(title="Status", markerscale=1.5)
    fig.tight_layout()
    path = output_dir / "distance_vs_reward_gap.png"
    fig.savefig(path, dpi=180)
    generated.append(path)
    plt.close(fig)
    return generated


def plot_svg(points, output_dir):
    if not points:
        return []
    statuses = ["CORRECT", "OVERCONSTRAINED", "UNDERCONSTRAINED", "BOTH"]
    colors = {
        "CORRECT": "#2ca02c",
        "OVERCONSTRAINED": "#d62728",
        "UNDERCONSTRAINED": "#1f77b4",
        "BOTH": "#9467bd",
    }

    def write_plot(filename, y_key, y_label, title, log_y=False):
        width = 1000
        height = 620
        left = 82
        right = 28
        top = 54
        bottom = 80
        plot_width = width - left - right
        plot_height = height - top - bottom
        xs = [p["distance"] for p in points]
        y_floor = reward_error_floor(points) if log_y else 0.0
        ys = [plottable_reward_error(p, y_floor) if log_y else p[y_key] for p in points]
        x_min = min(xs)
        x_max = max(xs)
        y_min = min(ys)
        y_max = max(ys)
        if x_min == x_max:
            x_max = x_min + 1.0
        if y_min == y_max:
            y_max = y_min + 1.0
        if log_y:
            y_min_log = math.floor(math.log10(y_min))
            y_max_log = math.ceil(math.log10(y_max))
            if y_min_log == y_max_log:
                y_max_log += 1
        else:
            y_pad = (y_max - y_min) * 0.04
            y_min = max(0.0, y_min - y_pad)
            y_max = y_max + y_pad

        def sx(value):
            return left + (value - x_min) * plot_width / (x_max - x_min)

        def sy(value):
            if log_y:
                value = max(value, y_floor)
                return top + plot_height - (math.log10(value) - y_min_log) * plot_height / (y_max_log - y_min_log)
            return top + plot_height - (value - y_min) * plot_height / (y_max - y_min)

        corr_points = [p for p in points if p["statusFolder"] != "CORRECT"]
        corr_ys = [
            math.log10(plottable_reward_error(p, y_floor)) if log_y else p[y_key]
            for p in corr_points
        ]
        corr = correlation([p["distance"] for p in corr_points], corr_ys)
        path = output_dir / filename
        with path.open("w", encoding="utf-8") as handle:
            handle.write(f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">\n')
            handle.write('<rect width="100%" height="100%" fill="white"/>\n')
            handle.write(f'<text x="{width / 2:.1f}" y="28" text-anchor="middle" font-family="sans-serif" font-size="20">{title} (r={corr:.3f})</text>\n')
            handle.write(f'<line x1="{left}" y1="{top + plot_height}" x2="{left + plot_width}" y2="{top + plot_height}" stroke="#333"/>\n')
            handle.write(f'<line x1="{left}" y1="{top}" x2="{left}" y2="{top + plot_height}" stroke="#333"/>\n')
            for i in range(6):
                x_value = x_min + (x_max - x_min) * i / 5.0
                x_pos = sx(x_value)
                handle.write(f'<line x1="{x_pos:.1f}" y1="{top}" x2="{x_pos:.1f}" y2="{top + plot_height}" stroke="#eee"/>\n')
                handle.write(f'<text x="{x_pos:.1f}" y="{top + plot_height + 24}" text-anchor="middle" font-family="sans-serif" font-size="12">{x_value:.0f}</text>\n')
                if log_y:
                    y_value = 10 ** (y_min_log + (y_max_log - y_min_log) * i / 5.0)
                    y_label_value = f"{y_value:.0e}"
                else:
                    y_value = y_min + (y_max - y_min) * i / 5.0
                    y_label_value = f"{y_value:.2f}"
                y_pos = sy(y_value)
                handle.write(f'<line x1="{left}" y1="{y_pos:.1f}" x2="{left + plot_width}" y2="{y_pos:.1f}" stroke="#eee"/>\n')
                handle.write(f'<text x="{left - 10}" y="{y_pos + 4:.1f}" text-anchor="end" font-family="sans-serif" font-size="12">{y_label_value}</text>\n')
            handle.write(f'<text x="{left + plot_width / 2:.1f}" y="{height - 24}" text-anchor="middle" font-family="sans-serif" font-size="15">Canonical edit distance</text>\n')
            handle.write(f'<text x="20" y="{top + plot_height / 2:.1f}" transform="rotate(-90 20 {top + plot_height / 2:.1f})" text-anchor="middle" font-family="sans-serif" font-size="15">{y_label}</text>\n')
            for status in statuses:
                rows = [p for p in points if p["statusFolder"] == status]
                for point in rows:
                    y_value = plottable_reward_error(point, y_floor) if log_y else point[y_key]
                    handle.write(f'<circle cx="{sx(point["distance"]):.1f}" cy="{sy(y_value):.1f}" r="3.2" fill="{colors[status]}" opacity="0.58"/>\n')
            legend_x = left + plot_width - 190
            legend_y = top + 18
            for index, status in enumerate(statuses):
                y_pos = legend_y + index * 22
                handle.write(f'<circle cx="{legend_x}" cy="{y_pos}" r="5" fill="{colors[status]}" opacity="0.75"/>\n')
                handle.write(f'<text x="{legend_x + 12}" y="{y_pos + 4}" font-family="sans-serif" font-size="13">{status}</text>\n')
            handle.write("</svg>\n")
        return path

    return [
        write_plot(
            "distance_vs_candidate_reward.svg",
            "candidateReward",
            "Candidate reward against invXC",
            "Canonical edit distance vs Rewarder candidate reward",
        ),
        write_plot(
            "distance_vs_reward_gap.svg",
            "rewardError",
            "1 - candidate reward (log scale)",
            "Canonical edit distance vs log reward error",
            log_y=True,
        ),
    ]


def main():
    json_path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("distance_results/distances.json")
    output_dir = Path(sys.argv[2]) if len(sys.argv) > 2 else json_path.parent
    output_dir.mkdir(parents=True, exist_ok=True)
    points = load_points(json_path)
    csv_path = write_csv(points, output_dir)
    svg_images = plot_svg(points, output_dir)
    images = plot(points, output_dir)
    print(f"Loaded {len(points)} rewarded records")
    print(f"Wrote {csv_path}")
    for image in svg_images:
        print(f"Wrote {image}")
    if images:
        for image in images:
            print(f"Wrote {image}")
    else:
        print("matplotlib is not installed; SVG and CSV outputs are available")


if __name__ == "__main__":
    main()
