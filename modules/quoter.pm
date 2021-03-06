package SweetieBot::Module::Quoter;
use base 'SweetieBot::Module';
use warnings;
no warnings 'redefine';
use strict;

use Switch;

my %dbsth;

sub init {
	my ($self, $bot, $message, $args) = @_;

	# Check if module Log is loaded
	if (!$bot->moduleLoaded('log')) {
		# If $message is defined, we're calling it from IRC. Else it's from
		# autoloading. Don't try to say() command there since we're obviously
		# not connected to IRC yet.
		if (defined($message)) {
			$bot->say(
				who     => $message->{who},
				channel => $message->{channel},
				body    => "\x02Warning\x0F: Module 'Log' is not loaded or disabled and this module sort of depends on it. Type !load Log to enable module 'Log' or suffer the consequences.",
				address => $message->{address}
			);

		# Autoload, print to CLI only
		} else {
			print "\nWarning: Module 'Log' is not loaded or disabled and this module sort of depends\n"
			    , "on it. Type !load Log to enable module 'Log' or suffer the consequences.\n";
		}
	}

	# Create needed tables if needed
	$self->createTableIfNotExists('activity', $message);

	# Prepared statements
	$dbsth{searchquote}       = $self->{bot}->{db}->prepare('SELECT type, who, body FROM activity WHERE channel = ? AND body LIKE ? AND lower(who) != lower(?) AND BODY NOT LIKE "!%" AND BODY NOT LIKE "s/%" ORDER BY timestamp DESC LIMIT 1;');
	$dbsth{searchquotedouble} = $self->{bot}->{db}->prepare('SELECT type, who, body FROM activity WHERE channel = ? AND body LIKE ? AND body LIKE ? AND lower(who) != lower(?) AND BODY NOT LIKE "!%" AND BODY NOT LIKE "s/%" ORDER BY timestamp DESC LIMIT 1;');
	$dbsth{searchquoteregex}  = $self->{bot}->{db}->prepare('SELECT type, who, body FROM activity WHERE channel = ? AND body REGEXP ? AND lower(who) != lower(?) AND BODY NOT LIKE "!%" AND BODY NOT LIKE "s/%" ORDER BY timestamp DESC LIMIT 1;');

	# Register hooks
	$self->registerHook('said', \&handleSaidQuoteSearch);
	$self->registerHook('said', \&handleSaidQuoteReplace);
	$self->registerHook('said', \&handleSaidQuoteSwitch);
	$self->registerHook('said', \&handleSaidQuoteRegex);
}

# !q search
# Searches for text and outputs it
sub handleSaidQuoteSearch {
	my ($bot, $message) = @_;

	return unless ($message->{body} =~ /^!q (.+)$/);

	# We may not use this through PRIVMSG, since it might contain Auth login
	# information
	return if ($message->{channel} eq 'msg');

	my $search = $1;
	my ($type, $who, $body);

	# Search latest line, not by our bot and not starting with ! or s/
	$dbsth{searchquote}->execute($message->{channel}, "%$search%", $bot->pocoirc->nick_name);
	$dbsth{searchquote}->bind_columns(\$type, \$who, \$body);
	$dbsth{searchquote}->fetch;

	return unless defined($who);

	switch ($type) {
		case 'said' {
			$bot->say(
				who     => $message->{who},
				channel => $message->{channel},
				body    => "<$who> $body",
				address => $message->{address}
			);
		}
		case 'emote' {
			$bot->say(
				who     => $message->{who},
				channel => $message->{channel},
				body    => "* $who $body",
				address => $message->{address}
			);
		}
	}
}

