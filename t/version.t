# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk ;
use ExtUtils::testlib;
use Puppet::Show ;
use Puppet::VcsTools::Version;
use Puppet::VcsTools::GraphWidget ;
use Fcntl ;
use MLDBM qw(DB_File);
require Tk::ErrorDialog; 
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):
package Dummy ;

  my $bChangeData = ['none', 'cosmetic', 'minor','major'] ;
  my $changeData = ['none', 'cosmetic', 'major'] ;
  my @state = qw(Dead Exp Team Lab Special Product) ;

  # each entry is a hash made of 
  # - name : name of the field stored in log
  # - var : variable name used in internal hash (default = name) 
  # - type : is line, enum or array or text
  # - values : possible values of enum type
  # - mode : specifies if the value can be modified (r|w) (default 'w')
  # - pile : define how to pile the data when building a log resume.
  # - help : help string
  
my $logDataFormat = 
    [
     { 'name' => 'state', 'type' => 'enum',  'values' => \@state},
     { 'name' => 'date', 'type' => 'line', 'mode' => 'r' },
     { 'name' => 'merged from', 'type' => 'line','var' => 'mergedFrom' },
     { 'name' => 'comes from', 'type' => 'line','var' => 'previous', 
       'help' => 'enter a version if it cannot be figured out by the tool' },
     { 'name' => 'equal to', 'type' => 'line','var' => 'equalTo','type' => 'array' },
     # will fit better in the description field TBD
     #   { 'name' => 'visibility', 'values' => ['none', 'team', 'lab','client']},
     { 'name' => 'writer','type' => 'line', 'mode' => 'r' },
     { 'name' => 'keywords', 'type' => 'array', 'pile' => 'push' },
     { 'name' => 'fix','type' => 'array','pile' => 'push',
       'help' => 'enter number a la GREhp01243' },
     { 'name' => 'behavior change' , 'type' => 'enum','var' => 'behaviorChange',
       'values' => $bChangeData },
     { 'name' => 'interface change' , 'type' => 'enum','var' => 'interfaceChange',
       'values' => $changeData },
     { 'name' => 'inter-peer change' , 'type' => 'enum','var' => 'interPeerChange',
       'values' => $changeData },
     { 'name' => 'misc' , 'var' => 'log', 'type' => 'text', 'pile' => 'concat'}
  ];

sub new 
  {
    my $type = shift ;
    my %args = @_ ;

    my $self ={};
    $self->{dbHash}=$args{dbHash};
    $self->{topTk} = $args{topTk} ;
    $self->{body} = new Puppet::Show(cloth => $self, @_) ;
    
    bless $self,$type ;
  }

sub body {return shift ->{body};}

sub display
  {
    my $self = shift ;

    my $top = $self->{body}->display(@_);

    return unless defined $top ;

    my $tree = $top ->newSlave
      (type => 'MultiVcsGraph', title => 'history graph');

    $self->{tree} = $tree;

    my @v_new=  (
                 storageArgs =>
                 {
                  keyRoot => 'version',
                  dbHash => $self->{dbHash}
                 },
                 topTk => $self->{topTk},
                 manager => $self
                ) ;

    my %info = (
                'log' => "Nothing to tell\n",
                keywords => [qw/salut les copains/],
                date => '23/03/98'
               );

    $tree->command(on => 'menu',
                   -label=>'find ancestor', 
                   command =>
                   sub{
                     my @revs = $tree->getSelectedNodes();
                     if (defined @revs and scalar(@revs) == 2)
                       {
                         my $rev = shift @revs;
                         my $anc = $self->getVersionObj($rev)->
                           findAncestor(shift @revs);
                         # must set color of ancestor node TBD
                         $tree->setNode(nodeId => $anc,color => 'brown');
                       }
                     else
                       {
                         warn scalar(@revs)," nodes selected\n";
                       }
                   });

    $tree->command(on => 'menu',
                   -label=>'find elder', 
                   command =>
                   sub{
                     my @revs = $tree->getSelectedNodes();
                     if (defined @revs and scalar(@revs) == 1)
                       {
                         my $rev = shift @revs;
                         my $anc = $self->getVersionObj($rev)->
                           findOldest();
                         # must set color of ancestor node TBD
                         $tree->setNode(nodeId => $anc,color =>'yellow');
                       }
                     else
                       {
                         warn scalar(@revs)," nodes selected\n";
                       }
                   });

    $tree->command(on => 'menu',-label=>'unselect all', 
                   command => sub{$tree->unselectAllNodes();});

    foreach my $root (qw/1. 1.1.1. 1.2.1. 1.4.1. 1.1.1.2.1. 2./)
      {
        foreach my $i (1 .. 5 )
          {
            my $v = $root.$i ;
            # warn "making version $v\n";
            my $name = 'v'.$v ;
            $self->{version}{$v} = 
              new Puppet::VcsTools::Version (name => $name,
                                     @v_new,revision => $v) ;
            $self->{body}->acquire(body => $self->{version}{$v}->body());

            $tree->addRev($v) ;
          }
      }

    # store info after all version objects are known by getVersionObj
    foreach my $v (keys %{$self->{version}})
      {
        my %local = %info ;
        $local{branches} = ['1.1.1.1','1.2.1.1']     if $v eq '1.1' ;
        $local{branches} = ['1.1.1.2.1.1'] if $v eq '1.1.1.2' ;
        $local{branches} = ['1.4.1.1']     if $v eq '1.4' ;
        $local{mergedFrom} = '1.1.1.1'   if $v eq '1.3' ;
        
        $self->{version}{$v}->update (info => \%local);
      }

    my @orphan =();
    foreach my $v (keys %{$self->{version}})
      {
        unless ($self->{version}{$v}->hasParent())
          {
            $self->{body}->printEvent("Version $v has no previous version\n");
            push @orphan,$v;
          }
      }

    if (scalar @orphan > 1)
      {
        $self->{body}->printEvent
          ("Warning: this test has more than one revision without parent:". join(' - ',@orphan)."\n") ;
       }

    $tree->Subwidget('list')->bind('<Double-1>' =>
                    sub  {
                      my $item = shift ;
                      my $name = $item->get ('active') ;
                      $self->{version}{$name}->drawTree($tree) ;
                    }
                   );
    
    $tree->Subwidget('list')->bind
      (
       '<3>' =>
       sub  {
         my $item = shift ;
         my $name = $item->get ('active') ;
         $self->getVersionObj($name)->body()->display() ;
       }
      );
    
  }

sub getVersionObj
  {
    my $self = shift ;
    my $rev = shift ;
    if (defined $self->{version}{$rev})
      {
        return $self->{version}{$rev} ;
      }
    return undef ;
  }

package main ;

use Tk::Multi::Manager ;

use strict ;

my $file = 'test.db';
unlink($file) if -r $file ;

my %dbhash;
tie %dbhash,  'MLDBM',    $file , O_CREAT|O_RDWR, 0640 or die $! ;

my $mw = MainWindow-> new ;

$mw->withdraw;

my $mgr = new Dummy (dbHash => \%dbhash,
                     keyRoot => 'key root',
                     name => "dummy history",
                     topTk => $mw);

$mgr -> display(master => 1) ;

MainLoop ; # Tk's

print "ok 2\n";
