#!/usr/bin/perl
# vim:fdm=marker:

use strict;
use warnings;
use Net::Twitter;
use Getopt::Long;


#< usage and help
sub usage {
  my     $APP = 'picam';
  my $VERSION = 0.07;

  pod2usage(
       msg  => "$APP v$VERSION\n",
    verbose => 1,
    exitval => 0,
  );
}

# If --help is called, there's no reason to go any further.
# Make Pod::Usage spit out the help, based on the POD at the very end of this
# file.

BEGIN {
  use Pod::Usage;
  if( (!@ARGV) or ($ARGV[0] =~ m/--?h(?:elp)?\z/) ) {
    usage();
    exit;
  }
}
#>

#< variables
my $image_dir      = "$ENV{HOME}/camera/";
my $pidfile        = "$ENV{HOME}/picam.pid";

# time between tweets. default is 30 min.
my $sleep          = 1800;

# the Net::Twitter::update_with_media method expects an array ref... and the
# documentation for said module is sparse at best.
my @image_latest = ("$image_dir/latest.png");
#>

#< options handling
# if an argument is passed to --tweet, set twitter status to supplied data.
# else, post system uptime.
GetOptions(
  't|tweet'     => sub {
    while(1) {
      printf "tweeting \"@ARGV\"\n";
      tweet(set_twitter_status(@ARGV));
      printf "sleeping for $sleep s...\n";
      sleep $sleep;
    }
  },
  'd|daemon'    => sub { daemonize("$ENV{HOME}/picam_log"); },

  'h|help'      => \&usage,
  'v|version'   => sub { printf "$0 v0.02\n"; exit; },
);
#>

#< status functions
sub set_twitter_status {
  my $status = shift;
  if(!defined($status)) {
    $status = `./bin/pi_status`;
  }
  chomp $status;
  return $status;
}
#>

#< do the twitter!

# The needed twitter details is imported from shell variables.
# Export them in your shellrc, but make sure NOT to share that rc to the world.
#   TWITTER_ACCESS_{SECRET,TOKEN}
#   TWITTER_CONSUMER_{SECRET,TOKEN}

sub tweet {
  my ($text) = @_;

  my $twitter = Net::Twitter->new(
    access_token_secret => $ENV{TWITTER_ACCESS_SECRET},
    consumer_secret     => $ENV{TWITTER_CONSUMER_SECRET},
    access_token        => $ENV{TWITTER_ACCESS_TOKEN},
    consumer_key        => $ENV{TWITTER_CONSUMER_KEY},
    user_agent          => 'picam_japh',
    traits              => [qw(API::RESTv1_1)],
    ssl                 => 1,
  );

  #$twitter->update($text);
  $twitter->update_with_media(
    {
      status => $text,
      media  => \@image_latest,
    }
  ) and printf "@image_latest tweeted!\nCaption: \033[31;1m%s\033[m\n", $text;
}
#>

#< detach and daemonize
sub daemonize {
  # in most cases, we don't care for any log output
  my $daemon_log = shift // '/dev/null';

  use POSIX 'setsid';
  my $PID = fork();

  exit 0 if $PID;            # parent process
  exit 1 if(!defined($PID)); # out of resources. not likely :) 

  setsid();

  $PID = fork();
  exit 1 if(!defined($PID));

  if($PID) { # parent
    open(my $fh, '>', $pidfile) or confess($!);

    # print the process id to pidfile
    print $fh $$;
    close $fh;

    waitpid($PID, 0);
    #unlink $pidfile;
   }
 }
#>







=pod

=head1 NAME

picam - RPi based surveillance camera that autoposts on twitter

=head1 DESCRIPTION

picam is a Raspberry Pi based surveillance camera daemon that autoposts its
updates on twitter.

=head1 OPTIONS

  -t, --tweet   tweet, with optional status message
  -d, --daemon  detach from terminal and run in background

  -h, --help    show the help, and exit
  -v, --version show version, and exit


=head1 ENVIRONMENT

To upload to twitter, picam needs four different environment variables to be
set. You will get the information needed from the Twitter "create app" page.
The variables that need to be set is:

  TWITTER_ACCESS_TOKEN
  TWITTER_ACCESS_SECRET
  TWITTER_CONSUMER_KEY
  TWITTER_CONSUMER_SECRET

=head1 AUTHOR

  Magnus Woldrich
  CPAN ID: WOLDRICH
  http://github.com/trapd00r
  http://japh.se
  m@japh.se

=cut
