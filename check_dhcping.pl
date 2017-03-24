#!/usr/bin/perl
#!/usr/local/bin/perl -w
#
# check_dhcp.pl - nagios plugin
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
#
# Report bugs to: luc.duchosal@arcantel.ch, nagiosplug-help@lists.sf.net
#
#
# $Id: check_dhcp, v 1.0 2004/11/24 05:29:54 lduchosal Exp $

   use POSIX;
   use strict;

   use lib  "/usr/lib/nagios/plugins" ;
   use utils qw(%ERRORS);

   my $PROGNAME  = "check_dhcping.pl";

   my $server    = @ARGV[0] or &Usage();
   my $ip        = @ARGV[1] or &Usage();
   my $mac       = @ARGV[2] or &Usage();
   my $debug     = 0;
   my $timeout   = 3;
   my $blocksize = 1024;
   my $dhcping   = "/usr/bin/dhcping";
        my $state;
   my $err;

   sub Usage() {

      print "Usage : $0 <server> <ip> <mac>\n";
      print "  server : DHCP server to probe\n";
      print "  ip     : IP address to lease\n";
      print "  mac    : MAC to ask lease with\n";
      print "\n";
      print " $0 localhost 1.2.3.4 00:de:ad:be:ef:00\n";
      $state = 'WARNING';
      exit $ERRORS{$state};

   }

   sub plugin_die($) {

      my ($msg) = @_;
      print "DHCP WARNING - PLUGIN DIE - $msg\n";
      $state = 'WARNING';
      exit $ERRORS{$state};

   }

   print "Connecting to $server...\n" if $debug;

   my $result = `$dhcping -c $ip -s $server -h $mac -t $timeout 2>&1`;
   $result =~ s/\n//g;

   if ( $result =~ m/^Got answer from/ ) {
        $err = 0;
   } else {
        $err = 1;
   }

   if ( $err ) {
      if ($result =~ m/bind: Address already in use/ ) {
         print "DHCP UNKNOWN - ERROR OCCURED - $result\n";
         $state = 'UNKNOWN';
      }
      elsif ($result =~ m/received from [0-9\.]+, expected from [0-9\.]+/) {
         print "DHCP UNKNOWN - ERROR OCCURED - $result\n";
         $state = 'UNKNOWN';
      }
      else {
         print "DHCP CRITICAL - ERROR OCCURED - $result \n";
         $state = 'CRITICAL';
      }
   }
   else {
        print "DHCP OK - $ip LEASED AT $server TO $mac\n";
                $state = 'OK';
   }

   print "DHCP RETURN: $ERRORS{$state}\n" if $debug;
   exit $ERRORS{$state};
