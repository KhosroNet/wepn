#!/bin/bash
#
# test_firewall.sh
# A small diagnostic script to test the firewall rules for syntax errors.
#

echo "--- Preparing to test firewall rules ---"

# Create a temporary file to hold the firewall rules
RULES_FILE=$(mktemp)

# Write the problematic firewall rules into the temporary file.
# These rules contain special characters that may cause parsing errors.
cat > "$RULES_FILE" <<'EOF'
*filter
:KHOSRO-P2P - [0:0]
-A KHOSRO-P2P -m string --algo bm --string 'BitTorrent' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'peer_id=' -j DROP
-A KHOSRO-P2P -m string --algo bm --string '.torrent' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'announce.php?passkey=' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'torrent' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'announce' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'info_hash' -j DROP
-A KHOSRO-P2P -m string --string 'get_peers' --algo bm -j DROP
-A KHOSRO-P2P -m string --string 'find_node' --algo bm -j DROP
-A KHOSRO-P2P -m string --string 'announce?info_hash=' --algo bm -j DROP
-A KHOSRO-P2P -m string --string 'announce_peer' --algo bm -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'magnet:' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'd1:a' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'd1:r' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'uTorrent' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'BitComet' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'Transmission' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'Azureus' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'Vuze' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'GET /scrape?' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'GET /announce?' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'qBittorrent' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'Deluge' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'BitTornado' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'dht_ping' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'find_node' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'GNUTELLA' -j DROP
-A KHOSRO-P2P -m string --algo bm --string 'eDonkey' -j DROP
COMMIT
EOF

# Ensure the required kernel module is loaded
sudo modprobe xt_string
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to load xt_string module."
    exit 1
fi

# Use iptables-restore's test functionality to check for syntax errors
echo ""
echo "--- Running firewall syntax test... ---"
sudo iptables-restore --test < "$RULES_FILE"

if [ $? -eq 0 ]; then
    echo ""
    echo "SUCCESS: The firewall rules have no syntax errors."
else
    echo ""
    echo "FAILURE: The firewall rules have syntax errors. See the output from iptables-restore above."
fi

# Clean up the temporary file
rm "$RULES_FILE"
echo "--- Test complete ---" 
