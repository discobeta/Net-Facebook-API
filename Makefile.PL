use 5.008005;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

    
    %PREREQ_PM => {
	'JSON::XS' => '2.3',
	'MIME::Base64::URLSafe' => '0.01',
	'LWP::UserAgent' => '5.835',
	'Digest::SHA' => '5.50',
	'URI::Escape' => '3.30'
	};
    
    
    WriteMakefile(
    NAME              => 'Net::Facebook::API',
    VERSION_FROM      => 'lib/Net/Facebook/API.pm',
    PREREQ_PM         => \%PREREQ_PM,
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Net/Facebook/API.pm', # retrieve abstract from module
       AUTHOR         => 'Asaf Klibansky <asaf@sortprice.com>') : ()),
);
