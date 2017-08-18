# This module defines a small NixOS installation CD.  It does not
# contain any graphical stuff.

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./programmer-dvorak.nix
    ];

    # add zfs support to the live environment
    boot.supportedFilesystems = [ "zfs" ];

    # add the automated installation files
    environment.etc = {
	"techhazard/automated_install.sh" = {
	    source = ./automated_install.sh;
	    mode = "0700";
	};
	"techhazard/formatluks.sh" = {
	    source = ./formatluks.sh;
	    mode = "0700";
	};
	"techhazard/formatzfs.sh" = {
	    source = ./formatzfs.sh;
	    mode = "0700";
	};
	"techhazard/partition.sh" = {
	    source = ./partition.sh;
	    mode = "0700";
	};
	"techhazard/lukskeyfile.nix" = {
	    source = ./lukskeyfile.nix;
	    mode = "0600";
	};
	"techhazard/zfs.nix" = {
	    source = ./zfs.nix;
	    mode = "0600";
	};
	"techhazard/programmer-dvorak.nix" = {
	    source = ./programmer-dvorak.nix;
	    mode = "0600";
	};
#	"techhazard/Readme.md" = {
#	    source = ./Readme.md;
#	    mode = "0600";
#	};
	"techhazard/hostkey" = {
	    source = ./hostkey;
	    mode = "0600";
	};
    };

    # add the directory with the files to the path
    environment.variables = { PATH = [ "/bin" "/usr/bin" "/etc/techhazard" ]; };
}
