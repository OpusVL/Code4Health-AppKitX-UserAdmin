package Code4Health::AppKitX::UserAdmin::Controller::Users;

use Moose;
use Code4Health::AppKitX::UserAdmin::HTML::FormHandler::RegistrationForm;
use namespace::autoclean;
BEGIN { extends 'Catalyst::Controller'; };
with 'OpusVL::AppKit::RolesFor::Controller::GUI';

__PACKAGE__->config
(
    appkit_name                 => 'Users',
    appkit_myclass              => __PACKAGE__,
    appkit_method_group         => 'Users',
    appkit_shared_module        => 'Users',
);

has 'registration_form' => (
    is => 'ro',
    isa => 'Object',
    builder => '_build_registration_form'
);

sub _build_registration_form {
    my $form = Code4Health::AppKitX::UserAdmin::HTML::FormHandler::RegistrationForm->new(
        name => "registration_form",
        field_list => [
            submit => {
                type => 'Submit',
                value => 'Register',
            }
        ]
    );

    return $form;
}

sub list
    : Local
    : Args(0)
    : NavigationName('List Users')
    : AppKitFeature('Users')
{
    my ($self, $c) = @_;

    my $users = [$c->model('Users')->resultset('Person')->all];

    $c->stash->{users} = $users;
}

sub user
    : Chained('/')
    : PathPart('user')
    : CaptureArgs(1)
    : AppKitFeature('Users')
{
    my ($self, $c, $user_id) = @_;

    my $user = $c->model('Users::Person')->find($user_id)
        or $c->detach('/404');

    $c->stash->{user} = $user;
}

sub edit
    : Chained('user')
    : PathPart('edit')
    : AppKitFeature('Users')
{
}

1;
__END__
sub register
    : Public
    : Path('/register')
    : Args(0)
{
    my ($self, $c) = @_;

    my $form = $self->registration_form;

    if ($form->process(ctx => $c, params => scalar $c->req->parameters)) {
        $c->model('Users')->resultset('Person')->add_user({
            %{$form->value},
            full_name => $form->value->{first_name} . " " . $form->value->{surname}
        });
    }

    $c->stash(
        render_form => $form->render
    );

    $c->detach(qw/Controller::Root default/);
}

=head1 NAME

Code4Health::AppKitX::UserAdmin::Controller:Users - 

=head1 DESCRIPTION

=head1 METHODS

=head1 BUGS

=head1 AUTHOR

=head1 COPYRIGHT and LICENSE

Copyright (C) 2015 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;
