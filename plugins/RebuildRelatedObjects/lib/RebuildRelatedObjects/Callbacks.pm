package RebuildRelatedObjects::Callbacks;
use strict;
use MT::Entry;
use MT::Page;

use MT::Log;
use Data::Dumper;
use File::Basename;
sub doLog {
    my ($msg, $code) = @_;
    return unless defined($msg);
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
    $year += 1900;
    $mon += 1;
    # my $now = "$year年$mon月$mday日($youbi[$wday]) $hour時$min分$sec秒\n";
    my $now = "$hour:$min:$sec";
    my $log = MT::Log->new;
    $log->message("[$now] $msg");
    $log->metadata($code);
    $log->save or die $log->errstr;
}
# doLog(basename(FILE).':'.LINE, Dumper($can_access_blogs));



sub _hdlr_cms_post_save {
    my ($cb, $app, $obj, $orig_obj) = @_;

    my $blog_id = $obj->blog_id
        or return;
    my $scope = 'blog:' . $blog_id;
    my $plugin = MT->component('RebuildRelatedObjects');

    my $class = $obj->class
        or return;

    my $setting_name = $class . '_field_basename';

    my $field = $plugin->get_config_value($setting_name, $scope);

    my $ids = $obj->$field
        or return;

    $ids =~ s/^,|,$//g;
    require MT::WeblogPublisher;
    foreach my $id ( split(/,/, $obj->$field) ) {
        my $object = ($class eq 'entry') ? MT::Entry->load($id) : MT::Page->load($id);
        my $pub = MT::WeblogPublisher->new;
        my $result = $pub->rebuild_entry(Entry => $object);
    }
}

1;