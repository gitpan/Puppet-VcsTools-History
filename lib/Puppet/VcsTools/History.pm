package Puppet::VcsTools::History ;

use strict;
use Puppet::Show ;
use Puppet::VcsTools::Version ;
use Carp ;

use base 'VcsTools::History' ;

use vars qw($VERSION);

use AutoLoader qw/AUTOLOAD/ ;

$VERSION = sprintf "%d.%03d", q$Revision: 1.2 $ =~ /(\d+)\.(\d+)/;

sub new
  {
    my $type = shift ;
    my %args = @_ ;

    my $self = {};
    $self->{name}=$args{name};

    $self->{body} = new Puppet::Show
      (
       cloth => $self,
       podName => 'Puppet::VcsTools::History',
       podSection => 'WIDGET USAGE',
       @_
      ) ;

    my %storeArgs = %{$args{storageArgs}} ;
    
    croak "No storageArgs defined for VcsTools::History $self->{name}\n"
      unless defined %storeArgs;

    $self->{storageArgs} = \%storeArgs;

    my $usage = $self->{usage} = $args{usage} || 'File' ;
    if ($usage eq 'MySql')
      {
        require VcsTools::HistSqlStorage;
        $self->{storage} = new VcsTools::HistSqlStorage (%storeArgs) ;
      }
    else
      {
        $self->{storage} =  new Puppet::Storage (name => $self->{name},
                                                 %storeArgs) ;
      }

    # mandatory parameter
    foreach (qw/name dataScanner topTk/)
      {
        croak "No $_ passed to $self->{name}\n" unless 
          defined $args{$_};
        $self->{$_} = delete $args{$_} ;
      }

    $self->{storageArgs}{keyRoot} .= ' '.$self->{name} ;
    bless $self,$type ;
  }

1;

__END__

=head1 NAME

Puppet::VcsTools::History - TK GUI for VcsTools::History

=head1 SYNOPSIS

 require VcsTools::DataSpec::HpTnd ; # for instance
 # could be VcsTools::DataSpec::Rcs

 my $ds = new VcsTools::DataSpec::HpTnd ; # ditto

 my $hist = new Puppet::VcsTools::History 
  (
   dbHash => \%dbhash,         # for permanent data storage
   keyRoot => 'history root',  # key for permanent data storage
   'topTk' => $mw,
   name => 'Foo history',
   dataScanner => $ds          # log analyser
  );

=head1 DESCRIPTION

This class provides a GUI to the L<VcsTools::History> class. 

It contains a GraphWidget to draw the history tree and some key
bindings to read the log informations from the tree drawing .

=head1 WIDGET USAGE

The display of the history object is made of :

=over 4

=item *

A canvas to draw a revision tree.

=item *

A revision list. If you double click on a revision of this list, History
will draw the revision tree starting from this revision.

=item *

A text window to display informations related to the revision tree.

=back

=head2 Nodes 

Each rectangle in the tree represent a revision (aka a node). 
The text in the rectangle is bound to some keys :

=over 4

=item *

button-1 selects the node for further operation (See below)

=item *

button-3 pops-up a menu

=item *

double button-1 redraws the tree from this revision

=back

The node popup menu features :

=over 4

=item *

draw from here: Re-draws the tree from this revision

=item *

open version object: Opens the display of the L<Puppet::VcsTools::Version>
object.

=back

=head2 Arrows

Each arrow is bound to some keys :

=over 4

=item *

button-1 shows the log of this revision

=item *

button-3 pops up a menu

=back

The arrow popup menu features :

=over 4

=item *

show log: shows the log of this revision

=item *

show full log: shows the full log of this revision with all fields.

=back

=head2 global features

The graph widget features a global menu invoked on the title of the graph 
widget. It features :

=over 4

=item *

unselect all: unselect all nodes.

=item *

reload from archive: Reloads information from the VCS archive. This
will also update your local information data base. Use this menu when
other people have worked on your VCS files.

=item *

show cumulated log: Will show a concatenation of logs between 2
selected revisions. One of this revision B<must> be the ancestor of
the other.

=back

The VcsTools::File(3) object have also some bindings 
(See L<VcsTools::File/"WIDGET USAGE">)

=head1 Constructor

=head2 new(...)

Will create a new history object.

Parameters are:

=over 4

=item *

All parameter of L<Puppet::Body/"Constructor">

