use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile
  (
   'NAME'	   => 'Puppet-VcsTools-History',
   'VERSION' => '1.001',
   'EXE_FILES' => ['viewHistory'],
   'dist' => {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
   ($] >= 5.005 ?
    (ABSTRACT   => 'VCS history viewing tools',
     AUTHOR     => 'Dominique Dumont (domi@barrayar.grenoble.hp.com)') : ()),
   'PREREQ_PM' =>
   {
    'Tk' => 0,
    'Tk::Multi::Manager' => '2.001',
    'Tk::Multi::Text' => '2.001',
    'Data::Dumper'=> 0,
    'Puppet::Show' => '0.04',
    'MLDBM' => 0,
    'DB_File' =>0,
    'VcsTools::Version' => 0,
    'VcsTools::History' => 0
   }
  );
