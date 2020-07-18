package WWW::CPANTS::Role::Logger;

use Mojo::Base -role, -signatures;

sub log ($self, $level, $message) {
    WWW::CPANTS->instance->logger->log($level => $message);
}

1;
