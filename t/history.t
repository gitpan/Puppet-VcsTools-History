# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..9\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk ;
use ExtUtils::testlib;
use Time::Local ;
use Puppet::VcsTools::History;
use VcsTools::LogParser ;
use VcsTools::DataSpec::HpTnd qw($description readHook);
require Tk::ErrorDialog; 
use Fcntl ;
use MLDBM qw(DB_File);
$loaded = 1;
my $idx = 1;
print "ok ",$idx++,"\n";
my $trace = shift ;

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

use strict ;

my $file = 'test.db';
unlink($file) if -r $file ;

my %dbhash;
tie %dbhash,  'MLDBM',    $file , O_CREAT|O_RDWR, 0640 or die $! ;

my $mw = MainWindow-> new ;
$mw->withdraw ;

my @history = <DATA> ;

my $ds = new VcsTools::LogParser
  (
   description => $description,
   readHook => \&readHook
  ) ;

print "ok ",$idx++,"\n";

my $how = $trace ? 'warn' : undef ;

print "ok ",$idx++,"\n";

my $hist = new Puppet::VcsTools::History 
  (
   storageArgs =>
   {
    dbHash => \%dbhash,
    keyRoot => 'history root'
   },
   'topTk' => $mw,
   name => 'History test',
   dataScanner => $ds ,
   how => $how
  );

print "ok ",$idx++,"\n";

$hist -> update (history => \@history, time => timelocal(localtime) );
print "ok ",$idx++,"\n";

my $top = $hist -> display(master => 1);

print "ok ",$idx++,"\n";

$hist->drawTree(revision => '3.0') ;

print "ok ",$idx++,"\n";

my $asub =sub 
  {
    my $info = {'log' => 'auto archive'};
    $hist-> addNewVersion(revision => '3.20', 
                          info => $info,
                          after =>'3.19');
  } ;
 
$top->add('command',
          -label => 'archive 3.20',
          -command => $asub ,
         ) ;

print "ok ",$idx++,"\n";

MainLoop ; # Tk's

print "ok ",$idx++,"\n";

__DATA__

file:  /7UP/code/tcap/FileRevList
type:  RCS
head: 5.0
symbolic names:
keyword substitution: kv
total revisions: 91;	selected revisions: 91
description:
----------------------------
revision 3.19
date: 1997/09/26 15:46:25;  author: domi;  state: Exp;  lines: +3 -3
Author: domi
fix: default_class
From SccpAP.m v3.6:
- in SendToNet: set sccp class parameter when using default values
----------------------------
revision 3.18
date: 1997/09/25 11:09:06;  author: herve;  state: Exp;  lines: +4 -5
Author: herve
merged from: 3.4.1.6
writer: herve
keywords: SS7
fix: GREhp11677
bugs fixed :

 - GREhp11677   :  SS7 stack memory leak when TCAP transaction failed leads to a core dump
----------------------------
revision 3.17
date: 1997/09/23 16:13:47;  author: cilou;  state: Exp;  lines: +2 -1
Author: domi
writer: cilou
keywords: bug_fix
fix:
bugs fixed :
 none

   In SccpAP, fill sccp_use_extended_data field of tcx_sccp_service_quality
   structure. Even if this information should be reserved for LNP applications
   and is only significant for UNITDATA request, it gives the information if
   data has been received within UDT or XUDT and it prevents to display
   incoherent value if application wants to trace this structure.
----------------------------
revision 3.16
date: 1997/09/16 13:23:42;  author: cilou;  state: Exp;  lines: +1 -1
Author: cilou
writer: cilou
keywords: qualityParm
bugs fixed :
 none

   In sendToNet, don't use qualityParm input parameter to fill
   UNITDATA Request parameters as the qualityParm structure does
   not contain the application parameters. Get all tcx_sccp_service_quality
   parameters from TCAPMessage
----------------------------
revision 3.15
date: 1997/07/22 14:27:00;  author: herve;  state: Exp;  lines: +1 -1
Author: herve
bugs fixed :

 - GREhp11165   :  itmi Q787:A412, A422, TA4226, TA4228 failed: transaction with XX_W_PERM refused
 - GREhp10825   :  Pb when sending a TC_END after receiving a TC_BEGIN without setting orig addr.
