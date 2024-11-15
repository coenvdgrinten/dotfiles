echo $($xrandr | $(grep -q "DP-3-5 connected"))

if [ $($xrandr | $(grep -q "eDP-1 connected")) ] && [ $($xrandr | $(grep -q "DP-3-5 connected")) ] && [ $($xrandr | $(grep -q "DP-3-6 connected")) ]; then
echo "Work monitors connected!"
else
echo "Only Laptop Screen Connected!"
fi