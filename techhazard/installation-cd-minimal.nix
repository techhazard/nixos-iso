# This module defines a small NixOS installation CD.  It does not
# contain any graphical stuff.

{ config, lib, pkgs, ... }:

{
  imports =
    [ ./installation-cd-base.nix
      ./techhazard/programmer-dvorak.nix
    ];

    # add zfs support to the live environment
    boot.supportedFilesystems = [ "zfs" ];

    # add the automated installation files
    environment.etc = {
	"techhazard/automated_install.sh" = {
	    source = techhazard/automated_install.sh;
	    mode = "0700";
	};
	"techhazard/formatluks.sh" = {
	    source = techhazard/formatluks.sh;
	    mode = "0700";
	};
	"techhazard/formatzfs.sh" = {
	    source = techhazard/formatzfs.sh;
	    mode = "0700";
	};
	"techhazard/partition.sh" = {
	    source = techhazard/partition.sh;
	    mode = "0700";
	};
	"techhazard/lukskeyfile.nix" = {
	    source = techhazard/lukskeyfile.nix;
	    mode = "0600";
	};
	"techhazard/zfs.nix" = {
	    source = techhazard/zfs.nix;
	    mode = "0600";
	};
	"techhazard/programmer-dvorak.nix" = {
	    source = techhazard/programmer-dvorak.nix;
	    mode = "0600";
	};
	"techhazard/Readme.md" = {
	    source = techhazard/Readme.md;
	    mode = "0600";
	};
	"techhazard/hostkey" = {
	    source = techhazard/hostkey;
	    mode = "0600";
	};
    };

    # add the directory with the files to the path
    environment.variables = { PATH = [ "/bin" "/usr/bin" "/etc/techhazard" ]; };
}