----------------------------
revision 3.14
date: 1997/07/17 11:27:13;  author: cilou;  state: Exp;  lines: +10 -10
Author: domi
writer: cilou
keywords: fast_track, SCCP-WB-FT
bugs fixed :
 none

   Intermediate delivery for WB SCCP Fast Track with new SCCP service
----------------------------
revision 3.13
date: 1997/05/23 16:22:52;  author: domi;  state: Exp;  lines: +1 -1
Author: domi
writer: domi
keywords:
bugs fixed :
 none

   - previous version does not compile in ANSI
----------------------------
revision 3.12
date: 1997/04/22 11:26:47;  author: domi;  state: Exp;  lines: +3 -3
Author: domi
writer: domi
keywords: GT_adr
fix: GREhp10979, GREhp11029
bugs fixed :

 - GREhp10979   :  With option PreferRoutOnGt in sys.tcap, RoutInd is not RoutOnGt in P-Abort
 - GREhp11029   :  Specific SSN in specficic GT in sys.tcap is not taken in account

   - coupled with tcapIncludes
   - does not compile in ANSI
----------------------------
revision 3.11
date: 1997/04/16 16:06:02;  author: domi;  state: Exp;  lines: +3 -3
Author: domi
writer: domi
keywords: BB_vs_WB
fix: GREhp10971
bugs fixed :

 - GREhp10971   :  TC_P_ABORT address format doesn't respect addr option in sys.tcap (case WB - BB)
----------------------------
revision 3.10
date: 1997/04/15 10:53:37;  author: domi;  state: Exp;  lines: +3 -4
Author: domi
bugs fixed :

 - GREhp10945   :  Stack stuck when a string is made of number in sys.* files
----------------------------
revision 3.9
date: 1997/03/28 16:22:13;  author: domi;  state: Exp;  lines: +6 -5
Author: domi
writer: domi
keywords: no_PC_in_GT
fix: GREhp10767
bugs fixed :

 - GREhp10767   :  Allow PC to be removed from calling address when routing on GT

   - sys.tcap parameters must be modified to enable the fix to work
   - must also use GREhp10420's fix

 FORCED ARCHIVE because :
WARNING : There are locked files...
file AP.h
rev:  3.0;  locked by: herve
   TMgr.m is OUT-OF-DATE
     (Your revision: 3.12, RCS/HMS revision: 3.12.1.1.)
----------------------------
revision 3.8
date: 1997/03/07 16:51:10;  author: domi;  state: Exp;  lines: +2 -2
Author: domi
merged from: 3.4.1.3
writer: domi
keywords: BB_vs_WB
fix: GREhp10739
bugs fixed :

 - GREhp10739   :  Incorrect P_ABORT cause when operating WB vs BB

   - fix handling of ABORTS and dialog portion in white book mode

   - coupled with tcapIncludes
----------------------------
revision 3.7
date: 1997/03/04 10:39:30;  author: herve;  state: Exp;  lines: +13 -10
Author: domi
writer: herve
keywords: GDI
bugs fixed :
 none

   now TCAP can be compile to access GDI with the GDI_BUILD compile option
----------------------------
revision 3.6
date: 1996/12/16 11:59:09;  author: domi;  state: Exp;  lines: +3 -3
Author: domi
writer: domi
keywords: mem_leak
fix: GREhp10170, GREhp10337
bugs fixed :

 - GREhp10170   :  HPSS7 Stack memory leak
 - GREhp10337   :  "dialog portion absent" is not an error

   - coupled with proxys v3.8.
----------------------------
revision 3.5
date: 1996/06/20 18:41:01;  author: hmgr;  state: Exp;  lines: +6 -6
branches:  3.5.1;
Author: domi
bugs fixed :

 - GREhp00021   :  Calling address should be taken from TC-CONTINUE upon request

   - enable address change on the first TC_CONTINUE comming from the user
   (This features is standard in white book mode and is authorized in
   blue book mode by the "enableAddressChange" parameter in sys.tcap)
----------------------------
revision 3.4
date: 1996/06/05 13:15:27;  author: hmgr;  state: Exp;  lines: +4 -4
branches:  3.4.1;
Author: eric
bugs fixed : 
  
 - GREhp03732   :  Under stress, active transaction number increase all the time  
 
    
