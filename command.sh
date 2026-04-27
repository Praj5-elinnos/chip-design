#!/bin/bash

ask() {
    while true; do
        read -p "➡️  Continue to next command? (yes/no): " ans
        case $ans in
            yes|y|Y|YES) return 0 ;;
            no|n|N|NO) echo "⛔ Stopped by user."; exit 0 ;;
            *) echo "⚠️  Please type yes or no." ;;
        esac
    done
}

echo "🚀 Starting continuous commands for 15 seconds each..."
echo ""

# Command 1: Print current time every second for 15 seconds
echo "⏰ [CMD 1] Printing current time every second for 15 seconds..."
for i in $(seq 1 15); do
    echo "  🕐 Time: $(date '+%H:%M:%S')  | Second: $i/15"
    sleep 1
done

ask

# Command 2: Count files in /etc every second for 15 seconds
echo ""
echo "📁 [CMD 2] Counting files in /etc every second for 15 seconds..."
for i in $(seq 1 15); do
    count=$(ls /etc | wc -l)
    echo "  📂 Files in /etc: $count | Second: $i/15"
    sleep 1
done

ask

# Command 3: Show CPU load every second for 15 seconds
echo ""
echo "💻 [CMD 3] Monitoring CPU load for 15 seconds..."
for i in $(seq 1 15); do
    load=$(cat /proc/loadavg | awk '{print $1}')
    echo "  ⚡ CPU Load avg: $load | Second: $i/15"
    sleep 1
done

ask

# Command 4: Show disk usage every second for 15 seconds
echo ""
echo "💾 [CMD 4] Monitoring disk usage for 15 seconds..."
for i in $(seq 1 15); do
    usage=$(df -h / | awk 'NR==2{print $5}')
    echo "  🗄️  Disk used: $usage | Second: $i/15"
    sleep 1
done

ask

# Command 5: Show memory usage every second for 15 seconds
echo ""
echo "🧠 [CMD 5] Monitoring RAM usage for 15 seconds..."
for i in $(seq 1 15); do
    mem=$(free -m | awk 'NR==2{printf "Used: %sMB / Total: %sMB", $3, $2}')
    echo "  🧮 RAM → $mem | Second: $i/15"
    sleep 1
done

echo ""
echo "✅ All commands completed successfully!"
