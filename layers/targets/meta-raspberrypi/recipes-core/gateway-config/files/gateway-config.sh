#!/bin/sh

do_main_menu() {
    while true
    do
        FUN=$(dialog --title "ChirpStack Gateway OS" --cancel-label "Quit" --menu "Configuration options:" 15 60 7 \
            1 "Set admin password" \
            2 "Setup LoRa concentrator shield" \
            3 "Edit ChirpStack Concentratord config" \
            4 "Edit ChirpStack Gateway Bridge config" \
            5 "Restart ChirpStack Concentratord" \
            6 "Restart ChirpStack Gateway Bridge" \
            7 "Configure WIFI" \
            3>&1 1>&2 2>&3)
        RET=$?
        if [ $RET -eq 1 ]; then
            clear
            exit 0
        elif [ $RET -eq 0 ]; then
            case "$FUN" in
                1) do_setup_admin_password;;
                2) do_setup_concentrator_shield;;
                3) do_edit_chirpstack_concentratord_config && do_restart_chirpstack_concentratord;;
                4) do_edit_chirpstack_gateway_bridge_config && do_restart_chirpstack_gateway_bridge;;
                5) do_restart_chirpstack_concentratord;;
                6) do_restart_chirpstack_gateway_bridge;;
                7) do_configure_wifi;;
            esac
        fi
    done
}

do_setup_admin_password() {
    dialog --title "Setup admin password" --msgbox "You will be asked to enter a new password." 5 60
    passwd admin
    RET=$?
    if [ $RET -eq 0 ]; then
        dialog --title "Setup admin password" --msgbox "Password has been changed succesfully." 5 60
    else
        exit $RET
    fi
}

do_setup_concentrator_shield() {
    FUN=$(dialog --title "Setup LoRa concentrator shield" --menu "Select shield:" 15 60 9 \
        1  "Dragino    - PG1301" \
	    2  "IMST       - iC880A" \
        3  "IMST       - iC980A" \
        4  "IMST       - Lite Gateway" \
        5  "Pi Supply  - LoRa Gateway HAT" \
        6  "RAK        - RAK2245" \
        7  "RAK        - RAK831" \
        8  "RisingHF   - RHF0M301" \
        9  "Sandbox    - LoRaGo PORT" \
        10 "Semtech    - SX1302 CoreCell" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 0 ]; then
        case "$FUN" in
            1) do_set_concentratord "sx1301" && do_set_concentrator_reset_pin 23 && do_setup_pg1301;;
	        2) do_set_concentratord "sx1301" && do_prompt_concentrator_reset_pin && do_setup_ic880a;;
            3) do_set_concentratord "sx1301" && do_prompt_concentrator_reset_pin && do_setup_ic980a;;
            4) do_set_concentratord "sx1301" && do_set_concentrator_reset_pin 5  && do_setup_imst_lite;;
            5) do_set_concentratord "sx1301" && do_set_concentrator_reset_pin 22 && do_setup_pislora;;
            6) do_set_concentratord "sx1301" && do_set_concentrator_reset_pin 17 && do_setup_rak831;;
            7) do_set_concentratord "sx1301" && do_set_concentrator_reset_pin 17 && do_setup_rak831;;
            8) do_set_concentratord "sx1301" && do_set_concentrator_reset_pin 7  && do_setup_rhf0m301;;
            9) do_set_concentratord "sx1301" && do_set_concentrator_reset_pin 25 && do_setup_lorago_port;;
            10) do_set_concentratord "sx1302" && do_set_concentrator_reset_pin 23 && do_set_concentratord_power_en_pin 18 && do_setup_semtech_corecell;;
        esac
    fi
}

do_setup_pg1301() {
    FUN=$(dialog --title "Channel-plan configuration" --menu "Select the channel-plan:" 15 60 1 \
        1 "EU868" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        do_main_menu
    elif [ $RET -eq 0 ]; then
        case "$FUN" in
			1) do_copy_concentratord_config "sx1301" "generic_eu868" "" "eu868" "0" && do_copy_chirpstack_ns_config "eu868";;
        esac
    fi
}

do_setup_ic880a() {
    FUN=$(dialog --title "Channel-plan configuration" --menu "Select the channel-plan:" 15 60 1 \
        1 "EU868" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        do_main_menu
    elif [ $RET -eq 0 ]; then
        case "$FUN" in
			1) do_copy_concentratord_config "sx1301" "imst_ic880a_eu868" "" "eu868" "0" && do_copy_chirpstack_ns_config "eu868";
        esac
    fi
}