# !s search replace
# !ss search replace
# Searches for text, replaces it and outputs it
sub handleSaidQuoteReplace {
	my ($bot, $message) = @_;

	return unless ($message->{body} =~ /^!(ss?) (?:\"([^"]+)\"|(.+?)) (?:\"([^"]+)\"|(.+))$/);

	# We may not use this through PRIVMSG, since it might contain Auth login
	# information
	return if ($message->{channel} eq 'msg');

	my $cmd = $1;
	my $search = $2 || $3;
	my $replace = $4 || $5;
	my ($type, $who, $body);

	# Search latest line, not by our bot and not starting with !s
	$dbsth{searchquote}->execute($message->{channel}, "%$search%", $bot->pocoirc->nick_name);
	$dbsth{searchquote}->bind_columns(\$type, \$who, \$body);
	$dbsth{searchquote}->fetch;

	return unless defined($who);

	# !ss is replace all occurences (regex global), !s is replace first
	# occurence. Also escape all meta characters.
	($cmd eq 'ss')
		? $body =~ s/\Q$search/$replace\E/ig
		: $body =~ s/\Q$search/$replace\E/i;

	# Limit to 293 characters to prevent spam
	$body = ((length($body) > 296) ? (substr($body, 0, 293) . '...') : $body);

	switch ($type) {
		case 'said' {
			$bot->say(
				who     => $message->{who},
				channel => $message->{channel},
				body    => "<$who> $body",
				address => $message->{address}
			);
		}
		case 'emote' {
			$bot->say(
				who     => $message->{who},
				channel => $message->{channel},
				body    => "* $who $body",
				address => $message->{address}
			);
		}
	}
}

# !sd text1 text2
# Searches for text1 and text2 in the same string, switches them around and
# outputs it
sub handleSaidQuoteSwitch {
	my ($bot, $message) = @_;

	return unless ($message->{body} =~ /^!sd (?:\"([^"]+)\"|(.+?)) (?:\"([^"]+)\"|(.+))$/);

	# We may not use this through PRIVMSG, since it might contain Auth login
	# information
	return if ($message->{channel} eq 'msg');

	my $word1 = $1 || $2;
	my $word2 = $3 || $4;
	my ($type, $who, $body);

	# Search latest line, not by our bot and not starting with ! or s/
	$dbsth{searchquotedouble}->execute($message->{channel}, "%$word1%", "%$word2%", $bot->pocoirc->nick_name);
	$dbsth{searchquotedouble}->bind_columns(\$type, \$who, \$body);
	$dbsth{searchquotedouble}->fetch;

	return unless defined($who);

	$body =~ s/\Q$word1\E/\x1A/ig;
	$body =~ s/\Q$word2/$word1\E/ig;
	$body =~ s/\x1A/\Q$word2\E/ig;
	$body =~ s/\\(.)/$1/g;

	# Limit to 293 characters to prevent spam
	$body = ((length($body) > 296) ? (substr($body, 0, 293) . '...') : $body);

	switch ($type) {
		case 'said' {
			$bot->say(
				who     => $message->{who},
				channel => $message->{channel},
				body    => "<$who> $body",
				address => $message->{address}
			);
		}
		case 'emote' {
			$bot->say(
				who     => $message->{who},
				channel => $message->{channel},
				body    => "* $who $body",
				address => $message->{address}
			);
		}
	}
}

# s/search/replace/[modifiers]
# Searches for search string, replaces it using regex with optional modifiers
# and outputs it
sub handleSaidQuoteRegex {
	my ($bot, $message) = @_;

	return unless ($message->{body} =~ /^s\/([^\/]+)\/([^\/]+)\/([gi]*)/);

	# We may not use this through PRIVMSG, since it might contain Auth login
	# information
	return if ($message->{channel} eq 'msg');

	my $search = $1;
	my $replace = $2;
	my $modifiers = $3;
	my ($type, $who, $body);

	# Search latest line, not by our bot and not starting with ! or s/
	$dbsth{searchquoteregex}->execute($message->{channel}, $search, $bot->pocoirc->nick_name);
	$dbsth{searchquoteregex}->bind_columns(\$type, \$who, \$body);
	$dbsth{searchquoteregex}->fetch;

	return unless defined($who);

	# Hack for supporting capture group 0, the whole search string
	$replace =~ s/\\(\d+)/sprintf("\\%d",$1+1)/eg;
	eval("\$body =~ s/($search)/$replace/$modifiers;");

	# Limit to 293 characters to prevent spam
	$body = ((length($body) > 296) ? (substr($body, 0, 293) . '...') : $body);

	switch ($type) {
		case 'said' {
			$bot->say(
				who     => $message->{who},
				channel => $message->{channel},
				body    => "<$who> $body",
				address => $message->{address}
			);
		}
		case 'emote' {
			$bot->say(
				who     => $message->{who},
				channel => $message->{channel},
				body    => "* $who $body",
				address => $message->{address}
			);
		}
	}
}

1;
