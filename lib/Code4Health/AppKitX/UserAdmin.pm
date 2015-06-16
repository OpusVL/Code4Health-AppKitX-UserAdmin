package Code4Health::AppKitX::UserAdmin;
use Moose::Role;
use CatalystX::InjectComponent;
use File::ShareDir qw/module_dir/;
use namespace::autoclean;

our $VERSION = '0.01';

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

Code4Health::AppKitX::UserAdmin - 

=head1 DESCRIPTION

=head1 METHODS

=head1 BUGS

=head1 AUTHOR

=head1 COPYRIGHT and LICENSE

Copyright (C) 2015 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

