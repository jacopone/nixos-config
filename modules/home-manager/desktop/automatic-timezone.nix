# Automatic timezone — clock follows physical location (shared tech + business).
#
# time.timeZone is intentionally UNSET in hosts/common/base.nix; GNOME's datetime
# plugin -> GeoClue -> systemd-timedated owns /etc/localtime so the clock tracks
# the machine as it travels. That chain needs BOTH gsettings below:
# automatic-timezone is necessary but NOT sufficient — without location.enabled,
# GNOME never requests a GeoClue fix and the zone freezes (2026-06-07: stuck on
# Europe/London for 4 days because location services had been toggled off in the
# GNOME UI). Declared here so the per-user gsettings cannot silently drift off.
{ ... }:

{
  dconf.settings = {
    "org/gnome/system/location" = {
      enabled = true;
    };
    "org/gnome/desktop/datetime" = {
      automatic-timezone = true;
    };
  };
}
