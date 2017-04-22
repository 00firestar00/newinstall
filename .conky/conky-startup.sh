sleep 2s
killall conky
conky -c "/home/evan/.conky/cpu_panel_8core" &
conky -c "/home/evan/.conky/network_panel" &
conky -c "/home/evan/.conky/clock" &
conky -c "/home/evan/.conky/sensors" &