do_setup_ic980a() {
    FUN=$(dialog --title "Channel-plan configuration" --menu "Select the channel-plan:" 15 60 3 \
        1 "US915" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        do_main_menu
    elif [ $RET -eq 0 ]; then
        case "$FUN" in
            1) do_select_us915_block "sx1301" "generic_eu868";;
        esac
    fi
}

do_setup_imst_lite() {
    FUN=$(dialog --title "Channel-plan configuration" --menu "Select the channel-plan:" 15 60 1 \
        1 "EU868" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        do_main_menu
    elif [ $RET -eq 0 ]; then
        case "$FUN" in
			1) do_copy_concentratord_config "sx1301" "imst_ic880a_eu868" "" "eu868" "0" && do_copy_chirpstack_ns_config "eu868";
        esac
    fi
}

do_setup_pislora() {
    FUN=$(dialog --title "Channel-plan configuration" --menu "Select the channel-plan:" 15 60 2 \
        1 "EU868" \
        3 "US915" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        do_main_menu
    elif [ $RET -eq 0 ]; then
        case "$FUN" in
			1) do_copy_concentratord_config "sx1301" "generic_eu868" "" "eu868" "0" && do_copy_chirpstack_ns_config "eu868";;
            2) do_select_us915_block "sx1301" "generic_us915";;
        esac
    fi
}

do_setup_rak831() {
    FUN=$(dialog --title "Channel-plan configuration" --menu "Select the channel-plan:" 15 60 3 \
        1 "EU868" \
        2 "AU915" \
        3 "US915" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        do_main_menu
    elif [ $RET -eq 0 ]; then
        case "$FUN" in
			1) do_copy_concentratord_config "sx1301" "generic_eu868" "GNSS" "eu868" "0" && do_copy_chirpstack_ns_config "eu868";;
            2) do_select_au915_block "sx1301" "generic_au915_gps";;
            3) do_select_us915_block "sx1301" "generic_us915_gps";;
        esac
    fi
}

do_setup_rhf0m301() {
    FUN=$(dialog --title "Channel-plan configuration" --menu "Select the channel-plan:" 15 60 2 \
        1 "EU868" \
        2 "US915" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        do_main_menu
    elif [ $RET -eq 0 ]; then
        case "$FUN" in
			1) do_copy_concentratord_config "sx1301" "generic_eu868" "" "eu868" "0" && do_copy_chirpstack_ns_config "eu868";;
            2) do_select_us915_block "sx1301" "generic_us915";;
        esac
    fi
}

do_setup_lorago_port() {
    FUN=$(dialog --title "Channel-plan configuration" --menu "Select the channel-plan:" 15 60 2 \
        1 "EU868" \
        2 "US915" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        do_main_menu
    elif [ $RET -eq 0 ]; then
        case "$FUN" in
			1) do_copy_concentratord_config "sx1301" "generic_eu868" "" "eu868" "0" && do_copy_chirpstack_ns_config "eu868";;
            2) do_select_us915_block "sx1301" "generic_us915_gps";;
        esac
    fi
}

do_setup_semtech_corecell() {
    FUN=$(dialog --title "Channel-plan configuration" --menu "Select the channel-plan:" 15 60 2 \
        1 "EU868" \
        2 "US915" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        do_main_menu
    elif [ $RET -eq 0 ]; then
        case "$FUN" in
			1) do_copy_concentratord_config "sx1302" "generic_sx1250_eu868" "" "eu868" "0" && do_copy_chirpstack_ns_config "eu868";;
            2) do_select_us915_block "sx1302" "generic_sx1250_us915";;
        esac
    fi
}

do_select_us915_block() {
    # $1: concentratord version
	# $2: model
	# $3: model flags
    FUN=$(dialog --title "Channel-plan configuration" --menu "Select the US915 channel-block:" 15 60 8 \
        1 "Channels  0 -  7 + 64" \
        2 "Channels  8 - 15 + 65" \
        3 "Channels 16 - 23 + 66" \
        4 "Channels 24 - 31 + 67" \
        5 "Channels 32 - 39 + 68" \
        6 "Channels 40 - 47 + 69" \
        7 "Channels 48 - 55 + 70" \
        8 "Channels 56 - 64 + 71" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        do_main_menu
    elif [ $RET -eq 0 ]; then
        case "$FUN" in
            1) do_copy_concentratord_config $1 $2 $3 "us915" "0" && do_copy_chirpstack_ns_config "us915_0";;
            2) do_copy_concentratord_config $1 $2 $3 "us915" "1" && do_copy_chirpstack_ns_config "us915_1";;
            3) do_copy_concentratord_config $1 $2 $3 "us915" "2" && do_copy_chirpstack_ns_config "us915_2";;
            4) do_copy_concentratord_config $1 $2 $3 "us915" "3" && do_copy_chirpstack_ns_config "us915_3";;
            5) do_copy_concentratord_config $1 $2 $3 "us915" "4" && do_copy_chirpstack_ns_config "us915_4";;
            6) do_copy_concentratord_config $1 $2 $3 "us915" "5" && do_copy_chirpstack_ns_config "us915_5";;
            7) do_copy_concentratord_config $1 $2 $3 "us915" "6" && do_copy_chirpstack_ns_config "us915_6";;
            8) do_copy_concentratord_config $1 $2 $3 "us915" "7" && do_copy_chirpstack_ns_config "us915_7";;
        esac
    fi
}

