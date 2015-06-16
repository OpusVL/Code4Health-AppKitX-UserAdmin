package Code4Health::AppKitX::UserAdmin::Controller::Preferences;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::HTML::FormFu' }
with 'OpusVL::AppKit::RolesFor::Controller::GUI';
with 'OpusVL::AppKitX::PreferencesAdmin::Role::Controller';

__PACKAGE__->config
(
    appkit_name                 => 'Users',
    appkit_myclass              => 'Code4Health::AppKitX::UserAdmin',
    appkit_method_group         => 'Users',
    appkit_shared_module        => 'Users',
);

has model => (
    is => 'ro',
    default => 'Users'
);

has resultset => (
    is => 'ro',
    default => 'Person'
);

sub auto : Action {
    my ($self, $c) = @_;
    my $index_url = $c->uri_for($self->action_for('index'));
    $c->stash->{index_url} = $index_url;
    $self->add_breadcrumb($c, { name => 'User Parameters', url => $index_url });
}

sub index
    : Path
    : Args(0)
    : NavigationName('Preferences')
    : AppKitFeature('Users')
{
    my ($self, $c) = @_;

    $self->index_preferences($c);
}

sub add
    : Local
    : Args(0)
    : AppKitFeature('Users')
    : AppKitForm
{
    my ($self, $c) = @_;
    $self->add_preferences($c);
}

1;
