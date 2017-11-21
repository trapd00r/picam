use strict;
use warnings;
use Net::Twitter;
use Getopt::Long;

my     $APP = 'picam_twitter';
my $VERSION = 0.02;


my @latest_image = ("$ENV{HOME}/camera/latest.png");


GetOptions(
  'h|help'   => \&usage,
  'd|daemon' => \&daemonize,
);


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
      media  => \@latest_image,
    }
  );
}

tweet(
  @ARGV ? @ARGV : "this is autoposted"
);
