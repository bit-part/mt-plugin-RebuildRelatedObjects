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
    my $posted_id = $obj->id;

    my $setting_name = $posted_class . '_field_basename';

    my $fields = $plugin->get_config_value($setting_name, $scope);
    my $enable_mutual_relation = $plugin->get_config_value('enable_mutual_relation', $scope);

    foreach my $field ( split(/,/, $fields) ) {
        my $rebuild_class = ($field =~ /^page\./) ? 'page' : 'entry';
        $field =~ s/^(page|entry)\.//;

        my $related_field = '';
        if ($field =~ /([^:]+):([^:]+)/) {
            ($field, $related_field) = split(/:/, $field);
        }
        else {
            $related_field = $field;
        }

        # Get the IDs of original object; that is "Original IDs".
        my $orig_ids = $orig_obj->$field;
        $orig_ids =~ s/^,|,$//g;
        my @orig_ids = split(/,/, $orig_ids);

        # Get the IDs of saving object; that is "Saving IDs".
        my $ids = $obj->$field;
        $ids =~ s/^,|,$//g;
        my @ids = split(/,/, $ids);

        # If an ID of the Original IDs isn't included in Saving IDs, push the ID into @disconnect_ids.
        my @disconnect_ids;
        foreach my $id (@orig_ids) {
            unless (grep {$_ eq $id} @ids) {
                push(@disconnect_ids, $id);
            }
        }

        require MT::WeblogPublisher;
        my $pub = MT::WeblogPublisher->new;
        # Relate
        foreach my $id (@ids) {
            my $object = MT->model($rebuild_class)->load($id);
            if ($enable_mutual_relation) {
                my $relation_ids = $object->$related_field;
                unless ($relation_ids) {
                    $object->$related_field($posted_id);
                }
                else {
                    $relation_ids =~ s/^,+|,+$//;
                    my @relation_ids_array = split(/,/, $relation_ids);
                    if (grep {$_ eq $posted_id} @relation_ids_array) {
                        # have got
                    }
                    else {
                        push(@relation_ids_array, $posted_id);
                        $object->$related_field(',' . join(',', @relation_ids_array) . ',');
                    }
                }
                $object->save;
            }
            my $result = $pub->rebuild_entry(Entry => $object);
        }
        # Disconnect
        foreach my $id (@disconnect_ids) {
            my $object = MT->model($rebuild_class)->load($id) or next;
            my $relation_ids = $object->$related_field or next;

            $relation_ids =~ s/^,+|,+$//;
            my @relation_ids_array = split(/,/, $relation_ids);
            @relation_ids_array = grep {$_ ne $posted_id} @relation_ids_array;
            if ($#relation_ids_array > 0) {
                $object->$related_field(',' . join(',', @relation_ids_array) . ',');
            }
            elsif ($#relation_ids_array == 0) {
                $object->$related_field($relation_ids_array[0]);
            }
            else {
                $object->$related_field('');
            }
            $object->save;
            my $result = $pub->rebuild_entry(Entry => $object);
        }
    }
}

sub _hdlr_cms_post_delete {
    my ($cb, $app, $obj) = @_;

    my $blog_id = $obj->blog_id
        or return;
    my $scope = 'blog:' . $blog_id;
    my $plugin = MT->component('RebuildRelatedObjects');

    my $posted_class = $obj->class
        or return;
    my $posted_id = $obj->id;

    my $setting_name = $posted_class . '_field_basename';

    my $fields = $plugin->get_config_value($setting_name, $scope);
    my $enable_mutual_relation = $plugin->get_config_value('enable_mutual_relation', $scope);

    foreach my $field ( split(/,/, $fields) ) {
        my $rebuild_class = ($field =~ /^page\./) ? 'page' : 'entry';
        $field =~ s/^(page|entry)\.//;

        my $related_field = '';
        if ($field =~ /([^:]+):([^:]+)/) {
            ($field, $related_field) = split(/:/, $field);
        }
        else {
            $related_field = $field;
        }

        my $ids = $obj->$field;
        $ids =~ s/^,|,$//g;
        my @ids = split(/,/, $ids);

        require MT::WeblogPublisher;
        my $pub = MT::WeblogPublisher->new;

        # Disconnect
        foreach my $id (@ids) {
            my $object = MT->model($rebuild_class)->load($id)
                or next;
            my $relation_ids = $object->$related_field
                or next;
            $relation_ids =~ s/^,+|,+$//;
            my @relation_ids_array = split(/,/, $relation_ids);
            @relation_ids_array = grep {$_ ne $posted_id} @relation_ids_array;
            if ($#relation_ids_array > 0) {
                $object->$related_field(',' . join(',', @relation_ids_array) . ',');
            }
            elsif ($#relation_ids_array == 0) {
                $object->$related_field($relation_ids_array[0]);
            }
            else {
                $object->$related_field('');
            }
            $object->save;
            my $result = $pub->rebuild_entry(Entry => $object);
        }
    }
}

1;