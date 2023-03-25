##################################################
# Filename     : Makefile
# Date         : 23 Mar 2023
# Author       : Jonathan L. Jacobson
# Email        : jacobson.jonathan.1@gmail.com
#
# Makefile for IP
#
##################################################

LIB_NAME = jacobson_ip
LIB_DIR  = ../lib

# Compile everything into the lib folder
compile: ./*
	cd ../ && \
	vcom -work lib/jacobson_ip \
	    jacobson_ip/ip_counter.vhd \
		jacobson_ip/vga_counter.vhd \
		jacobson_ip/clk_divider.vhd \


# Delete the library using vdel
clean:
	cd $(LIB_DIR) && \
	vdel -all -lib $(LIB_NAME)