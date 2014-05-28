package RebuildRelatedObjects::Callbacks;
use strict;
use MT::Entry;
use MT::Page;

sub _hdlr_cms_post_save {
    my ($cb, $app, $obj, $orig_obj) = @_;

    my $blog_id = $obj->blog_id
        or return;
    my $scope = 'blog:' . $blog_id;
    my $plugin = MT->component('RebuildRelatedObjects');

    my $posted_class = $obj->class
        or return;

    my $setting_name = $posted_class . '_field_basename';

    my $field = $plugin->get_config_value($setting_name, $scope);

    my $rebuild_class = ($field =~ /^page\./) ? 'page' : 'entry';
    $field =~ s/^(page|entry)\.//;

    my $ids = $obj->$field
        or return;

    $ids =~ s/^,|,$//g;
    require MT::WeblogPublisher;
    foreach my $id ( split(/,/, $obj->$field) ) {
        my $object = ($rebuild_class eq 'page') ? MT::Page->load($id) : MT::Entry->load($id);
        my $pub = MT::WeblogPublisher->new;
        my $result = $pub->rebuild_entry(Entry => $object);
    }
}

1;