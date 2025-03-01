#!/bin/bash

OUTPUT_FILE="result.csv"

if [ -f "$OUTPUT_FILE" ]; then
    read -r -p "$OUTPUT_FILE already exists. Overwrite? (y/n) " ans
    case "$ans" in
    [Yy]*)
        rm -f "$OUTPUT_FILE"
        ;;
    [Nn]*)
        echo "Aborting."
        exit 1
        ;;
    *)
        echo "Invalid input. Aborting."
        exit 1
        ;;
    esac
fi

tmp_exe=$(mktemp -u /tmp/amdahls_law.XXXXXX)
gcc -o "$tmp_exe" main.c -O3
if [ $? -ne 0 ]; then
    echo -e "Compile failed.\n"
    exit 1
else
    echo -e "Compile success.\n"
fi

echo "N,totalsum,threads,time,speedup" > "$OUTPUT_FILE"

Ns=(10000000 20000000 30000000 40000000 50000000 60000000 70000000 80000000 90000000 100000000)

total_runs=30
run_count=1

for N in "${Ns[@]}"; do

    for i in {1..3}; do
        echo "Experiment ${run_count}/${total_runs}"
        OUTPUT=$("$tmp_exe" "$N" 10000007 1)
        echo "$OUTPUT"

        while IFS= read -r line; do
            if [[ "$line" =~ ^Total\ sum:\ .*Threads:\ .*Time:\ .*sec,\ Speedup:\ .* ]]; then

                totalsum=$(echo "$line"  | sed -E 's/^Total sum: ([0-9\.]+), Threads: ([0-9]+), Time: ([0-9\.]+) sec, Speedup: ([0-9\.]+)/\1/')
                threads=$(echo "$line"   | sed -E 's/^Total sum: ([0-9\.]+), Threads: ([0-9]+), Time: ([0-9\.]+) sec, Speedup: ([0-9\.]+)/\2/')
                time=$(echo "$line"      | sed -E 's/^Total sum: ([0-9\.]+), Threads: ([0-9]+), Time: ([0-9\.]+) sec, Speedup: ([0-9\.]+)/\3/')
                speedup=$(echo "$line"   | sed -E 's/^Total sum: ([0-9\.]+), Threads: ([0-9]+), Time: ([0-9\.]+) sec, Speedup: ([0-9\.]+)/\4/')

                echo "$N,$totalsum,$threads,$time,$speedup" >> "$OUTPUT_FILE"
            fi
        done <<<"$OUTPUT"
        ((run_count++))
        echo "--------------------------------"
    done
done

rm -f "$tmp_exe"
echo "All done."
