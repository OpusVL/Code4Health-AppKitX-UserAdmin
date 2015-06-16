package Code4Health::AppKitX::UserAdmin::Model::Users;

use Moose;

BEGIN {
    extends 'Catalyst::Model::DBIC::Schema';
}

__PACKAGE__->config(
    schema_class => 'Code4Health::DB::Schema',
    traits => 'SchemaProxy',
);

1;