do_select_au915_block() {
    # $1: concentratord version
	# $2: model
	# $3: model flags
    FUN=$(dialog --title "Channel-plan configuration" --menu "Select the AU915 channel-block:" 15 60 8 \
        1 "Channels  0 -  7 + 64" \
        2 "Channels  8 - 15 + 65" \
        3 "Channels 16 - 23 + 66" \
        4 "Channels 24 - 31 + 67" \
        5 "Channels 32 - 39 + 68" \
        6 "Channels 40 - 47 + 69" \
        7 "Channels 48 - 55 + 70" \
        8 "Channels 56 - 64 + 71" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        do_main_menu
    elif [ $RET -eq 0 ]; then
        case "$FUN" in
            1) do_copy_concentratord_config $1 $2 $3 "au915" "0" && do_copy_chirpstack_ns_config "au915_0";;
            2) do_copy_concentratord_config $1 $2 $3 "au915" "1" && do_copy_chirpstack_ns_config "au915_1";;
            3) do_copy_concentratord_config $1 $2 $3 "au915" "2" && do_copy_chirpstack_ns_config "au915_2";;
            4) do_copy_concentratord_config $1 $2 $3 "au915" "3" && do_copy_chirpstack_ns_config "au915_3";;
            5) do_copy_concentratord_config $1 $2 $3 "au915" "4" && do_copy_chirpstack_ns_config "au915_4";;
            6) do_copy_concentratord_config $1 $2 $3 "au915" "5" && do_copy_chirpstack_ns_config "au915_5";;
            7) do_copy_concentratord_config $1 $2 $3 "au915" "6" && do_copy_chirpstack_ns_config "au915_6";;
            8) do_copy_concentratord_config $1 $2 $3 "au915" "7" && do_copy_chirpstack_ns_config "au915_7";;
        esac
    fi
}


do_set_concentratord() {
	monit stop chirpstack-concentratord
	sed -i "s/CONCENTRATORD_VERSION=.*/CONCENTRATORD_VERSION=\"$1\"/" /etc/default/chirpstack-concentratord
}