=item *

dataScanner : VcsTools::DataSpec::HpTnd (or equivalent) object reference

=item *

topTk: the ref of the Tk main window

=back

=head1 Methods

All L<VcsTools::History/"Methods"> plus these ones:

=head2 addNewVersion(...)

The call will be delegated to L<VcsTools::History/"addNewVersion(...)">,
then the drawing will be updated with it.

=head2 display()

Will launch a widget for this object.

=head2 closeDisplay()

Delegated to the L<Puppet::Body/"closeDisplay"> method.

=head2 drawTree(...)

Parameters are:

=over 4

=item *

revision: The tree will start from this revision number. Optional. If not 
passed the tree will be re-drawn from the revision that was passed the 
previous time this funcion was called. 

=item *

nodeId: same as revision.

=back

=head2 getTreeGraph()

Returns the L<Tk::TreeGraph> ref embedded in History display 
or undef if the display was not opened.

=head2 getInfoWidget()

Returns the L<Tk::ROText> ref embedded in History display or undef if
the display was not opened.

=head1 TODO

Trigger a history update if the database time stamp is younger than the 
time of the last history analysis


=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

Copyright (c) 1998-1999 Dominique Dumont. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Tk(3), Puppet::Show(3), VcsTools::DataSpec::HpTnd(3), 
Puppet::VcsTools::Version(3), Puppet::VcsTools::File(3)

=cut



#internal do not call from outside because there's no sanity checks
sub createVersionObj
  {
    my $self = shift ;
    my $rev = shift ;

    $self->{body}->printDebug("Creating puppet version object for rev $rev\n");
    
    return new Puppet::VcsTools::Version  
      (
       name => $rev,
       title => "$self->{name} v$rev",
       topTk => $self->{topTk},
       dataFormat => $self->{dataScanner}->getDescription,
       manager => $self,
       managerName => $self->{name},
       storageArgs => $self->{storageArgs},
       usage => $self->{usage},
       revision => $rev
      ) ;
  }

sub getTreeGraph
  {
    my $self = shift ;
    return undef unless defined $self->{widget};

    return  $self->{widget}->getSlave($self->{treeName}) ;
  }

sub getInfoWidget
  {
    my $self = shift ;
    return undef unless defined $self->{widget};
    return  $self->{widget}->getSlave($self->{textName});
  }


sub display
  {
    my $self = shift ;

    my $top = $self->{body}->display(@_);

    return unless defined $top;
 
    require Puppet::VcsTools::GraphWidget ;

    $self->{widget}=$top ;
    $self->{treeName} = 'history graph';
    my $tree = $top ->newSlave
      (
       type => 'MultiVcsGraph', 
       title => $self->{treeName}
      );

    require Tk::Menubutton;

    $tree->addRev(@{$self->{storage}->getDbInfo('versionList')}) ;

    # a garder TBD ?
    $self->{textName}=$self->{name};
    $top -> newSlave
        (
         'type' => 'MultiText', 
         'title' => $self->{textName},
         'hidden' => 0 ,
         'help' => 'This text window display the results of the operations '.
         'invoked within the History graph widget'
        );


    # must add menu button related to the graph funcionnality
    # i.e draw, merge, show diff
    # these function will ask for currently selected nodes


    $tree->command(on => 'menu', -label=>'unselect all', 
                   command => sub{$tree->unselectAllNodes();});

    $tree->command
      (
       on => 'menu',
       -label=>'show cumulated log', 
       command => sub
       {
         my $info = $self->buildCumulatedInfo($tree->getSelectedNodes()) ;
         my $str = $self->{dataScanner}->buildLogString($info) ;
         $self->showResult($self->{dataScanner}->buildLogString($info));
       }
      );

    $tree->Subwidget('list')->bind
      (
       '<Double-1>' => sub 
       {
         my $item = shift ;
         my $rev = $item->get ('active') ;
         $self->body()->printEvent("drawing tree from rev $rev\n") ;
         $self->drawTree(revision =>$rev) ;
       }
      ) ;

    my $showLog = sub 
      {
        my %args = @_ ;
        my $str = $self->getLog(version => $args{to} || $args{nodeId}, 
                                key => 'log');
        $self->showResult($str) ;
      } ;
    
    my $showFullLog = sub 
      {
        my %args = @_ ;
        my $str = $self->getLog(version => $args{to}|| $args{nodeId});
        $self->showResult($str) ;
      } ;
    
    $tree->arrowBind
      (
       button => '<1>',
       color => 'red', 
       command => $showLog
      ) ;

    $tree->command 
      (
       on => 'arrow', 
       label => 'show log', 
       command => $showLog
      ) ;

    $tree->command 
      (
       on => 'arrow', 
       label => 'show full log', 
       command => $showFullLog
      ) ;
    
    $tree->command 
      (
       on => 'node', 
       label => 'show log', 
       command => $showLog
      ) ;

    $tree->command 
      (
       on => 'node', 
       label => 'show full log', 
       command => $showFullLog
      ) ;
    
    $tree->arrowBind
      (
       button => '<3>',
       color => 'orange', 
       command => sub {$tree->popupMenu(@_);}
      ) ;

    # bind double-1 to redraw the whole graph 
    $tree->nodeBind
      (
       button =>  '<Double-1>',
       color =>   'black', 
       command => sub {$self->drawTree(@_)}
      );

    # bind button <3> on nodes to pop up a menu
    $tree->nodeBind
      (
       button =>  '<3>',
       color =>   'red', 
       command => sub {$tree->popupMenu(@_);}
      ) ;

    $tree->command
      (
       on => 'node',
       label =>'draw from here',
       command => sub {$self->drawTree(@_)}
      );

    $tree->command
      (
       on => 'node',
       label => 'open version object',
       command => sub 
       {
         my %args = @_ ;
         $self->{body}->getContent($args{nodeId})->cloth()->display() ;
       }
      ) ;

    return $top ;
  }

