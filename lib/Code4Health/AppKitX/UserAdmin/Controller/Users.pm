package Code4Health::AppKitX::UserAdmin::Controller::Users;

use Moose;
use Code4Health::AppKitX::UserAdmin::HTML::FormHandler::RegistrationForm;
use Text::CSV;
use namespace::autoclean;
use Data::Munge qw/elem/;

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

sub export_users
  : Local
  : Args(0)
  : AppKitFeature('Users')
{
    my ($self, $c) = @_;
    my $ePrefs = sub {
        my $prefs = shift;
        if ($prefs) {
            my @types = qw/members communities supporters/;
            return map { (elem $_, $prefs) ? 'Yes' : 'No' } @types;
        }
        else {
            return ('No', 'No', 'No');
        }
    };

    my @communities = $c->model('Users')->resultset('Community')->all;
    my $memberships = sub {
        my $person = shift;
        my %memberships = map { $_->community_id => 1 } $person->community_links;

        return map { $memberships{$_->id} ? 'Yes' : 'No' } @communities;
    };

    my @header = ('First Name', 'Surname', 'Email Address',
        'Show Membership',
        'General C4H Emails', 'Community Specific Emails', 'Emails from supporters',
        map {$_->name} @communities
    );
    my @people = $c->model('Users')->resultset('Person')->all;
    my @data = map { [
        $_->first_name, $_->surname, $_->email_address, 
        ($_->show_membership ? 'Yes' : 'No'),
        $ePrefs->($_->email_preferences),
        $memberships->($_)
    ] } @people;
    my $csv = Text::CSV->new ( { binary => 1 } )
        or die "Cannot use CSV: ".Text::CSV->error_diag ();
    my $data = '';
    open my $fh, '>', \$data;
    $csv->print($fh, \@header);
    print $fh "\r\n";
    for (@data)
    {
        $csv->print ($fh, $_);
        print $fh "\r\n";
    }
    close $fh;


    my $content_type = 'text/csv';
    my $filename = 'C4H-user-list.csv';

    $c->forward( $c->view('DownloadFile'), [ { content_type => $content_type, body => $data, header => $filename } ] );
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
        or $c->detach('/not_found');

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

    my $defaults = $self->_object_defaults($user);
    $self->add_prefs_defaults($c, {
        defaults => $defaults,
        object => $user,
    });
    $form->default_values($defaults);

    if($form->submitted_and_valid) {
        $user->update({
            email_address => $form->param_value('email_address'),
            title => $form->param_value('title'),
            first_name => $form->param_value('first_name'),
            surname => $form->param_value('surname'),
        });
        $self->update_prefs_values($c, $user);
        $c->res->redirect($c->req->uri);
        $c->flash->{status_msg} = "User saved";
    }
}

sub _object_defaults {
    my ($self, $object) = @_;

    return {
        email_address => $object->email_address,
        title => $object->title,
        first_name => $object->first_name,
        surname => $object->surname,
    };
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
