#!/bin/bash

if [ -n "$IMAGE_VERSION" ]; then
    echo -e "\033[1;31mWorkspace environment detected. Please conduct the experiment on the pi-cluster.\033[0m"
    exit 0
fi

OUTPUT_FILE="result.csv"

if [ -f "$OUTPUT_FILE" ]; then
    read -r -p "$OUTPUT_FILE already exists. Overwrite? (y/n) " ans
    case "$ans" in
    [Yy]*)
        rm -f "$OUTPUT_FILE"
        ;;
    [Nn]*)
        echo "Aborting."
        exit 0
        ;;
    *)
        echo "Invalid input. Aborting."
        exit 0
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

Ns=(1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304 8388608 16777216 33554432 67108864)

total_runs=85
run_count=1

for N in "${Ns[@]}"; do

    for i in {1..5}; do
        echo "Experiment ${run_count}/${total_runs}"
        OUTPUT=$("$tmp_exe" "$N" 1000007 1)
        echo "$OUTPUT"

        while IFS= read -r line; do
            if [[ "$line" =~ ^Total\ sum:\ .*Threads:\ .*Time:\ .*sec,\ Speedup:\ .* ]]; then

                totalsum=$(echo "$line"  | sed -E 's/^Total sum: (-?[0-9\.]+), Threads: ([0-9]+), Time: ([0-9\.]+) sec, Speedup: ([0-9\.]+)/\1/')
                threads=$(echo "$line"   | sed -E 's/^Total sum: (-?[0-9\.]+), Threads: ([0-9]+), Time: ([0-9\.]+) sec, Speedup: ([0-9\.]+)/\2/')
                time=$(echo "$line"      | sed -E 's/^Total sum: (-?[0-9\.]+), Threads: ([0-9]+), Time: ([0-9\.]+) sec, Speedup: ([0-9\.]+)/\3/')
                speedup=$(echo "$line"   | sed -E 's/^Total sum: (-?[0-9\.]+), Threads: ([0-9]+), Time: ([0-9\.]+) sec, Speedup: ([0-9\.]+)/\4/')

                echo "$N,$totalsum,$threads,$time,$speedup" >> "$OUTPUT_FILE"
            fi
        done <<<"$OUTPUT"
        ((run_count++))
        echo "--------------------------------"
    done
done

rm -f "$tmp_exe"
echo "All done."