sub closeDisplay
  {
    my $self = shift ;
    delete $self->{widget};
    $self->{body}->closeDisplay();
  }
  

#internal
sub showResult
  {
    my $self = shift ;
    
    return unless defined $self->{widget};

    my $txt = $self->{widget}->getSlave($self->{textName}) ;
    $txt -> clear();
    my $ref =shift ;
    my $str = ref($ref) eq 'ARRAY' ? join("\n",@$ref) : $ref ;

    $txt->insertText($str) ;
  }

sub drawTree
  {
    my $self = shift ;
    my %args = @_ ;

    return unless defined $self->{widget};
    my $tree = $self->{widget}->getSlave($self->{treeName});
    $self->{drawRoot}=$args{revision} || $args{nodeId} || $self->{drawRoot} ;
    return unless defined $self->{drawRoot};

    $self->getVersionObj($self->{drawRoot})->drawTree($tree);
  }

# called to add a new version of the file (after an archive)
sub addNewVersion
   {
     my $self = shift ;

     my $obj = $self->SUPER::addNewVersion(@_);

     return unless defined $self->{widget};
     my $tree = $self->{widget}->getSlave($self->{treeName});
     $tree->addRev($obj->getRevision()) ;
     
     $self->drawTree();
   }

sub update
  {
    my $self = shift ;
    
    if (defined $self->{widget})
      {
        my $tree = $self->{widget}->getSlave($self->{treeName});
        $tree->Subwidget('graph')-> clear ;
        $tree->Subwidget('list')->delete(0,'end');
      } ;
    
    $self->SUPER::update(@_);
    
    if (defined $self->{widget})
      {
        my $tree = $self->{widget}->getSlave($self->{treeName});
        $tree->addRev(@{$self->{storage}->getDbInfo('versionList')}) ;

        $self->drawTree;
      }
  }
1;



# Pas testee
# sub findMerge
#   {
#     my $self = shift ;
#     my $rev1 = shift ;
#     my $rev2 = shift ;

#     # find in history if rev1 and rev2 are merged. return the merge version
#     foreach (("$rev1-$rev2","$rev2-$rev1"))
#       {
#         if (defined $self->{myDbHash}{info}{mergeList}{$_}) 
#           {
#             my $rev =  $self->{myDbHash}{info}{mergeList}{$_} ;

#             while ($self->{myDbHash}{state} eq 'Dead')
#               {
#                 my $old = $rev ;
#                 $rev = $self->{myDbHash}{lower} ;
#                 unless (defined $rev)
#                   {
#                     croak "Found Dead $self->{name} version $old for merge\n"  ;
#                     return undef ;
#                   } 
#               }
#             return $rev ;
#           }
#       }

#     return undef ;
#   }
