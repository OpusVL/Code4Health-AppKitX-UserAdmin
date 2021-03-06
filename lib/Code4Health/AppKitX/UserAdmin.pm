package Code4Health::AppKitX::UserAdmin;
use Moose::Role;
use CatalystX::InjectComponent;
use File::ShareDir qw/module_dir/;
use namespace::autoclean;

with 'OpusVL::AppKit::RolesFor::Plugin';

our $VERSION = '0.08';

after 'setup_components' => sub {
    my $class = shift;
   
    $class->add_paths(__PACKAGE__);
    
    # .. inject your components here ..
    CatalystX::InjectComponent->inject(
        into      => $class,
        component => 'Code4Health::AppKitX::UserAdmin::Controller::Users',
        as        => 'Controller::Users'
    );
    CatalystX::InjectComponent->inject(
        into      => $class,
        component => 'Code4Health::AppKitX::UserAdmin::Controller::Preferences',
        as        => 'Controller::UserPreferences'
    );
    CatalystX::InjectComponent->inject(
        into      => $class,
        component => 'Code4Health::AppKitX::UserAdmin::Model::Users',
        as        => 'Model::Users'
    );
};

1;

=head1 NAME

Code4Health::AppKitX::UserAdmin - Administration for website users

=head1 DESCRIPTION

This module combines the required components to administrate the users who sign
up through the website.

=head1 METHODS

=head1 BUGS

=head1 AUTHOR

=head1 COPYRIGHT and LICENSE

Copyright (C) 2015 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

