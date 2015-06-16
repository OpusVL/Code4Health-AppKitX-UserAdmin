package Code4Health::AppKitX::UserAdmin::Controller::Users;

use Moose;
use Code4Health::AppKitX::UserAdmin::HTML::FormHandler::RegistrationForm;
use namespace::autoclean;
BEGIN { extends 'Catalyst::Controller::HTML::FormFu'; };
with 'OpusVL::AppKit::RolesFor::Controller::GUI';

__PACKAGE__->config
(
    appkit_name                 => 'Users',
    appkit_myclass              => 'Code4Health::AppKitX::UserAdmin',
    appkit_method_group         => 'Users',
    appkit_shared_module        => 'Users',
);

has 'registration_form' => (
    is => 'ro',
    isa => 'Object',
    builder => '_build_registration_form'
);

has 'prf_model' => (
    is => 'ro',
    default => 'Users',
);

has 'prf_owner' => (
    is => 'ro',
    default => 'Person'
);

with 'OpusVL::AppKitX::PreferencesAdmin::Role::ObjectPreferences';

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

sub auto : Action {
    my ($self, $c) = @_;
    my $index_url = $c->uri_for($self->action_for('list'));
    $c->stash->{index_url} = $index_url;
    $self->add_breadcrumb($c, { name => 'Users', url => $index_url });
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
    : AppKitForm
{
    my ($self, $c) = @_;

    my $form = $c->stash->{form};
    my $user = $c->stash->{user};

    $self->add_final_crumb($c, $user->username);

    $self->construct_global_data_form($c, { object => $user });
    $form->process;

    my $defaults = $self->add_prefs_defaults($c, { 
        defaults => {},
        object => $user,
    }); 
    $form->default_values($defaults);
    
    if($form->submitted_and_valid) {
        $self->update_prefs_values($c, $user);
        $c->res->redirect($c->req->uri);
        $c->flash->{status_msg} = "User saved";
    }
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
