# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..13\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk ;
use ExtUtils::testlib;
use Tk::Multi::Manager;
use Puppet::VcsTools::GraphWidget;
require Tk::ErrorDialog; 
$loaded = 1;
my $idx = 1;
print "ok ",$idx++,"\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

use strict ;
my $trace = shift ;
my $mw = MainWindow-> new ;

my $w_menu = $mw->Frame(-relief => 'raised', -borderwidth => 2);
$w_menu->pack(-fill => 'x');

my $f = $w_menu->Menubutton(-text => 'File', -underline => 0) 
  -> pack(side => 'left' );
$f->command(-label => 'Quit',  -command => sub{$mw->destroy;} );

my $wmgr = $mw -> MultiManager ( 'title' => 'log test' ,
                             'menu' => $w_menu ) 
  -> pack (qw/expand 1 fill both/);

my $tg = $wmgr -> newSlave('type'=>'MultiVcsGraph', title => 'graph try') ;
print "ok ",$idx++,"\n";

$tg -> addLabel (text => 'Looks like a VCS revision tree (hint hint)');
print "ok ",$idx++,"\n";

my $ref = [1000..1005];
my ($ox,$oy) = (100,100);

$tg -> addNode 
  (
   nodeId => '1.0', 
   text => $ref, 
   xref => \$ox, 
   yref => \$oy
  ) ;

print "ok ",$idx++,"\n";

my ($x,$y)= ($ox,$oy) ;

$tg -> addDirectArrow
  (
   from => '1.0', 
   to => '1.1',
   xref => \$x,
   yref => \$y
  ) ;

print "ok ",$idx++,"\n";

$tg -> addNode 
  (
   nodeId => '1.1',
   text => $ref,
   xref => \$x,
   yref => \$y
  ) ;

$tg -> addDirectArrow
  (
   from => '1.1',
   to => '1.2',
   xref => \$x,
   yref => \$y
  ) ;

$tg -> addNode 
  (
   nodeId => '1.2',
   text => $ref,
   xref => \$x,
   yref => \$y
  ) ;

$tg -> addDirectArrow
  (
   from => '1.2',
   to => '1.3',
   xref => \$x,
   yref => \$y
  ) ;

$tg -> addNode 
  (
   nodeId => '1.3',
   text => $ref,
   xref => \$x,
   yref => \$y
  ) ;

print "ok ",$idx++,"\n";

my ($bx,$by)=($ox,$oy) ;
my $dx ;

$tg -> addSlantedArrow
  (from => '1.0',
   to => '1.0.1.1',
   xref => \$bx,
   yref => \$by,
   deltaXref => \$dx
  ) ;

print "ok ",$idx++,"\n";

$tg -> addNode 
  (
   nodeId => '1.0.1.1',
   text => $ref,
   xref => \$bx,
   yref => \$by
  ) ;

$tg -> addDirectArrow
  (
   from => '1.0.1.1',
   to => '1.0.1.2',
   xref => \$bx,
   yref => \$by
  ) ;

$tg -> addNode 
  (
   nodeId => '1.0.1.2',
   text => $ref,
   xref => \$bx,
   yref => \$by
  ) ;

my ($b2x,$b2y)=($ox,$oy) ;

$tg -> addSlantedArrow
  (
   from => '1.0',
   to => '1.0.2.1',
   xref => \$b2x,
   yref => \$b2y,
   deltaXref => \$dx
  ) ;

$tg -> addNode 
  (
   nodeId => '1.0.2.1',
   text => $ref,
   xref => \$b2x,
   yref => \$b2y
  ) ;

$tg -> addDirectArrow
  (
   from => '1.0.2.1',
   to => '1.0.2.2',
   xref => \$b2x,
   yref => \$b2y
  ) ;

$tg -> addNode 
  (
   nodeId => '1.0.2.2',
   text => $ref,
   xref => \$b2x,
   yref => \$b2y
  ) ;

$tg->addShortcutInfo
  (
   from => '1.2',
   to => '1.0.2.1'
  ) ;

print "ok ",$idx++,"\n";

$tg->addAllShortcuts() ;

print "ok ",$idx++,"\n";

$tg->arrowBind
  (
   button => '<1>',
   color => 'orange',
   command =>  sub{my %h = @_;
                   warn "clicked 1 arrow $h{from} -> $h{to}\n";}
  );

print "ok ",$idx++,"\n";

$tg->nodeBind
  (
   button => '<2>',
   color => 'red',
   command => sub {my %h = @_;
                   warn "clicked 2 node $h{nodeId}\n";}
  );

$tg->command( on => 'arrow', label => 'dummy 1', 
                 command => sub{warn "arrow menu dummy1\n";});
$tg->command( on => 'arrow', label => 'dummy 2', 
                 command => sub{warn "arrow menu dummy2\n";});
$tg->arrowBind(button => '<3>', color => 'green', 
              command => sub{$tg->popupMenu(@_);});

$tg->command(on => 'node', label => 'dummy 1', 
                 command => sub{warn "node menu dummy1\n";});
$tg->command(on => 'node', label => 'dummy 2', 
                 command => sub{warn "node menu dummy2\n";});
$tg->nodeBind(button => '<3>', color => 'green', 
              command => sub{$tg->popupMenu(@_);});

print "ok ",$idx++,"\n";

$tg->addRev(qw/1.0 1.1 1.2 1.4 1.3 1.0.2.1 1.0.2.3 1.0.2.2/);
print "ok ",$idx++,"\n";

MainLoop ; # Tk's

print "ok ",$idx++,"\n";
