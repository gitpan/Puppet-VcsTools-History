package Puppet::VcsTools::Version ;

use strict;
use Carp;
use vars qw(@ISA $VERSION);
use Puppet::Show ;
use VcsTools::Version ;

$VERSION = sprintf "%d.%03d", q$Revision: 1.5 $ =~ /(\d+)\.(\d+)/;

@ISA=qw/VcsTools::Version/;

# must pass the info data structure when creating it
sub new
  {
    my $type = shift;
    my %args = @_;

    my $self = {};
    $self->{name}=$args{name};

    $self->{body} = new Puppet::Show(cloth => $self, @_);
    
    if (defined $args{storageArgs})
      {
        # transition code, should be removed sooner or later
        my %storeArgs = %{$args{storageArgs}} ;
        carp "new $type $args{name}: storageArgs is deprecated";
        carp "new $type $args{name}: usage is deprecated" 
          if defined $args{usage};
 
        my $usage = $self->{usage} = $args{usage} || 'File';
        
        if ($usage eq 'MySql')
          {
            $storeArgs{version} = $args{revision};
            require VcsTools::VerSqlStorage;
            $args{storage} = new VcsTools::VerSqlStorage (%storeArgs) ;
          }
        else
          {
            $args{storage} =  new Puppet::Storage (name => $self->{name},
                                                     %storeArgs) ;
          }
         $self->{storageArgs}=$args{storageArgs};
     }

    if (defined $args{manager})
      {
        carp "new $type $args{name}: manager is deprecated";
        my $mgr = $args{manager} ;
        $args{getBrotherSub} = sub {$mgr->getVersionObj(@_)} ;
        $self->{manager}=$args{manager};
      }

    # mandatory parameter
    foreach (qw/revision getBrotherSub storage/)
      {
        die "No $_ passed to $type $self->{name}\n" unless 
          defined $args{$_};
        $self->{$_} = delete $args{$_} ;
      }
    
    $self->{editor} = $args{editor};
    
    bless $self,$type ;
  }

sub getVersionObj
  {
    my $self = shift ;
    my $rev = shift ;
    carp "Version::getVersionObj is deprecated";
    return $self->{getBrotherSub}->($rev);
  }


sub display
  {
    my $self = shift ;
    $self->{body}-> display(@_);
 }

sub closeDisplay
  {
    shift->{body}->closeDisplay();
  }

sub drawTree
  {
    my $self = shift ;
    my $tree = shift ;
    my $x = 100 ;
    my $y = 100 ;
    my $widthR = 0 ;
    
    $tree->clear();
    $self->drawSubTree($tree,$x,$y,\$widthR) ;
    $tree->addAllShortcuts() ;
    # We give up the equalTo stuff. Too many potential problems with it.
  }

# called recursively to draw all nodes, internal method
sub drawSubTree
  {
    my $self = shift ;
    my $tree = shift ;
    my $x = shift ;
    my $y = shift ;
    my $widthR = shift ;

    my $rev = $self->{revision} ;
    my $info =  $self->{storage}->
      getDbInfo(qw/date keywords fix mergedFrom lower branches/) ;

    my $date = $info->{date} || '';
    $date =~ s/ .*$//;

    # print "drawing $rev : x $x y $y widthR $$widthR\n";

    my @array = ($date) ;
    push @array, @{$info->{keywords}} if defined $info->{keywords};
    push @array, @{$info->{fix}}      if defined $info->{fix} ;

    $tree->addNode
      (
       nodeId => $rev,
       text => \@array,
       xref => \$x,
       yref => \$y
      ) ;

    # check if this node is a merge
    # we must store the info now, and draw them later on.
    if (defined $info->{mergedFrom})
      {
        $tree->addShortcutInfo(from => $info->{mergedFrom}, to => $rev) ;
      }

    if (defined $info->{lower})
      {
        my ($lx,$ly)=($x,$y);
        $tree->addDirectArrow
          (
           from => $rev,
           to => $info->{lower},
           xref => \$lx,
           yref => \$ly
          );

        $self->{getBrotherSub}->($info->{lower}) 
          ->drawSubTree($tree, $lx, $ly, $widthR );
      }
    
    if (defined $info->{branches})
      {
        foreach my $branch ( @{$info->{branches}} )
          {
            my ($lx,$ly)=($x,$y);
            my $subWidth = 0;
            $tree->addSlantedArrow
              (
               from => $rev,
               to => $branch,
               xref => \$lx,
               yref => \$ly,
               deltaXref => $widthR
              );

            $self->{getBrotherSub}->($branch)
              ->drawSubTree($tree, $lx ,$ly, \$subWidth );
            $$widthR += $subWidth ;
          }
      }
  }

1;

__END__

=head1 NAME

Puppet::VcsTools::Version - Tk GUI to manage a VcsTools::Version object

=head1 SYNOPSIS

No synopsis given. This object is better used with the 
L<Puppet::VcsTools::History> module.

=head1 DESCRIPTION

This class represents one version of a VCS file. It holds all the
information relevant to this version including the log of this
version, the parent revision, child revision and so on.

Its main function is to deal with the History object and its TreeGraph
object to draw the history revision tree. The Version object will
perform all necessary calls to the drawing methods of TreeGraph to get
the correct drawing.

The information structure stored in each Version object are described
in the dataFormat HASH reference passed to the constructor (See
L<VcsTools::DataSpec::Rcs> or L<VcsTools::DataSpec::HpTnd> for more details).

This Object heavily uses L<Puppet::Show>, L<Puppet::Body> and
L<Puppet::Storage>.

=head1 WIDGET USAGE

Well, By itself, the Version widget cannot do much. 

Future version may be better depending on user inputs.

The only function available is to edit the history through the
"File->edit log" menu if the 'edit' parameter was specified to the
constructor.

=head1 Constructor

=head2 new(...)

Parameters are those of L<VcsTools::Version/"new()"> plus:

=over 4

=item *

editor : LogEditor ref. If specified, the history of this version
can be edited by calling the Show() method of the LogEditor. See
L<Puppet::VcsTools::LogEdit/"Show()">. (optional)

=back

=head1 Methods

All L<VcsTools::Version/"Methods"> plus these ones:

=head2 display(...)

Will launch a widget for this object. All parameters are passed to
L<Puppet::Show/"display(...)">

=head2 closeDisplay()

Delegated to the L<Puppet::Body/"closeDisplay"> method.

=head2 editLog()

Will run the log editor for this version.

=head2 archiveLog()

Will delegate the call to the history manager. Used to update the VCS
base from the log stored in the Version object. Used generally after an
editLog.

=head2 drawTree(tree_graph)

Will start drawing a tree (from the revision of this Version object) calling
History object's graph.

=cut

#'

=head1 Internal Methods

Not for faint hearted people.

=head2  drawSubTree(tree_graph, x, y, width_reference)

Called recursively to draw all nodes, internal method.

x,y are the coordinates of the root of the sub-tree. The width will be changed
to the actual width (in pixels) of the sub-tree. Note that the width of the
sub-tree depends on the number of branches.


=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

Copyright (c) 1998-1999 Dominique Dumont. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Tk(3), Puppet::Show(3), VcsTools::Version(3), VcsTools::History(3)

=cut

