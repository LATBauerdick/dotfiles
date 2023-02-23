	let
#	  external-mac = "00:11:22:33:44:55";
	  ext-if = "ens3";
	  external-ip = "116.203.126.183";
	  external-gw = "116.203.126.255";
	  external-netmask = 27;
	  external-ip6 = "2a01:4f8:c2c:68e::1";
	  external-gw6 = "fe80::1";
	  external-netmask6 = 64;
	in {
	  # rename the external interface based on the MAC of the interface
	  # services.udev.extraRules = ''SUBSYSTEM=="net", ATTR{address}=="${external-mac}", NAME="${ext-if}"'';
	  networking = {
	    interfaces."${ext-if}" = {
	      ipv4.addresses = [{
		address = external-ip;
		prefixLength = external-netmask;
	      }];
	      ipv6.addresses = [{
		address = external-ip6;
		prefixLength = external-netmask6;
	      }];
	    };
	    defaultGateway6 = {
	      address = external-gw6;
	      interface = ext-if;
	    };
	    defaultGateway = external-gw;
	  };
	}