----------------------------
revision 3.3
date: 1996/04/26 13:30:39;  author: hmgr;  state: Exp;  lines: +5 -5
Author: domi
bugs fixed : 
  
 - GREhp07855   :  half traffic is lost for 45s after switchover (Nokia)  
 
   - changed tc_service_parms to tc_private_service_parms (fix GREhp07855)
   - When a new connection is made :
   Check for other connection with same applicationId or instanceId
   (i.e a ghost connection) and deactivate the associated user if
   necessary (i.e. with non NULL ids)
   reset the other variables of the table 
----------------------------
revision 3.2
date: 1996/01/12 11:37:58;  author: hmgr;  state: Exp;  lines: +1 -1
Author: domi
bugs fixed : 
  
 - GREhp06376   :  In switching slee phase, P_ABORT generated increase the transactions Nb.  
  
----------------------------
revision 3.1
date: 1995/12/20 16:53:03;  author: hmgr;  state: Exp;  lines: +7 -7
Author: domi
bugs fixed : 
 none  
 
   - Added a lot of traces in case of protocol errors (at the COM_E_LL_ERROR
   level) to help debug problem (Was needed for GREHp04971). 
----------------------------
revision 3.0
date: 1995/10/17 03:27:54;  author: hmgr;  state: Exp;  lines: +19 -19
Author: rey
First Revision for OC1.2
----------------------------
revision 3.4.1.6
date: 1997/09/24 16:57:03;  author: herve;  state: Exp;  lines: +4 -4
Author: herve
merged from: 3.4.1.2.1.1
writer: herve
keywords: SS7
fix: GREhp11677
bugs fixed :

 - GREhp11677   :  SS7 stack memory leak when TCAP transaction failed leads to a core dump
----------------------------
revision 3.4.1.5
date: 1997/07/22 10:15:38;  author: herve;  state: Exp;  lines: +1 -1
Author: herve
bugs fixed :

 - GREhp10825   :  Pb when sending a TC_END after receiving a TC_BEGIN without setting orig addr.
 - GREhp11165   :  itmi Q787:A412, A422, TA4226, TA4228 failed: transaction with XX_W_PERM refused
----------------------------
revision 3.4.1.4
date: 1997/07/16 10:04:24;  author: herve;  state: Exp;  lines: +1 -1
Author: herve
bugs fixed :

 - GREhp09922   :  total service lost when tcap user table full
----------------------------
revision 3.4.1.3
date: 1997/03/10 11:55:09;  author: domi;  state: Exp;  lines: +1 -1
Author: domi
writer: domi
keywords: BB_vs_WB
fix: GREhp10739
bugs fixed :

 - GREhp10739   :  Incorrect P_ABORT cause when operating WB vs BB

   - coupled with tcapIncludes
----------------------------
revision 3.4.1.2
date: 1997/02/28 16:50:19;  author: domi;  state: Exp;  lines: +1 -1
branches:  3.4.1.2.1;
Author: domi
writer: domi
keywords: mem_leak
fix: GREhp10170
bugs fixed :

 - GREhp10170   :  HPSS7 Stack memory leak

   - the previous leaf in this branch did not feature the complete fix.
   Do NOT use it.
----------------------------
revision 3.4.1.1
date: 1997/01/22 16:18:46;  author: domi;  state: Dead;  lines: +1 -1
Author: domi
writer: domi
keywords:
fix: GREhp10170
bugs fixed :

 - GREhp10170   :  HPSS7 Stack memory leak

 - branched for #75
 - This version is kaput, DO NOT USE
----------------------------
revision 3.5.1.1
date: 1997/01/22 16:18:46;  author: domi;  state: Dead;  lines: +1 -1
Author: domi
writer: domi
keywords:
fix: GREhp10170
bugs fixed :

 - GREhp10170   :  HPSS7 Stack memory leak

 - dummy branch
----------------------------
revision 3.4.1.2.1.1
date: 1997/09/24 13:34:02;  author: herve;  state: Exp;  lines: +4 -4
Author: herve
writer: herve
keywords: mem_leak(#728)
fix: GREhp11677
bugs fixed :

 - GREhp11677   :  SS7 stack memory leak when TCAP transaction failed leads to a core dump

   PATCH_SIEMENS memory leak

=================================================