do_prompt_concentrator_reset_pin() {
    PIN=$(dialog --inputbox "Please enter the GPIO pin to which the concentrator reset is connected: " 8 60 \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        do_setup_concentrator_shield
    elif [ $RET -eq 0 ]; then
        do_set_concentrator_reset_pin $PIN
    fi
}

do_set_concentrator_reset_pin() {
	sed -i "s/CONCENTRATOR_RESET=.*/CONCENTRATOR_RESET=\"yes\"/" /etc/default/chirpstack-concentratord
    sed -i "s/CONCENTRATOR_RESET_PIN=.*/CONCENTRATOR_RESET_PIN=$1/" /etc/default/chirpstack-concentratord
}

do_set_concentratord_power_en_pin() {
    sed -i "s/CONCENTRATOR_POWER_EN_PIN=.*/CONCENTRATOR_POWER_EN_PIN=$1/" /etc/default/chirpstack-concentratord
}

do_copy_concentratord_config() {
	# $1 concentratord version
	# $2 model
	# $3 model flags
	# $4 region
	# $5 sub-band
    RET=0
    if [ -f "/etc/chirpstack-concentratord/$1/global.toml" ] || [ -f "/etc/chirpstack-concentratord/$1/band.toml"] || [ -f "/etc/chirpstack-concentratord/$1/channels.toml" ]; then
        dialog --yesno "A ChirpStack Concentratord configuration file already exists. Do you want to overwrite it?" 6 60
        RET=$?
    fi

    if [ $RET -eq 0 ]; then
		cp /etc/chirpstack-concentratord/$1/examples/global.toml /etc/chirpstack-concentratord/$1/global.toml
		cp /etc/chirpstack-concentratord/$1/examples/$4.toml /etc/chirpstack-concentratord/$1/band.toml
		cp /etc/chirpstack-concentratord/$1/examples/$4_$5.toml /etc/chirpstack-concentratord/$1/channels.toml

        RET=$?
        if [ $RET -eq 0 ]; then
			# set model
			sed -i "s/model=.*/model=\"${2}\"/" /etc/chirpstack-concentratord/$1/global.toml	

			# set model flags
			IFS=' '; read -ra model_flags <<< $3
			model_flags_str=""
			for i in "${model_flags[@]}"; do model_flags_str="$model_flags_str\"$i\","; done
			sed -i "s/model_flags=.*/model_flags=[$model_flags_str]/" /etc/chirpstack-concentratord/$1/global.toml

			# set gateway id
			GWID_MIDFIX="fffe"
			GWID_BEGIN=$(ip link show eth0 | awk '/ether/ {print $2}' | awk -F\: '{print $1$2$3}')
			GWID_END=$(ip link show eth0 | awk '/ether/ {print $2}' | awk -F\: '{print $4$5$6}')
			sed -i "s/gateway_id=.*/gateway_id=\"${GWID_BEGIN}${GWID_MIDFIX}${GWID_END}\"/" /etc/chirpstack-concentratord/$1/global.toml

            dialog --title "Channel-plan configuration" --msgbox "Channel-plan configuration has been copied." 5 60
			do_restart_chirpstack_concentratord
        fi
    fi
}

do_copy_chirpstack_ns_config() {
	# $1 channel plan
    if [ ! -d /etc/chirpstack-network-server ]; then
        return;
    fi
    if [ -f /etc/chirpstack-network-server/chirpstack-network-server.toml ]; then

    RET=0
        dialog --yesno "A ChirpStack Network Server configuration file already exists. Do you want to overwrite it?" 6 60
        RET=$?
    fi

    if [ $RET -eq 0 ]; then
        cp /etc/chirpstack-network-server/config/$1.toml /etc/chirpstack-network-server/chirpstack-network-server.toml
        do_restart_chirpstack_ns
    fi
}

do_restart_chirpstack_ns() {
    monit restart chirpstack-network-server
    RET=$?
    if [ $RET -eq 0 ]; then
        dialog --title "Restart ChirpStack Network Server" --msgbox "ChirpStack Network Server has been restarted." 5 60
    else
        exit $RET
    fi
}

do_edit_chirpstack_concentratord_config() {
    FUN=$(dialog --title "Edit ChirpStack Concentratord config" --menu "Select shield:" 15 60 3 \
        1 "General configuration" \
        2 "Beacon configuration" \
        3 "Channel configuration" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 0 ]; then
		source /etc/default/chirpstack-concentratord

        case "$FUN" in
			1) nano "/etc/chirpstack-concentratord/${CONCENTRATORD_VERSION}/global.toml";;
			2) nano "/etc/chirpstack-concentratord/${CONCENTRATORD_VERSION}/band.toml";;
			3) nano "/etc/chirpstack-concentratord/${CONCENTRATORD_VERSION}/channels.toml";;
        esac
    fi
}

do_edit_chirpstack_gateway_bridge_config() {
	nano /etc/chirpstack-gateway-bridge/chirpstack-gateway-bridge.toml
}

do_restart_chirpstack_concentratord() {
	monit restart chirpstack-concentratord
    RET=$?
    if [ $RET -eq 0 ]; then
        dialog --title "Restart ChirpStack Concentratord" --msgbox "The ChirpStack Concentratord has been restarted." 5 60
    else
        exit $RET
    fi
}

do_restart_chirpstack_gateway_bridge() {
    monit restart chirpstack-gateway-bridge
    RET=$?
    if [ $RET -eq 0 ]; then
        dialog --title "Restart ChirpStack Gateway Bridge" --msgbox "The ChirpStack Gateway Bridge has been restarted." 5 60
    else
        exit $RET
    fi
}

do_configure_wifi() {
	NAME=$(dialog --title "Configure WIFI" --inputbox "Please enter the name of WiFi network: " 8 60 \
        3>&1 1>&2 2>&3)
    RET=$?
	if [ ! $RET -eq 0 ]; then
		do_main_menu
	fi

	PASSWORD=$(dialog --title "Configure WIFI" --inputbox "Please enter the password: " 8 60 \
        3>&1 1>&2 2>&3)
    RET=$?
	if [ ! $RET -eq 0 ]; then
		do_main_menu
	fi
	
	dialog --title "Configure WIFI" --msgbox "The system will reboot to apply the new configuration." 5 60

	cat > /var/lib/connman/wifi.config << EOF
[service_wifi]
Type=wifi
Name=$NAME
Passphrase=$PASSWORD
IPv4=dhcp
EOF

	sed -i "s/Tethering=true/Tethering=false/" /var/lib/connman/settings
	reboot
}

if [ $EUID -ne 0 ]; then
   echo "This script must be run as root" 
   exit 1
fi

do_main_menu
