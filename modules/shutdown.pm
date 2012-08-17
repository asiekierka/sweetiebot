package SweetieBot::Module::Shutdown;
use base 'SweetieBot::Module';
use warnings;
no warnings 'redefine';
use strict;
use File::Slurp;

sub init {
	my ($self, $bot, $message, $args) = @_;

	# Register hooks
        $self->registerHook('said', \&shutdowneverything);

}

sub shutdowneverything {
        my ($bot, $message) = @_;
	my $shut = read_file('/home/ola/sweetiebot/modules/shutdown.txt');
        return unless 
($message->{body}=~/^(?:!shutdown|shutdown?)$/i);


   $bot->say(
                                who     => $message->{who},
                                channel => $message->{channel},
                                body    => $shut,
                                address => $message->{address}
                        );
}

1;
